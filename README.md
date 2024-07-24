# Guida alla Distribuzione Remota di Software su Client Windows e macOS tramite PowerShell

## Introduzione

Questa guida descrive i passaggi necessari per configurare e distribuire software su computer client Windows e macOS in rete tramite PowerShell e Apple Remote Desktop. L'obiettivo è centralizzare la distribuzione dei software utilizzando un dispositivo Apple su cui è installato Apple Remote Desktop e virtualizzare Windows per gestire i client Windows.

## Requisiti

### Hardware e Software

- **Mac con processore ARM**
  - Installare VMWare Fusion Pro (versione gratuita).
  - Installare Apple Remote Desktop per la distribuzione di pacchetti e script su macOS.
- **Macchina Virtuale con Windows 11 Pro per ARM**
  - Utilizzare VMWare Fusion Pro per la virtualizzazione.

### Note Importanti

- Le funzionalità di gestione remota di Windows non sono compatibili con macOS su processore ARM.
- È necessario installare Windows Pro su una macchina virtuale tramite VMWare Fusion Pro per raggiungere l'obiettivo.

## Macro Passaggi

1. **Configurazione dei computer client in rete.**
2. **Installazione e configurazione della macchina virtuale su VMWare Fusion.**
3. **Preparazione dei file necessari per la distribuzione su Windows.**
4. **Esecuzione degli script di verifica e distribuzione.**

