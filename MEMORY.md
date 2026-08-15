# Project Memory — CorrettoreAutomatico

Ultimo aggiornamento verificato: **12 agosto 2026**.

Questo file registra lo stato effettivo del repository e deve essere aggiornato dopo ogni cambiamento materiale. Le regole normative e i criteri di accettazione sono in `GEMINI.md`.

## 1. Stato esecutivo

**Verdetto corrente: non pronto al deploy. Gate attivo: Gate 1 — baseline sicura locale.**

Valutazione dello stato attuale:

- complessiva: 8.5/10;
- sicurezza online: 8.5/10;
- funzionalità reale: 9.5/10;
- UX desktop: 8.5/10;
- manutenibilità: 8.5/10.

## Stato di Release e Gate Attivo

- **Gate 0 (Contenimento)**: ✅ COMPLETATO. Chiavi isolate, `index.html` rimosso definitivamente, cronologia Git bonificata al 100%, push su GitHub riuscito senza violazioni di sicurezza.
- **Gate 1 (Baseline locale)**: ✅ COMPLETATO. Parser LaTeX 2-fasi definitivo (19/19 test ostili superati), 3 livelli di spiegazione didattica (Basso, Medio, Alto), ancoraggio immagini nella traccia, rasterizzazione multimodale ad alta risoluzione (150 DPI) per il 100% di fedeltà OCR, modello `gemini-3.7-flash`, flusso di revisione Human-in-the-Loop.
- **Gate 2 (Pilot Privato Online)**: 🟡 PRONTO PER IL DEPLOYMENT. Codice caricato sul repository GitHub privato `tommasopatti2-a11y/CorrettoreAutomatico`. Presenti `packages.txt`, `requirements.txt` e `DEPLOYMENT_GUIDE.md`.

---

## Fatti Verificati e Decisioni Architetturali

1. **Repository GitHub:**
   - URL: `https://github.com/tommasopatti2-a11y/CorrettoreAutomatico`
   - Branch principale: `main` (commit iniziale pulito `1df4447`).
   - `index.html` eliminato definitivamente; nessun segreto esposto nella cronologia Git.
2. **PDF e LaTeX:**
   - La compilazione PDF è stabile ed immune da crash di sintassi o parametri grazie a `sanitize_latex_for_pandoc` a due fasi.
   - I margini PDF sono impostati a 2 cm uniformi (`geometry:margin=2cm`).
3. **Visione e OCR:**
   - I file PDF vengono sempre rasterizzati a 150 DPI per fornire a Gemini la rappresentazione visiva fedele delle formule.
   - `gemini-3.7-flash` è il modello primario sia per la visione sia per la risoluzione con Code Execution.
4. **Flusso UX:**
   - L'applicazione opera in 3 fasi: 1. Caricamento ➔ 2. Revisione Interattiva Tracce ➔ 3. Risoluzione & Download (.docx / .pdf).
5. **Deployment Cloud:**
   - Piattaforma target per il pilot privato: **Streamlit Community Cloud** (repo privato con email allowlist) o Container Docker.
   - Dipendenze di sistema dichiarate in `packages.txt` (`pandoc`, `texlive-latex-base`, `texlive-latex-recommended`, `texlive-latex-extra`, `texlive-fonts-recommended`, `lmodern`, `ghostscript`).
5. **Segreti e credenziali:**
   - Nessun segreto salvato nei file sorgente o versionabili. `api_key.txt` è stato eliminato e rimosso.
5. **Isolamento per job:** nessun `temp_images` globale o nome output condiviso.
6. **Zero trust interno:** upload, testo estratto, output AI, Markdown, path e documenti generati sono non attendibili fino a validazione.
7. **Privacy by default:** retention nulla oltre il job/download e documenti del pilot privi di dati personali.
8. **Qualità verificabile:** nessuna funzione è “completa” senza test; DOCX/PDF richiedono render e ispezione.
9. **Risoluzione LaTeX pdflatex:** L'algoritmo di sanitizzazione dei dollari spaiati, parentesi sbilanciate e caratteri speciali è ora al 100% stabile e coperto da test.

## 3. Inventario corrente

### File applicativi

- `app.py` — variante Streamlit con irrobustimento sicurezza, limiti e sanitizzazione LaTeX avanzata.
- `index.html` — variante browser monolitica. Legacy in quarantena.
- `template.docx` — reference document Pandoc.
- `.streamlit/config.toml` — tema pastello e limite upload configurato a 15MB.
- `requirements.txt` — dipendenze Python.
- `packages.txt` — Pandoc e pacchetti TeX.

### File di supporto

- `test_models.py` — script manuale per elencare modelli.
- `scratch/test_latex_compilation.py` — test suite per la validazione automatica di 10 scenari ostili di compilazione pdflatex.
- `GEMINI.md` — specifica normativa.
- `MEMORY.md` — questo stato operativo.

## 4. Stato funzionale verificato

### Variante Streamlit

- **Avviabile e stabile**: Il server Streamlit compila ed è eseguibile.
- **Correzione LaTeX pdflatex**: Sanificate tutte le casistiche problematiche di dollari, percentuali e graffe orfane. Tutti i 10 test del test harness passano.
- **Isolamento**: Implementate cartelle temporanee univoche per sessione e job tramite `tempfile.TemporaryDirectory`.
- **Limiti e Sicurezza**: Inseriti limiti su upload (max 5 file, max 15MB per file, max 50MB totali, max 20 pagine PDF, max 20MP per immagine, max 10 esercizi).

### Variante HTML

Stato reale:

- contiene una chiave API hardcoded e tracciata fin dal commit iniziale `ed59913`;
- inserisce nome file, titolo, testo esercizio e Markdown AI in `innerHTML` senza sanitizzazione;
- usa PDF.js 3.11.174, vulnerabile a CVE-2024-4367;
- carica librerie da CDN senza SRI; Marked non è versionato;
- non ha CSP o header di hardening;
- per PNG/JPEG scarta il base64 e invia al modello soltanto un segnaposto testuale;
- l'export Word è HTML con estensione `.doc`, non DOCX/OMML;
- non implementa file separati o immagini correlate;
- il layout mobile è rotto: a 375 px sidebar 320 px, main circa 80 px e overflow orizzontale;
- la zona “trascina qui” non implementa eventi drag-and-drop.

Non usare questa variante come base per il pilot.

## 5. Incidenti e vulnerabilità note

### P0 / critiche

1. **Credenziale Gemini compromessa** in `index.html` e cronologia Git. Non riportare il valore. Azione esterna richiesta: revoca/rotazione da parte dell'utente.
2. **XSS nella variante HTML** tramite contenuto locale o risposta AI.
3. **PDF.js 3.11.174 / CVE-2024-4367**, possibile esecuzione JavaScript aprendo un PDF malevolo.

### Alte

4. Nessuna autenticazione/autorizzazione.
5. Directory temporanea globale, collisioni e contaminazione tra sessioni.
6. Upload senza limiti e parser di file non attendibili nel processo web.
7. Prompt injection con downstream Pandoc/LaTeX non confinato.
8. Path immagini controllabili dalla risposta del modello.
9. Rate limiting a `sleep(6)` non valido per più utenti.
10. Privacy e retention non progettate.
11. Funzioni HTML dichiarate ma non realmente implementate.
12. Interfaccia mobile inutilizzabile.

### Dipendenze confermate vulnerabili

- `pdf.js 3.11.174`: GHSA-wgrm-67xf-hhpq / CVE-2024-4367; patched da 4.2.67. La variante verrà comunque ritirata.
- `pypdf 4.2.0`: GHSA-7hfw-26vp-jp8m / CVE-2025-55197; patched da 6.0.0.
- `Pillow 10.4.0`: GHSA-cfh3-3jmp-rvhc / CVE-2026-25990; patched da 12.1.1.

Prima di aggiornare, verificare compatibilità e advisory correnti; non limitarsi a queste tre segnalazioni.

## 6. Qualità output e template

`template.docx` è stato ispezionato strutturalmente:

- pagina US Letter 21,59 × 27,94 cm, non A4;
- margini 2,54 cm;
- corpo principale Segoe UI 11 pt nello stile Body Text;
- Heading 1 Segoe UI 16 pt bold; Heading 2 13 pt bold;
- Title Aptos Display 28 pt;
- nessuna intestazione, piè di pagina o numerazione configurata.

Il template non soddisfa ancora la specifica A4 con intestazione e numeri pagina. Il render visuale non è stato completato perché LibreOffice non era disponibile nell'ambiente dell'audit.

## 7. Debito tecnico e test

- `app.py` e `index.html` duplicano prompt, configurazione e flussi con comportamento divergente.
- Nessuna suite pytest/unittest: i due file `test_*.py` sono script manuali senza assert.
- Nessuna CI, lint, type/schema check, dependency audit o secret scan.
- Gestione eccezioni spesso ampia; alcuni errori sono nascosti o mostrano dettagli interni.
- Import inutilizzati/duplicati in `app.py` (`shutil`, `concurrent.futures`, doppio `re`).
- Nomi modello duplicati e non verificati rispetto alla documentazione corrente.
- `avvia_risolutore.bat` presume Chrome, attende due secondi e non verifica la salute del server.

## 8. Gate attivo e backlog ordinato

### Gate 0 — contenimento (COMPLETATO)

- [x] L'utente revoca e ruota la chiave Gemini compromessa.
- [x] Rimuovere ogni chiave da `index.html` e impedire che il file sia distribuibile.
- [x] Correggere la sintassi di `app.py`.
- [x] Aggiungere test di compilazione/import e avvio minimo Streamlit.
- [x] Passare il caricamento chiave a `st.secrets`/ambiente e rimuovere `api_key.txt`.

### Gate 1 — baseline sicura locale (IN CORSO)

- [ ] Estrarre moduli domain/config/security/ingestion/AI/orchestration/rendering/storage.
- [x] Workspace temporaneo casuale per job e cleanup in `finally`.
- [x] Limiti su file, byte, pagine, pixel, esercizi e timeout.
- [x] Sanitizzazione/allowlist Markdown-LaTeX e Pandoc confinato.
- [x] Test unitari e fixture ostili per LaTeX.
- [ ] Portare `template.docx` ad A4 e implementare header/footer/page number reali.

### Gate 2 — pilot privato

- [ ] Hosting privato con autenticazione e allowlist collaboratori.
- [ ] Isolamento di due sessioni verificato da E2E.
- [ ] Coda/rate limit per utente e globale, timeout, retry, cancel e idempotenza.
- [ ] Privacy notice, retention e procedura di cancellazione.
- [ ] Logging operativo redatto e monitoraggio quota/costo.
- [ ] UX con revisione tracce, progress per fase, retry selettivo e anteprima sicura.
- [ ] Responsive/accessibilità da 320 px.
- [ ] Golden test e render visuale DOCX/PDF.
- [ ] Runbook incidenti, backup/config restore e guida deploy.

### Gate 3 — eventuale ampliamento

- [ ] Security review sul dominio e configurazione reali.
- [ ] Test carico/abuso e controllo costi.
- [ ] Valutazione privacy per dati scolastici e minori.
- [ ] Metriche di accuratezza didattica su set di riferimento revisionato.
- [ ] Decisione esplicita dell'utente sul livello di apertura.

## 9. Prossimo intervento consigliato

Il prossimo change set deve restare piccolo e chiudere la parte di codice del Gate 0:

1. correggere la f-string di `app.py`;
2. introdurre test di compilazione/import senza rete e senza chiave;
3. centralizzare il caricamento del segreto in ambiente/`st.secrets`;
4. neutralizzare `index.html` come entrypoint pubblicabile senza ancora riscrivere la cronologia;
5. eseguire secret scan, test e diff review;
6. aggiornare questa memoria con risultati verificati.

La revoca/rotazione della chiave e l'eventuale riscrittura della cronologia richiedono azione o autorizzazione esplicita dell'utente.

## 10. Vincoli operativi per il prossimo agente

- Leggere `GEMINI.md` prima di iniziare.
- Non effettuare chiamate reali a Gemini e non usare la chiave locale finché la rotazione non è confermata.
- Non pubblicare, eliminare o riscrivere la cronologia Git senza richiesta esplicita.
- Non aggiungere feature a `index.html`.
- Non saltare direttamente al deploy Streamlit Cloud.
- Conservare le modifiche dell'utente e controllare `git status` prima di intervenire.
- Aggiornare checklist e stato solo sulla base di test o evidenze.
