$list = Import-Csv "C:\Users\ladmin\Desktop\O365\ExportData.csv"
 
foreach($entry in $list) {
 
$User = $entry.User
 
Get-Mailbox -id $User |Enable-Mailbox -Archive
 
}