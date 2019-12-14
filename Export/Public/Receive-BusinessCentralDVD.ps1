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
        $DownloadDirectory = $DownloadDirectory        

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
        <#
        # Unzip downloaded file
                
        $dvdPath = Join-Path $DownloadDirectory "DVD"
        if (-not (Test-Path (Join-Path $dvdPath 'setup.exe'))) {
            Write-CustomHost -Message "Unzipping $dvdFilename"
            Expand-Archive -Path $dvdFilename -DestinationPath $dvdPath
            Write-CustomHost -Message "Unzip complete"
            if (-not (Test-Path (Join-Path $dvdPath 'setup.exe'))) {
                # Get DVD-Zip from just extracted dir
                $dvdZipfile = Get-ChildItem -Path $dvdPath -Filter *.zip | Select-Object -First 1 | % { $_.FullName }

                # Move extracted ZIP to parent and delete remaining directory
                Write-CustomHost -Message "Cleaning up directory..."
                Move-Item $dvdZipfile $DownloadDirectory
                Remove-Item $dvdPath -Confirm:$false -Force -Recurse

                # Find moved file and Unzip it
                $dvdZipfile = Get-ChildItem -Path $DownloadDirectory -Filter *.zip | Where-Object { $_.Name -ne $filename } | Select-Object -First 1 | % { $_.FullName }

                Write-CustomHost -Message "Unzipping $dvdZipfile"
                Expand-Archive -Path $dvdZipfile -DestinationPath $dvdPath
                Write-CustomHost -Message "Unzip complete"

                # Remove previously extracted ZIP (from other ZIP)
                $dvdZipfile = Get-ChildItem -Path $DownloadDirectory -Filter *.DVD.zip | Where-Object { $_.Name -ne $filename } | Select-Object -First 1 | % { $_.FullName }
                Remove-Item $dvdZipfile -Confirm:$false -Force -Recurse
            }
        }
        #>
    }
}
Export-ModuleMember Receive-BusinessCentralDVD