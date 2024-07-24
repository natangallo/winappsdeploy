#########################################################################################################
#
# Script studiato e creato da Natan Gallo
# v00 Luglio 2024
#
# Rucordarsi di verificare le restrizione di esecuzione degli script poershell e di
# eseguire il comando "set-executionpolicy remotesigned -Force".
#########################################################################################################
#
#########################################################################################################
# Variabili di Sistema che possono essere modificate a seconda del contesto e necessità
#########################################################################################################
#
# Configurazione delle credenziali
$username = Read-Host "Inserisci il nome utente amministratore"
$password = Read-Host "Inserisci la password amministratore" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential ($username, $password)

# Ottenere l'indirizzo IP del computer di amministrazione
# Verrà utilizzato per trasferire i log di installazione dei client
# Se si è valutato di spostare i log su un file server esterno, considerare di attivare la seguente variabile e commentare la seccessiva
# Aggiornare quindi sia la variabile $remoteIPAddress, sia la variabile $fileRoot

# $remoteIPAddress = "\\$fileRoot"
$remoteIPAddress = (Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -ne 'Loopback' } | Select-Object -First 1).IPAddress
$adminIpAddress = "\\$remoteIPAddress"

# Verifica e creazione della directory dei log e software locali
$fileRoot = "C:" # "\\serveriporname" può esssere modificato in caso di cartella di rete esterna.
$logsDirectory = "$fileRoot\logs"
if (-not (Test-Path -Path $logsDirectory)) {
    New-Item -Path $logsDirectory -ItemType Directory
}

$msiDirectory = "$fileRoot\MSIFiles"
if (-not (Test-Path -Path $logsDirectory)) {
    New-Item -Path $logsDirectory -ItemType Directory
}
$rootFolder = "$adminIpAddress\MSIFiles"

# File di log sul computer di amministrazione
$adminLogFile = "$logsDirectory\admin_logfile.txt"
"" | Out-File -FilePath $adminLogFile -Append
"Log iniziale - $(Get-Date)" | Out-File -FilePath $adminLogFile -Append

# Lettura dell'elenco dei client
$clientsFile = "$fileRoot\clients.txt"
$appsFile = "$fileRoot\apps.txt"



if (Test-Path -Path $clientsFile) {
    $clients = Get-Content -Path $clientsFile
} else {
    "Il file con l'elenco dei computer non è stato trovato." | Out-File -FilePath $adminLogFile -Append
    exit 1
}

# Lettura dell'elenco delle applicazioni
if (Test-Path -Path $appsFile) {
    $apps = Get-Content -Path $appsFile
} else {
    "Il file con l'elenco delle applicazioni non è stato trovato." | Out-File -FilePath $adminLogFile -Append
    exit 1
}

#########################################################################################################
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#         ScriptBlock per configurare i client remoti e installare/aggiornare le applicazioni           #
#                     Da qui in avanti si consiglia di non modificare i dati                            #
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#########################################################################################################

# Funzione per l'installazione di applicazioni tramite Winget
$scriptBlockWinget = {
    param ($apps, $adminIpAddress, $credential)
    
    $remoteLogFile = "C:\logfile.txt"
    "Log iniziale sul client remoto - $(Get-Date)" | Out-File -FilePath $remoteLogFile -Append

    foreach ($app in $apps) {
        try {
            $appInfo = winget list | Where-Object { $_ -match $app }
            if ($appInfo) {
                winget upgrade --id $app --silent --accept-package-agreements --accept-source-agreements
                "$app aggiornato correttamente su $env:COMPUTERNAME - $(Get-Date)" | Out-File -FilePath $remoteLogFile -Append
            } else {
                winget install --id $app --silent --accept-package-agreements --accept-source-agreements
                "$app installato correttamente su $env:COMPUTERNAME - $(Get-Date)" | Out-File -FilePath $remoteLogFile -Append
            }
        } catch {
            "Errore durante l'installazione/aggiornamento di $app su $env:COMPUTERNAME - $(Get-Date): $_" | Out-File -FilePath $remoteLogFile -Append
        }
    }

    $adminLogsPath = "$adminIpAddress\logs\${env:COMPUTERNAME}_logfile.txt"
    try {
        Copy-Item -Path $remoteLogFile -Destination $adminLogsPath
        "Log trasferito correttamente a $adminLogsPath - $(Get-Date)" | Out-File -FilePath $remoteLogFile -Append
    } catch {
        "Errore durante il trasferimento del log a $adminLogsPath - $(Get-Date): $_" | Out-File -FilePath $remoteLogFile -Append
    }
}

# Funzione per l'installazione di file MSI
$scriptBlockMsi = {
    param ($apps, $adminIpAddress, $credential)
    
    $remoteLogFile = "C:\logfile.txt"
    "Log iniziale sul client remoto - $(Get-Date)" | Out-File -FilePath $remoteLogFile -Append

    foreach ($app in $apps) {
        try {
            $msiPath = Join-Path -Path $rootFolder -ChildPath $app
            if (Test-Path -Path $msiPath) {
                Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait
                "$app installato correttamente su $env:COMPUTERNAME - $(Get-Date)" | Out-File -FilePath $remoteLogFile -Append
            } else {
                "File MSI non trovato: $msiPath - $(Get-Date)" | Out-File -FilePath $remoteLogFile -Append
            }
        } catch {
            "Errore durante l'installazione di $app su $env:COMPUTERNAME - $(Get-Date): $_" | Out-File -FilePath $remoteLogFile -Append
        }
    }

    $adminLogsPath = "$adminIpAddress\logs\${env:COMPUTERNAME}_logfile.txt"
    try {
        Copy-Item -Path $remoteLogFile -Destination $adminLogsPath
        "Log trasferito correttamente a $adminLogsPath - $(Get-Date)" | Out-File -FilePath $remoteLogFile -Append
    } catch {
        "Errore durante il trasferimento del log a $adminLogsPath - $(Get-Date): $_" | Out-File -FilePath $remoteLogFile -Append
    }
}

# Richiesta della tipologia di installazione
$installType = Read-Host "Inserisci la tipologia di installazione (Winget/MSI)"

# Esecuzione delle installazioni in base alla tipologia
if ($installType -eq 'Winget') {
    $parametersExecute = @{
        ComputerName          = $clients
        ScriptBlock           = $scriptBlockWinget
        ArgumentList          = $apps, $adminIpAddress, $credential
        Credential            = $credential
    }
} elseif ($installType -eq 'MSI') {
    $parametersExecute = @{
        ComputerName          = $clients
        ScriptBlock           = $scriptBlockMsi
        ArgumentList          = $apps, $adminIpAddress, $credential
        Credential            = $credential
    }
} else {
    "Tipologia di installazione non valida. Esci." | Out-File -FilePath $adminLogFile -Append
    exit 1
}

# Esecuzione dello script
$results = Invoke-Command @parametersExecute

"Script di distribuzione completato - $(Get-Date)" | Out-File -FilePath $adminLogFile -Append
Set-ExecutionPolicy Restricted -Force
