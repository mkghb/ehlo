﻿$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Start-ManagedFolderAssistant -Identity 
Set-OrganizationConfig –AutoExpandingArchive