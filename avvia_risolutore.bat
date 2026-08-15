@echo off
title Risolutore di Matematica e Fisica - Launcher
color 0B
echo.
echo    ====================================================================
echo    =                                                                  =
echo    =               RISOLUTORE DI MATEMATICA E FISICA                  =
echo    =                                                                  =
echo    ====================================================================
echo.
echo    [ INFO ] Preparazione dell'ambiente in corso...
echo.

cd /d "%~dp0"

if not exist ".venv" (
    color 0C
    echo    [ ERRORE CRITICO ] Ambiente virtuale '.venv' non trovato!
    echo    Assicurati di aver completato l'installazione del progetto.
    echo.
    pause
    exit /b
)

echo    [ OK ] Ambiente virtuale rilevato. Attivazione in corso...
call .venv\Scripts\activate.bat

echo    [ OK ] Avvio del motore Streamlit...
:: Avviamo streamlit in background
start /b streamlit run app.py --server.headless true

echo    [ INFO ] Attesa del caricamento dell'interfaccia (2 secondi)...
timeout /t 2 /nobreak >nul

echo    [ OK ] Apertura dell'applicazione nel browser...
:: Forziamo l'apertura esplicita dell'indirizzo locale con Google Chrome
start chrome http://localhost:8501

echo.
echo    ====================================================================
echo    Applicazione in esecuzione corretta. 
echo    ATTENZIONE: Lasciare aperta questa finestra per mantenere attivo
echo    il server locale. Chiudere per terminare l'applicazione.
echo    ====================================================================
echo.
pause
