# post-uninstall-maven.ps1
# Runs after `choco uninstall maven`.
# Removes the junction so it doesn't point at a now-missing directory.

$ErrorActionPreference = 'Stop'

# Same location lookup as post-install-maven.ps1.
$junctionPath = @(
    $env:MAVEN_JUNCTION_PATH
    [Environment]::GetEnvironmentVariable('MAVEN_JUNCTION_PATH', 'Machine')
    [Environment]::GetEnvironmentVariable('MAVEN_JUNCTION_PATH', 'User')
) | Where-Object { $_ } | Select-Object -First 1
if (-not $junctionPath) {
    $toolsLocation = if (Get-Command Get-ToolsLocation -ErrorAction SilentlyContinue) { Get-ToolsLocation } else { 'C:\tools' }
    $junctionPath = Join-Path $toolsLocation 'maven'
}

$existing = Get-Item $junctionPath -Force -ErrorAction SilentlyContinue
if ($existing -and $existing.LinkType -ne 'Junction') {
    Write-Warning "maven-junction.hook: $junctionPath is not a junction, leaving it in place."
} elseif ($existing) {
    cmd /c "rmdir `"$junctionPath`"" 2>&1 | Out-Null
    Write-Host "maven-junction.hook: Junction $junctionPath removed."
} else {
    Write-Host "maven-junction.hook: Junction $junctionPath not present, nothing to remove."
}
