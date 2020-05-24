Param( 
    [Parameter(Mandatory = $true)] 
    [string] $ResourceGroupName, 
    [Parameter(Mandatory = $true)] 
    [string] $AppServiceName, 
    [Parameter(Mandatory = $true)] 
    [string] $SubscriptionId, 
    [Parameter(Mandatory = $true)]
    [Hashtable[]] $NewIpRules
)

$ErrorActionPreference = "Stop"

Import-Module Az

if($Null -eq (Get-AzContext)){
    Login-AzAccount
}

Select-AzSubscription -SubscriptionId $SubscriptionId

$APIVersion = ((Get-AzResourceProvider -ProviderNamespace Microsoft.Web).ResourceTypes | Where-Object ResourceTypeName -eq sites).ApiVersions[0]

$WebAppConfig = Get-AzResource -ResourceName $AppServiceName -ResourceType Microsoft.Web/sites/config -ResourceGroupName $ResourceGroupName -ApiVersion $APIVersion

foreach ($NewIpRule in $NewIpRules) {
    $WebAppConfig.Properties.ipSecurityRestrictions += $NewIpRule
}

Set-AzResource -ResourceId $WebAppConfig.ResourceId -Properties $WebAppConfig.Properties -ApiVersion $APIVersion