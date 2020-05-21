



Install-Module PowershellGet -Force
Update-Module PowershellGet
Set-ExecutionPolicy RemoteSigned
Install-Module -Name ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement
Update-Module -Name ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement


#connect

$UserCredential = Get-Credential
Connect-ExchangeOnline -UserPrincipalName <UPN> -ShowProgress $true
