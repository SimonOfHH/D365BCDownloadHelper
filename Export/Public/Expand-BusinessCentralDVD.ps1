function Expand-BusinessCentralDVD {
    [CmdletBinding()]
    <#
    .SYNOPSIS
        ...
    .DESCRIPTION
        ...
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $ZipFilename,
        [Parameter(Mandatory = $false)]
        [string]
        $TargetDirectoryParent,
        [Parameter(Mandatory = $false)]
        [string]
        $TargetDirectoryName = "DVD"
    )
    process {
        if (-not (Test-Path $ZipFilename)){
            Write-Error "Zip-file $ZipFilename does not exist"
            return
        }

        if (-not($TargetDirectoryParent)){
            Write-Verbose "TargetDirectoryParent not set. Using parent of `$ZipFilename"
            $TargetDirectoryParent = Split-Path $ZipFilename
            Write-Verbose "TargetDirectoryParent: $TargetDirectoryParent"
        }
        $fullTargetDirectory = Join-Path $TargetDirectoryParent $TargetDirectoryName        
                
        if (-not (Test-Path (Join-Path $fullTargetDirectory 'setup.exe'))) { # Check if there is already an extracted DVD
            Write-Verbose "Expanding $ZipFilename (Unzip)"
            Expand-Archive -Path $ZipFilename -DestinationPath $fullTargetDirectory
            Write-Verbose "Expansion complete."
            if (-not (Test-Path (Join-Path $fullTargetDirectory 'setup.exe'))) { # Sometimes the Zip-file contains another Zip-file, so maybe extract the child-zip as well
                Write-Verbose "Archive contains a second archive. Processing this one as well."
                # Get DVD-Zip from just extracted dir
                $childZipFilename = Get-ChildItem -Path $fullTargetDirectory -Filter *.zip | Select-Object -First 1 | % { $_.FullName }

                # Move extracted ZIP to parent and delete remaining directory
                Write-Verbose "Moving extracted Zip-file to parent directory"
                Write-Verbose "    File: $childZipFilename"
                Write-Verbose "    From: $(Split-Path $childZipFilename)"
                Write-Verbose "      To: $($TargetDirectoryParent)"
                Move-Item $childZipFilename $TargetDirectoryParent
                Write-Verbose "Deleting $fullTargetDirectory (not needed)"
                Remove-Item $fullTargetDirectory -Confirm:$false -Force -Recurse
                Write-Verbose "Deleting original Zip-file $ZipFilename (not needed)"
                Remove-Item $ZipFilename -Confirm:$false -Force -Recurse

                # Find moved file and Unzip it
                $ZipFilename = Get-ChildItem -Path $TargetDirectoryParent -Filter *.zip | Where-Object { $_.Name -ne $filename } | Select-Object -First 1 | % { $_.FullName }
                Write-Verbose "Expanding $ZipFilename (Unzip)"
                Expand-Archive -Path $ZipFilename -DestinationPath $fullTargetDirectory
                Write-Verbose "Expansion complete."                
            }
        }
    }
}
Export-ModuleMember Expand-BusinessCentralDVD