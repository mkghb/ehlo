﻿Enable MFA:
$UserCredential = Get-Credential
Import-Module MSOnline
Connect-MsolService –Credential $UserCredential
$auth = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$auth.RelyingParty = "*"
$auth.State = "Enabled"
$auth.RememberDevicesNotIssuedBefore = (Get-Date)
Get-MsolUser –All | Foreach{ Set-MsolUser -UserPrincipalName $_.UserPrincipalName -StrongAuthenticationRequirements $auth}

Disable MFA:
Connect-MSolService
$auth=@()
Get-MsolUser –All | Foreach{ Set-MsolUser -UserPrincipalName $_.UserPrincipalName -StrongAuthenticationRequirements $auth}