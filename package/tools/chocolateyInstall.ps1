# chocolateyInstall.ps1
# Hooks run later, during `choco install maven`, when this package's parameters
# are no longer available. So /JunctionPath is saved as a machine environment
# variable, which the hooks read. Without the parameter an existing setting is
# kept, so upgrades don't reset it.

$ErrorActionPreference = 'Stop'

$pp = Get-PackageParameters

if ($pp['JunctionPath']) {
    $junctionPath = $pp['JunctionPath']
    if (-not [IO.Path]::IsPathRooted($junctionPath)) {
        throw "maven-junction.hook: /JunctionPath must be an absolute path, got '$junctionPath'."
    }
    Install-ChocolateyEnvironmentVariable -VariableName 'MAVEN_JUNCTION_PATH' -VariableValue $junctionPath -VariableType Machine
    Write-Host "maven-junction.hook: Junction location set to $junctionPath."
}

Write-Host 'maven-junction.hook: The junction is updated on the next `choco install/upgrade maven`.'
