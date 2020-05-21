<#
.SYNOPSIS
  Install or UnInstall Microsoft Teams Client.
  
.DESCRIPTION
  Install or Uninstall Microsoft Teams Client. Select 32bit or 64bit version. Check if Teams exist before (un)installation. Default option is 64bit.

  Download the Teams client from https://teams.microsoft.com/downloads

.NOTES
  Version:        1.0
  Author:         R. Mens
  Blog:			  https://lazyadmin.nl
  Twitter:        https://twitter.com/lazyadmin	
  Creation Date:  25 juli 2018
  Purpose/Change: Initial script development

.EXAMPLE
  Install Teams

  .\Install-MicrosoftTeams.ps1 -source '\\filesrv\Repository\Microsoft\Teams'

.EXAMPLE
  Install 32bit version of Teams

   .\Install-MicrosoftTeams.ps1 -source '\\filesrv\Repository\Microsoft\Teams' -version 'x86'

.EXAMPLE
  Uninstall Teams

  .\Install-MicrosoftTeams.ps1 -uninstall $true
#>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
[CmdletBinding()]
PARAM(	
	[parameter(ValueFromPipeline=$true,
				ValueFromPipelineByPropertyName=$true,
				Mandatory=$true)]
	[string]$source,
	[parameter(ValueFromPipeline=$true,
				ValueFromPipelineByPropertyName=$true,
				Mandatory=$false)]
	[switch]$uninstall=$false,
	[parameter(ValueFromPipeline=$true,
				ValueFromPipelineByPropertyName=$true,
				Mandatory=$false)]
	[string]$version='x64'
)

#-----------------------------------------------------------[Functions]------------------------------------------------------------
function installTeams {
	$clientInstaller = "$($source)\Teams_windows_$($version).exe"

	#Test if install file exsist
	If (!(Test-Path $clientInstaller)) {
        throw "Unable to locate the $($version) client installer at $($source)"
    }

	try {
		cmd.exe /c $($clientInstaller) /s
	}
    catch {
        Write-Error $_.Exception.Message
    }

}

function unInstallTeams($path) {

	$clientInstaller = "$($path)\Update.exe"
	
	 try {
        $process = Start-Process -FilePath "$clientInstaller" -ArgumentList "--uninstall /s" -PassThru -Wait -ErrorAction STOP

        if ($process.ExitCode -ne 0)
		{
			Write-Error "UnInstallation failed with exit code  $($process.ExitCode)."
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }

}


#-----------------------------------------------------------[Script]------------------------------------------------------------

#Locate installation folder
$localAppData = "$($env:LOCALAPPDATA)\Microsoft\Teams"
$programData = "$($env:ProgramData)\$($env:USERNAME)\Microsoft\Teams"


If (Test-Path "$($localAppData)\Current\Teams.exe") 
{
	If ($uninstall) {
		unInstallTeams($localAppData)
	}
	else {
		Write-Host "Teams already installed" -ForegroundColor Green
	}
		
}
elseif (Test-Path "$($programData)\Current\Teams.exe") {
	If ($uninstall) {
		unInstallTeams($programData)
	}
	else {
		Write-Host "Teams already installed" -ForegroundColor Green
	}
}
else {
	If ($uninstall) {
		Write-Warning  "Teams installation not found"
	}
	else {
		installTeams
	}
}