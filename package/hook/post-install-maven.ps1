# post-install-maven.ps1
# Runs after every `choco install maven` or `choco upgrade maven`.
# Creates (or retargets) the Maven junction -> the newly installed Maven directory.

param(
    # Chocolatey provides chocolateyPackageVersion to hook scripts; chocolateyInstall.ps1 passes ''
    # to use the newest installed Maven directory.
    [string]$MavenVersion = $env:chocolateyPackageVersion
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'junction-path.ps1')
$junctionPath = Get-MavenJunctionPath

# The Maven Chocolatey package unpacks into:
#   $env:ChocolateyInstall\lib\maven\apache-maven-<version>
$mavenLibDir = Join-Path $env:ChocolateyInstall "lib\maven"
$mavenTarget = if ($MavenVersion) { Join-Path $mavenLibDir "apache-maven-$MavenVersion" }

if ($MavenVersion) {
    Write-Host "maven-junction.hook: Maven $MavenVersion installed."
}

# Package fix versions (e.g. 3.9.9.20260101) don't match the directory name.
if (-not $mavenTarget -or -not (Test-Path $mavenTarget)) {
    # Sort by version, not name: apache-maven-3.9.10 is newer than apache-maven-3.9.9.
    $candidates = Get-ChildItem -Path $mavenLibDir -Directory -Filter 'apache-maven-*' -ErrorAction SilentlyContinue |
                  Sort-Object { ($_.Name -replace '^apache-maven-' -replace '-.*$') -as [version] }, Name -Descending
    if ($candidates) {
        $mavenTarget = @($candidates)[0].FullName
    } else {
        Write-Warning "maven-junction.hook: Cannot locate Maven install directory under $mavenLibDir. Junction not updated."
        return
    }
}

Write-Host "  Target : $mavenTarget"
Write-Host "  Junction: $junctionPath"

# Ensure the junction's parent directory exists.
$junctionParent = Split-Path $junctionPath -Parent
if (-not (Test-Path $junctionParent)) {
    New-Item -ItemType Directory -Path $junctionParent -Force | Out-Null
}

# Remove any existing junction at the path, but never a real directory or file.
$existing = Get-Item $junctionPath -Force -ErrorAction SilentlyContinue
if ($existing) {
    if ($existing.LinkType -ne 'Junction') {
        Write-Warning "maven-junction.hook: $junctionPath exists and is not a junction. Junction not updated."
        return
    }
    # Use cmd /c rmdir so we remove the junction leaf without touching its contents.
    cmd /c "rmdir `"$junctionPath`"" 2>&1 | Out-Null
}

# Create the new junction.
cmd /c "mklink /J `"$junctionPath`" `"$mavenTarget`"" | Out-Null

if ((Get-Item $junctionPath -Force -ErrorAction SilentlyContinue).LinkType -eq 'Junction') {
    Write-Host "maven-junction.hook: Junction created successfully."
    Write-Host "  $junctionPath -> $mavenTarget"
} else {
    Write-Warning "maven-junction.hook: Junction creation failed. You may need to run as Administrator."
}
