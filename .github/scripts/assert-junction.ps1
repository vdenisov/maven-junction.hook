# Asserts that $Path is a junction to an apache-maven-* directory and that mvn works through it.
# Returns the junction target.

param(
    [Parameter(Mandatory)][string]$Path
)

$ErrorActionPreference = 'Stop'

$junction = Get-Item $Path -Force
if ($junction.LinkType -ne 'Junction') {
    throw "$Path is not a junction (LinkType: '$($junction.LinkType)')"
}
$target = @($junction.Target)[0]
Write-Host "$Path -> $target"
if ((Split-Path $target -Leaf) -notlike 'apache-maven-*') {
    throw "Unexpected junction target: $target"
}

& (Join-Path $Path 'bin\mvn.cmd') -v | Out-Host
if ($LASTEXITCODE -ne 0) { throw "mvn -v through the junction failed ($LASTEXITCODE)" }

$target
