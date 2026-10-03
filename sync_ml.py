import json
import urllib.request
import urllib.error
import sys
import time

PROXY = "https://ml-proxy.rpgdog.workers.dev"

def check_product(link):
    """Retorna True se o produto está ativo, False se inativo."""
    url = PROXY + "?url=" + urllib.request.quote(link)
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            return resp.status == 200
    except urllib.error.HTTPError as e:
        if e.code in (404, 410, 403):
            return False
        return True
    except Exception:
        return True  # se der erro de rede, mantém o produto

def main():
    with open("manual.json", "r") as f:
        offers = json.load(f)

    ml_offers = [o for o in offers if "meli.la" in o.get("link", "") or "mercadolivre" in o.get("link", "")]
    print(f"Verificando {len(ml_offers)} produtos ML...")

    inativos = []
    for i, offer in enumerate(ml_offers):
        link = offer.get("link", "")
        nome = offer.get("nome", "sem nome")[:40]
        if not check_product(link):
            inativos.append(offer)
            print(f"  ❌ INATIVO: {nome}")
        else:
            print(f"  ✅ {nome}")
        time.sleep(1)  # não spampear o proxy

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
