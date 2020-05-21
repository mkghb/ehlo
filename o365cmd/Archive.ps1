#Enable Archive for users
Get-Mailbox -Filter {ArchiveStatus -Eq "None" -AND RecipientTypeDetails -eq "UserMailbox"} | Enable-Mailbox -Archive

#Atuo Expanding Archive 
#Enable Archive for all users
Set-OrganizationConfig -AutoExpandingArchive

#Enable for Specific users
Enable-Mailbox <user mailbox> -AutoExpandingArchive

#verify if enabled for whole org
Get-OrganizationConfig | FL AutoExpandingArchiveEnabled

#For Specific user
Get-Mailbox <user mailbox> | FL AutoExpandingArchiveEnabled