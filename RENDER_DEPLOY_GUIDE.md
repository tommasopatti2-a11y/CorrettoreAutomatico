# Guida al Deploy su Render.com (Docker Web Service)

Questa guida illustra la procedura per pubblicare **CorrettoreAutomatico** su [Render.com](https://render.com) tramite container Docker, senza alcun watermark o logo di terze parti.

---

## 1. Perché Render?
* **Zero Watermark:** Nessun nastro *"Hosted with Streamlit"*, nessun avatar e nessun banner esterno.
* **Ambiente Dedicato:** TeX Live e Pandoc sono già integrati nell'immagine Linux Debian (`Dockerfile`).
* **URL Diretto & HTTPS:** Ottieni un dominio sicuro del tipo `https://correttore-automatico.onrender.com`.

---

## 2. Procedura Passo-Passo per il Deploy su Render

### Passo 1: Iscrizione / Accesso a Render
1. Vai su [dashboard.render.com](https://dashboard.render.com).
2. Effettua l'accesso cliccando su **"Sign in with GitHub"**.

### Passo 2: Creazione del Web Service
1. Nella Dashboard di Render, clicca sul pulsante in alto a destra **"New +"** e seleziona **"Web Service"**.
2. Seleziona **"Build and deploy from a Git repository"** e clicca su **Next**.
3. Cerca e seleziona il tuo repository: `tommasopatti2-a11y/CorrettoreAutomatico` (se non compare nell'elenco, clicca su *"Configure access on GitHub"* per autorizzare Render a leggere il repository privato).
4. Clicca su **Connect**.

### Passo 3: Configurazione del Servizio
1. **Name:** Inserisci un nome (es. `correttore-automatico`).
2. **Region:** Seleziona `Frankfurt (EU Central)` (o la regione più vicina).
3. **Branch:** `main`.
4. **Runtime:** Seleziona **`Docker`** (Render rileverà automaticamente il `Dockerfile` presente nella radice del progetto).
5. **Instance Type:** Seleziona **Free** (oppure *Starter* per mantenere il server sempre attivo senza sleep di inattività).

### Passo 4: Inserimento della Chiave API Gemini
1. Scorri in basso fino alla sezione **"Environment Variables"** (o clicca su *Advanced*).
2. Clicca su **"Add Environment Variable"**:
   * **Key:** `GEMINI_API_KEY`
   * **Value:** *(Incolla la tua chiave API di Gemini ottenuta da Google AI Studio)*
3. Clicca sul pulsante **"Create Web Service"** in fondo alla pagina.

---

## 3. Build & Pubblicazione
* Render avvierà automaticamente il download dell'immagine Docker, l'installazione di Pandoc/TeX Live e l'avvio di Streamlit.
* Il primo build richiede circa **3-4 minuti**.
* Non appena lo stato passa a **"Live"** con un pallino verde, clicca sul link in alto a sinistra (es. `https://correttore-automatico.onrender.com`) per aprire la tua applicazione pulita e autonoma al 100%!
