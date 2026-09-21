# post-uninstall-maven.ps1
# Runs after `choco uninstall maven`.
# Removes the junction so it doesn't point at a now-missing directory.

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'junction-path.ps1')
$junctionPath = Get-MavenJunctionPath

$existing = Get-Item $junctionPath -Force -ErrorAction SilentlyContinue
if ($existing -and $existing.LinkType -ne 'Junction') {
    Write-Warning "maven-junction.hook: $junctionPath is not a junction, leaving it in place."
} elseif ($existing) {
    cmd /c "rmdir `"$junctionPath`"" 2>&1 | Out-Null
    Write-Host "maven-junction.hook: Junction $junctionPath removed."
} else {
    Write-Host "maven-junction.hook: Junction $junctionPath not present, nothing to remove."
}
