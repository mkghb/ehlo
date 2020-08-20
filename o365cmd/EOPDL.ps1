#Connect to EOL
Install-Module -Name AzureAD
Set-ExecutionPolicy RemoteSigned
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

#Shared Mailbox
Get-Mailbox -ResultSize unlimited -Filter {(RecipientTypeDetails -eq 'SharedMailbox')}
Get-Mailbox -RecipientTypeDetails shared
Get-Mailbox -ResultSize unlimited -Filter {(RecipientTypeDetails -eq 'SharedMailbox')} | Select-Object -Property Name, ArchiveStatus, EffectivePublicFolderMailbox
Get-Mailbox -InactiveMailboxOnly
Get-Mailbox
Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited | Get-MailboxPermission |Select-Object Identity,User,AccessRights | Where-Object {($_.user -like '*@*')}|Export-Csv Z:\Downloads\NewApp\o365cmd\sharedfolders1.csv -NoTypeInformation 

#MSOL Service
Connect-MsolService -Credential $UserCredential
Get-MsolUser -All -UnlicensedUsersOnly
Get-MsolUser -All | where {$_.isLicensed -eq $true}
Get-MsolAccountSku
(Get-MsolAccountSku | where {$_.AccountSkuId -eq "EXCHANGEENTERPRISE"}).ServiceStatus
(Get-MsolAccountSku | where {$_.AccountSkuId -eq "litwareinc:ENTERPRISEPACK"}).ServiceStatus
Get-MsolAccountSku | where {$_.AccountSkuId -eq "litwareinc:ENTERPRISEPACK"}
Get-Mailbox | Get-MailboxStatistics | Select-Object DisplayName, IsArchiveMailbox, ItemCount, TotalItemSize | Format-Table –autosize
Get-Mailbox | Get-MailboxStatistics | Select-Object DisplayName, IsArchiveMailbox, ItemCount, TotalItemSize | Export-CSV –Path “C:\Logs\ExchangeOnlineUsage.csv”


Get-AzureAdUser | ForEach { $licensed=$False ; For ($i=0; $i -le ($_.AssignedLicenses | Measure).Count ; $i++) { If( [string]::IsNullOrEmpty(  $_.AssignedLicenses[$i].SkuId ) -ne $True) { $licensed=$true } } ; If( $licensed -eq $true) { Write-Host $_.UserPrincipalName} }
     
#Management SnapIN
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Support
Get-PSSnapin -Registered | where ($_.name -like "*exchange*")

#Mail and DL identity
Get-RecipientPermission -Identity manoj@eccouncil.org | Select Trustee, AccessControlType, AccessRights
Add-RecipientPermission -Identity user@example.com -Trustee admin@example.com -AccessRights SendAs
Get-DistributionGroup
Set-DistributionGroup -Identity "EGS SOC Analyst" -GrantSendOnBehalfTo ""



Get-Mailbox | Get-ADPermission | Where-Object {($_.ExtendedRights -like 'Send-As') -and ($_.User -notlike 'NT AUTHORITY\SELF')} | fl Identity,User,ExtendedRights,AccessRights -wrap


   



   Get-DistributionGroup "EGS SOC Analyst" | Add-ADPermission -User "User" -ExtendedRights "Send As"
   Get-DistributionGroupMember -Identity "cyberdefence.engineer@eccouncil.org"
   Get-DistributionGroup -Identity socsupport.fwd@eccouncil.org | Format-List GrantSendOnBehalfTo

@{add="Morgan"}

Set-DistributionGroup -Identity cyberdefence.engineer@eccouncil.org -GrantSendOnBehalfTo Aakash.Kothari@eccouncil.org



  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="Aakash.Kothari@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="norzul.mubin@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="Maral.Rezvan@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="tiankang.tan@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="dillon.bong@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="murshid.ishtiaq@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="thilagarajan.s@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="valarmathi.natarajan@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="azizi@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="aiman.roslan@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="syahmi.rahim@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="ezril.tee@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="nasrullah.azhar@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="yaashan@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="izzuddin.ashyibli@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="abdul.azim@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="andzar.rahimi@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="dennish.azhar@eccouncil.org"}
  Set-DistributionGroup -Identity soc.analyst@eccouncil.org -GrantSendOnBehalfTo @{add="arash@eccouncil.org"}
   

Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee Aakash.Kothari@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee norzul.mubin@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee Maral.Rezvan@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee tiankang.tan@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee dillon.bong@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee murshid.ishtiaq@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee thilagarajan.s@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee Maral.Rezvan@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee valarmathi.natarajan@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee azizi@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee aiman.roslan@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee syahmi.rahim@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee ezril.tee@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee nasrullah.azhar@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee yaashan@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee izzuddin.ashyibli@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee abdul.azim@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee andzar.rahimi@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee dennish.azhar@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity soc.analyst@eccouncil.org -Trustee arash@eccouncil.org -AccessRights SendAs



Set-DistributionGroup -Identity cyberdefence.engineer@eccouncil.org -GrantSendOnBehalfTo @{add="tiankang.tan@eccouncil.org","dillon.bong@eccouncil.org","murshid.ishtiaq@eccouncil.org","thilagarajan.s@eccouncil.org","Maral.Rezvan@eccouncil.org","syahreilhafiz@eccouncil.org","arash@eccouncil.org","amirul.amri@eccouncil.org"}
Add-RecipientPermission -Identity cyberdefence.engineer@eccouncil.org -Trustee tiankang.tan@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.engineer@eccouncil.org -Trustee dillon.bong@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.engineer@eccouncil.org -Trustee murshid.ishtiaq@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.engineer@eccouncil.org -Trustee thilagarajan.s@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.engineer@eccouncil.org -Trustee Maral.Rezvan@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.engineer@eccouncil.org -Trustee syahreilhafiz@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.engineer@eccouncil.org -Trustee arash@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.engineer@eccouncil.org -Trustee amirul.amri@eccouncil.org -AccessRights SendAs


Set-DistributionGroup -Identity cyberdefence.threatintel@eccouncil.org -GrantSendOnBehalfTo @{add="Aakash.Kothari@eccouncil.org","divhyha@eccouncil.org","Maral.Rezvan@eccouncil.org","mohd.azmawee@eccouncil.org","arash@eccouncil.org"}
Add-RecipientPermission -Identity cyberdefence.threatintel@eccouncil.org -Trustee Aakash.Kothari@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.threatintel@eccouncil.org -Trustee divhyha@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.threatintel@eccouncil.org -Trustee Maral.Rezvan@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.threatintel@eccouncil.org -Trustee mohd.azmawee@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.threatintel@eccouncil.org -Trustee arash@eccouncil.org -AccessRights SendAs


Set-DistributionGroup -Identity cyberdefence.reporting@eccouncil.org -GrantSendOnBehalfTo @{add="Aakash.Kothari@eccouncil.org","norzul.mubin@eccouncil.org","Maral.Rezvan@eccouncil.org","valarmathi.natarajan@eccouncil.org","arash@eccouncil.org"}
Add-RecipientPermission -Identity cyberdefence.reporting@eccouncil.org -Trustee Aakash.Kothari@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.reporting@eccouncil.org -Trustee norzul.mubin@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.reporting@eccouncil.org -Trustee Maral.Rezvan@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.reporting@eccouncil.org -Trustee valarmathi.natarajan@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity cyberdefence.reporting@eccouncil.org -Trustee arash@eccouncil.org -AccessRights SendAs



Set-DistributionGroup -Identity socsupport.fwd@eccouncil.org -GrantSendOnBehalfTo @{add="valarmathi.natarajan@eccouncil.org","niroshen.nicholas@eccouncil.org","ili.qistina@eccouncil.org","lai.yeewei@eccouncil.org"}
Add-RecipientPermission -Identity socsupport.fwd@eccouncil.org -Trustee valarmathi.natarajan@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity socsupport.fwd@eccouncil.org -Trustee niroshen.nicholas@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity socsupport.fwd@eccouncil.org -Trustee ili.qistina@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity socsupport.fwd@eccouncil.org -Trustee lai.yeewei@eccouncil.org -AccessRights SendAs
Add-RecipientPermission -Identity socsupport.fwd@eccouncil.org -Trustee lai.yeewei@eccouncil.org -AccessRights SendAs