param($eventGridEvent, $TriggerMetadata)

# Make sure to pass hashtables to Out-String so they're logged correctly
$eventGridEvent | Out-String | Write-Host

# uncomment for claims detail for debugging
# Write-Output $eventGridEvent.data.claims | Format-List

$name = $eventGridEvent.data.claims.name
Write-Output "NAME: $name"

$appid = $eventGridEvent.data.claims.appid
Write-Output "APPID: $appid"

$objid = $eventGridEvent.data.claims.'http://schemas.microsoft.com/identity/claims/objectidentifier'
Write-Output "OBJECTID: $objid"

$email = $eventGridEvent.data.claims.'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'
Write-Output "EMAIL: $email"

$time = Get-Date -Format o
Write-Output "TIMESTAMP: $time"

$uri = $eventGridEvent.data.resourceUri
Write-Output "URI: $uri"


try {
    $resource = Get-AzResource -ResourceId $uri -ErrorAction Stop

    If (($resource) -and ($resource.ResourceId -notlike '*Microsoft.Resources/deployments*') -and ($name.length -gt 1)) {
        Write-Output 'Tagging resource'
        $tags = @{
            "LastModifiedBy"        = $name
            "LastModifiedTimeStamp" = $time
        }
        Update-AzTag -ResourceId $uri -Tag $tags -Operation Merge
    }
    else {
        Write-Output 'Tags do not appear to be supported on this resource, or name is empty'
    }
}
catch {
    Write-Output "Not a resource we can tag"
}
