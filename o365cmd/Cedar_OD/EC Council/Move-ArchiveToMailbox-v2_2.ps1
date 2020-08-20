<#
    .SYNOPSIS
    Move-ArchiveToMailbox.ps1
   
    Pavel Rozenberg
    pavel@u-btech.com
	
    THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
    RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	
    Version 2.0, October 10th, 2017
    
    .DESCRIPTION
    This script will move all the items in the archive mailbox back to their original location in the main mailbox in Exchange Online and Exchange On-Premise.
	The script will move all the known IPM items - custom IPM items were not tested
	
    .LINK
    http://blogs.microsoft.co.il/u-btech/2016/10/04/simply-move-all-your-archive-back-to-the-mailbox/
    
    .NOTES
    *	Requires Microsoft Exchange Subscription.
	*	Requires Exchange Web Services (EWS) version 2.2 (https://www.microsoft.com/en-us/download/details.aspx?id=42951)
	*	Requires an Exchange Online Organization Management account (usually a global admin)
	*	You must create a new Retention Policy without any Archive Tags and assign it to the specified user's mailbox
	*	Look for the log of the processed mailbox in the run directory


    Revision 	History
    ---------------------------------------------------------------------------------------------------
    1.0			Initial release
	1.1			Added support for folders that exceed the 1000 item count and a 'Result' column to the log
	2.0			1)	Fixed the issues with special characters (including different languages) in a folder name
				2)	Added support for moving items which are not listed under any folder in the main mailbox:
					*	The script will move the remaining folders(!) to the path "/Archive"
					*	If that path does not exist, the script will create it for you(!!)
				3)	Added support for Exchange On-Premise
					*	EWS works only using Autodiscover
					*	Only kerberos authentication is supported
	2.1			Fixed issues with connections to Exchange On-Premise
	2.2			Fixed an issue with emails moving to non-IPF folders
	
    .EXAMPLE
    .\Move-ArchiveToMailbox.ps1
	
	Output:
		Enter admin account UPN (Application Impersonation): admin@yourtenant.onmicrosoft.com
		Enter admin account password: *********
		Enter impersonated user UPN: user@domain.com
	
#>

Add-Type -AssemblyName System.Web

#Function that lists all the subfolders of a specified folder
Function List-Folders ($Folder, $View){
	$FolderSearchResults = $exchService.FindFolders($Folder.Id, $View)
	return $FolderSearchResults
}

#Function that retrieves the folder path of the specified folder
Function Get-FolderPath ($Folder, $FolderRange, $StartingPoint, $FolderIds){
	if ($FolderIds -eq $null){
		$Ids = @()
	}
	else {
		$Ids = $FolderIds
	}
	$Parent = ($FolderRange | ? {$_.Id -eq $Folder.ParentFolderId})
	if ($Parent -eq $null){
		$Ids = ,$Folder.Id + $Ids
		$Path = $StartingPoint.Insert(0,$Folder.DisplayName)
		$Result = New-Object PSObject
		$Result | Add-Member -MemberType NoteProperty -Name "FolderIds" -Value $Ids
		$Result | Add-Member -MemberType NoteProperty -Name "Path" -Value $Path
		return $Result
	}
	else {
		$Path = $StartingPoint.Insert(0,"`r`n" + $Folder.DisplayName)
		$Ids = ,$Folder.Id + $Ids
		return Get-FolderPath -Folder $Parent -FolderRange $FolderRange -StartingPoint $Path -FolderIds $Ids
	}
}

function ConvertId($Id,$EwsService,$UPN,$ToFormat,$IsArchive){      
    process{  
        $aiItem = New-Object Microsoft.Exchange.WebServices.Data.AlternateId        
        $aiItem.Mailbox = $impuser
		$aiItem.IsArchive = $IsArchive
		Switch ($ToFormat){
			"EWS" {
					$aiItem.Format = [Microsoft.Exchange.WebServices.Data.IdFormat]::OwaId; 
					$aiItem.UniqueId = [System.Web.HttpUtility]::UrlEncode($Id);
					$convertedId = $EwsService.ConvertId($aiItem, [Microsoft.Exchange.WebServices.Data.IdFormat]::EwsId)}
			"OWA" {
					$aiItem.Format = [Microsoft.Exchange.WebServices.Data.IdFormat]::EwsId; 
					$aiItem.UniqueId = $Id;
					$convertedId = $EwsService.ConvertId($aiItem, [Microsoft.Exchange.WebServices.Data.IdFormat]::OwaId)}
		}
        
        return $convertedId.UniqueId
    }  
}  

#--------------------------------------------------------------------------#
#							Begining of the Script						   #
#--------------------------------------------------------------------------#

#Check for the EWS module
$EwsInstallDir = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Exchange\Web Services\2.2").'Install Directory'

$isRoleAssigned = $true

$log = @()

if ($EwsInstallDir -ne $null){
	#Load EWS module
	$EwsDLL = "Microsoft.Exchange.WebServices.dll"
	$EwsModule = $EwsInstallDir + $EwsDLL
	Import-Module -Name $EwsModule
	
	Write-Host "Choose between Exchange versions:" -fore Cyan
	Write-Host "---------------------------------"
	Write-Host "1)	Exchange Online (Office365)"
	Write-Host "2)	Exchange On-Premise"
	Write-Host
	$exConfig = Read-Host "Select your configuration (Exchange Online is default)"
	Write-Host
	$u = Read-Host "Enter admin account UPN (Application Impersonation)"
	$p = Read-Host "Enter admin account password" -AsSecureString
	$creds = new-object System.Management.Automation.PSCredential -argumentlist $u,$p
	
	Switch ($exConfig){
		"1" {
			$impuser = Read-Host "Enter impersonated user SMTP"
			
			
			#Connect to Exchange Online
			Write-Host
			Write-Host "Connecting to Exchange Online..." -fore Cyan
			$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -AllowRedirection -Authentication basic -Credential $creds
			Import-PSSession $session
		}
		"2" {
			Write-Host
			$exServer = Read-Host "Enter Exchange server FQDN"
			$impuser = Read-Host "Enter impersonated user SMTP"
			
			#Connecting to Exchange On-Premise
			Write-Host
			Write-Host "Connecting to Exchange On-Premise..." -fore Cyan
			$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$exServer/PowerShell -Authentication kerberos
			Import-PSSession $session
		}
		default {
			$impuser = Read-Host "Enter impersonated user SMTP"
			$creds = new-object System.Management.Automation.PSCredential -argumentlist $u,$p
			
			#Connect to Exchange Online
			Write-Host
			Write-Host "Connecting to Exchange Online..." -fore Cyan
			$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -AllowRedirection -Authentication basic -Credential $creds
			Import-PSSession $session
		}
	}
		
	#Credential and mailbox information input
	
	#Check whether the admin account is assigned to ApplicationImpersonation role
	$RoleAssignment = Get-ManagementRoleAssignment -Role ApplicationImpersonation -RoleAssignee $u -AssignmentMethod Direct
	
	if ($RoleAssignment -eq $null){
		$isRoleAssigned = $false
		$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",""
		$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",""
		$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
		$caption = "Warning!"
		$message = "Do you want to assign the ApplicationImpersonation role to the user " + $u + "?"
		$result = $Host.UI.PromptForChoice($caption,$message,$choices,0)
		if($result -eq 0) {
			$RoleAssignment = New-ManagementRoleAssignment -Role "ApplicationImpersonation" -User $u
		}
		if($result -eq 1) {
			Write-Host
			Write-Host "You chose not to assign ApplicationImpersonation role to the user" $u -fore Yellow
			Write-Host "This script will now exit with an error..." -fore Yellow
		}
	}
	
	if ($RoleAssignment -ne $null){
		#Connect to the working mailbox
		Write-Host
		Write-Host "Connecting to the mailbox of" $impuser -fore Cyan
		
		$exchService = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService
		$exchService.Credentials = $creds.GetNetworkCredential()
		$exchService.ImpersonatedUserId = New-Object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress, $impuser)
		$exchService.AutodiscoverUrl($impuser,{$true})

		#Connect to the mailbox root and the archive root folders
		$MaxFolderBatchSize = (Get-MailboxFolderStatistics -Identity $impuser).count
		$MailboxRoot = [Microsoft.Exchange.WebServices.Data.Folder]::Bind( $exchService, [Microsoft.Exchange.WebServices.Data.WellknownFolderName]::MsgFolderRoot)
		$ArchiveRoot = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($exchService, [Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::ArchiveMsgFolderRoot)
		$FolderView = New-Object Microsoft.Exchange.WebServices.Data.FolderView( $MaxFolderBatchSize)
		$FolderView.Traversal = [Microsoft.Exchange.WebServices.Data.FolderTraversal]::Deep
		$FolderView.PropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet(
					[Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties,
					[Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName, 
					[Microsoft.Exchange.WebServices.Data.FolderSchema]::Id,
					[Microsoft.Exchange.WebServices.Data.FolderSchema]::ManagedFolderInformation,
					[Microsoft.Exchange.WebServices.Data.FolderSchema]::ChildFolderCount,
					[Microsoft.Exchange.WebServices.Data.FolderSchema]::ParentFolderId,
					[Microsoft.Exchange.WebServices.Data.FolderSchema]::ArchiveTag)

		Write-Host
		Write-Host "Script start!" -fore Green
		
		#List all the subfolders in the archive
		$ArchiveFolders = List-Folders -Folder $ArchiveRoot -View $FolderView
		Write-Host
		Write-Host "Found" $ArchiveFolders.count "folders in Archive root" -fore Green
		
		#List all the subfolders in the mailbox
		$MailboxFolders = List-Folders -Folder $MailboxRoot -View $FolderView
		Write-Host
		Write-Host "Found" $MailboxFolders.count "folders in Mailbox root" -fore Green
		
		#Get statistical data of the archive mailbox from Exchange
		$ExOnlineArchiveStats = Get-MailboxFolderStatistics -Identity $impuser -Archive | ? {$_.ContainerClass -like "IPF.*" -and $_.ContainerClass -ne "IPF.Files"}
		$ExMainMailboxStats = Get-MailboxFolderStatistics -Identity $impuser | ? {$_.ContainerClass -like "IPF.*" -and $_.ContainerClass -ne "IPF.Files"}

		#Go over each folder in the archive
		foreach ($folder in $ArchiveFolders){
			#Get statistical data of the main mailbox from Exchange
			$ExMainMailboxStats = Get-MailboxFolderStatistics -Identity $impuser
			Write-Host
			Write-Host "Working on" $folder.DisplayName -fore Cyan
			$OwaArchiveFolder = ConvertId -Id $folder.Id -EwsService $exchService -UPN $impuser -ToFormat "OWA" -IsArchive $true
			$indexA = $ExOnlineArchiveStats.folderid.IndexOf($OwaArchiveFolder)
			$FolderPath = $ExOnlineArchiveStats[$indexA].FolderPath
			$indexB = $ExMainMailboxStats.folderpath.indexof($FolderPath)
			
			#Get statistical data of a single archive folder to check for the item count
			$MaxItemBatchSize = $folder.TotalCount
			
			Write-Host "	Found" $MaxItemBatchSize "items in the folder" -fore Green
			
			#Continue only if the item count is larger than 0
			if ($indexB -ne -1 -and $MaxItemBatchSize -gt 0){
				Write-Host "Entering the move phase..." -fore Cyan
				
				#Retrieve the original folder Id of an item in EWS format
				$OriginalFolderId = New-Object Microsoft.Exchange.WebServices.Data.FolderId(ConvertId -Id $ExMainMailboxStats[$indexB].FolderId -EwsService $exchService -UPN $impuser -ToFormat "EWS")
				
				#Move items from archive folder to mailbox folder
				Write-Host
				Write-Host "			The script will move items from  <" $FolderPath ">  in the Archive mailbox to  <" $ExMainMailboxStats[$indexB].FolderPath ">  in the main mailbox" -fore Cyan
				Write-Host
				if ($MaxItemBatchSize -gt 1000){
					$remain = $MaxItemBatchSize % 1000
					$loops = (($MaxItemBatchSize - $remain) / 1000) + 1
					$itemCount = 1000
					for ($i = 0; $i -lt $loops; $i++){
						if ($i -eq ($loops - 1)){
							$itemCount = $remain
							$ItemView = New-Object Microsoft.Exchange.WebServices.Data.ItemView($itemCount)
							$ItemView.PropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)
							$ItemView.OrderBy.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::LastModifiedTime, [Microsoft.Exchange.WebServices.Data.SortDirection]::Descending)
							$itemList = $exchService.FindItems($folder.Id, $ItemView)
							$items = $itemList.Items
							
							foreach ($item in $items){
								Write-Host "				Moving item  [" $item.ItemClass "] <" $item.Subject ">  to" $ExMainMailboxStats[$indexB].FolderPath -fore Green
								$error.clear()
								$item.Move($OriginalFolderId)
								$entry = New-Object PSObject
								$entry | Add-Member -MemberType NoteProperty -Name "ArchiveFolderPath" -Value $FolderPath
								$entry | Add-Member -MemberType NoteProperty -Name "ArchiveFolderId" -Value $folder.Id
								$entry | Add-Member -MemberType NoteProperty -Name "MailboxFolderPath" -Value $ExMainMailboxStats[$indexB].FolderPath
								$entry | Add-Member -MemberType NoteProperty -Name "MailboxFolderId" -Value $OriginalFolderId
								$entry | Add-Member -MemberType NoteProperty -Name "Class" -Value $item.ItemClass
								$entry | Add-Member -MemberType NoteProperty -Name "Subject" -Value $item.Subject
								if ($error.count -gt 0){
									$entry | Add-Member -MemberType NoteProperty -Name "Result" -Value "Error"
								}
								else {
									$entry | Add-Member -MemberType NoteProperty -Name "Result" -Value "Success"
								}
								$log += $entry
							}
							Write-Host
							Write-Host "			Finished moving the remaining" $itemCount "items"
							Write-Host
						}
						else {
							$ItemView = New-Object Microsoft.Exchange.WebServices.Data.ItemView($itemCount)
							$ItemView.PropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)
							$ItemView.OrderBy.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::LastModifiedTime, [Microsoft.Exchange.WebServices.Data.SortDirection]::Descending)
							$itemList = $exchService.FindItems($folder.Id, $ItemView)
							$items = $itemList.Items
							
							foreach ($item in $items){
								Write-Host "				Moving item  [" $item.ItemClass "] <" $item.Subject ">  to" $ExMainMailboxStats[$indexB].FolderPath -fore Green
								$error.clear()
								$item.Move($OriginalFolderId)
								$entry = New-Object PSObject
								$entry | Add-Member -MemberType NoteProperty -Name "ArchiveFolderPath" -Value $FolderPath
								$entry | Add-Member -MemberType NoteProperty -Name "ArchiveFolderId" -Value $folder.Id
								$entry | Add-Member -MemberType NoteProperty -Name "MailboxFolderPath" -Value $ExMainMailboxStats[$indexB].FolderPath
								$entry | Add-Member -MemberType NoteProperty -Name "MailboxFolderId" -Value $OriginalFolderId
								$entry | Add-Member -MemberType NoteProperty -Name "Class" -Value $item.ItemClass
								$entry | Add-Member -MemberType NoteProperty -Name "Subject" -Value $item.Subject
								if ($error.count -gt 0){
									$entry | Add-Member -MemberType NoteProperty -Name "Result" -Value "Error"
								}
								else {
									$entry | Add-Member -MemberType NoteProperty -Name "Result" -Value "Success"
								}
								$log += $entry
							}
							Write-Host
							Write-Host "			Finished moving 1000 items"
							Write-Host
						}
					}
				}
				
				else {
					
					$ItemView = New-Object Microsoft.Exchange.WebServices.Data.ItemView($MaxItemBatchSize)
					$ItemView.PropertySet = New-Object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)
					$ItemView.OrderBy.Add([Microsoft.Exchange.WebServices.Data.ItemSchema]::LastModifiedTime, [Microsoft.Exchange.WebServices.Data.SortDirection]::Descending)
					$itemList = $exchService.FindItems($folder.Id, $ItemView)
					$items = $itemList.Items
					
					foreach ($item in $items){
						Write-Host "				Moving item  [" $item.ItemClass "] <" $item.Subject ">  to" $ExMainMailboxStats[$indexB].FolderPath -fore Green
						$error.clear()
						$item.Move($OriginalFolderId)
						$entry = New-Object PSObject
						$entry | Add-Member -MemberType NoteProperty -Name "ArchiveFolderPath" -Value $FolderPath
						$entry | Add-Member -MemberType NoteProperty -Name "ArchiveFolderId" -Value $folder.Id
						$entry | Add-Member -MemberType NoteProperty -Name "MailboxFolderPath" -Value $ExMainMailboxStats[$indexB].FolderPath
						$entry | Add-Member -MemberType NoteProperty -Name "MailboxFolderId" -Value $OriginalFolderId
						$entry | Add-Member -MemberType NoteProperty -Name "Class" -Value $item.ItemClass
						$entry | Add-Member -MemberType NoteProperty -Name "Subject" -Value $item.Subject
						if ($error.count -gt 0){
							$entry | Add-Member -MemberType NoteProperty -Name "Result" -Value "Error"
						}
						else {
							$entry | Add-Member -MemberType NoteProperty -Name "Result" -Value "Success"
						}
						$log += $entry
					}
				}
			}
			elseif ($indexB -eq -1 -and $MaxItemBatchSize -gt 0){
				#Check for a folder path "/Archive" in the main mailbox
				$ArchiveFolderOwaId = ($ExMainMailboxStats | ? {$_.FolderPath -eq "/Archive"}).FolderId
				
				if ($ArchiveFolderOwaId -eq $null){
					#Create a new "Archive" folder in the main mailbox and move there the running folder
					$NewArchiveFolder = New-Object Microsoft.Exchange.WebServices.Data.Folder($exchService)
					$NewArchiveFolder.DisplayName = "Archive"
					$NewArchiveFolder.FolderClass = "IPF.Note"
					$NewArchiveFolder.Save($MailboxRoot.Id)
					
					Write-Host "				Moving folder <" $folder.DisplayName "> to Archive folder in the main mailbox" -fore Green
					$folder.move($NewArchiveFolder.Id)
				}
				else {
					#Retrieve the EWS "Archive" folder Id and move there the running folder
					Write-Host "				Moving folder <" $folder.DisplayName "> to Archive folder in the main mailbox" -fore Green
					$DestFolderId = New-Object Microsoft.Exchange.WebServices.Data.FolderId(ConvertId -Id $ArchiveFolderOwaId -EwsService $exchService -UPN $impuser -ToFormat "EWS")
					$folder.move($DestFolderId)
				}
			}
			else {
				Write-Host
				Write-Host "The folder  <" $folder.DisplayName ">  is empty or inaccessible" -fore Yellow
			}
		}
	}
	else {
		Write-Host
		Write-Host "The user  <" $u ">  Does not have access rights to the mailbox  <" $impuser ">  because it wasn't assigned to ApplicationImpersonation role!" -back Black -fore Red
		Write-Host "Please assign the user to the role manually..." -back Black -fore Red
	}
}

else {
	Write-Host
	Write-Host "The EWS Managed Api 2.2 wasn't found on the computer!" -back Black -fore Red
	Write-Host "Exiting..." -back Black -fore Red
}

if (!$isRoleAssigned){
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",""
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",""
	$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
	$caption = "Warning!"
	$message = "Do you want to remove the ApplicationImpersonation role assignment from the user " + $u + "?"
	$result = $Host.UI.PromptForChoice($caption,$message,$choices,0)
	if($result -eq 0) {
		Get-ManagementRoleAssignment -Role ApplicationImpersonation -RoleAssignee $u -AssignmentMethod Direct | Remove-ManagementRoleAssignment -Confirm:$false
	}
	if($result -eq 1) {
		Write-Host
		Write-Host "You chose to keep the user" $u "as the ApplicationImpersonation role member" -fore Yellow
	}
}

$filename = $impuser + ".csv"
$log | export-csv $filename -notypeinformation -encoding utf8

Get-PSSession | ? {$_.computername -like '*office365*' -or $_.computername -like '*$exServer*'} | Remove-PSSession
