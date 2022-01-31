<#
.SYNOPSIS
    Appends a URL encoded query string from a hashtable to the supplied URI.
.DESCRIPTION
    Appends a URL encoded query string from a hashtable to the supplied URI.
.PARAMETER Uri
    The URI to append the query string to.
.PARAMETER QueryParameters
    A hashtable to convert to a query string.
.EXAMPLE
    PS C:\> $QueryParams = @{name = "John Smith"; age = 39; is_active=$true}
    PS C:\> $Uri = 'https://example.com/api/users'
    PS C:\> New-HttpQueryUri -Uri $Uri -QueryParameters $QueryParams
     
    https://example.com:443/api/users?is_active=True&name=John+Smith&age=39
.OUTPUTS
    System.String
#>
function New-MMHttpQueryUri {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.UriBuilder]
        $Uri,
        [Parameter(Mandatory = $true, Position = 1)]
        [hashtable]
        $QueryParameters
    )    
    process {
        $QueryParameterCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        foreach ($Key in $QueryParameters.Keys) {
            $QueryParameterCollection.Add($Key, $QueryParameters.$Key)
        }

        $Uri.Query = $QueryParameterCollection.ToString()
        Write-Output $Uri.Uri.OriginalString
    }
}