# Configurazione della rete come privata
try {
    $net = Get-NetConnectionProfile
    Set-NetConnectionProfile -Name $net.Name -NetworkCategory Private
    Write-Host "La connessione di rete è stata configurata come privata su $env:COMPUTERNAME."
} catch {
    Write-Host "Errore durante la configurazione della rete come privata su $env:COMPUTERNAME: $_"
}

# Abilitazione del servizio WinRM
try {
    winrm quickconfig -q
    #winrm set winrm/config/service @{AllowUnencrypted="true"}
    #winrm set winrm/config/service/auth @{Basic="true"}
    Write-Host "WinRM configurato correttamente su $env:COMPUTERNAME."
} catch {
    Write-Host "Errore durante la configurazione di WinRM su $env:COMPUTERNAME: $_"
}

# Verifica se Winget è installato
try {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        # Scarica e installa Winget
        Invoke-WebRequest -Uri "https://aka.ms/get-winget" -OutFile "$env:USERPROFILE\Downloads\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Add-AppxPackage -Path "$env:USERPROFILE\Downloads\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Write-Host "Winget installato correttamente su $env:COMPUTERNAME."
    } else {
        # Aggiornamento di Winget all'ultima versione
        irm bonguides.com/winget | iex
        Write-Host "Winget aggiornato correttamente su $env:COMPUTERNAME."
        winget -v
    }
} catch {
    Write-Host "Errore durante l'installazione/aggiornamento di Winget su $env:COMPUTERNAME: $_"
}
