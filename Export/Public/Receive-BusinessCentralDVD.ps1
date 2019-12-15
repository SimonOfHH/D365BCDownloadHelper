function Receive-BusinessCentralDVD {
    [CmdletBinding()]
    <#
    .SYNOPSIS
        Downloads a Business Central DVD
    .DESCRIPTION
        ...
    #>
    param(
        [Parameter(Mandatory = $false)]
        [string]
        $Version = "14",
        [Parameter(Mandatory = $false)]
        [string]
        $CumulativeUpdate = "CU01",
        [Parameter(Mandatory = $false)]
        [string]
        $Language = "W1",
        [Parameter(Mandatory = $false)]
        [string]
        $DownloadDirectory = "C:\Install\"
    )
    process {
        Add-Type -AssemblyName System.Web

        $UrlToDownload = Get-BusinessCentralDownloadURL -Version $Version -CumulativeUpdate $CumulativeUpdate -Language $Language
        if (-not($UrlToDownload)){
            Write-Error "Download URL not found."
            return
        }
        $filename = Split-Path $UrlToDownload -Leaf
        $dvdFilename = Join-Path $DownloadDirectory $filename

        if (!(Test-Path $DownloadDirectory)) {
            New-Item -ItemType Directory -Path  $DownloadDirectory | Out-Null
        }
        if (!(Test-Path $dvdFilename)) {
            Write-Verbose "Downloading File:"
            Write-Verbose "   URL: $UrlToDownload"
            Write-Verbose "   Filename: $dvdFilename"
            $clnt = New-Object System.Net.WebClient
            $clnt.DownloadFile($UrlToDownload, $dvdFilename)
            Write-Verbose "Download complete"
        }
        else { 
            Write-Verbose "File $dvdFilename already exists."
        }
        $dvdFilename        
    }
}
Export-ModuleMember Receive-BusinessCentralDVD