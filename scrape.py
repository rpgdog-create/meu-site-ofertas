import requests, hashlib, time, json, os, traceback

APP_ID = os.environ.get("SHOPEE_APP_ID", "")
APP_SECRET = os.environ.get("SHOPEE_APP_SECRET", "")

KEYWORDS = ["fone bluetooth", "air fryer", "tênis masculino", "smartwatch", "garrafa térmica", "organizador de gaveta", "caixa de som bluetooth", "power bank", "carregador celular", "teclado mecânico", "mouse gamer", "headset gamer", "monitor gamer", "cafeteira", "liquidificador", "panela elétrica", "aspirador de pó", "purificador de ar", "secador de cabelo", "chapinha", "skincare", "maquiagem", "mochila", "fortnite", "óculos de sol", "relógio masculino", "tênis feminino", "halter", "tapete de yoga", "garrafa de água", "brinquedo", "controle de videogame", "câmera de segurança", "lâmpada led", "tomada inteligente", "drone", "tablet", "notebook", "ssd", "memória ram", "webcam", "microfone", "ring light", "cabo hdmi", "suporte notebook", "mousepad", "silla de coche", "carrinho de bebê", "fralda", "leite em pó", "fralda", "potty", "tênis corrida", "meia", "camiseta", "bermuda", "jaqueta", "bolsa", "carteira", "protetor solar", "shampoo", "condicionador", "perfume", "desodorante", "creme dental", "escova dental", "máscara facial", "sérum facial", "vitamina", "whey protein", "creatina", "suplemento", "dumbbell", "corda de pular", "elástico", "faixa de resistência", "bola de futebol", "raquete", "cabo de força", "extensão elétrica", "luminária", "abajur", "cortina", "tapete", "almofada", "manta", "travesseiro", "colchão", "kit panelas", "faca", "tábua", "escorredor", "pote hermético", "copo térmico", "garrafa de vidro", "coador de café", "moedor de café", "batedeira", "fritadeira", "fogão", "micro-ondas", "geladeira", "freezer", "lavadora", "secadora", "ar condicionado", "ventilador", "aquecedor", "umidificador", "ar purificador", "purificador água", "bebedouro", "jogo de taças", "jogo de xícaras", "jogo de pratos", "toalha", "toalheiro", "cabo de toalha", "saco de lixo", "papel toalha", "esponja", "detergente", "sabão", "amaciante", "desinfetante", "limpa vidros", "pano de chão", "rodo", "pá", "balde", "vassoura", "escova", "aspirador", "pá de lixo", "saco de dormir", "mochila de viagem", "mala", "garrafa squeeze", "caneca", "jarra", "coador", "escorredor de macarrão", "abridor", "abridor de garrafa", "abridor de lata", "descascador", "ralador", "espremedor", "prensa", "molde", "assadeira", "forma", "bowl", "tupperware", "sacola térmica", "forno", "airfryer", "fritadeira elétrica", "sanduicheira", "torradeira", "chaleira", "ferro de passar", "búfalo", "panela de pressão", "waffle", "panqueca", "crepe", "torta", "pizza", "forno de micro-ondas", "forno elétrico", "forno de convecção", "forno de pizza", "forno a lenha", "forno de chão""fone bluetooth", "garrafa termica", "caixa de som", "teclado", "mouse", "headset", "monitor", "aspirador de po", "oculos de sol", "relogio", "tenis", "legging", "regata", "whey", "carrinho de bebe", "leite em po", "mascara facial", "serum facial", "luminaria", "colchao", "tapa", "pote hermetico", "copo termico", "coador de cafe", "moedor de cafe", "fogao", "jogo de tacas", "jogo de xicaras", "sabao", "sacola termica", "panela de pressao", "forno eletrico", "forno de convecao", "forno de chao", "racao cachorro", "racao gato", "areia gato", "brinquedo cachorro", "coleira", "roupinha pet", "arranhador", "fonte agua pet", "comedouro", "caminha pet", "antipulgas", "shampoo pet", "suporte celular carro", "capa volante", "aromatizador carro", "aspirador carro", "camera retrovisor", "retrovisor moto", "oleo motor", "farol led", "vestido feminino", "saia", "blusa feminina", "calca jeans", "conjunto feminino", "tenis feminino", "bota feminina", "base maquiagem", "batom", "esmalte", "placa cabelo", "cera cabelo", "sabonete", "locao hidratante", "cortina blackout", "jogo lencol", "organizador banheiro", "tapete banheiro", "varal", "cabide", "papel de parede", "quadro decorativo", "vela aromatizadora", "difusor", "cafe em grao", "cafe moido", "cha", "chocolate", "snack", "granola", "mel", "azeite", "molho", "tempero", "caneta gel", "caderno", "pasta", "estojo", "lapis de cor", "agenda", "planner", "go pro", "tripode", "câmera de seguranca", "mala de viagem", "organizador mala", "cadeado", "controle playstation", "controle xbox", "termometro", "balanca digital", "massageador", "compressa gel", "oximetro", "furadeira", "alicate", "multimetro", "serra", "chave inglesa", "trena", "livro", "revista", "lego", "boneca", "carrinho controle remoto", "quebra cabeca", "puzzle", "bicicleta", "patins", "skate", "bola volei", "faixa resistencia", "roupa bebe", "roupa infantil", "tenis infantil", "mamadeira", "chupeta", "capinha celular", "película celular", "carregador turbo", "fone sem fio", "suporte celular", "processador alimentos", "mini liquidificador", "ferro passar"
]
MIN_COMMISSION = 0.005
MIN_SALES = 0
MAX_RESULTS_PER_KEYWORD = 80
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
  preco = float(p.get("priceMin") or 0)
  discount = float(p.get("priceDiscountRate") or 0)
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
    "comissao": round(float((p.get("commissionRate") or 0)) * 100, 1),
    "vendas": (p.get("sales") or 0),
    "keyword": keyword,
    "captured_at": time.strftime("%Y-%m-%dT%H:%M:%S")
  }


def main():
  try:
    _main_inner()
  except Exception:
    traceback.print_exc()
    raise

def _main_inner():
  if not APP_ID or not APP_SECRET:
    print("SHOPEE_APP_ID e SHOPEE_APP_SECRET nao configurados.")
    return
  todas, vistos = ["retrovisor moto", "escapamento moto", "pneu moto", "oleo motor", "farol led carro", "suporte celular carro", "capa volante", "aromatizador carro", "aspirador carro", "câmera retrovisor", "processador audio carro", "friso roda", "estica correia", "pneu carro", "pasta freio", "racao cachorro", "racao gato", "areia gato", "brinquedo cachorro", "coleira cachorro", "roupinha pet", "arranhador gato", "fonte agua pet", "comedouro pet", "caminha pet", "antipulgas", "shampoo pet", "vestido feminino", "saia midi", "blusa feminina", "calca jeans", "conjunto feminino", "legging", "regata", "camiseta masculina", "calca masculina", "bermuda masculina", "chinelo", "sandalia", "tenis feminino", "bota feminina", "base maquiagem", "batom", "mascara cilios", "esmalte", "secador cabelo", "placa cabelo", "cera cabelo", "sabonete", "locao hidratante", "cortina blackout", "jogo lençol", "manta cama", "organizador banheiro", "tapete banheiro", "varal", "cabide", "papel de parede", "luminaria led", "quadro decorativo", "vela aromatizadora", "difusor oleo", "cafe em grão", "cafe moído", "cha", "chocolate", "snack", "granola", "mel", "azeite", "molho", "tempero", "caneta gel", "caderno", "pasta organizadora", "estojo", "lapis de cor", "tesoura", "cola", "fita adesiva", "agenda", "planner", "go pro", "tripode", "câmera action", "mala de viagem", "mochila viagem", "organizador mala", "cadeado", "garrafa viagem", "controle playstation", "controle xbox", "ficha jogo", "cartucho", "termometro", "balanca digital", "massageador", "compressa gel", "protetor auricular", "oximetro", "furadeira", "alicate", "multimetro", "serra", "chave inglesa", "jogo chaves", "trena", "livro", "livro colorir", "revista", "lego", "boneca", "carrinho controle remoto", "quebra cabeça", "puzzle", "bicicleta", "patins", "skate", "bola vôlei", "corda pular", "faixa resistencia", "roupa bebe", "roupa infantil", "tenis infantil", "mamadeira", "chupeta", "carrinho bebe", "capinha celular", "película celular", "carregador turbo", "fone sem fio", "suporte celular", "processador alimentos", "mini liquidificador", "ferro passar"
], set()
  for i, kw in enumerate(KEYWORDS):
    print("Buscando: " + kw)
    if i > 0:
      time.sleep(1)
    try:
      results = search_products(kw, MAX_RESULTS_PER_KEYWORD)
    except Exception as e:
      print("  Erro: " + str(e))
      continue
    for p in results:
      try:
        if not isinstance(p, dict):
          continue
        item_id = p.get("itemId")
        if item_id in vistos:
          continue
        comm = float(p.get("commissionRate") or 0)
        sales = int(p.get("sales") or 0)
        if comm >= MIN_COMMISSION and sales >= MIN_SALES:
          todas.append(map_item(p, kw))
          vistos.add(item_id)
      except Exception:
        continue
  todas = [x for x in todas if isinstance(x, dict)]
  todas.sort(key=lambda x: x.get("comissao", 0), reverse=True)
  with open("ofertas.json", "w", encoding="utf-8") as f2:
    json.dump(todas, f2, ensure_ascii=False, indent=2)
  print("OK: " + str(len(todas)) + " ofertas salvas")


if __name__ == "__main__":
  main()
