$VerbosePreference="SilentlyContinue"
# Version, Author, CompanyName and nugetkey
. (Join-Path $PSScriptRoot ".\Private\settings.ps1")

Clear-Host
#Invoke-ScriptAnalyzer -Path $PSScriptRoot -Recurse -Settings PSGallery -Severity Warning

Get-ChildItem -Path $PSScriptRoot -Recurse | % { Unblock-File -Path $_.FullName }

Remove-Module D365BCDownloadHelper -ErrorAction Ignore
Uninstall-module D365BCDownloadHelper -ErrorAction Ignore

$path = "C:\temp\D365BCDownloadHelper"

if (Test-Path -Path $path) {
    Remove-Item -Path $path -Force -Recurse
}
Copy-Item -Path $PSScriptRoot -Destination "C:\temp" -Exclude @("settings.ps1", ".gitignore", "README.md", "PublishD365BCDownloadHelper.ps1","TestRunner.ps1") -Recurse
Remove-Item -Path (Join-Path $path ".git") -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path (Join-Path $path "Private") -Force -Recurse

$modulePath = Join-Path $path "D365BCDownloadHelper.psm1"
Import-Module $modulePath -DisableNameChecking

#get-module -Name SetupD365Environment

$functionsToExport = (get-module -Name D365BCDownloadHelper).ExportedFunctions.Keys | Sort-Object
$aliasesToExport = (get-module -Name D365BCDownloadHelper).ExportedAliases.Keys | Sort-Object

Update-ModuleManifest -Path (Join-Path $path "D365BCDownloadHelper.psd1") `
                      -RootModule "D365BCDownloadHelper.psm1" `
                      -ModuleVersion $version `
                      -Author $author `
                      -CompanyName $CompanyName #`
                      #-FunctionsToExport $functionsToExport `
                      #-AliasesToExport $aliasesToExport `
                      #-FileList @("") `
                      #-ReleaseNotes (get-content (Join-Path $path "ReleaseNotes.txt")) 

Copy-Item -Path (Join-Path $path "D365BCDownloadHelper.psd1") -Destination $PSScriptRoot -Force
Publish-Module -Path $path -NuGetApiKey $powershellGalleryApiKey

Remove-Item -Path $path -Force -Recurse