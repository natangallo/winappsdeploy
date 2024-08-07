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

# Verifica e creazione della directory dei log
$fileRoot = "C:" # "\\serveriporname" può esssere modificato in caso di cartella di rete esterna.
$logsDirectory = "$fileRoot\logs"
if (-not (Test-Path -Path $logsDirectory)) {
    New-Item -Path $logsDirectory -ItemType Directory
}

# File di log sul computer di amministrazione
$adminLogFile = "$logsDirectory\admin_logfile.txt"
"" | Out-File -FilePath $adminLogFile -Append
"Log iniziale - $(Get-Date)" | Out-File -FilePath $adminLogFile -Append

# Lettura dell'elenco dei client
$clientsFile = "$fileRoot\clients.txt"
$appsFile = "$fileRoot\apps.txt"

# Ottenere l'indirizzo IP del computer di amministrazione
# Verrà utilizzato per trasferire i log di installazione dei client
# Se si è valutato di spostare i log su un file server esterno, considerare di attivare la seguente variabile e commentare la seccessiva
# $adminIpAddress = "\\$fileRoot"
$remoteIPAddress = (Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -ne 'Loopback' } | Select-Object -First 1).IPAddress
$adminIpAddress = "\\$remoteIPAddress"

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

$scriptBlock = {
    param ($apps, $adminIpAddress, $credential)
    
    # Verifica e creazione della directory dei log locali
    $remoteLogFile = "C:\logfile.txt"
    "" | Out-File -FilePath $remoteLogFile -Append
    "Log iniziale sul client remoto - $(Get-Date)" | Out-File -FilePath $remoteLogFile -Append

    foreach ($app in $apps) {
        try {
            $appInfo = winget list | Where-Object { $_ -match $app }
            if ($appInfo) {
                # Se l'applicazione è già installata, aggiorna all'ultima versione
                winget upgrade --id $app --silent --accept-package-agreements --accept-source-agreements
                "$app aggiornato correttamente su $env:COMPUTERNAME - $(Get-Date)" | Out-File -FilePath $remoteLogFile -Append
            } else {
                # Se l'applicazione non è installata, procedi con l'installazione
                winget install --id $app --silent --accept-package-agreements --accept-source-agreements
                "$app installato correttamente su $env:COMPUTERNAME - $(Get-Date)" | Out-File -FilePath $remoteLogFile -Append
            }
        } catch {
            "Errore durante l'installazione/aggiornamento di $app su $env:COMPUTERNAME - $(Get-Date): $_" | Out-File -FilePath $remoteLogFile -Append
        }
    }

    # Trasferimento del file di log al computer di amministrazione
    $adminLogsPath = "$adminIpAddress\logs\"
    try {
        New-PSDrive -Name "Z" -PSProvider FileSystem -Root $adminLogsPath -Credential $credential -ErrorAction Stop
        Copy-Item -Path $remoteLogFile -Destination Z:\${env:COMPUTERNAME}_logfile.txt
        "Log trasferito correttamente a $adminLogsPath - $(Get-Date)" | Out-File -FilePath $remoteLogFile -Append
    } catch {
        "Errore durante il trasferimento del log a $adminLogsPath - $(Get-Date): $_" | Out-File -FilePath $remoteLogFile -Append
    }
}

# Verifica dei requisiti sui client remoti
$parametersVerify = @{
    ComputerName          = $clients
    InDisconnectedSession = $true
    FilePath              = "$fileRoot\verify_requirements.ps1"
    Credential            = $credential
}
Invoke-Command @parametersVerify

# Connessione a ciascun client e esecuzione dello script di setup e installazione/aggiornamento
$parametersExecute = @{
    ComputerName          = $clients
    ScriptBlock           = $scriptBlock
    ArgumentList          = $apps, $adminIpAddress, $credential
    Credential            = $credential
}
$results = Invoke-Command @parametersExecute

"Script di distribuzione completato - $(Get-Date)" | Out-File -FilePath $adminLogFile -Append

