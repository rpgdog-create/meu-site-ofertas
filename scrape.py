import requests, hashlib, time, json, os

APP_ID = os.environ.get("SHOPEE_APP_ID", "")
APP_SECRET = os.environ.get("SHOPEE_APP_SECRET", "")

KEYWORDS = ["fone bluetooth", "air fryer", "tênis masculino", "smartwatch", "garrafa térmica", "organizador de gaveta"]
MIN_COMMISSION = 0.01
MIN_SALES = 0
MAX_RESULTS_PER_KEYWORD = 30
API_URL = "https://open-api.affiliate.shopee.com.br/graphql"


def sign(app_id, timestamp, payload, secret):
  factor = app_id + str(timestamp) + payload + secret
  return hashlib.sha256(factor.encode()).hexdigest()


def search_products(keyword, limit=30):
  timestamp = int(time.time())
  q = 'query { productOfferV2(listType: 0, sortType: 5, keyword: "' + keyword + '", limit: ' + str(limit) + ') { nodes { itemId productName priceMin priceMax priceDiscountRate sales commissionRate commission offerLink imageUrl } } }'
  payload = json.dumps({"query": q, "variables": {}})
  signature = sign(APP_ID, timestamp, payload, APP_SECRET)
  auth = "SHA256 Credential=" + APP_ID + ",Timestamp=" + str(timestamp) + ",Signature=" + signature
  resp = requests.post(API_URL, headers={"Content-Type": "application/json", "Authorization": auth}, data=payload)
  resp.raise_for_status()
  return resp.json().get("data", {}).get("productOfferV2", {}).get("nodes", [])


def map_item(p, keyword):
  preco = float(p.get("priceMin", "0"))
  discount = float(p.get("priceDiscountRate", 0))
  preco_original = round(preco / (1 - discount / 100), 2) if discount > 0 else ""
  return {
    "nome": p.get("productName", ""),
    "preco": preco,
    "imagem": p.get("imageUrl", ""),
    "frete": "",
    "categoria": "",
    "link": p.get("offerLink", ""),
    "precoOriginal": preco_original,
    "marketplace": "Shopee",
    "comissao": round(float(p.get("commissionRate", "0")) * 100, 1),
    "vendas": p.get("sales", 0),
    "keyword": keyword,
    "captured_at": time.strftime("%Y-%m-%dT%H:%M:%S")
  }


def main():
  if not APP_ID or not APP_SECRET:
    print("SHOPEE_APP_ID e SHOPEE_APP_SECRET nao configurados.")
    return
  todas, vistos = [], set()
  for kw in KEYWORDS:
    print("Buscando: " + kw)
    try:
      results = search_products(kw, MAX_RESULTS_PER_KEYWORD)
    except Exception as e:
      print("  Erro: " + str(e))
      continue
    for p in results:
      item_id = p.get("itemId")
      if item_id in vistos:
        continue
      if float(p.get("commissionRate", "0")) >= MIN_COMMISSION and p.get("sales", 0) >= MIN_SALES:
        todas.append(map_item(p, kw))
        vistos.add(item_id)
  todas.sort(key=lambda x: x.get("comissao", 0), reverse=True)
  with open("ofertas.json", "w", encoding="utf-8") as f2:
    json.dump(todas, f2, ensure_ascii=False, indent=2)
  print("OK: " + str(len(todas)) + " ofertas salvas")


if __name__ == "__main__":
  main()
