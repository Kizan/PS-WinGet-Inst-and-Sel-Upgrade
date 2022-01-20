function Update-WinGet {

    Install-PackageProvider -Name Nuget -Force -Scope AllUsers -Confirm:$false | Out-Null
    
    #$WingetCLI_Local = Get-AppPackage -name Microsoft.Winget.Source
    $WingetCLI_Local = Test-Path -Path "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\winget.exe" -PathType Leaf

    If ($WingetCLI_Local -ne $true)
    {
        Write-Host "Winget - MS Application MUST be installed!" -ForegroundColor Red
        Add-AppxPackage -Path "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
        Add-AppxPackage -Path "https://aka.ms/getwinget"
        <#
        #& $currentpath\'100 - install-winget.bat'
        #& start ms-appinstaller:?source=https://aka.ms/getwinget

        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.1.12653/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "C:\WinGet.msixbundle"
        Add-AppxPackage "C:\WinGet.msixbundle" #-ErrorAction:SilentlyContinue
        Remove-Item -Path "C:\WinGet.msixbundle"
        #>

    } else {
        Write-Host "Winget - MS Application already installed!" -ForegroundColor Green
    }  

    $WinGetPS_Local = Get-Package -Name Winget -ErrorAction:SilentlyContinue

    If ($null -eq $WinGetPS_Local.Name)
    {
        Write-Host "Winget - PS Module MUST be Installed!" -ForegroundColor Yellow

        #Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
        # Install-PackageProvider -Name Nuget -Force -Scope AllUsers -Confirm:$false -Verbose
        Install-PackageProvider WinGet -Scope AllUsers -Force -Confirm:$false #-Verbose

    } else {
        Write-Host "Winget - PS Module already installed!" -ForegroundColor Green

        #$WinGetPS_Local = Get-Package -Name Winget -ErrorAction:Continue
        $WinGetPS_Current = Find-Package -Name Winget
        If ($WinGetPS_Current.Version -ne $WinGetPS_Local.Version){
            Write-Host "   Winget - PS Module MUST be Updatded!" -ForegroundColor Yellow
            Install-PackageProvider WinGet -Scope AllUsers -Force -Confirm:$false #-Verbose
            #Update-Module -Name Winget
        }  else {
            Write-Host "   Winget - PS Module up to Date!" -ForegroundColor Magenta
        }  
    }
} #End Function
