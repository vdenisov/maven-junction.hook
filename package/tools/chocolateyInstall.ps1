# chocolateyInstall.ps1
# Hooks run later, during `choco install maven`, when this package's parameters
# are no longer available. So /JunctionPath is saved as a machine environment
# variable, which the hooks read. Without the parameter an existing setting is
# kept, so upgrades don't reset it.

$ErrorActionPreference = 'Stop'

$hookDir = Join-Path $env:ChocolateyPackageFolder 'hook'
. (Join-Path $hookDir 'junction-path.ps1')
$oldJunctionPath = Get-MavenJunctionPath

$pp = Get-PackageParameters

if ($pp['JunctionPath']) {
    $junctionPath = $pp['JunctionPath']
    if (-not [IO.Path]::IsPathRooted($junctionPath)) {
        throw "maven-junction.hook: /JunctionPath must be an absolute path, got '$junctionPath'."
    }
    Install-ChocolateyEnvironmentVariable -VariableName 'MAVEN_JUNCTION_PATH' -VariableValue $junctionPath -VariableType Machine
    # The process value takes precedence in Get-MavenJunctionPath and may be stale.
    $env:MAVEN_JUNCTION_PATH = $junctionPath
    Write-Host "maven-junction.hook: Junction location set to $junctionPath."
}

if (-not (Test-Path (Join-Path $env:ChocolateyInstall 'lib\maven'))) {
    Write-Host 'maven-junction.hook: Maven is not installed; the junction is created on the next `choco install maven`.'
    return
}

if ($oldJunctionPath -ne (Get-MavenJunctionPath)) {
    # The uninstall hook removes the junction at the location in the process variable.
    $newJunctionPath = $env:MAVEN_JUNCTION_PATH
    $env:MAVEN_JUNCTION_PATH = $oldJunctionPath
    & (Join-Path $hookDir 'post-uninstall-maven.ps1')
    $env:MAVEN_JUNCTION_PATH = $newJunctionPath
}

& (Join-Path $hookDir 'post-install-maven.ps1') -MavenVersion ''
