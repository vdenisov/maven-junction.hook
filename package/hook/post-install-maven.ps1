# post-install-maven.ps1
# Runs after every `choco install maven` or `choco upgrade maven`.
# Creates (or retargets) the Maven junction -> the newly installed Maven directory.

$ErrorActionPreference = 'Stop'

# Junction location: MAVEN_JUNCTION_PATH (process, then machine, then user scope),
# falling back to <Chocolatey tools location>\maven, i.e. C:\tools\maven by default.
$junctionPath = @(
    $env:MAVEN_JUNCTION_PATH
    [Environment]::GetEnvironmentVariable('MAVEN_JUNCTION_PATH', 'Machine')
    [Environment]::GetEnvironmentVariable('MAVEN_JUNCTION_PATH', 'User')
) | Where-Object { $_ } | Select-Object -First 1
if (-not $junctionPath) {
    $toolsLocation = if (Get-Command Get-ToolsLocation -ErrorAction SilentlyContinue) { Get-ToolsLocation } else { 'C:\tools' }
    $junctionPath = Join-Path $toolsLocation 'maven'
}

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
