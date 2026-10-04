import json, time, random, subprocess
from playwright.sync_api import sync_playwright

TAG = "ofertas01dc-20"

CATEGORIAS = [
    ("Maiores Descontos", "https://www.amazon.com.br/gp/goldbox"),
    ("Eletrônicos", "https://www.amazon.com.br/gp/bestsellers/electronics"),
    ("Informática", "https://www.amazon.com.br/gp/bestsellers/computers"),
    ("Casa e Cozinha", "https://www.amazon.com.br/gp/bestsellers/home-garden"),
    ("Beleza", "https://www.amazon.com.br/gp/bestsellers/beauty"),
    ("Esportes", "https://www.amazon.com.br/gp/bestsellers/sporting-goods"),
    ("Brinquedos", "https://www.amazon.com.br/gp/bestsellers/toys"),
    ("Celulares", "https://www.amazon.com.br/gp/bestsellers/wireless"),
]   

def parse_price(text):
    import re
    m = re.search(r'R\$\s*([\d.]+,\d{2})', text)
    if m:
        return float(m.group(1).replace(".", "").replace(",", "."))
    try:
        return float(text.replace("R$", "").replace(".", "").replace(",", ".").strip())
    except:
        return None   

def main():
    results = []
    seen_asins = set()

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
            locale="pt-BR",
            viewport={"width": 1920, "height": 1080}
        )
        page = context.new_page()

        for cat_name, cat_url in CATEGORIAS:
            print(f"Buscando: {cat_name}...", end=" ", flush=True)
            try:
                page.goto(cat_url, timeout=30000, wait_until="domcontentloaded")
                page.wait_for_timeout(4000)
            except:
                print("timeout")
                continue

            title = page.title()
            if "Algo deu errado" in title or "Robot Check" in title:
                page.wait_for_timeout(5000)
                page.reload(wait_until="domcontentloaded")
                page.wait_for_timeout(4000)
                if "Algo deu errado" in page.title():
                    print("bloqueado")
                    continue

            cards = page.query_selector_all('[data-asin]')   

            found = 0
            for card in cards:
                asin = card.get_attribute("data-asin") or ""
                if not asin or len(asin) != 10 or asin in seen_asins:
                    continue

                # nome
                name = ""
                name_el = card.query_selector('.a-truncate-full.a-offscreen') or card.query_selector('._cDEzb_p13n-sc-css-line-clamp-3_g3dy1') or card.query_selector('h2 span')   
                if name_el:
                    name = name_el.inner_text().strip()
                if len(name) < 10:
                    continue   

                # preço atual
                price_el = card.query_selector('._cDEzb_p13n-sc-price_3mJ9Z') or card.query_selector('.a-color-price') or card.query_selector('.a-price:not(.a-text-price) .a-offscreen')   
                if not price_el:
                    continue
                price = parse_price(price_el.inner_text().strip())
                if price is None or price < 10:
                    continue

                # preço original (só se tiver desconto)
                po_el = card.query_selector('.a-text-price ._cDEzb_p13n-sc-price_3mJ9Z') or card.query_selector('.a-price.a-text-price .a-offscreen') or card.query_selector('[data-a-strike]')   
                po = parse_price(po_el.inner_text().strip()) if po_el else None
                
                # Goldbox: exige desconto. Bestsellers: aceita sem desconto.
                is_goldbox = "goldbox" in cat_url
                if is_goldbox and (po is None or po <= price):
                    continue   

                # imagem
                img_el = card.query_selector('img[src*="media-amazon.com"]') or card.query_selector('img.p13n-sc-dynamic-image') or card.query_selector('img.s-image')   
                image = img_el.get_attribute("src") if img_el else ""

                link = f"https://www.amazon.com.br/dp/{asin}?tag={TAG}"
                seen_asins.add(asin)

                line = f"{name} ||| {price:.2f} ||| {image} |||  ||| {cat_name} ||| {link} ||| {po:.2f}" if po else f"{name} ||| {price:.2f} ||| {image} |||  ||| {cat_name} ||| {link} |||"   
                results.append(line)
                found += 1

            print(f"→ {found} com desconto")
            time.sleep(random.uniform(3, 5))

        browser.close()

    if not results:
        print("\nNenhum produto com desconto encontrado.")
        return

    print(f"\n✓ {len(results)} produtos com desconto copiados pro clipboard.")
    print("Cola no admin → Importar → Adicionar todos → Salvar.\n")

    subprocess.run(["pbcopy"], input="\n".join(results).encode())

if __name__ == "__main__":
    main()   
