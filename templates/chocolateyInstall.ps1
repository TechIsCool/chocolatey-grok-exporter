$package = '##PACKAGENAME##'

$launch_path = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$choco_params = @{
  PackageName    = "$package"
  UnzipLocation  = "C:\ProgramData\${package}"
  url           = "##FILEPATH##/##FILEx86##"
  url64         = "##FILEPATH##/##FILEx64##"
  checksum       = '##SHA256x86##'
  checksumType   = 'sha256'
  checksum64     = '##SHA256x64##'
  checksumType64 = 'sha256'
  ValidExitCodes = @(0)
}

Install-ChocolateyZipPackage @choco_params

&nssm install "$package" "C:\ProgramData\${package}\${package}.exe" "$($env:chocolateyPackageParameters)"
&nssm set "$package" Start SERVICE_AUTO_START