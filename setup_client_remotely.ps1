# Abilitazione del servizio WinRM
try {
    winrm quickconfig -q
    winrm set winrm/config/service @{AllowUnencrypted="true"}
    winrm set winrm/config/service/auth @{Basic="true"}
    Write-Host "WinRM configurato correttamente su $env:COMPUTERNAME."
} catch {
    Write-Host "Errore durante la configurazione di WinRM su $env:COMPUTERNAME: $_"
}

# Verifica se Winget è installato
try {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        # Scarica e installa Winget
        Invoke-WebRequest -Uri "https://aka.ms/get-winget" -OutFile "$env:USERPROFILE\Downloads\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle"
        Add-AppxPackage -Path "$env:USERPROFILE\Downloads\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle"
        Write-Host "Winget installato correttamente su $env:COMPUTERNAME."
    } else {
        Write-Host "Winget è già installato su $env:COMPUTERNAME."
    }
} catch {
    Write-Host "Errore durante l'installazione di Winget su $env:COMPUTERNAME: $_"
}
