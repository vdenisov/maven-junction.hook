# maven-junction.hook

A [Chocolatey extension hook](https://docs.chocolatey.org/en-us/features/hook/) package that keeps a stable directory junction (`C:\tools\maven` by default) pointing to the Maven installation Chocolatey currently manages.

After every `choco install maven` or `choco upgrade maven`, the junction moves to the new `apache-maven-<version>` directory. Tools configured with the junction as their Maven home, such as IntelliJ IDEA, `M2_HOME`, or `PATH`, keep working across upgrades without any changes. `choco uninstall maven` removes the junction.

## How it works

Chocolatey copies the package's `hook\` folder to `%ChocolateyInstall%\hooks\maven-junction\` and runs the scripts there based on their file names:

| Script | Runs after |
| --- | --- |
| `post-install-maven.ps1` | `choco install maven` / `choco upgrade maven` |
| `post-uninstall-maven.ps1` | `choco uninstall maven` |

The install hook targets `%ChocolateyInstall%\lib\maven\apache-maven-<version>`. If that directory doesn't exist, it uses the newest `apache-maven-*` directory it finds there instead.

Installing the hook package also creates the junction right away if Maven is already installed.

## Junction location

The hooks use the first of these that is set:

1. The `MAVEN_JUNCTION_PATH` environment variable (process, then machine, then user scope).
2. `<Chocolatey tools location>\maven`, which is `C:\tools\maven` unless the `ChocolateyToolsLocation` environment variable points somewhere else.

The easiest way to set it is with a package parameter at install time. This saves the value as a machine-level `MAVEN_JUNCTION_PATH`:

```powershell
choco install maven-junction.hook --params "/JunctionPath:'D:\sdk\maven'"
```

Upgrading the hook package without the parameter keeps the saved location. Uninstalling it removes the variable.

Changing the location on a reinstall or upgrade of the hook package moves the junction right away: the junction at the old location is removed and a new one is created. If a real directory or file (not a junction) already exists at the location, the hooks leave it alone and print a warning.

## Build

Requires Chocolatey.

```powershell
.\build.ps1                  # version from the nuspec
.\build.ps1 -Version 1.0.1   # override the version
```

The package is written to `dist\`.

## Releases

CI builds the package and tests it on every push, once with the default junction location and once with a custom one passed as `/JunctionPath`. On a clean Windows runner it installs an older Maven and then the hook, and checks that the junction was created. It then upgrades Maven and checks that the junction follows, moves the junction with a new `/JunctionPath`, and uninstalls Maven and the hook, checking that the junction and the saved location are removed.

To release, push a version tag. The package version comes from the tag, and the `.nupkg` is attached to a GitHub Release:

```powershell
git tag v1.0.1
git push origin v1.0.1
```

## Install

Requires Chocolatey CLI 1.2.0 or later.

Download the `.nupkg` from [Releases](https://github.com/vdenisov/maven-junction.hook/releases) (or build it), then from an elevated shell in its folder:

```powershell
choco install maven-junction.hook --source .
```

## Layout

```
.github/
  scripts/assert-junction.ps1
  workflows/build.yml
package/
  maven-junction.hook.nuspec
  hook/
    junction-path.ps1
    post-install-maven.ps1
    post-uninstall-maven.ps1
  tools/
    chocolateyInstall.ps1     # saves /JunctionPath as MAVEN_JUNCTION_PATH
    chocolateyUninstall.ps1   # removes it
build.ps1
```

## License

[MIT](LICENSE)
