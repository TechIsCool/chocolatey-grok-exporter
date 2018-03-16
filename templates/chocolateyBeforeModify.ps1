$package = '##PACKAGENAME##'

if ((Get-Service | Where-Object { $_.Name -eq $package }).length) {
    Get-Service $package | Stop-Service
    &nssm remove $package confirm
}