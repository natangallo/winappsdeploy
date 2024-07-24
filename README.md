# README: Guida alla Distribuzione Remota di Software su Client Windows e macOS tramite PowerShell

## Introduzione

Questa guida descrive i passaggi necessari per configurare e distribuire software su computer client Windows e macOS in rete tramite PowerShell e Apple Remote Desktop. L'obiettivo è centralizzare la distribuzione dei software utilizzando un dispositivo Apple su cui è installato Apple Remote Desktop e virtualizzare Windows per gestire i client Windows.

## Requisiti

### Hardware e Software

- **Mac con processore ARM**
  - Installare VMWare Fusion Pro (versione gratuita).
  - Installare Apple Remote Desktop per la distribuzione di pacchetti e script su macOS.
- **Macchina Virtuale con Windows 11 Pro per ARM**
  - Utilizzare VMWare Fusion Pro per la virtualizzazione.

### Configurazione dei Client

- **Client Windows**
  - Verificare le credenziali di amministratore locali univoche.
  - Scaricare e applicare gli aggiornamenti di sistema.
  - Trasferire lo script `setup_client.ps1` su ciascun client.
  - Aprire PowerShell in modalità amministratore.
  - Eseguire il comando `Set-ExecutionPolicy RemoteSigned -Force`.
  - Lanciare lo script di PowerShell `setup_client.ps1`.
  - Al termine dell'esecuzione dello script, eseguire il comando `Set-ExecutionPolicy Restricted -Force`.

### Note Importanti

- Le funzionalità di gestione remota di Windows non sono compatibili con macOS su processore ARM.
- È necessario installare Windows Pro su una macchina virtuale tramite VMWare Fusion Pro per raggiungere l'obiettivo.

## Macro Passaggi

1. **Configurazione dei computer client in rete.**
2. **Installazione e configurazione della macchina virtuale su VMWare Fusion.**
3. **Preparazione dei file necessari per la distribuzione su Windows.**
4. **Esecuzione degli script di verifica e distribuzione.**

## Dettagli dei Passaggi

### 1. Configurazione dei Computer Client in Rete

1. Verificare le credenziali di amministratore locali univoche.
2. Scaricare e applicare gli aggiornamenti di sistema.
3. Trasferire lo script `setup_client.ps1` su ciascun client.
4. Aprire PowerShell in modalità amministratore.
5. Eseguire il comando `Set-ExecutionPolicy RemoteSigned -Force`.
6. Lanciare lo script di PowerShell `setup_client.ps1`.
7. Al termine dell'esecuzione dello script, eseguire il comando `Set-ExecutionPolicy Restricted -Force`.

### 2. Installazione e Configurazione della Macchina Virtuale su VMWare Fusion

1. Installare VMWare Fusion Pro (versione gratuita) su macOS.
2. Creare una nuova macchina virtuale con Windows 11 per ARM.
3. Impostare la RAM e il processore in modo adeguato.
4. Durante la procedura di setup, disattivare la scheda di rete.
5. Seguire la procedura di installazione di Windows 11:
   - La procedura di attivazione richiede un account Microsoft.
   - Premere `Shift + F10` per aprire il prompt dei comandi.
   - Eseguire il comando `oobe\bypassnro`. La macchina si riavvierà.
   - Al riavvio, continuare il setup senza connessione Internet e con funzionalità limitate.
6. Installare VMWare Tools una volta concluso il setup e riavviare.
7. Scaricare e applicare gli aggiornamenti di sistema.

### 3. Preparazione dei File Necessari per la Distribuzione

Sul computer di amministrazione (la macchina virtuale), preparare i seguenti file:

1. **Script di verifica requisiti ([verify_requirements.ps1](https://github.com/natangallo/winappsdeploy/blob/6503819a40e62ada21595b0355952d64796a29fb/setup_client_remotely.ps1))**
2. **Script di produzione ([execute_deployment.ps1](https://github.com/natangallo/winappsdeploy/blob/da751a427390f24cdce5a15de72c21307d75bc54/execute_deployment.ps1))**
3. **Script di verifica requisiti client ([verify_requirements.ps1](https://github.com/natangallo/winappsdeploy/blob/6503819a40e62ada21595b0355952d64796a29fb/verify_requirements.ps1))**
4. **Elenco degli IP/nomi dei computer ([clients.txt](#))**
3. **Elenco dei software ([apps.txt](#))**

### 4. Esecuzione degli Script di Verifica e Distribuzione

1. Aprire PowerShell in modalità amministratore.
2. Eseguire il comando `Set-ExecutionPolicy RemoteSigned -Force`.
3. Lanciare lo script di verifica dei requisiti (`verify_requirements.ps1`):

   ```powershell
   .\verify_requirements.ps1
   ```

4. Dopo aver lanciato lo script di verifica dei requisiti, eseguire il comando di ricerca dell'ID delle app da installare:

   ```powershell
   winget search <nome_dell_app>
   ```

5. Prendere nota degli ID delle app da installare e inserirli nel file `apps.txt`.
6. Compilare il file `clients.txt` con l'elenco degli IP dei PC client sui quali verranno installati gli applicativi.
7. Lanciare lo script di installazione e distribuzione (`execute_deployment.ps1`):

   ```powershell
   .\execute_deployment.ps1
   ```

## Ulteriori Considerazioni

### Prevedere una VM di Testing

Si consiglia di installare una VM con Windows come sistema di testing prima della distribuzione massiva per verificare che tutti gli script funzionino correttamente e che non ci siano problemi di compatibilità o errori.

### Configurazione della Cartella di Log

Assicurarsi che la cartella di log sul computer di amministrazione sia condivisa e accessibile dai client remoti per il trasferimento dei file di log post-installazione.

### Verifica delle Credenziali

Verificare che tutte le credenziali di amministratore utilizzate sui client siano corrette e abbiano i permessi necessari per eseguire gli script e le installazioni.

---

Per maggiori dettagli e per scaricare gli script, visitare i seguenti link:

- [verify_requirements.ps1](#)
- [clients.txt](#)
- [apps.txt](#)
- [execute_deployment.ps1](#)

Pubblicato su GitHub alla repository [Deployment-Scripts](#).
