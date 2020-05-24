Param( 
    [Parameter(Mandatory = $true)] 
    [string] $ResourceGroupName, 
    [Parameter(Mandatory = $true)] 
    [string] $AppServiceName, 
    [Parameter(Mandatory = $true)] 
    [string] $SubscriptionId, 
    [Parameter(Mandatory = $true)] 
    [string] $RulePriority
)

$ErrorActionPreference = "Stop"

$IPv4s = (Invoke-WebRequest -Uri "https://www.cloudflare.com/ips-v4").Content.TrimEnd([Environment]::NewLine).Split([Environment]::NewLine);
$IPv6s = (Invoke-WebRequest -Uri "https://www.cloudflare.com/ips-v6").Content.TrimEnd([Environment]::NewLine).Split([Environment]::NewLine);

$NewIpRestrictions = @();
foreach($IPv4 in $IPv4s){
    $NewIpRestrictions += @{
        ipAddress = $IPv4; 
        action = "Allow";
        priority = $RulePriority;
        name = "Cloudflare IPv4";
        description = "Cloudflare IPv4";
        tag = "Default";
    }
}

foreach($IPv6 in $IPv6s){
    $NewIpRestrictions += @{
        ipAddress = $IPv6; 
        action = "Allow";
        priority = $RulePriority;
        name = "Cloudflare IPv6";
        description = "Cloudflare IPv6";
        tag = "Default";
    }
}

& "$PSScriptRoot\AddRestrictedIPAzureAppService.ps1" -ResourceGroupName $ResourceGroupName -AppServiceName $AppServiceName -SubscriptionId $SubscriptionId -NewIpRules $NewIpRestrictions