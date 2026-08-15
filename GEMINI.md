# CorrettoreAutomatico — specifica normativa per coding agent

Questo file è la fonte di verità normativa del progetto. Ogni coding agent, incluso Antigravity, deve leggerlo integralmente insieme a `MEMORY.md` prima di analizzare, modificare, eseguire o distribuire il software.

- `GEMINI.md` stabilisce obiettivi, architettura, vincoli e criteri di accettazione.
- `MEMORY.md` descrive lo stato reale del repository, gli incidenti noti, le decisioni già prese e il prossimo lavoro autorizzato.
- In caso di conflitto, prevalgono nell'ordine: richiesta esplicita dell'utente, sicurezza e protezione dei dati, questo file, `MEMORY.md`, commenti nel codice.
- Non descrivere come completata una funzione che non sia stata verificata con test proporzionati al rischio.

## 1. Missione e perimetro

Costruire un'applicazione server-side privata che:

1. riceva PDF, DOCX, TXT, PNG e JPEG contenenti fino a 10 esercizi di matematica o fisica;
2. estragga testo e immagini, inclusi documenti scansionati o scritti a mano;
3. consenta all'utente di verificare e correggere le tracce riconosciute;
4. identifichi e risolva gli esercizi separatamente tramite Gemini;
5. generi output `.docx` con equazioni Word native modificabili e `.pdf` di qualità;
6. possa essere usata online da un piccolo gruppo di collaboratori autorizzati senza esporre segreti, documenti o quota API.

Il target iniziale è un pilot privato tra collaboratori. Non progettare o dichiarare un servizio pubblico per studenti finché non sono stati superati i gate di sicurezza, privacy, affidabilità e qualità definiti qui.

## 2. Decisioni architetturali vincolanti

### 2.1 Un solo prodotto server-side

- La direzione ufficiale è Python + Streamlit con tutte le chiamate Gemini eseguite sul server.
- `index.html` è una variante legacy non distribuibile: contiene una credenziale compromessa, duplica la logica, ha vulnerabilità XSS e usa dipendenze browser insicure. Non aggiungere nuove funzioni a questa variante e non pubblicarla.
- La rimozione definitiva di `index.html` e la bonifica della cronologia Git richiedono un'attività esplicita e verificata; fino ad allora deve essere trattato come materiale in quarantena.
- Nessuna chiave provider, token o logica privilegiata può essere presente nel browser.

### 2.2 Architettura target modulare

`app.py` deve diventare un entrypoint/UI sottile. Il refactoring incrementale deve convergere verso moduli con responsabilità isolate, ad esempio:

```text
app.py                       # composizione UI e stato della sessione
correttore/
  config.py                  # configurazione tipizzata e secret loading
  domain.py                  # Exercise, Job, ExtractedAsset, Result
  ingestion.py               # validazione, estrazione testo e immagini
  security.py                # limiti, path policy, sanitizzazione, redazione log
  ai_gateway.py              # client Gemini, schema, retry, timeout e quota
  prompts.py                 # prompt versionati e separati dal codice UI
  orchestration.py           # pipeline/job, progress, cancel e idempotenza
  rendering.py               # Markdown ristretto, Pandoc, DOCX/PDF
  storage.py                 # workspace temporaneo per job e cleanup
tests/
  unit/
  integration/
  fixtures/
  golden/
```

I nomi possono evolvere, ma i confini di responsabilità no. Evitare un nuovo monolite o duplicazioni di prompt e policy.

### 2.3 Pipeline di fiducia

Ogni passaggio deve trattare l'output precedente come non attendibile:

```text
upload non attendibile
  -> validazione firma, tipo e limiti
  -> parser isolato e limitato
  -> testo/asset normalizzati
  -> schema esercizi validato
  -> soluzione AI validata
  -> Markdown/LaTeX ristretto
  -> converter confinato
  -> verifica artefatto
  -> download autorizzato
  -> cleanup del job
```

## 3. Sicurezza non negoziabile

Una modifica che viola questa sezione non è accettabile anche se rende il prototipo apparentemente funzionante.

### 3.1 Segreti

- Caricare `GEMINI_API_KEY` esclusivamente da `st.secrets` o variabili d'ambiente server-side.
- Non leggere nuove credenziali da file versionabili come `api_key.txt`; il supporto legacy va rimosso durante l'hardening.
- Non inserire segreti in sorgenti, HTML, URL, query string, errori, log, telemetria, test, screenshot o fixture.
- La chiave presente nella cronologia Git va considerata compromessa: prima di qualsiasi chiamata reale o deploy, l'utente deve confermarne revoca e rotazione.
- Attivare secret scanning/pre-commit e CI. Una semplice regola `.gitignore` non è una protezione sufficiente.

### 3.2 Accesso e autorizzazione

- Il pilot online deve essere privato e accessibile solo a indirizzi esplicitamente autorizzati.
- Usare l'autenticazione del provider di hosting o un identity proxy affidabile; non inventare autenticazione artigianale.
- Ogni job e download deve appartenere alla sessione/identità che lo ha creato.
- Registrare eventi operativi minimi per utente senza contenuto scolastico o dati personali.
- Non rendere l'app pubblica finché non esiste una decisione esplicita dell'utente e un nuovo security review sul deploy reale.

### 3.3 Isolamento e filesystem

- Un job deve usare una directory temporanea casuale e privata, creata con `TemporaryDirectory` o equivalente.
- Vietata una directory globale condivisa come `temp_images` per dati di utenti diversi.
- Tutti i nomi esterni devono essere separati dai percorsi fisici. Generare ID interni casuali e conservare il nome originale solo come metadato escapato.
- Prima di leggere o scrivere, risolvere il path canonico e verificare che resti dentro il workspace del job.
- Non usare mai path, URL o nomi immagine prodotti dal modello senza confronto con un'allowlist di asset estratti dal job.
- Cleanup in `finally`, anche dopo cancel, timeout o errore. Retention predefinita: zero oltre la durata necessaria al download, salvo diversa policy documentata.
- Output e temporanei devono avere nomi casuali, non timestamp con precisione al secondo.

### 3.4 Upload e parser

Limiti predefiniti del pilot, modificabili solo insieme a test e documentazione:

- massimo 5 file per job;
- massimo 15 MB per file e 50 MB complessivi;
- massimo 20 pagine per PDF;
- massimo 20 megapixel per immagine/pagina rasterizzata;
- massimo 10 esercizi identificati;
- timeout esplicito per parsing, OCR, chiamata AI e rendering.

Ulteriori regole:

- Verificare firma e struttura del file, non soltanto nome o estensione.
- Accettare esclusivamente PDF, DOCX, TXT UTF-8/compatibile, PNG e JPEG reali. Bloccare formati rinominati, file cifrati non gestiti e archivi anomali.
- Applicare protezioni contro zip/decompression bomb e dimensioni immagine eccessive.
- Aggiornare e sottoporre ad audit le dipendenze prima di elaborare input non attendibili online. Come baseline minima: `pypdf >= 6.0.0` e `Pillow >= 12.1.1`, previa verifica di compatibilità.
- Parser e converter devono essere eseguiti con privilegi minimi e limiti di CPU, memoria, disco e rete compatibili con l'hosting scelto.

### 3.5 Prompt injection e output AI

- Il documento caricato è dati non attendibili, mai istruzioni di sistema.
- Delimitare chiaramente il contenuto nel prompt e istruire il modello a ignorare comandi presenti nel documento.
- L'identificazione deve restituire uno schema tipizzato, ad esempio `Exercise(id, text, asset_ids)`, senza path arbitrari.
- Validare tipo, lunghezza, cardinalità, ID, testo e riferimenti asset. Rifiutare o riparare in modo controllato risposte fuori schema.
- Non affidare al modello decisioni di autorizzazione, path resolution, policy di rete o scelta dei segreti.
- Non rendere mai HTML grezzo prodotto dal modello. In Streamlit usare componenti sicuri; se in futuro serve HTML, applicare sanitizzazione allowlist e CSP.

### 3.6 Pandoc, LaTeX e documenti finali

- Prima della conversione, trasformare l'output AI in un sottoinsieme esplicito di Markdown/LaTeX.
- Bloccare HTML raw, script, iframe, link attivi non necessari, URI `file:`, URL remoti e riferimenti immagine non presenti nell'allowlist del job.
- Configurare Pandoc con resource path limitato al job e senza accesso di rete. Valutare `--sandbox` e isolamento di processo; verificarne realmente l'efficacia con test ostili.
- Non passare al converter metadati o nomi file non escapati.
- Controllare che l'artefatto prodotto sia del tipo richiesto, non vuoto e apribile. Per DOCX/PDF, aggiungere golden test e render visuale rappresentativo.
- Non affermare che il PDF possiede intestazione o numerazione finché tali elementi non sono implementati e verificati.

### 3.7 Quota, concorrenza e abusi

- Un `sleep` per sessione non è un rate limiter multiutente.
- Introdurre una coda o un coordinatore globale con limiti per utente e per progetto, retry con backoff/jitter, timeout e circuit breaker.
- Rendere i job cancellabili e idempotenti. Evitare doppie richieste da rerun Streamlit o doppio click.
- Mostrare stima, progresso per fase ed errori azionabili senza dettagli interni.
- Misurare richieste, token/costo se disponibili, durata, fallback ed errori senza registrare il contenuto dei compiti.

### 3.8 Privacy

- Mostrare prima dell'upload un'informativa chiara: i contenuti vengono inviati a Gemini per l'elaborazione.
- Per il pilot usare documenti sintetici o privi di dati personali. Non caricare nomi, voti, firme o altri identificativi di minori senza una base organizzativa e una policy approvate dall'utente.
- Applicare minimizzazione, retention breve, cancellazione verificabile e redazione dei log.
- Documentare provider, regione di hosting, flusso dei dati e responsabilità prima di un uso scolastico reale.

## 4. Contratto funzionale

### 4.1 Flusso UX target

1. **Informativa e configurazione**: dettaglio, anno, indirizzo, formato e modalità multi-file.
2. **Upload validato**: limiti e tipi mostrati prima della selezione; errori specifici per file.
3. **Revisione input**: anteprima delle tracce identificate e possibilità di correggere testo, ordine, raggruppamento e immagini associate.
4. **Elaborazione**: progresso per fase e per esercizio, tempo stimato, annullamento e retry selettivo.
5. **Revisione output**: anteprima sicura, indicazione del modello/fallback usato e possibilità di rigenerare un singolo esercizio.
6. **Esportazione**: DOCX/PDF o ZIP, seguita dal cleanup del job.

### 4.2 Input

- PDF testuali: estrazione lineare più immagini incorporate.
- PDF scansionati/scritti a mano: rasterizzazione limitata e invio multimodale.
- DOCX: paragrafi, tabelle e immagini.
- TXT: decodifica controllata e limite di lunghezza.
- PNG/JPEG: validazione reale, normalizzazione e invio multimodale.
- Non basarsi soltanto sulla soglia di 150 caratteri per decidere se un PDF sia una scansione; usare segnali per pagina e consentire override dell'utente.

### 4.3 Identificazione esercizi

- Mantenere insieme i sottoquesiti correlati.
- Deduplicare soltanto quando la confidenza è sufficiente e rendere la decisione visibile all'utente.
- Conservare provenienza del file/pagina e associazione agli asset.
- Non permettere più di 10 esercizi senza conferma o nuova policy.

### 4.4 Soluzione didattica

Il prompt di soluzione deve mantenere questi requisiti:

- lingua italiana anche per input straniero;
- strumenti matematici compatibili con anno e indirizzo;
- per la fisica: dati e costanti con unità, sviluppo simbolico prima di quello numerico, cifre significative coerenti;
- calcoli numerici verificati tramite code execution quando il modello e l'SDK lo supportano;
- nessun saluto, preambolo o testo estraneo;
- distinzione esplicita tra dato della traccia, assunzione e risultato;
- se la traccia è ambigua o incompleta, segnalarlo invece di inventare dati.

Struttura logica minima per esercizio:

```markdown
# Esercizio X
### Testo del problema
[traccia confermata dall'utente]

### Soluzione del problema
[soluzione coerente con il profilo]
```

### 4.5 Formattazione matematica

- Formule inline tra `$ ... $`; formule isolate tra `$$ ... $$`.
- Variabili, operatori e simboli matematici devono stare in math mode.
- Unità in `\text{ ... }`, ad esempio `$9.81 \text{ m/s}^2$`.
- Evitare simboli matematici Unicode fuori da LaTeX quando compromettono Pandoc/OMML.
- Non correggere LaTeX con regex generiche che possono cambiare il significato matematico senza test. Preferire parser, validazione strutturale e fallback esplicito.

### 4.6 Output

- DOCX: Pandoc con `template.docx` come reference document ed equazioni OMML modificabili.
- PDF: A4, margini coerenti, page break tra esercizi, intestazione e numerazione implementate realmente.
- Il template va portato da US Letter ad A4 e verificato con rendering su tutte le pagine rappresentative.
- Il file Word client-side `.doc` basato su HTML non è un output conforme.

## 5. UI, estetica e accessibilità

Mantenere l'identità pastello esistente, senza sacrificare usabilità:

- sfondo `#F8F9FA`;
- sidebar/aree secondarie `#E3F2FD`;
- testo `#2D3748`;
- CTA `#2A9D8F` con contrasto verificato.

Requisiti:

- layout utilizzabile da 320 px in su, senza overflow orizzontale;
- controlli raggiungibili da tastiera, label reali e focus visibile;
- status/progresso annunciabili tramite semantica accessibile;
- icone decorative escluse dall'albero accessibile e pulsanti icona con nome;
- rispetto di `prefers-reduced-motion` dove applicabile;
- messaggi di errore chiari, non colpevolizzanti e utili al recupero;
- nessuna promessa UI per funzioni non implementate, come drag-and-drop o immagini multimodali.

## 6. Modelli e SDK

- Non assumere che i nomi modello presenti nel codice siano ancora disponibili. Prima di modificarli, consultare la documentazione ufficiale corrente e verificare l'elenco modelli con la chiave ruotata.
- Centralizzare modello primario e fallback in configurazione, non duplicarli nei prompt o nella UI.
- Un fallback deve dichiarare capacità e qualità compatibili: JSON mode, input multimodale, code execution e limiti di contesto.
- Non effettuare fallback silenziosi che cambiano qualità/costo. Registrare l'evento e mostrarlo nell'output in modo non invasivo.
- Pin delle dipendenze riproducibile, aggiornamenti tramite PR/change set dedicati e dependency audit in CI.

## 7. Strategia di test obbligatoria

Ogni correzione deve includere il test che avrebbe rilevato il difetto. Baseline prima del pilot:

### Unit test

- validazione tipi, firme, dimensioni, pagine e pixel;
- path traversal e allowlist asset;
- parsing dello schema AI e risposte fuori contratto;
- sanitizzazione Markdown/LaTeX e metadati;
- rate limit, retry, timeout, cancel e idempotenza;
- cleanup anche su eccezione.

### Fixture ostili

- PDF/DOCX corrotti, cifrati e decompressivi;
- immagini rinominate, enormi e con formato non ammesso;
- nomi file con HTML, separatori, Unicode e path traversal;
- prompt injection nel testo;
- output AI con HTML, URL remoti, `file:` e path assoluti;
- richieste concorrenti nello stesso secondo.

### Integrazione/E2E

- import/avvio Streamlit;
- upload -> revisione -> soluzione mock -> DOCX/PDF;
- multi-file cumulativo e separato;
- isolamento tra due sessioni;
- autenticazione e accesso negato;
- apertura e rendering di DOCX/PDF golden con formule, immagini e page break.

I test che chiamano Gemini devono essere separati, opt-in e protetti da budget. La suite predefinita usa mock/fixture e non richiede segreti o rete.

## 8. Definition of Done

Una modifica è conclusa solo se:

1. il codice compila/importa;
2. i test pertinenti passano;
3. non introduce segreti o dati personali;
4. rispetta isolamento e limiti;
5. aggiorna documentazione e `MEMORY.md` se cambia stato o decisioni;
6. è stata verificata sull'interfaccia quando modifica la UX;
7. gli artefatti DOCX/PDF sono renderizzati e ispezionati quando cambia l'output;
8. il diff è limitato allo scopo e non cancella modifiche dell'utente;
9. rischi residui e controlli non eseguiti sono dichiarati esplicitamente.

## 9. Procedura operativa per gli agenti

All'inizio di ogni sessione:

1. leggere integralmente `GEMINI.md` e `MEMORY.md`;
2. controllare `git status` e preservare modifiche esistenti;
3. verificare il gate attivo in `MEMORY.md`;
4. non saltare a feature successive se restano blocker P0;
5. formulare un piano piccolo e verificabile.

Durante il lavoro:

- preferire cambi incrementali e testabili;
- non eseguire chiamate reali o deploy finché la rotazione della chiave non è confermata;
- non installare o aggiornare dipendenze senza verificare compatibilità e advisory correnti;
- non riscrivere la cronologia Git, eliminare file o ruotare credenziali senza autorizzazione esplicita;
- aggiornare `MEMORY.md` con fatti verificati, non intenzioni generiche.

Prima del handoff:

- eseguire i controlli proporzionati al rischio;
- riportare file modificati, test eseguiti e rischi residui;
- indicare il prossimo passo più sicuro coerente con il gate attivo.

## 10. Gate di rilascio

### Gate 0 — contenimento

- chiave compromessa revocata/ruotata;
- `index.html` escluso dal deploy;
- `app.py` compilabile;
- test di import e secret scan attivi.

### Gate 1 — baseline sicura locale

- architettura modulare minima;
- workspace per job e limiti upload;
- dipendenze vulnerabili aggiornate;
- schema AI validato;
- rendering confinato;
- suite unit/security essenziale.

### Gate 2 — pilot privato

- autenticazione/allowlist;
- isolamento tra utenti verificato;
- quota/rate limit/cancel;
- privacy notice e retention;
- E2E e golden output;
- logging redatto e runbook incidenti.

### Gate 3 — ampliamento

- security review sul deploy reale;
- test di carico e abuso;
- valutazione privacy/organizzativa per dati scolastici;
- monitoraggio costi e qualità;
- decisione esplicita dell'utente sul pubblico target.

Finché Gate 0 non è completato, il progetto è **non distribuibile**.
