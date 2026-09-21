# maven-junction.hook

A [Chocolatey extension hook](https://docs.chocolatey.org/en-us/features/hook/) package that keeps a stable directory junction at `C:\tools\maven` pointing to the Maven installation Chocolatey currently manages.

After every `choco install maven` or `choco upgrade maven`, the junction moves to the new `apache-maven-<version>` directory. Tools configured with `C:\tools\maven` as their Maven home, such as IntelliJ IDEA, `M2_HOME`, or `PATH`, keep working across upgrades without any changes. `choco uninstall maven` removes the junction.

## How it works

Chocolatey copies the package's `hook\` folder to `%ChocolateyInstall%\hooks\maven-junction\` and runs the scripts there based on their file names:

| Script | Runs after |
| --- | --- |
| `post-install-maven.ps1` | `choco install maven` / `choco upgrade maven` |
| `post-uninstall-maven.ps1` | `choco uninstall maven` |

The install hook targets `%ChocolateyInstall%\lib\maven\apache-maven-<version>`. If that directory doesn't exist, it uses the newest `apache-maven-*` directory it finds there instead.

## Build

Requires Chocolatey.

```powershell
.\build.ps1                  # version from the nuspec
.\build.ps1 -Version 1.0.1   # override the version
```

The package is written to `dist\`.

## Install

From an elevated shell:

```powershell
choco install maven-junction.hook --source .\dist
```

To create the junction for a Maven version that is already installed, reinstall Maven once:

```powershell
choco install maven --force
```

## Layout

```
package/
  maven-junction.hook.nuspec
  hook/
    post-install-maven.ps1
    post-uninstall-maven.ps1
build.ps1
```
