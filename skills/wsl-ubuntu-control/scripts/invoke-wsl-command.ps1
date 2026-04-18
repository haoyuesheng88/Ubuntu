[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Command,

    [string]$Distro = 'Ubuntu',

    [string]$LinuxWorkingDirectory,

    [string]$WindowsWorkingDirectory
)

$ErrorActionPreference = 'Stop'

function Get-CleanText {
    param([string]$Value)
    return ($Value -replace [char]0, '').TrimEnd()
}

function Escape-BashSingleQuoted {
    param([string]$Value)
    return $Value.Replace("'", ("'" + '"' + "'" + '"' + "'"))
}

$distroListing = Get-CleanText ((& wsl.exe -l -v 2>&1) | Out-String)
if ($LASTEXITCODE -ne 0) {
    throw "Failed to query WSL distros.`n$distroListing"
}

if ($distroListing -notmatch "(?m)^\*?\s*$([regex]::Escape($Distro))\s+") {
    throw "WSL distro '$Distro' was not found.`nAvailable distros:`n$distroListing"
}

$resolvedLinuxDirectory = $LinuxWorkingDirectory

if (-not $resolvedLinuxDirectory -and $WindowsWorkingDirectory) {
    $absoluteWindowsPath = [System.IO.Path]::GetFullPath($WindowsWorkingDirectory)
    $resolvedLinuxDirectory = Get-CleanText ((& wsl.exe -d $Distro wslpath -a $absoluteWindowsPath 2>&1) | Out-String)
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to convert Windows path '$absoluteWindowsPath' into a WSL path.`n$resolvedLinuxDirectory"
    }
}

$bashScript = $Command
if ($resolvedLinuxDirectory) {
    $escapedDirectory = Escape-BashSingleQuoted $resolvedLinuxDirectory
    $bashScript = "cd '$escapedDirectory' && $Command"
}

& wsl.exe -d $Distro bash -lc $bashScript
exit $LASTEXITCODE
