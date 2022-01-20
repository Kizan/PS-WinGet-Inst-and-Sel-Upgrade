#Winget Install Apps
#Douglas Bowie

#Script searches local folder for files with "install" anywhere in the name and imports them.

#Set-Executionpolicy -Executionpolicy Bypass -Scope LocalMachine -Force

#Remove-Variable * -ErrorAction:SilentlyContinue; Remove-Module *; $error.Clear();

If ($args.count){

        Write-Host "Winget Install Useage:"
        Write-Host " "
        Write-Host "   -Help        This Help Screen"
        Write-Host " "
        Write-Host "Install files " -ForegroundColor Green
        Write-Host "Create one or more CSV files with the word 'install' in file name."
        Write-Host " "
        Write-Host "First line is 'ID'"
        Write-Host "Each line after that is the Winget application ID of the app to be skipped."
        Write-Host " "
        Write-Host "Example file would contain the following:"
        Write-Host "ID" -ForegroundColor Cyan
        Write-Host "Microsoft.OneDrive" -ForegroundColor Cyan
        Write-Host " "
        Write-Host "WinGet MUST be installed to get list of IDs. Otherwise see Microsoft for list." -ForegroundColor Red
        Write-Host " "
        Write-Host "For a full listing of Application IDs run: Winget list"
        Write-Host "Example: " -NoNewline
        Write-Host "Winget list --name microsoft" -ForegroundColor Magenta
        Write-Host " "
        Write-Host "CLI Params"
        Write-Host $args[0]
        Clear-Variable args* -ErrorAction:SilentlyContinue; Remove-Module *; $error.Clear();
        exit
}

$currentpath = Split-Path $MyInvocation.MyCommand.Path -Parent
Import-Module -Name $currentpath"\WinGet-Mods.psm1" #-Verbose

#Install or Update WinGet both MS and PS versions and dependancies
Update-WinGet

#Install Apps
$currentpath = Split-Path $MyInvocation.MyCommand.Path -Parent
$applist = Import-CSV -Path  (Get-ChildItem -Path $currentpath -Filter '*install*.csv').FullName

Write-Host "Apps being Installed"
Write-Host $applist.id -ForegroundColor Magenta

if ($null -eq $applist.id) { 
    write-host "No *install*.csv files found" 
    Exit 
}

foreach($app in $applist)
{
    $WinGetMS_Local_Package = Get-WinGetPackage | Where-Object {$_.Source -eq 'winget' -And $_.ID -eq $app.ID}
    $WinGetMS_Remote_Package = Find-WinGetPackage -ID $app.ID -Exact | Where-Object {$_.ID -eq $app.ID}

    If ($WinGetMS_Local_Package.Version -ne $WinGetMS_Remote_Package.Version ){
        Write-Host "Installing: " -NoNewline
        Write-Host $app.id -ForegroundColor Green
        winget install -e --id $app.id --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host "Installed and updated: " -NoNewline
        Write-Host $app.id -ForegroundColor Magenta
    }
}

Remove-Variable * -ErrorAction:SilentlyContinue; Remove-Module *; $error.Clear();