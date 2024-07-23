## Documentazione per la Distribuzione Remota di Software su PC Windows

### Introduzione

Questa documentazione descrive il processo per configurare e utilizzare PowerShell su un PC Windows di amministrazione per distribuire software su più PC Windows remoti. La procedura include la verifica dei requisiti sulla macchina di amministrazione e l'esecuzione effettiva dei comandi di distribuzione.

### Requisiti

#### Requisiti della Macchina di Amministrazione

- **Sistema Operativo**: Windows 10 o successivo
- **PowerShell**: Versione 5.1 o successiva
- **WSMan**: Deve essere installato e configurato
- **Winget**: Deve essere installato e aggiornato all'ultima versione

#### Requisiti dei PC Remoti

- **Sistema Operativo**: Windows 10 o successivo
- **WinRM**: Deve essere abilitato e configurato per accettare comandi remoti
- **Accesso Amministrativo**: Le credenziali amministrative devono essere disponibili per eseguire comandi remoti e installare software

### Procedura

#### 1. Verifica dei Requisiti sulla Macchina di Amministrazione

Prima di eseguire la distribuzione del software, è necessario assicurarsi che la macchina di amministrazione soddisfi tutti i requisiti.

1. **Installazione e Configurazione di WSMan**:
   - Verificare se il modulo WSMan è installato e configurarlo se necessario.
   - Utilizzare `Install-WindowsFeature` per installare il modulo WSMan, se non già presente.
   - Configurare `winrm quickconfig` e impostare gli host attendibili.

2. **Verifica e Aggiornamento di Winget**:
   - Verificare se Winget è installato e aggiornato all'ultima versione disponibile.
   - Se Winget non è aggiornato, scaricare e installare l'ultima versione utilizzando `Add-AppxPackage`.

#### 2. Esecuzione Effettiva dei Comandi di Distribuzione

Dopo aver verificato che la macchina di amministrazione soddisfi tutti i requisiti, eseguire lo script di distribuzione per installare il software sui PC remoti.

1. **Configurazione delle Credenziali**:
   - Richiedere all'utente di inserire le credenziali di amministratore per connettersi ai PC remoti.

2. **Lettura dei File di Elenco**:
   - Leggere l'elenco dei PC remoti e delle applicazioni da installare da file forniti dall'utente.
   - Verificare l'esistenza dei file di elenco e leggere il loro contenuto.

3. **Esecuzione dello Script sui PC Remoti**:
   - Connettersi a ciascun PC remoto utilizzando PowerShell Remoting (`Invoke-Command`).
   - Verificare e installare Winget se necessario sui PC remoti.
   - Installare le applicazioni specificate sui PC remoti utilizzando Winget.

### Avvio dello Script di Distribuzione

Per avviare il processo di distribuzione, eseguire lo script di esecuzione che include la verifica dei requisiti e l'esecuzione dei comandi di distribuzione.

1. Eseguire lo script di verifica dei requisiti (`verify_requirements.ps1`) sulla macchina di amministrazione.
2. Eseguire lo script di esecuzione effettiva dei comandi di distribuzione (`execute_deployment.ps1`).

### Conclusioni

Questo documento fornisce una guida dettagliata per configurare un ambiente di distribuzione remota del software utilizzando PowerShell su una macchina di amministrazione Windows. Include la verifica e l'aggiornamento di tutti i requisiti necessari e descrive i passaggi per eseguire la distribuzione remota del software sui PC Windows remoti. Per eseguire correttamente la procedura, è essenziale seguire tutti i passaggi descritti e garantire che tutti i requisiti siano soddisfatti.
