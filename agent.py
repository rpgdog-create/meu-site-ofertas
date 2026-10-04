import os, json, time, random, base64, hashlib
import requests
from bs4 import BeautifulSoup

# ─── CONFIG ───────────────────────────────────────────────────────
TAG = "ofertas01dc-20"
MAX_PER_SEARCH = 5
MIN_PRICE = 10.0
GEMINI_MODEL = "gemini-3.5-flash-lite"
CATEGORIES = [
    "Acessórios para Veículos","Agro","Alimentos e Bebidas","Animais",
    "Antiguidades e Coleções","Arte, Papelaria e Armarinho","Automotivo e Moto",
    "Bebês","Beleza e Cuidado Pessoal","Brinquedos e Hobbies",
    "Calçados, Roupas e Bolsas","Carros, Motos e Outros","Casa, Móveis e Decoração",
    "Celulares e Telefones","Câmeras e Acessórios","Construção","Cozinha e Utensílios",
    "Eletrodomésticos","Eletrônicos, Áudio e Vídeo","Esportes e Fitness","Ferramentas",
    "Festas e Lembrancinhas","Games","Indústria e Comércio","Ingressos",
    "Instrumentos Musicais","Jardim e Piscina","Joias e Relógios",
    "Livros, Revistas e Comics","Música, Filmes e Seriados","Móveis",
    "Papelaria e Escritório","Saúde","Serviços","Televisores","Informática","Outros"
]

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
    "Accept-Language": "pt-BR,pt;q=0.9,en;q=0.8",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
}

# ─── AMAZON SCRAPING ──────────────────────────────────────────────
def fetch_page(url, retries=2):
    for i in range(retries + 1):
        try:
            r = requests.get(url, headers=HEADERS, timeout=15)
            if r.status_code == 200:
                return r.text
            if r.status_code in (503, 429):
                time.sleep(random.uniform(3, 6) * (i + 1))
                continue
            return None
        except Exception:
            time.sleep(3)
    return None

def parse_search(html):
    soup = BeautifulSoup(html, "html.parser")
    products = []
    for card in soup.select('div[data-component-type="s-search-result"]'):
        asin = card.get("data-asin", "")
        if not asin or len(asin) != 10:
            continue
        # nome
        name_el = card.select_one('h2 a span') or card.select_one('.a-size-medium')
        if not name_el:
            continue
        name = name_el.get_text(strip=True)
        if len(name) < 5:
            continue
        # preço
        price_el = card.select_one('.a-price:not(.a-text-price) .a-offscreen')
        if not price_el:
            continue
        price = parse_price(price_el.get_text(strip=True))
        if price is None or price < MIN_PRICE:
            continue
        # precoOriginal
        po_el = card.select_one('.a-price.a-text-price .a-offscreen')
        po = parse_price(po_el.get_text(strip=True)) if po_el else None
        if po is not None and po <= price:
            po = None
        # imagem
        img_el = card.select_one('img.s-image')
        image = img_el["src"] if img_el and img_el.get("src") else ""
        products.append({
            "name": name,
            "price": price,
            "precoOriginal": po or "",
            "image": image,
            "frete": "",
            "categoria": "",
            "link": f"https://www.amazon.com.br/dp/{asin}?tag={TAG}"
        })
    return products

def parse_price(text):
    try:
        return float(text.replace("R$", "").replace(".", "").replace(",", ".").strip())
    except:
        return None

# ─── GEMINI (categorização em lote) ───────────────────────────────
def categorize_batch(names):
    if not names:
        return {}
    api_key = os.environ.get("GEMINI_API_KEY", "")
    if not api_key:
        return {n: "Outros" for n in names}
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"
    prompt = (
        f"Categorize each product into EXACTLY one of these categories (respond in JSON array of same length):\n"
        f"{json.dumps(CATEGORIES)}\n\n"
        f"Products:\n{json.dumps(names, ensure_ascii=False)}\n\n"
        f"Return ONLY a JSON array of category strings, same order."
    )
    payload = {"contents": [{"parts": [{"text": prompt}]}]}
    try:
        r = requests.post(url, headers={"x-goog-api-key": api_key, "Content-Type": "application/json"}, json=payload, timeout=30)
        text = r.json()["candidates"][0]["content"]["parts"][0]["text"].strip()
        if text.startswith("```"):
            text = text.split("\n", 1)[1].rsplit("```", 1)[0]
        cats = json.loads(text)
        return dict(zip(names, cats))
    except Exception as e:
        print(f"  Gemini error: {e}")
        return {n: "Outros" for n in names}

# ─── GITHUB API ───────────────────────────────────────────────────
def gh(path):
    return f"https://api.github.com/repos/{os.environ['GITHUB_REPOSITORY']}/contents/{path}"   

def gh_headers():
    return {"Authorization": f"token {os.environ['GITHUB_TOKEN']}", "Accept": "application/vnd.github+json"}

def read_file(path):
    r = requests.get(gh(path), headers=gh_headers())
    if r.status_code == 404:
        return None
    return base64.b64decode(r.json()["content"]).decode()

def write_file(path, content, message):
    data = content.encode()
    b64 = base64.b64encode(data).decode()
    # chunks de 0x8000
    chunks = [b64[i:i+0x8000] for i in range(0, len(b64), 0x8000)]
    sha = ""
    r = requests.get(gh(path), headers=gh_headers())
    if r.status_code == 200:
        sha = r.json()["sha"]
    body = {
        "message": message,
        "content": b64,
        "branch": "main"
    }
    if sha:
        body["sha"] = sha
    r = requests.put(gh(path), headers=gh_headers(), json=body)
    return r.status_code in (200, 201)

# ─── MAIN ─────────────────────────────────────────────────────────
def main():
    print("=== AGENT AMAZON ===")
    # carrega termos de busca
    terms_raw = read_file("search_terms.json")
    if not terms_raw:
        print("search_terms.json não encontrado. Abortando.")
        return
    search_terms = json.loads(terms_raw)
    print(f"Termos de busca: {len(search_terms)}")

    # carrega manual.json existente
    manual_raw = read_file("manual.json")
    existing = json.loads(manual_raw) if manual_raw else []
    existing_links = {item["link"] for item in existing}
    print(f"Produtos existentes: {len(existing)}")

    # busca na Amazon
    all_new = []
    for term in search_terms:
        url = f"https://www.amazon.com.br/s?k={requests.utils.quote(term)}"
        print(f"  Buscando: {term}")
        html = fetch_page(url)
        if not html:
            print(f"    ⚠ Amazon bloqueou (captcha/503). Pulando.")
            continue
        found = parse_search(html)
        valid = [p for p in found if p["link"] not in existing_links]
        all_new.extend(valid[:MAX_PER_SEARCH])
        print(f"    → {len(valid)} novos")
        time.sleep(random.uniform(2, 4))

    if not all_new:
        print("Nenhum produto novo encontrado. Nada a fazer.")
        return

    # categoriza com Gemini (lote de até 20)
    print(f"\nCategorizando {len(all_new)} produtos com Gemini...")
    names = [p["name"] for p in all_new]
    for i in range(0, len(names), 20):
        batch = names[i:i+20]
        cats = categorize_batch(batch)
        for j, name in enumerate(batch):
            all_new[i+j]["categoria"] = cats.get(name, "Outros")
        time.sleep(1)

    # valida e insere
    added = 0
    for p in all_new:
        if p["link"] in existing_links:
            continue
        existing.append(p)
        existing_links.add(p["link"])
        added += 1

    print(f"\n✓ {added} produtos adicionados. Total: {len(existing)}")

    # push
    content = json.dumps(existing, ensure_ascii=False, indent=2)
    ok = write_file("manual.json", content, f"agent: +{added} produtos Amazon")
    if ok:
        print("✓ Push OK")
    else:
        print("✗ Push falhou")

if __name__ == "__main__":
    main()   
