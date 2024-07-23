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
$latestWingetVersion = "(Get-AppxPackage Microsoft.DesktopAppInstaller).Version"

if ($wingetVersion -ne $latestWingetVersion) {
    Write-Host "Aggiornamento Winget all'ultima versione."
    irm bonguides.com/winget | iex
    Write-Host "Winget aggiornato all'ultima versione."
} else {
    Write-Host "Winget è già aggiornato all'ultima versione."
}

Write-Host "Verifica dei requisiti completata."
