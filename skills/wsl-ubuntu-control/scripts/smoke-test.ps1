[CmdletBinding()]
param(
    [string]$Distro = 'Ubuntu'
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$targetFile = '/tmp/codex_wsl_ubuntu_control_smoke.txt'
$expected = "woaini`n"

& (Join-Path $scriptRoot 'write-file-in-ubuntu.ps1') -Distro $Distro -LinuxPath $targetFile -Text $expected
if ($LASTEXITCODE -ne 0) {
    throw "Failed to write the smoke-test file in distro '$Distro'."
}

$actual = ((& (Join-Path $scriptRoot 'invoke-wsl-command.ps1') -Distro $Distro -Command "cat '$targetFile'" | Out-String) -replace "`r`n", "`n")
if ($LASTEXITCODE -ne 0) {
    throw "Failed to read the smoke-test file in distro '$Distro'."
}

if ($actual -ne $expected) {
    throw "Smoke test content mismatch. Expected '$expected' but got '$actual'."
}

& (Join-Path $scriptRoot 'invoke-wsl-command.ps1') -Distro $Distro -Command "rm -f '$targetFile'"
if ($LASTEXITCODE -ne 0) {
    throw "Smoke test cleanup failed for '$targetFile'."
}

Write-Host "Smoke test passed for distro '$Distro'."
