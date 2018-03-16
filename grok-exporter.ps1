Add-Type -Assembly System.IO.Compression.FileSystem
Set-Location $PSScriptRoot
$DebugPreference = 'Continue'

$Params = @{
  Source = 'LOCAL';
  Algorithm = 'SHA256';
  LocalZip = @{};
  FileName = @{};
  LocalFile = @{};
  URL = @{};
  ZipHash = @{};
  FileHash = @{};
  ProductCode = @{};
  Object = @{};
}
$Package     = 'grok_exporter'
$feed     = 'https://api.github.com/repos/fstab/grok_exporter/releases'

if($Params['Source'] -eq 'Local'){
  $OutputPath = 'output'
  $FilePath = 'file:///${launch_path}\..\binaries'
} else {
  $OutputPath = 'temp'
}

$FeedFilter = @{
  Platform = 'windows';
  }

Try{ 
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $Results = $(Invoke-RestMethod -Uri $feed -ErrorAction Stop) 
}
Catch [System.Exception]{ 
  $WebReqErr = $error[0] | Select-Object * | Format-List -Force 
  Write-Error "An error occurred while attempting to connect to the requested site.  The error was $WebReqErr.Exception" 
}

$FilteredResults = $Results[0].assets | `
 Where-Object {$_.name -like "*$($FeedFilter['Platform'])*"}


$Params['Object']['x86'] = $($FilteredResults | `
  Where-Object {$_.name -like '*amd64*'})

$Params['Object']['x64'] = $($FilteredResults | `
  Where-Object {$_.name -like '*amd64*'})

$Version = $Results[0].tag_name.TrimStart('v')
$ReleaseNotes = $Results[0].body

Write-Output `
  $Package `
  "Release Version: $Version" `
  "Release Notes: $ReleaseNotes"

New-Item `
  -ItemType Directory `
  -Path `
    "$PSScriptRoot\$OutputPath\binaries", `
    "$PSScriptRoot\output\tools\" `
  -ErrorAction SilentlyContinue | Out-Null


foreach ($OS in 'x86','x64') {
  $Params['URL'][$OS] = $Params['Object'][$OS].browser_download_url
  $Params['FileName'][$OS] = $Params['Object'][$OS].name
  $Params['LocalZip'][$OS] = "$PSScriptRoot\$OutputPath\binaries\$($Params['FileName'][$OS])"

  Invoke-WebRequest `
   -Uri $Params['URL'][$OS] `
   -OutFile $Params['LocalZip'][$OS]
  Write-Output "Downloaded $OS from $($Params['URL'][$OS])"

  $Params['ZipHash'][$OS] = Get-FileHash `
    -Path $Params['LocalZip'][$OS] `
    -Algorithm $Params['Algorithm']

  if($Params['Source'] -ne 'Local'){
    $FilePath = ($Params['URL'][$OS] | Split-Path -Parent)
  }
}

$(Get-Content -Path "$PSScriptRoot\templates\$Package.nuspec") `
  -replace '##VERSION##', $Version `
  -replace '##RELEASENOTES##', $ReleaseNotes | `
  Out-File "$PSScriptRoot\output\$Package.nuspec"
Write-Output "Created output\$Package.nuspec"

$(Get-Content -Path "$PSScriptRoot\templates\chocolateyBeforeModify.ps1") `
  -replace '##PACKAGENAME##', $Package | `
  Out-File "$PSScriptRoot\output\tools\chocolateyBeforeModify.ps1"
Write-Output 'Created output\tools\chocolateyBeforeModify.ps1'



$(Get-Content -Path "$PSScriptRoot\templates\chocolateyInstall.ps1") `
  -replace '##PACKAGENAME##', $Package `
  -replace '##FILEPATH##', $FilePath `
  -replace '##FILEx86##', $Params['FileName']['x86'] `
  -replace '##FILEx64##', $Params['FileName']['x64'] `
  -replace '##SHA256x86##', $Params['ZipHash']['x86'].Hash `
  -replace '##SHA256x64##', $Params['ZipHash']['x64'].Hash | `
  Out-File "$PSScriptRoot\output\tools\chocolateyInstall.ps1"
Write-Output 'Created output\tools\chocolateyInstall.ps1'


$(Get-Content -Path "$PSScriptRoot\templates\chocolateyUninstall.ps1") `
  -replace '##PACKAGENAME##', $Package | `
  Out-File "$PSScriptRoot\output\tools\chocolateyUninstall.ps1"
Write-Output 'Created output\tools\chocolateyUninstall.ps1'

Set-Item -Path ENV:NUPKG -Value "$Package.$Version.nupkg"