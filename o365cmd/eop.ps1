Set-ExecutionPolicy RemoteSigned
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell-liveid?DelegatedOrg=<eccouncil.org> -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Get-Mailbox
Get-Mailbox -Identity syed.m@eccouncil.org
Set-Mailbox "syed.m" -Type:Regular
