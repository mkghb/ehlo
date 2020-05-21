Install-Module -Name AzureAD -Scope CurrentUser
Install-Module MSOnline -Scope CurrentUser
Import-Module MSOnline
Get-Command -Noun *MSOL*
Connect-MsolService
Get-MsolSubscription
Get-MsolAccountSku
Get-MsolUser -All -UnlicensedUsersOnly
Set-MsolUserLicense -UserPrincipalName "cbp@iibcouncil.org" -AddLicenses "ECCouncilAbq:ENTERPRISEPACK"
Set-MsolUserLicense -UserPrincipalName "cbp@iibcouncil.org" -AddLicenses "ECCouncilAbq:EMS"
