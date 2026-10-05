import json
import time
import random
import subprocess
from playwright.sync_api import sync_playwright

COUPONS_URL = "https://www.amazon.com.br/deals?bubble-id=deals-collection-coupons"


def main():
    results = []
    seen = set()

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
            locale="pt-BR",
            viewport={"width": 1920, "height": 1080}
        )
        page = context.new_page()

        print("Abrindo página de cupons da Amazon...")
        try:
            page.goto(COUPONS_URL, timeout=30000, wait_until="domcontentloaded")
            page.wait_for_timeout(5000)
        except:
            print("Timeout ao abrir página de cupons.")
            browser.close()
            return

        title = page.title()
        if "Algo deu errado" in title or "Robot Check" in title:
            print("Bloqueado. Tentando reload...")
            page.wait_for_timeout(5000)
            page.reload(wait_until="domcontentloaded")
            page.wait_for_timeout(5000)
            if "Algo deu errado" in page.title():
                print("Ainda bloqueado. Abortando.")
                browser.close()
                return

        # Scroll pra carregar todos os cupons
        for _ in range(3):
            page.mouse.wheel(0, 2000)
            page.wait_for_timeout(1500)
        page.wait_for_timeout(2000)

        # Seletores possíveis (a Amazon muda, testar em ordem)
        coupon_cards = page.query_selector_all('[data-asin]')
        if not coupon_cards:
            coupon_cards = page.query_selector_all('.coupon-card')
        if not coupon_cards:
            coupon_cards = page.query_selector_all('[data-component-type="s-search-result"]')
        if not coupon_cards:
            coupon_cards = page.query_selector_all('.a-section.a-spacing-small')

        print(f"Encontrados {len(coupon_cards)} cards. Extraindo...")

        for card in coupon_cards:
            try:
                # Nome/descrição do cupom
                name_el = (
                    card.query_selector('.a-truncate-full.a-offscreen')
                    or card.query_selector('h2 span')
                    or card.query_selector('[data-csa-c-content-id]')
                    or card.query_selector('.coupon-title')
                    or card.query_selector('h3')
                )
                if not name_el:
                    continue
                name = name_el.inner_text().strip()
                if not name or len(name) < 5:
                    continue

                # Dedup
                if name in seen:
                    continue
                seen.add(name)

                # Desconto (ex: "25% OFF", "R$20 OFF")
                discount_el = (
                    card.query_selector('.a-color-price')
                    or card.query_selector('.coupon-discount')
                    or card.query_selector('[class*="discount"]')
                    or card.query_selector('.a-price .a-offscreen')
                )
                discount = discount_el.inner_text().strip() if discount_el else ""

                # Código (se houver)
                code_el = (
                    card.query_selector('[class*="coupon-code"]')
                    or card.query_selector('.code')
                    or card.query_selector('[data-csa-c-content-id*="code"]')
                )
                code = code_el.inner_text().strip() if code_el else ""

                # Condições (mínima, máxima, validade)
                conditions_el = (
                    card.query_selector('[class*="conditions"]')
                    or card.query_selector('.coupon-conditions')
                    or card.query_selector('[class*="terms"]')
                    or card.query_selector('p')
                )
                conditions = conditions_el.inner_text().strip() if conditions_el else ""

                # Extrair mínima do texto de condições
                import re
                minima = ""
                maximo = ""
                validade = ""
                m_min = re.search(r'(?:m[íi]n(?:ima)?|acima de|a partir de)\s*R\$\s*([\d.]+,\d{2})', conditions, re.IGNORECASE)
                if m_min:
                    minima = "R$ " + m_min.group(1)
                m_max = re.search(r'(?:m[áa]x(?:ima)?|at[ée])\s*R\$\s*([\d.]+,\d{2})', conditions, re.IGNORECASE)
                if m_max:
                    maximo = "R$ " + m_max.group(1)
                m_val = re.search(r'(?:at[ée]|v[áa]lido|expira)[^.\n]*', conditions, re.IGNORECASE)
                if m_val:
                    validade = m_val.group(0).strip()[:50]

                # Link (resgatar)
                link_el = card.query_selector('a[href*="amazon.com.br"]')
                link = link_el.get_attribute("href") if link_el else "https://www.amazon.com.br"
                if link.startswith('/'):
                    link = 'https://www.amazon.com.br' + link

                results.append({
                    "nome": name,
                    "marketplace": "AM",
                    "desconto": discount if discount else name[:30],
                    "minima": minima,
                    "maximo": maximo,
                    "codigo": code,
                    "validade": validade,
                    "link": link
                })

            except Exception as e:
                continue

        browser.close()

    if not results:
        print("\nNenhum cupom encontrado. A estrutura da página pode ter mudado.")
        print("Abra a página manualmente e inspecione os seletores.")
        return

    print(f"\n✓ {len(results)} cupons extraídos.")
    print("Copiando JSON pro clipboard...\n")

    json_str = json.dumps(results, ensure_ascii=False, indent=2)
    subprocess.run(["pbcopy"], input=json_str.encode())
    print("Cola no nano (cupons.json) → salvar → push.")


if __name__ == "__main__":
    main()   
