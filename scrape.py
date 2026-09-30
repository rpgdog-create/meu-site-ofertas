import requests, hashlib, time, json, os
APP_ID = os.environ.get("SHOPEE_APP_ID", "")
APP_SECRET = os.environ.get("SHOPEE_APP_SECRET", "")
KEYWORDS = ["fone bluetooth", "air fryer", "tênis masculino", "smartwatch", "garrafa térmica", "organizador de gaveta"]
MIN_COMMISSION = 5
MIN_SALES = 100
MAX_RESULTS_PER_KEYWORD = 30
API_URL = "https://open-api.affiliate.shopee.com.br/graphql"
def sign(params):
    sorted_keys = sorted(params.keys())
    msg = "".join(k + str(params[k]) for k in sorted_keys)
    msg = APP_SECRET + msg + APP_SECRET
    return hashlib.sha256(msg.encode()).hexdigest().upper()
def search_products(keyword, limit=50):
    timestamp = int(time.time())
    params = {"appId": APP_ID, "timestamp": timestamp}
    params["sign"] = sign(params)
    query = """query ProductOfferList($keyword: String, $limit: Int) { productOfferList(keyword: $keyword, limit: $limit) { nodes { itemId productName price commissionRate salesCount rating offerLink } } }"""
    variables = {"keyword": keyword, "limit": limit}
    resp = requests.post(API_URL, headers={"Content-Type": "application/json", "x-api-version": "v1", "x-api-request-id": str(int(time.time()*1000)), "x-api-app-id": APP_ID, "x-api-timestamp": str(timestamp), "x-api-signature": params["sign"]}, json={"query": query, "variables": variables}, timeout=30)
    resp.raise_for_status()
    return resp.json().get("data", {}).get("productOfferList", {}).get("nodes", [])
def main():
    if not APP_ID or not APP_SECRET:
        print("⚠️  SHOPEE_APP_ID e SHOPEE_APP_SECRET não configurados."); return
    todas, vistos = [], set()
    for kw in KEYWORDS:
        print(f"Buscando: {kw}")
        try: results = search_products(kw, MAX_RESULTS_PER_KEYWORD)
        except Exception as e: print(f"  Erro: {e}"); continue
        for p in results:
            item_id = p.get("itemId")
            if item_id in vistos: continue
            if p.get("commissionRate", 0) >= MIN_COMMISSION and p.get("salesCount", 0) >= MIN_SALES:
                p["keyword"] = kw; p["captured_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
                todas.append(p); vistos.add(item_id)
    todas.sort(key=lambda x: x.get("commissionRate", 0), reverse=True)
    with open("ofertas.json", "w", encoding="utf-8") as f: json.dump(todas, f, ensure_ascii=False, indent=2)
    print(f"✅ {len(todas)} ofertas salvas")
if __name__ == "__main__": main()
