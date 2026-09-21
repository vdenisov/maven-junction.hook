# post-uninstall-maven.ps1
# Runs after `choco uninstall maven`.
# Removes the junction so it doesn't point at a now-missing directory.

$ErrorActionPreference = 'Stop'

$junctionPath = 'C:\tools\maven'

if (Test-Path $junctionPath) {
    cmd /c "rmdir `"$junctionPath`"" 2>&1 | Out-Null
    Write-Host "maven-junction.hook: Junction $junctionPath removed."
} else {
    Write-Host "maven-junction.hook: Junction $junctionPath not present, nothing to remove."
}
