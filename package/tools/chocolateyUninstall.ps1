# chocolateyUninstall.ps1
# Removes the junction location saved by chocolateyInstall.ps1.

$ErrorActionPreference = 'Stop'

if ([Environment]::GetEnvironmentVariable('MAVEN_JUNCTION_PATH', 'Machine')) {
    Uninstall-ChocolateyEnvironmentVariable -VariableName 'MAVEN_JUNCTION_PATH' -VariableType Machine
    Write-Host 'maven-junction.hook: Removed MAVEN_JUNCTION_PATH.'
}
