$Result=@() 
$mailboxes = Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited
$totalmbx = $mailboxes.Count
$i = 1 
$mailboxes | ForEach-Object {
$i++
$mbx = $_
$mbs = Get-MailboxStatistics -Identity $mbx.UserPrincipalName
 
if ($mbs.LastLogonTime -eq $null){
$lt = "Never Logged In"
}else{
$lt = $mbs.LastLogonTime }
  
Write-Progress -activity "Processing $mbx" -status "$i out of $totalmbx completed"
  
$Result += New-Object PSObject -property @{ 
UserPrincipalName = $mbx.UserPrincipalName
TotalSize = $mbs.TotalItemSize
TotalMessages = $mbs.ItemCount
LastLogonTime = $lt }
}
$Result | Select UserPrincipalName, TotalSize, TotalMessages, LastLogonTime |
Export-CSV "C:\\O365-Mailbox-Statistics.csv" -NoTypeInformation -Encoding UTF8