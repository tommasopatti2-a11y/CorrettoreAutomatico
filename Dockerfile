FROM python:3.11-slim

# Installa dipendenze di sistema (Pandoc, TeX Live per compilazione PDF)
RUN apt-get update && apt-get install -y --no-install-recommends \
    pandoc \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    lmodern \
    ghostscript \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Installa dipendenze Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia il codice dell'applicazione
COPY . .

# Imposta porta di ascolto predefinita per Render (10000)
ENV PORT=10000
EXPOSE 10000

# Avvio di Streamlit configurato per container cloud Render
CMD streamlit run app.py \
    --server.port=${PORT:-10000} \
    --server.address=0.0.0.0 \
    --server.headless=true \
    --server.enableCORS=false \
    --server.enableXsrfProtection=true
