# chocolatey-grok-exporter
[![Latest version released](https://img.shields.io/chocolatey/v/grok_exporter.svg)](https://chocolatey.org/packages/grok_exporter)
[![Package downloads count](https://img.shields.io/chocolatey/dt/grok_exporter.svg)](https://chocolatey.org/packages/grok_exporter)
[![Build status](https://ci.appveyor.com/api/projects/status/md5xg3pwjlumn87y?svg=true)](https://ci.appveyor.com/project/TechIsCool/chocolatey-grok_exporter)

Chocolatey package for [grok_exporter](https://github.com/repos/fstab/grok_exporter/).

This package installs the Grok Exporter Go package and registers as Service for the package.

*NOTE*: This does not start grok_exporter on install. Please start it with `Start-Service grok_exporter`

This Package is a template that will automatically be upgraded when a new verison is release.

Please make sure when passing through the install parameter you use

```
-params "'-c C:\\Path\\To\\Config'"
```


### Used Tech Stack
[AppVeyor](https://ci.appveyor.com/project/TechIsCool/chocolatey-grok-exporter) -
Builds the Nuget Package

[Chocolatey](https://chocolatey.org/packages/grok-exporter) -
Hosts the Nuget Package

[GitHub](https://github.com/TechIsCool/chocolatey-grok-exporter) -
Provided Version Control

[Zapier](https://zapier.com) - 
Checks API every 15 minutes and triggers automtic builds.

