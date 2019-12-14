function Get-ReceiveAndExpandBusinessCentralDVD {
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
        $DownloadDirectory = "C:\Install\",
        [Parameter(Mandatory = $false)]
        [string]
        $TargetDirectoryParent,
        [Parameter(Mandatory = $false)]
        [string]
        $TargetDirectoryName = "DVD"
    )
    process {
        $zipFilename = Receive-BusinessCentralDVD -Version $Version -CumulativeUpdate $CumulativeUpdate -Language $Language
        Expand-BusinessCentralDVD -ZipFilename $zipFilename -TargetDirectoryParent $TargetDirectoryParent -TargetDirectoryName $TargetDirectoryName
    }
}
Export-ModuleMember Get-ReceiveAndExpandBusinessCentralDVD