[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LinuxPath,

    [Parameter(Mandatory = $true)]
    [string]$Text,

    [string]$Distro = 'Ubuntu',

    [switch]$Append
)

$ErrorActionPreference = 'Stop'

function Escape-BashSingleQuoted {
    param([string]$Value)
    return $Value.Replace("'", ("'" + '"' + "'" + '"' + "'"))
}

$escapedLinuxPath = Escape-BashSingleQuoted $LinuxPath
$redirect = if ($Append) { '>>' } else { '>' }
$temporaryWindowsFile = [System.IO.Path]::GetTempFileName()

try {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($temporaryWindowsFile, $Text, $utf8NoBom)

    $temporaryWindowsFileForWsl = $temporaryWindowsFile.Replace('\', '/')
    $temporaryLinuxFile = (& wsl.exe -d $Distro wslpath -a $temporaryWindowsFileForWsl 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to convert temporary Windows file '$temporaryWindowsFile' into a WSL path.`n$temporaryLinuxFile"
    }

    $escapedTemporaryLinuxFile = Escape-BashSingleQuoted $temporaryLinuxFile
    $bashScript = 'mkdir -p -- "$(dirname -- ''{0}'')" && cat ''{1}'' {2} ''{0}''' -f $escapedLinuxPath, $escapedTemporaryLinuxFile, $redirect

    & wsl.exe -d $Distro bash -lc $bashScript
    exit $LASTEXITCODE
}
finally {
    Remove-Item -LiteralPath $temporaryWindowsFile -ErrorAction SilentlyContinue
}
