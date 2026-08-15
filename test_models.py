import os
from google import genai

def get_api_key():
    api_key = os.environ.get("GEMINI_API_KEY")
    if api_key:
        return api_key.strip()
        
    env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")
    if os.path.exists(env_path):
        try:
            with open(env_path, "r", encoding="utf-8") as f:
                for line in f:
                    if line.strip().startswith("GEMINI_API_KEY"):
                        parts = line.split("=", 1)
                        if len(parts) == 2:
                            return parts[1].strip().strip('"').strip("'")
        except:
            pass
            
    key_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "api_key.txt")
    if os.path.exists(key_path):
        try:
            with open(key_path, "r", encoding="utf-8") as f:
                for line in f:
                    cleaned_line = line.strip()
                    if cleaned_line and not cleaned_line.startswith("#") and not cleaned_line.startswith("//"):
                        return cleaned_line
        except:
            pass
            
    return None

api_key = get_api_key()

if not api_key:
    print("Errore: Chiave API non trovata in GEMINI_API_KEY, .env o api_key.txt")
else:
    try:
        client = genai.Client(api_key=api_key)
        print("--- Modelli abilitati per la tua chiave API ---")
        for m in client.models.list():
            print(f"- Nome modello da usare nel codice: {m.name}")
    except Exception as e:
        print(f"Errore durante la connessione o chiave API non valida: {e}")