# Esegui lo script di verifica dei requisiti
& .\verify_requirements.ps1

# Configurazione delle credenziali
$username = Read-Host "Inserisci il nome utente amministratore"
$password = Read-Host "Inserisci la password amministratore" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential ($username, $password)

# Prompt per i file di elenco
$clientsFile = Read-Host "Inserisci il percorso del file con l'elenco dei computer (ad esempio, C:\path\to\clients.txt)"
$applicationsFile = Read-Host "Inserisci il percorso del file con l'elenco delle applicazioni (ad esempio, C:\path\to\applications.txt)"

# File di log
$logFile = "C:\path\to\logfile.txt"
"Log iniziale - $(Get-Date)" | Out-File -FilePath $logFile -Append

# Lettura dell'elenco dei client
if (Test-Path -Path $clientsFile) {
    $clients = Get-Content -Path $clientsFile
} else {
    "Il file con l'elenco dei computer non è stato trovato." | Out-File -FilePath $logFile -Append
    exit 1
}

# Lettura dell'elenco delle applicazioni
if (Test-Path -Path $applicationsFile) {
    $applications = Get-Content -Path $applicationsFile
} else {
    "Il file con l'elenco delle applicazioni non è stato trovato." | Out-File -FilePath $logFile -Append
    exit 1
}

# Script da eseguire su ciascun client
$scriptBlock = {
    param ($applications, $credential, $logFile)

    # Verifica se Winget è installato
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        try {
            # Scarica e installa Winget
            Invoke-WebRequest -Uri "https://aka.ms/get-winget" -OutFile "$env:USERPROFILE\Downloads\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle"
            Add-AppxPackage -Path "$env:USERPROFILE\Downloads\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle"
            "Winget installato correttamente su $env:COMPUTERNAME - $(Get-Date)" | Out-File -FilePath $logFile -Append
        } catch {
            "Errore durante l'installazione di Winget su $env:COMPUTERNAME - $(Get-Date): $_" | Out-File -FilePath $logFile -Append
        }
    }

    # Verifica l'installazione di Winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        # Installazione delle applicazioni specificate
        foreach ($app in $applications) {
            try {
                winget install -e --id $app --accept-package-agreements --accept-source-agreements
                "Applicazione $app installata su $env:COMPUTERNAME - $(Get-Date)" | Out-File -FilePath $logFile -Append
            } catch {
                "Errore durante l'installazione dell'applicazione $app su $env:COMPUTERNAME - $(Get-Date): $_" | Out-File -FilePath $logFile -Append
            }
        }
    } else {
        "Winget non è stato installato correttamente su $env:COMPUTERNAME - $(Get-Date)" | Out-File -FilePath $logFile -Append
    }
}

# Connessione a ciascun client e esecuzione dello script
foreach ($client in $clients) {
    try {
        Invoke-Command -ComputerName $client -ScriptBlock $scriptBlock -ArgumentList $applications, $credential, $logFile -Credential $credential
    } catch {
        "Errore durante la connessione a $client - $(Get-Date): $_" | Out-File -FilePath $logFile -Append
    }
}

"Script completato - $(Get-Date)" | Out-File -FilePath $logFile -Append
