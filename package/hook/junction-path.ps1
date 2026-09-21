# junction-path.ps1
# Shared by the hooks and chocolateyInstall.ps1. Only defines a function, so it is harmless
# if Chocolatey ever runs it as a script.

# Junction location: MAVEN_JUNCTION_PATH (process, then machine, then user scope),
# falling back to <Chocolatey tools location>\maven, i.e. C:\tools\maven by default.
function Get-MavenJunctionPath {
    $junctionPath = @(
        $env:MAVEN_JUNCTION_PATH
        [Environment]::GetEnvironmentVariable('MAVEN_JUNCTION_PATH', 'Machine')
        [Environment]::GetEnvironmentVariable('MAVEN_JUNCTION_PATH', 'User')
    ) | Where-Object { $_ } | Select-Object -First 1
    if ($junctionPath) {
        return $junctionPath
    }
    $toolsLocation = if (Get-Command Get-ToolsLocation -ErrorAction SilentlyContinue) { Get-ToolsLocation } else { 'C:\tools' }
    Join-Path $toolsLocation 'maven'
}
