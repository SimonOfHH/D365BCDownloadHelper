# Based on https://stackoverflow.com/questions/66969841/how-to-accept-youtube-cookies-consent-with-powershell
function Get-GoogleCookieConsentSession {
    [CmdletBinding()]
    param (        
        [string]
        $SearchUrl
    )
    try {
        # in our first GET call we should get a response from consent.youtube.com.
        # we save the session including all cookies in variable $currentSession.
        $response = Invoke-WebRequest -Uri $SearchUrl -UseBasicParsing -SessionVariable 'currentSession' -ErrorAction Stop

        # using BaseResponse to figure out which host has responded
        if ($PSVersionTable.PSVersion.Major -gt 5) {
            # PS 6+ has other properties than PS5.1 and below
            $responseRequestUri = $response.BaseResponse.RequestMessage.RequestUri
        }
        else {
            $responseRequestUri = $response.BaseResponse.ResponseUri
        }

        if ($responseRequestUri.Host -eq 'consent.google.com') {
            # check if got redirected to "consent.google.com"

            # unfortunately the response object from "Invoke-WebRequest" does not provide any "Form" data as property,
            # so we have to parse it from the content. There are two <form..> nodes, but we only need the one for method "POST".
            $formContent = [regex]::Match(
                $response.Content,
                # we use lazy match, even if it's expensive when it comes to performance.
                ('{0}.+?(?:{1}.+?{2}|{2}.+?{1}).+?{3}' -f
                    [regex]::Escape('<form'),
                    [regex]::Escape('action="https://consent.google.com'),
                    [regex]::Escape('method="POST"'),
                    [regex]::Escape('</form>')
                )
            )

            # getting the POST URL using our parsed form data. As of now it should parse: "https://consent.google.com/s"
            $postUrl = [regex]::Match($formContent, '(?<=action\=\")[^\"]+(?=\")').Value

            # build POST body as hashtable using our parsed form data.
            # only elements with a "name" attribute are relevant and we only need the plain names and values
            $postBody = @{}
            [regex]::Matches($formContent -replace '\r?\n', '<input[^>]+>').Value | ForEach-Object {
                $name = [regex]::Match($_, '(?<=name\=\")[^\"]+(?=\")').Value
                $value = [regex]::Match($_, '(?<=value\=\")[^\"]+(?=\")').Value

                if (![string]::IsNullOrWhiteSpace($name)) {
                    $postBody[[string]$name] = [string]$value
                }
            }

            # now let's try to get an accepted CONSENT cookie by POSTing our hashtable to the parsed URL and override the sessionVariable again.
            # Using the previous session variable here would return a HTTP error 400 ("method not allowed")
            $response = Invoke-WebRequest -Uri $postUrl -Method Post -UseBasicParsing -SessionVariable 'currentSession' -Body $postBody -ErrorAction Stop

            # get all the cookies for domain '.google.com'
            $cookies = [object[]]$currentSession.Cookies.GetCookies('https://google.com')

            # check if we got the relevant cookie "CONSENT" with a "yes+" prefix in its value.
            # if the value changes in future, we have to adapt the condition here accordingly.
            $consentCookie = [object[]]($cookies | Where-Object { $_.Name -eq 'CONSENT' })
            if (!$consentCookie.Count) {
                Write-Error -Message 'The cookie "CONSENT" is missing in our session after our POST! Please check.' -ErrorAction Stop

            }
            elseif (!($consentCookie.Value -like 'YES+*').count) {
                Write-Error -Message ("The value of cookie ""CONSENT"" (""$($consentCookie.Value -join '" OR "')"") does not start with ""YES+"", but maybe it's intended and the condition has to be adapted!") -ErrorAction Stop
            }            
        }

    }
    finally {
        $currentSession        
    }
}
Export-ModuleMember Get-GoogleCookieConsentSession