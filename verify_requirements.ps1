# Verifica se il modulo WSMan è installato
if (-not (Get-Command -Module WSMan -ErrorAction SilentlyContinue)) {
    Install-WindowsFeature -Name WinRM
    Write-Host "Modulo WSMan installato e configurato correttamente."
} else {
    Write-Host "Modulo WSMan già presente."
}

# Configurazione WSMan
winrm quickconfig -q
winrm set winrm/config/client @{TrustedHosts="*"}
Set-Item wsman:\localhost\Client\TrustedHosts -Value "*"

# Verifica se Winget è installato e aggiornato
$wingetVersion = (winget --version 2>&1)
$latestWingetVersion = "v1.3.2091"

if ($wingetVersion -ne $latestWingetVersion) {
    Write-Host "Aggiornamento Winget all'ultima versione."
    Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "$env:USERPROFILE\Downloads\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle"
    Add-AppxPackage -Path "$env:USERPROFILE\Downloads\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle"
    Write-Host "Winget aggiornato all'ultima versione."
} else {
    Write-Host "Winget è già aggiornato all'ultima versione."
}

Write-Host "Verifica dei requisiti completata."
