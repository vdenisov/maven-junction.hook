# post-install-maven.ps1
# Runs after every `choco install maven` or `choco upgrade maven`.
# Creates (or retargets) C:\tools\maven -> the newly installed Maven directory.

$ErrorActionPreference = 'Stop'

$junctionPath = 'C:\tools\maven'

# The Maven Chocolatey package unpacks into:
#   $env:ChocolateyInstall\lib\maven\apache-maven-<version>
# $env:chocolateyPackageVersion is provided by Chocolatey to all hook scripts.
$mavenVersion  = $env:chocolateyPackageVersion
$mavenLibDir   = Join-Path $env:ChocolateyInstall "lib\maven"
$mavenTarget   = Join-Path $mavenLibDir "apache-maven-$mavenVersion"

Write-Host "maven-junction.hook: Maven $mavenVersion installed."
Write-Host "  Target : $mavenTarget"
Write-Host "  Junction: $junctionPath"

# Verify the target actually exists before touching the junction.
if (-not (Test-Path $mavenTarget)) {
    # Fallback: find the first apache-maven-* subdirectory in the lib folder.
    $candidates = Get-ChildItem -Path $mavenLibDir -Directory -Filter 'apache-maven-*' -ErrorAction SilentlyContinue |
                  Sort-Object Name -Descending
    if ($candidates) {
        $mavenTarget = $candidates[0].FullName
        Write-Host "  (version dir not found by name; using $mavenTarget)"
    } else {
        Write-Warning "maven-junction.hook: Cannot locate Maven install directory under $mavenLibDir. Junction not updated."
        return
    }
}

# Ensure C:\tools exists.
if (-not (Test-Path 'C:\tools')) {
    New-Item -ItemType Directory -Path 'C:\tools' | Out-Null
}

# Remove any existing junction or directory at the path.
if (Test-Path $junctionPath) {
    # Use cmd /c rmdir so we remove the junction leaf without touching its contents.
    cmd /c "rmdir `"$junctionPath`"" 2>&1 | Out-Null
}

# Create the new junction.
cmd /c "mklink /J `"$junctionPath`" `"$mavenTarget`"" | Out-Null

if (Test-Path $junctionPath) {
    Write-Host "maven-junction.hook: Junction created successfully."
    Write-Host "  $junctionPath -> $mavenTarget"
} else {
    Write-Warning "maven-junction.hook: Junction creation failed. You may need to run as Administrator."
}
