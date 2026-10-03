import json
import urllib.request
import urllib.error
import urllib.parse
import time

PROXY = "https://ml-proxy.rpgdog.workers.dev"

def check_ml(link):
    """Verifica produto ML via proxy."""
    url = PROXY + "?url=" + urllib.parse.quote(link)
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            return resp.status == 200
    except urllib.error.HTTPError as e:
        if e.code in (404, 410, 403):
            return False
        return True
    except Exception:
        return True

def check_amazon(link):
    """Verifica produto Amazon direto."""
    try:
        req = urllib.request.Request(link, headers={
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Accept-Language": "pt-BR,pt;q=0.9"
        })
        with urllib.request.urlopen(req, timeout=15) as resp:
            if resp.status == 404:
                return False
            return True
    except urllib.error.HTTPError as e:
        if e.code in (404, 410):
            return False
        return True
    except Exception:
        return True

def main():
    with open("manual.json", "r") as f:
        offers = json.load(f)

    inativos = []
    total = len(offers)
    print(f"Verificando {total} produtos...")

    for i, offer in enumerate(offers):
        link = offer.get("link", "")
        nome = offer.get("nome", "sem nome")[:40]

        if "amazon" in link.lower():
            ativo = check_amazon(link)
        elif "meli.la" in link or "mercadolivre" in link.lower():
            ativo = check_ml(link)
        else:
            ativo = True

        if not ativo:
            inativos.append(offer)
            print(f"  ❌ INATIVO: {nome}")
        else:
            print(f"  ✅ {nome}")
        time.sleep(1)

    if inativos:
        links_inativos = set(o.get("link", "") for o in inativos)
        novos = [o for o in offers if o.get("link", "") not in links_inativos]
        removidos = len(offers) - len(novos)
        print(f"\nRemovendo {removidos} produto(s) inativo(s)...")
        with open("manual.json", "w") as f:
            json.dump(novos, f, ensure_ascii=False, indent=2)
        print(f"Feito. {len(novos)} produtos restantes.")
    else:
        print("\nNenhum produto inativo. Nada a fazer.")

if __name__ == "__main__":
    main()   
