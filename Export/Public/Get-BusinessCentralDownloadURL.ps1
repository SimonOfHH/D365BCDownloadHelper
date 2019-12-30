function Get-BusinessCentralDownloadURL {
    [CmdletBinding()]
    param (                
        $Version,
        [string]
        $CumulativeUpdate,
        [string]
        $Language
    )
    Add-Type -AssemblyName System.Web
    Function Get-GoogleSearchResult {
        <#
        .SYNOPSIS
            Returns the URL for the first Google search result
        .DESCRIPTION
            This CmdLet will first generate a Query-string, based on the Parameters (Get-SearchString)
            Then it will convert this Query-string into a URL-compaitble format (Get-UriWthEncodedSearchQuery)
            Then it will do a WebRequest and return the Link for the first search-result (Get-LinkForFirstGoogleSearchResult)
        #>
        [CmdletBinding()]
        param (                
            $Version = "14",
            [string]
            $CumulativeUpdate = "CU01",
            [string]
            $Language = "W1"
        )
        function Get-SearchString {
            [CmdletBinding()]
            param (                
                $Version,
                [string]
                $CumulativeUpdate,
                [string]
                $Language,
                [int]
                $TryNo
            )
            Write-Verbose "==========================================="
            Write-Verbose "Generating Search String based on following parameters:"
            Write-Verbose "           $Version"
            Write-Verbose "           $CumulativeUpdate"
            Write-Verbose "           $Language"
            $VersionPhrase = ""
            # MS is a littlge bit weird, with the naming under https://www.microsoft.com/en-us/download/
            # e.g. https://www.microsoft.com/en-us/download/details.aspx?id=58318; sometimes it's "Business Central", sometimes it's "BC"
            # or it's "2019" the one time and another time it's "19"
            # so let's try different variants
            switch ($Version) {
                "13" { $VersionPhrase = "Dynamics 365 Business Central" }
                "14" { 
                    $VersionPhrase = "Dynamics 365 BC Spring 2019 Update On Premise"                    
                }
                "15" {
                    $VersionPhrase = "Update 15.x for Microsoft Dynamics 365 Business Central 2019 Release Wave 2"
                }
            }
            if ($TryNo -eq 2) {
                Write-Verbose "Second try; switching out phrase"
                if ($VersionPhrase.Contains("BC")) {
                    $VersionPhrase = $VersionPhrase.Replace("BC", "Business Central")
                }
                else {
                    $VersionPhrase = $VersionPhrase.Replace("Business Central", "BC")
                }
            }
            if ($TryNo -eq 3) {
                Write-Verbose "Third try; switching out phrase"
                if ($VersionPhrase.Contains("2019")) {
                    $VersionPhrase = $VersionPhrase.Replace("2019", "19")
                }
                else {
                    $VersionPhrase = $VersionPhrase.Replace("19", "2019")
                }
            }
            Write-Verbose "Using Phrase instead of Version"
            Write-Verbose "           Version: $Version"
            Write-Verbose "           Phrase: $VersionPhrase"
            $CumulativeUpdate = $CumulativeUpdate.Replace("CU", "")            
            if ($CumulativeUpdate.Length -eq 1) {
                $CumulativeUpdate = "0" + $CumulativeUpdate
            }            
            $CumulativeUpdateInt = [int] $CumulativeUpdate
            if ($Version -eq "15") {
                $searchString = "$($VersionPhrase.Replace(".x",".$($CumulativeUpdateInt)")).zip site:microsoft.com"
            }
            else {
                $searchString = "CU $CumulativeUpdate $VersionPhrase.zip site:microsoft.com"
            }
            Write-Verbose "Generated Search String is:"
            Write-Verbose "           $searchString"
            Write-Verbose "==========================================="
            $searchString
        }
        function Get-UriWthEncodedSearchQuery {
            [CmdletBinding()]
            param (
                $QueryString
            )
            Write-Verbose "==========================================="
            Write-Verbose "Converting Search String into valid Google-query part"
            Write-Verbose "           $searchString"
            $query = 'https://www.google.com/search?q='
            $subQuery = ""
            $QueryParts = $QueryString -split " "
            $QueryParts | ForEach-Object { $subQuery = $subQuery + "$_+" }
            $url = $subQuery.Substring(0, $subQuery.Length - 1)
            Write-Verbose "Created Query is:"
            Write-Verbose "           $subQuery"
            $url = $query + $subQuery
            Write-Verbose "Complete URI is:"
            Write-Verbose "           $url"
            Write-Verbose "==========================================="
            $url
        }
        function Get-LinkForFirstGoogleSearchResult {
            [CmdletBinding()]
            param (                
                $SearchUri
            )
            #$searchUri = Get-GoogleSearchUrl $SearchString
            Write-Verbose "==========================================="
            Write-Verbose "Searching Google with URI: $SearchUri"
            Write-Verbose "======= START WebRequest"
            $webResponse = Invoke-WebRequest $SearchUri -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome -UseBasicParsing
            Write-Verbose "======= END WebRequest"
            Write-Verbose "Grabbing first search result..."
            $linkObject = $webResponse.Links | Where-Object { $_.outerHTML -match 'https://www.microsoft.com/en-us/download/details.aspx' } | Select-Object -First 1
            $targetLink = $linkObject.outerHTML
            if (-not($targetLink)) {
                Write-Verbose "Couldn't find a result. Exiting."
                return ""
            }
            Write-Verbose "Parsing and decoding result..."
            $targetLink = $targetLink.Substring($targetLink.IndexOf("q=") + 2)
            $targetLink = $targetLink.Substring(0, $targetLink.IndexOf("amp;sa=") - 1)
            $targetLink = [System.Web.HttpUtility]::UrlDecode($targetLink)            
            Write-Verbose "Done searching Google"
            Write-Verbose "Target Link is: $targetLink"
            Write-Verbose "==========================================="
            $targetLink
        }
        $try = 0
        while ((-not($firstResultLink)) -and ($try -lt 5)) {
            $try += 1
            $searchString = Get-SearchString -Version $Version -CumulativeUpdate $CumulativeUpdate -Language $Language -TryNo $try
            $searchUri = Get-UriWthEncodedSearchQuery -QueryString $SearchString
            $firstResultLink = Get-LinkForFirstGoogleSearchResult -SearchUri $searchUri
        }
        <#
        $searchString = Get-SearchString -Version $Version -CumulativeUpdate $CumulativeUpdate -Language $Language -TryNo 1
        $searchUri = Get-UriWthEncodedSearchQuery -QueryString $SearchString
        $firstResultLink = Get-LinkForFirstGoogleSearchResult -SearchUri $searchUri
        if (-not($firstResultLink)) {
            $searchString = Get-SearchString -Version $Version -CumulativeUpdate $CumulativeUpdate -Language $Language -TryNo 2
            $searchUri = Get-UriWthEncodedSearchQuery -QueryString $SearchString
            $firstResultLink = Get-LinkForFirstGoogleSearchResult -SearchUri $searchUri
        }
        #>
        $firstResultLink
    }
    function Get-ActualDownloadLinkForPortalPage {
        [CmdletBinding()]
        param (                
            $PortalPageUri,
            $LanguageCode
        )
        Write-Verbose "==========================================="
        $confirmationLink = $PortalPageUri.Replace("details.aspx", "confirmation.aspx")
        Write-Verbose "Confirmation Link is: $confirmationLink"
        Write-Verbose "======= START WebRequest"
        $webResponse = Invoke-WebRequest $confirmationLink -UseBasicParsing -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
        Write-Verbose "======= END WebRequest"
        $searchPattern = "$LanguageCode.*\.zip"
        Write-Verbose "Searching result for download Link using pattern: $searchPattern..."
        $downloadLinkObject = $webResponse.Links | Where-Object { $_.href -match "$searchPattern" } | Select-Object -First 1
        Write-Verbose "Returning $($downloadLinkObject.href)"
        Write-Verbose "==========================================="
        $downloadLinkObject.href
    }    
    $firstGoogleSearchResultLink = Get-GoogleSearchResult -Version $Version -CumulativeUpdate $CumulativeUpdate -Language $Language    
    if (-not($firstGoogleSearchResultLink)) {
        Write-Error "Didn't find anything via Google. Exiting here."
        return
    }
    $microsoftDownloadLink = Get-ActualDownloadLinkForPortalPage -PortalPageUri $firstGoogleSearchResultLink -LanguageCode $Language
    $microsoftDownloadLink
}
Export-ModuleMember Get-BusinessCentralDownloadURL