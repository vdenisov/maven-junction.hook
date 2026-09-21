# build.ps1
# Packs the Chocolatey package into .\dist.
#   .\build.ps1                  -> version from the nuspec
#   .\build.ps1 -Version 1.0.1   -> overrides the nuspec version

param(
    [string]$Version
)

$ErrorActionPreference = 'Stop'

$nuspec = Join-Path $PSScriptRoot 'package\maven-junction.hook.nuspec'
$outDir = Join-Path $PSScriptRoot 'dist'

New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$chocoArgs = @('pack', $nuspec, '--outputdirectory', $outDir)
if ($Version) {
    $chocoArgs += @('--version', $Version)
}

& choco @chocoArgs
if ($LASTEXITCODE -ne 0) {
    throw "choco pack failed with exit code $LASTEXITCODE"
}
