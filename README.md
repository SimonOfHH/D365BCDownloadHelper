# D365BCDownloadHelper
This little module is used to provide you with a download link for a Dynamics 365 Business Central DVD. It will do a Google search with the necessary search query and return the correct link to the DVD Zip-File from Microsoft. It'll first search for the general download-page (where you can select the different languages) and then select the correct link from the confirmation page.

Works only for downloads listed in the Microsoft Download center. Business Central 15 is currently only available via Partner Source/Customer Source (afaik).

## Installation
Install from PSGallery via
```
Install-Module D365BCDownloadHelper
```
Import it into your current session
```
Import-Module D365BCDownloadHelper
```
## Usage Example
Use it like this
```
Get-BusinessCentralDownloadUrl -Version 13 -CumulativeUpdate CU14 -Language W1
=== Result ===
https://download.microsoft.com/download/9/5/4/954c190e-ecc0-4ab3-b78e-56f37ee9ec45/CU 14 Dynamics 365 Business Central W1.zip
```

If you're calling it with the `-Verbose` switch you'll receive detailed output
```
VERBOSE: ===========================================
VERBOSE: Generating Search String based on following parameters:
VERBOSE:            13
VERBOSE:            CU14
VERBOSE:            W1
VERBOSE: Using Phrase instead of Version
VERBOSE:            Version: 13
VERBOSE:            Phrase: Dynamics 365 Business Central
VERBOSE: Generated Search String is:
VERBOSE:            CU 14 Dynamics 365 Business Central.zip site:microsoft.com
VERBOSE: ===========================================
VERBOSE: ===========================================
VERBOSE: Converting Search String into valid Google-query part
VERBOSE:            CU 14 Dynamics 365 Business Central.zip site:microsoft.com
VERBOSE: Created Query is:
VERBOSE:            CU+14+Dynamics+365+Business+Central.zip+site:microsoft.com+
VERBOSE: Complete URI is:
VERBOSE:            https://www.google.com/search?q=CU+14+Dynamics+365+Business+Central.zip+site:microsoft.com+
VERBOSE: ===========================================
VERBOSE: ===========================================
VERBOSE: Searching Google with URI: https://www.google.com/search?q=CU+14+Dynamics+365+Business+Central.zip+site:microsoft.com+
VERBOSE: ======= START WebRequest
VERBOSE: GET https://www.google.com/search?q=CU+14+Dynamics+365+Business+Central.zip+site:microsoft.com+ with 0-byte payload
VERBOSE: received -1-byte response of content type text/html; charset=ISO-8859-1
VERBOSE: ======= END WebRequest
VERBOSE: Grabbing first search result...
VERBOSE: Parsing and decoding result...
VERBOSE: Done searching Google
VERBOSE: Target Link is: https://www.microsoft.com/en-us/download/details.aspx?id=100643
VERBOSE: ===========================================
VERBOSE: ===========================================
VERBOSE: Confirmation Link is: https://www.microsoft.com/en-us/download/confirmation.aspx?id=100643
VERBOSE: ======= START WebRequest
VERBOSE: GET https://www.microsoft.com/en-us/download/confirmation.aspx?id=100643 with 0-byte payload
VERBOSE: received 179022-byte response of content type text/html
VERBOSE: ======= END WebRequest
VERBOSE: Searching result for download Link using pattern: W1.*\.zip...
VERBOSE: Returning https://download.microsoft.com/download/9/5/4/954c190e-ecc0-4ab3-b78e-56f37ee9ec45/CU 14 Dynamics 365 Business Central W1.zip
VERBOSE: ===========================================
```