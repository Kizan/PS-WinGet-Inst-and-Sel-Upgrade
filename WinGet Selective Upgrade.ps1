#Winget Selective Upgrade
#by Douglas Bowie

#Script searches local folder for files with "exclude" anywhere in the name and imports them.

#Set-Executionpolicy -Executionpolicy Bypass -Scope LocalMachine -Force

#Remove-Variable * -ErrorAction:SilentlyContinue; Remove-Module *; $error.Clear();

$param1 = $null

If ($args.count){

    $param1 = $args[0]
    $param1 = $param1.ToLower()

    $verbose = "-verbose"

    If ($param1 -ne $verbose){
        Write-Host "Winget Selective Upgrade Useage:"
        Write-Host " "
        Write-Host "   -Verbose     Additional Detailed Output"
        Write-Host "   -Help        This Help Screen"
        Write-Host " "
        Write-Host "Exclude files" -ForegroundColor Green
        Write-Host "Create one or more CSV files with the word 'exclude' in file name application skip upgrading."
        Write-Host " "
        Write-Host "First line is 'ID'"
        Write-Host "Each line after that is the Winget application ID of the app to be skipped."
        Write-Host " "
        Write-Host "Example file would contain the following:"
        Write-Host "ID" -ForegroundColor Cyan
        Write-Host "Microsoft.OneDrive" -ForegroundColor Cyan
        Write-Host " "
        Write-Host "For a full listing of Application IDs run: Winget list"
        Write-Host "Example: " -NoNewline
        Write-Host "Winget list --name microsoft" -ForegroundColor Magenta
        Write-Host " "
        Write-Host "CLI Params"
        Write-Host $param1
        Clear-Variable args* -ErrorAction:SilentlyContinue; Remove-Module *; $error.Clear();
        exit
    } 
} 

$currentpath = Split-Path $MyInvocation.MyCommand.Path -Parent
Import-Module -Name $currentpath"\WinGet-Mods.psm1" #-Verbose
#Import-Module Cobalt
#Import-Module WinGet

#Install or Update WinGet both MS and PS versions and dependancies
Update-WinGet

Write-Host "Collecting WinGet Upgrade Package List"

$WinGetMS_Version = winget -v | Out-String
Write-Host "Installed MS App WinGet version: "$WinGetMS_Version

$WinGetMS_UpgradeResult = winget upgrade | Out-String
if ($WinGetMS_UpgradeResult -match "No installed package found matching input criteria.")
{
    Write-Host "No installed package found matching input criteria." -ForegroundColor Red
    Exit
}

#Get-WinGetPackage  - Retrives local package details
$WinGetMS_Local_Packages = Get-WinGetPackage | Where-Object {$_.Source -eq 'winget'}

If ($param1 -eq $verbose){    
    Write-Host "Local Packages:"
    $WinGetMS_Local_Packages | Format-Table -AutoSize
    Write-Host " "
}

#Find-WinGetPackage - Retrives latest version of package in remote Repo
$WinGetMS_Remote_Packages = foreach ($remote_package in $WinGetMS_Local_Packages){
    Find-WinGetPackage -ID $remote_package.ID -Exact | Where-Object {$_.ID -eq $remote_package.ID}
}

If ($param1 -eq $verbose){
    Write-Host "Remote Packages:"
    $WinGetMS_Remote_Packages | Format-Table -AutoSize
    Write-Host " "
}

$i = 0
$Packages_to_Upgrade = @()
foreach ($Local_package in $WinGetMS_Local_Packages){
    foreach ($Remote_package in $WinGetMS_Remote_Packages){
        if ($Local_package.ID -eq $Remote_package.ID -And $Local_package.Version -ne $Remote_package.Version){
            #Write-Host $Remote_package.ID" "$Local_package.Version" "$Remote_package.Version
            $Packages_to_Upgrade += $Local_package
            Add-Member -InputObject $Packages_to_Upgrade[$i++] -NotePropertyName "RemoteVersion" -NotePropertyValue $Remote_package.Version -Force
        }    
    }  
}
If ($param1 -eq $verbose){
    Write-Host "Packages Needing Upgrade:"
    $Packages_to_Upgrade | Format-Table -AutoSize
    Write-Host " "
}

#Import Package IDs to be skipped for Upgrade
$toSkip = Import-CSV -Path  (Get-ChildItem -Path $currentpath -Filter '*exclude*.csv').FullName

If ($param1 -eq $verbose){
    Write-Host "Packages to be Skipped"
    $toSkip | Format-Table -AutoSize
    Write-Host " "
}

foreach ($package in $Packages_to_Upgrade){
    if (-not ($toSkip.id -contains $package.ID)){
        Write-Host "Upgrade package: " -NoNewline
        Write-Host "$($package.ID) " -NoNewline -ForegroundColor Cyan
        Write-Host "v$($package.version), " -NoNewline -ForegroundColor Red
        Write-Host "New v$($package.RemoteVersion)" -ForegroundColor Green
        winget install -e --id $package.ID --accept-package-agreements --accept-source-agreements
        #Install-WinGetPackage -ID $package.ID -Exact -ErrorAction:SilentlyContinue
    }  else   {    
        Write-Host "Skipped package: " -NoNewline -ForegroundColor Red
        Write-Host "$($package.ID) " -NoNewline -ForegroundColor Cyan
        Write-Host "v$($package.version), " -NoNewline -ForegroundColor Red
        Write-Host "New v$($package.RemoteVersion)" -ForegroundColor Green
    }
}

Remove-Variable * -ErrorAction:SilentlyContinue; Remove-Module *; $error.Clear();