# Guida al Deploy Online — CorrettoreAutomatico (Pilot Privato)

Questa guida illustra la procedura passo-passo per pubblicare e rendere accessibile online l'applicazione **CorrettoreAutomatico** per un gruppo autorizzato di collaboratori (Pilot Privato).

---

## 1. Architettura di Deployment (Streamlit Community Cloud)

* **Repository:** GitHub (Privato)
* **Entrypoint dell'applicazione:** `app.py`
* **Dipendenze Python:** `requirements.txt`
* **Dipendenze Linux/Sistema (LaTeX + Pandoc):** `packages.txt`
* **Gestione Segreti:** *Streamlit Secrets Management* (Crittografato a riposo)
* **Accesso e Sicurezza:** Google OAuth con **Email Allowlist** (Accesso consentito solo agli indirizzi email specificati)

---

## 2. File di Configurazione Presenti nel Repository

1. **[`packages.txt`](file:///c:/Users/User/Documents/CorrettoreAutomatico/packages.txt)**:  
   Installa automaticamente sul container Linux Debian di Streamlit Cloud i pacchetti necessari alla compilazione dei PDF con equazioni e figure:
   ```text
   pandoc
   texlive-latex-base
   texlive-latex-recommended
   texlive-latex-extra
   texlive-fonts-recommended
   lmodern
   ghostscript
   ```
2. **[`requirements.txt`](file:///c:/Users/User/Documents/CorrettoreAutomatico/requirements.txt)**:  
   Dipendenze Python auditate e aggiornate (`streamlit`, `google-genai`, `pymupdf`, `pypdf>=6.0`, `pillow`, `pypandoc`, `python-docx`, `toml`).
3. **[`.gitignore`](file:///c:/Users/User/Documents/CorrettoreAutomatico/.gitignore)**:  
   Protegge e blocca l'inclusione di qualsiasi chiave o credenziale locale (`.streamlit/secrets.toml`, `.env`, `api_key.txt`).

---

## 3. Procedura Passo-Passo per la Messa Online

### Passo 1: Creazione del Repository GitHub Privato
1. Accedi a [github.com](https://github.com) e crea un **nuovo repository** (imposta la visibilità su **Private**).
2. Nel tuo terminale locale, collega il repository ed esegui il push:
   ```bash
   git add .
   git commit -m "Preparazione deploy per pilot privato su Streamlit Cloud"
   git branch -M main
   git remote add origin https://github.com/<tuo-utente>/<nome-repo>.git
   git push -u origin main
   ```

### Passo 2: Creazione dell'App su Streamlit Community Cloud
1. Vai su [share.streamlit.io](https://share.streamlit.io) ed effettua il login con il tuo account GitHub / Google.
2. Clicca su **"New app"** (o "Create app").
3. Seleziona il tuo repository privato, il branch (`main`) e imposta come **Main file path**:
   ```text
   app.py
   ```
4. Clicca su **"Advanced settings..."** prima del deploy.

### Passo 3: Configurazione della Chiave Segreta (`GEMINI_API_KEY`)
Nella sezione **Secrets** delle impostazioni avanzate, inserisci la nuova chiave API generata da Google AI Studio:
```toml
GEMINI_API_KEY = "AIzaSy..."
```
*(Non inserire la chiave legacy revocata/compromessa).*

### Passo 4: Impostazione dell'Accesso Privato (Collaborator Allowlist)
1. Nelle impostazioni dell'app su Streamlit Cloud, vai su **Settings ➔ Sharing / Privacy**.
2. Imposta l'app come **"Private"**.
3. Aggiungi gli indirizzi email dei colleghi/collaboratori autorizzati a partecipare al test del pilot.
4. Solo gli utenti loggati con quelle email potranno aprire e utilizzare l'applicazione.

---

## 4. Checklist di Verifica Post-Deploy (Smoke Test)

Dopo che l'app remota ha completato il build (richiede circa 2-3 minuti per la prima installazione dei pacchetti LaTeX):

- [ ] L'applicazione si avvia correttamente e mostra il titolo `📐 Risolutore di Matematica & Fisica`.
- [ ] L'accesso da un browser non autenticato viene bloccato (richiesta di login Google).
- [ ] Caricamento di un documento di prova (es. PDF 2 pagine).
- [ ] Riconoscimento delle tracce nella schermata di *Revisione Human-in-the-Loop*.
- [ ] Risoluzione e generazione del download finale sia in `.docx` che in `.pdf`.
