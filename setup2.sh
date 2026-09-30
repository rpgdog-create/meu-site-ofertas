cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

# ─── index.html ───────────────────────────────────────────
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ofertas do Dia</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <header>
    <h1>🔥 Ofertas do Dia</h1>
    <p class="subtitle">As melhores comissões dos marketplaces</p>
  </header>

  <nav class="tabs">
    <button class="tab active" data-source="shopee">Shopee</button>
    <button class="tab" data-source="manual">Mercado Livre / Amazon</button>
  </nav>

  <main>
    <div id="grid-shopee" class="grid"></div>
    <div id="grid-manual" class="grid" style="display:none"></div>
  </main>

  <footer>
    <p>Site de afiliados — comissões ajudam a manter o projeto.</p>
    <p style="margin-top:0.5rem;"><a href="admin.html">⚙️ Admin</a></p>
  </footer>

  <script src="script.js"></script>
</body>
</html>
EOF

# ─── style.css ────────────────────────────────────────────
cat > style.css << 'EOF'
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f5f5; color: #333; }
header { text-align: center; padding: 2rem 1rem; background: #fff; border-bottom: 1px solid #eee; }
header h1 { font-size: 2rem; }
.subtitle { color: #888; margin-top: 0.5rem; }
.tabs { display: flex; justify-content: center; gap: 0.5rem; padding: 1rem; background: #fff; }
.tab { padding: 0.5rem 1.2rem; border: 1px solid #ddd; border-radius: 20px; background: #fff; cursor: pointer; font-size: 0.9rem; }
.tab.active { background: #ee4d2d; color: #fff; border-color: #ee4d2d; }
main { max-width: 1200px; margin: 1.5rem auto; padding: 0 1rem; }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 1rem; }
.card { background: #fff; border-radius: 10px; padding: 1.2rem; box-shadow: 0 2px 8px rgba(0,0,0,0.06); display: flex; flex-direction: column; gap: 0.4rem; }
.card .tag { align-self: flex-start; background: #ee4d2d; color: #fff; padding: 0.15rem 0.5rem; border-radius: 4px; font-size: 0.7rem; font-weight: 600; }
.card h3 { font-size: 0.95rem; line-height: 1.3; }
.card .price { color: #ee4d2d; font-weight: 700; font-size: 1.15rem; }
.card .commission { color: #00a650; font-size: 0.8rem; }
.card .meta { color: #888; font-size: 0.8rem; }
.card .frete { color: #2c3e50; font-size: 0.8rem; }
.card .desc { color: #666; font-size: 0.8rem; line-height: 1.4; }
.card a { margin-top: auto; padding: 0.5rem; text-align: center; background: #ee4d2d; color: #fff; text-decoration: none; border-radius: 6px; font-size: 0.9rem; }
.card a:hover { background: #d63a1a; }
footer { text-align: center; padding: 2rem 1rem; color: #aaa; font-size: 0.8rem; }
footer a { color: #ee4d2d; text-decoration: none; }
EOF

# ─── script.js ────────────────────────────────────────────
cat > script.js << 'EOF'
const tabs = document.querySelectorAll('.tab');
const gridShopee = document.getElementById('grid-shopee');
const gridManual = document.getElementById('grid-manual');

tabs.forEach(tab => {
  tab.addEventListener('click', () => {
    tabs.forEach(t => t.classList.remove('active'));
    tab.classList.add('active');
    const source = tab.dataset.source;
    gridShopee.style.display = source === 'shopee' ? 'grid' : 'none';
    gridManual.style.display = source === 'manual' ? 'grid' : 'none';
  });
});

function renderCard(p) {
  const div = document.createElement('div');
  div.className = 'card';
  const tag = p.tag ? `<span class="tag">${p.tag}</span>` : '';
  const frete = p.frete ? `<p class="frete">🚚 ${p.frete}</p>` : '';
  const desc = p.descricao ? `<p class="desc">${p.descricao}</p>` : '';
  div.innerHTML = `
    ${tag}
    <h3>${p.productName || p.nome}</h3>
    <p class="price">R$ ${Number(p.price || p.preco).toFixed(2)}</p>
    <p class="commission">${p.commissionRate ? 'Comissão: ' + p.commissionRate + '%' : ''}</p>
    <p class="meta">${p.rating ? '⭐ ' + p.rating : ''} ${p.salesCount ? '| ' + p.salesCount + ' vendidos' : ''}</p>
    ${frete}
    ${desc}
    <a href="${p.offerLink || p.link}" target="_blank" rel="noopener">Ver oferta →</a>
  `;
  return div;
}

async function loadShopee() {
  try {
    const res = await fetch('ofertas.json?t=' + Date.now());
    const ofertas = await res.json();
    gridShopee.innerHTML = '';
    if (ofertas.length === 0) { gridShopee.innerHTML = '<p style="grid-column:1/-1;color:#888;">Nenhuma oferta Shopee ainda. Aguarde o primeiro scrape.</p>'; return; }
    ofertas.forEach(p => gridShopee.appendChild(renderCard(p)));
  } catch (e) {
    gridShopee.innerHTML = '<p style="grid-column:1/-1;color:#888;">Nenhuma oferta Shopee ainda.</p>';
  }
}

async function loadManual() {
  try {
    const res = await fetch('manual.json?t=' + Date.now());
    const ofertas = await res.json();
    gridManual.innerHTML = '';
    if (ofertas.length === 0) { gridManual.innerHTML = '<p style="grid-column:1/-1;color:#888;">Nenhuma oferta manual ainda.</p>'; return; }
    ofertas.forEach(p => gridManual.appendChild(renderCard(p)));
  } catch (e) {
    gridManual.innerHTML = '<p style="grid-column:1/-1;color:#888;">Nenhuma oferta manual ainda.</p>';
  }
}

loadShopee();
loadManual();
EOF

# ─── admin.html (com 2FA EmailJS) ─────────────────────────
cat > admin.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin - Ofertas</title>
  <link rel="stylesheet" href="style.css">
  <style>
    .admin-container { max-width: 800px; margin: 1.5rem auto; padding: 0 1rem; }
    .admin-section { background: #fff; border-radius: 10px; padding: 1.5rem; margin-bottom: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
    .admin-section h2 { margin-bottom: 1rem; font-size: 1.2rem; }
    .form-group { margin-bottom: 0.8rem; }
    .form-group label { display: block; font-size: 0.85rem; color: #666; margin-bottom: 0.3rem; }
    .form-group input, .form-group textarea { width: 100%; padding: 0.6rem; border: 1px solid #ddd; border-radius: 6px; font-size: 0.9rem; }
    .form-group textarea { height: 60px; resize: vertical; }
    .btn { padding: 0.6rem 1.2rem; border: none; border-radius: 6px; cursor: pointer; font-size: 0.9rem; }
    .btn-primary { background: #ee4d2d; color: #fff; }
    .btn-primary:hover { background: #d63a1a; }
    .btn-danger { background: #e74c3c; color: #fff; padding: 0.3rem 0.7rem; font-size: 0.8rem; }
    .btn-secondary { background: #6c757d; color: #fff; }
    .offer-item { display: flex; justify-content: space-between; align-items: center; padding: 0.8rem; border: 1px solid #eee; border-radius: 8px; margin-bottom: 0.5rem; }
    .offer-item .info { flex: 1; }
    .offer-item .info h4 { margin: 0; font-size: 0.9rem; }
    .offer-item .info p { margin: 0.2rem 0 0; font-size: 0.8rem; color: #888; }
    .token-box { background: #f9f9f9; padding: 1rem; border-radius: 8px; margin-bottom: 1rem; }
    .status { padding: 0.8rem; border-radius: 6px; margin-top: 1rem; font-size: 0.9rem; display: none; }
    .status.success { display: block; background: #d4edda; color: #155724; }
    .status.error { display: block; background: #f8d7da; color: #721c24; }
    .auth-screen { display: flex; align-items: center; justify-content: center; min-height: 60vh; }
    .auth-box { background: #fff; padding: 2rem; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); width: 100%; max-width: 380px; text-align: center; }
    .auth-box h2 { margin-bottom: 0.5rem; font-size: 1.3rem; }
    .auth-box p { color: #888; font-size: 0.85rem; margin-bottom: 1.5rem; }
    .auth-box input { width: 100%; padding: 0.7rem; border: 1px solid #ddd; border-radius: 6px; font-size: 1rem; margin-bottom: 1rem; text-align: center; }
    .auth-box .btn { width: 100%; }
    .auth-error { color: #e74c3c; font-size: 0.85rem; margin-top: 0.5rem; display: none; }
    .code-input { letter-spacing: 8px; font-size: 1.4rem !important; font-weight: bold; }
    #admin-panel { display: none; }
    .timer { font-size: 0.8rem; color: #888; margin-top: 0.5rem; }
  </style>
</head>
<body>
  <header>
    <h1>⚙️ Admin - Ofertas</h1>
    <p class="subtitle">Gerencie as ofertas manuais (ML / Amazon)</p>
  </header>

  <!-- TELA 1: Email -->
  <div class="auth-screen" id="screen-email">
    <div class="auth-box">
      <h2>🔒 Área Restrita</h2>
      <p>Digite seu email para receber o código de acesso.</p>
      <input type="email" id="auth-email" placeholder="seu@email.com" onkeydown="if(event.key==='Enter')sendCode()">
      <button class="btn btn-primary" onclick="sendCode()">Enviar código</button>
      <p class="auth-error" id="email-error"></p>
    </div>
  </div>

  <!-- TELA 2: Código -->
  <div class="auth-screen" id="screen-code" style="display:none;">
    <div class="auth-box">
      <h2>📩 Código de verificação</h2>
      <p>Enviamos um código de 6 dígitos para <strong id="show-email"></strong></p>
      <input type="text" id="auth-code" class="code-input" maxlength="6" placeholder="••••••" onkeydown="if(event.key==='Enter')verifyCode()">
      <button class="btn btn-primary" onclick="verifyCode()">Verificar</button>
      <p class="timer" id="timer"></p>
      <p class="auth-error" id="code-error"></p>
      <p style="margin-top:1rem;"><a href="#" onclick="resendCode()" style="font-size:0.8rem;color:#888;">Reenviar código</a></p>
    </div>
  </div>

  <!-- PAINEL -->
  <div id="admin-panel">
    <div class="admin-container">

      <div class="admin-section">
        <h2>🔑 Token do GitHub</h2>
        <div class="token-box">
          <p style="font-size:0.85rem;color:#666;margin-bottom:0.5rem;">Cole seu Personal Access Token (classic, com permissão <code>repo</code> + <code>workflow</code>). Fica salvo só no seu navegador.</p>
          <div class="form-group">
            <input type="password" id="gh-token" placeholder="ghp_...">
          </div>
          <button class="btn btn-primary" onclick="saveToken()">Salvar token</button>
          <span id="token-status" style="margin-left:0.5rem;font-size:0.85rem;color:#00a650;"></span>
        </div>
      </div>

      <div class="admin-section">
        <h2>➕ Nova oferta</h2>
        <div class="form-group">
          <label>Nome do produto *</label>
          <input type="text" id="f-nome" placeholder="Ex: Fone Bluetooth JBL Tune 510BT">
        </div>
        <div class="form-group">
          <label>Preço (R$) *</label>
          <input type="text" id="f-preco" placeholder="Ex: 299.90">
        </div>
        <div class="form-group">
          <label>Link de afiliado *</label>
          <input type="url" id="f-link" placeholder="https://mercadolivre.com/sec/...">
        </div>
        <div class="form-group">
          <label>Descrição (opcional)</label>
          <textarea id="f-descricao" placeholder="Ex: Frete grátis, 12x sem juros"></textarea>
        </div>
        <div class="form-group">
          <label>Frete (opcional)</label>
          <input type="text" id="f-frete" placeholder="Ex: Grátis / R$ 19.90">
        </div>
        <div class="form-group">
          <label>Tag / Destaque (opcional)</label>
          <input type="text" id="f-tag" placeholder="Ex: OFERTA, FRETE GRÁTIS, -30%">
        </div>
        <button class="btn btn-primary" onclick="addOffer()">Adicionar oferta</button>
      </div>

      <div class="admin-section">
        <h2>📋 Ofertas atuais (<span id="count">0</span>)</h2>
        <div id="offers-list"></div>
        <br>
        <button class="btn btn-primary" onclick="saveAll()">💾 Salvar no site</button>
        <button class="btn btn-secondary" onclick="loadOffers()" style="margin-left:0.5rem;">🔄 Recarregar</button>
        <button class="btn btn-danger" onclick="doLogout()" style="margin-left:0.5rem;">Sair</button>
        <div id="save-status" class="status"></div>
      </div>

    </div>
  </div>

  <footer>
    <p><a href="/">← Voltar ao site</a></p>
  </footer>

  <script src="https://cdn.jsdelivr.net/npm/@emailjs/browser@4/dist/email.min.js"></script>
  <script>
    const ADMIN_EMAIL = "rpgdog@gmail.com";
    const EMAILJS_PUBLIC_KEY = "iMkQX8pFPaer4mxtE";
    const EMAILJS_SERVICE_ID = "Gmail_service";
    const EMAILJS_TEMPLATE_ID = "template_2fa";
    const CODE_EXPIRY_MS = 5 * 60 * 1000;

    const OWNER = "rpgdog-create";
    const REPO = "meu-site-ofertas";
    const FILE_PATH = "manual.json";
    const API = `https://api.github.com/repos/${OWNER}/${REPO}/contents/${FILE_PATH}`;

    let offers = [];
    let currentCode = null;
    let codeExpiry = null;
    let timerInterval = null;

    (function(){ emailjs.init(EMAILJS_PUBLIC_KEY); })();

    function sendCode() {
      const email = document.getElementById("auth-email").value.trim().toLowerCase();
      const errEl = document.getElementById("email-error");
      errEl.style.display = "none";
      if (email !== ADMIN_EMAIL) {
        errEl.textContent = "Email não autorizado.";
        errEl.style.display = "block";
        return;
      }
      currentCode = String(Math.floor(100000 + Math.random() * 900000));
      codeExpiry = Date.now() + CODE_EXPIRY_MS;
      emailjs.send(EMAILJS_SERVICE_ID, EMAILJS_TEMPLATE_ID, {
        to_email: email,
        code: currentCode
      }).then(() => {
        document.getElementById("screen-email").style.display = "none";
        document.getElementById("screen-code").style.display = "flex";
        document.getElementById("show-email").textContent = email;
        startTimer();
      }).catch(err => {
        errEl.textContent = "Erro ao enviar: " + (err.text || err.message || "tente novamente");
        errEl.style.display = "block";
      });
    }

    function resendCode() { sendCode(); }

    function verifyCode() {
      const input = document.getElementById("auth-code").value.trim();
      const errEl = document.getElementById("code-error");
      errEl.style.display = "none";
      if (Date.now() > codeExpiry) {
        errEl.textContent = "Código expirado. Reenvie um novo.";
        errEl.style.display = "block";
        return;
      }
      if (input !== currentCode) {
        errEl.textContent = "Código incorreto.";
        errEl.style.display = "block";
        return;
      }
      sessionStorage.setItem("admin_auth", "1");
      showPanel();
    }

    function startTimer() {
      clearInterval(timerInterval);
      timerInterval = setInterval(() => {
        const remaining = codeExpiry - Date.now();
        if (remaining <= 0) {
          document.getElementById("timer").textContent = "⏰ Código expirado.";
          clearInterval(timerInterval);
          return;
        }
        const min = Math.floor(remaining / 60000);
        const sec = Math.floor((remaining % 60000) / 1000);
        document.getElementById("timer").textContent = `⏱ Expira em ${min}:${String(sec).padStart(2,'0')}`;
      }, 1000);
    }

    function showPanel() {
      document.getElementById("screen-email").style.display = "none";
      document.getElementById("screen-code").style.display = "none";
      document.getElementById("admin-panel").style.display = "block";
      clearInterval(timerInterval);
      if (getToken()) {
        document.getElementById("token-status").textContent = "✅ Token carregado";
        loadOffers();
      }
    }

    function doLogout() {
      sessionStorage.removeItem("admin_auth");
      location.reload();
    }

    if (sessionStorage.getItem("admin_auth") === "1") { showPanel(); }

    function getToken() { return localStorage.getItem("gh_token"); }
    function saveToken() {
      const t = document.getElementById("gh-token").value.trim();
      if (!t) return;
      localStorage.setItem("gh_token", t);
      document.getElementById("token-status").textContent = "✅ Salvo!";
      setTimeout(() => document.getElementById("token-status").textContent = "", 3000);
      loadOffers();
    }

    async function ghFetch(url, options = {}) {
      const token = getToken();
      if (!token) { alert("Salve seu token GitHub primeiro!"); throw new Error("No token"); }
      options.headers = { ...options.headers, "Authorization": `Bearer ${token}`, "Accept": "application/vnd.github+json" };
      const res = await fetch(url, options);
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.message || `HTTP ${res.status}`);
      }
      return res;
    }

    async function getFileSHA() {
      const res = await ghFetch(API);
      const data = await res.json();
      return data.sha;
    }

    async function commitFile(content, message) {
      const sha = await getFileSHA();
      const base64 = btoa(unescape(encodeURIComponent(JSON.stringify(content, null, 2))));
      await ghFetch(API, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message, content: base64, sha, branch: "main" })
      });
    }

    async function loadOffers() {
      try {
        const res = await fetch(`manual.json?t=${Date.now()}`);
        offers = await res.json();
        renderList();
      } catch (e) { offers = []; renderList(); }
    }

    function renderList() {
      document.getElementById("count").textContent = offers.length;
      const list = document.getElementById("offers-list");
      if (offers.length === 0) { list.innerHTML = "<p style='color:#888;'>Nenhuma oferta ainda.</p>"; return; }
      list.innerHTML = offers.map((o, i) => `
        <div class="offer-item">
          <div class="info">
            <h4>${o.tag ? `<span style="background:#ee4d2d;color:#fff;padding:0.1rem 0.4rem;border-radius:4px;font-size:0.7rem;">${o.tag}</span> ` : ""}${o.nome}</h4>
            <p>R$ ${o.preco} ${o.frete ? `| Frete: ${o.frete}` : ""}</p>
            ${o.descricao ? `<p>${o.descricao}</p>` : ""}
          </div>
          <button class="btn btn-danger" onclick="removeOffer(${i})">✕</button>
        </div>
      `).join("");
    }

    function addOffer() {
      const nome = document.getElementById("f-nome").value.trim();
      const preco = document.getElementById("f-preco").value.trim();
      const link = document.getElementById("f-link").value.trim();
      const descricao = document.getElementById("f-descricao").value.trim();
      const frete = document.getElementById("f-frete").value.trim();
      const tag = document.getElementById("f-tag").value.trim();
      if (!nome || !preco || !link) { alert("Preencha nome, preço e link."); return; }
      const offer = { nome, preco, link };
      if (descricao) offer.descricao = descricao;
      if (frete) offer.frete = frete;
      if (tag) offer.tag = tag;
      offers.push(offer);
      renderList();
      ["f-nome","f-preco","f-link","f-descricao","f-frete","f-tag"].forEach(id => document.getElementById(id).value = "");
    }

    function removeOffer(i) { offers.splice(i, 1); renderList(); }

    async function saveAll() {
      const status = document.getElementById("save-status");
      status.className = "status";
      status.textContent = "Salvando...";
      try {
        await commitFile(offers, `Update manual.json (${offers.length} ofertas)`);
        status.className = "status success";
        status.textContent = "✅ Salvo! O site atualiza em ~30 segundos.";
      } catch (e) {
        status.className = "status error";
        status.textContent = "❌ Erro: " + e.message;
      }
    }
  </script>
</body>
</html>
EOF

# ─── scrape.py ────────────────────────────────────────────
cat > scrape.py << 'EOF'
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
EOF

# ─── manual.json ──────────────────────────────────────────
cat > manual.json << 'EOF'
[]
EOF

# ─── ofertas.json ─────────────────────────────────────────
echo '[]' > ofertas.json

# ─── .github/workflows/scrape.yml ─────────────────────────
cat > .github/workflows/scrape.yml << 'EOF'
name: Atualizar Ofertas Shopee
on:
  schedule:
    - cron: "0 */6 * * *"
  workflow_dispatch:
jobs:
  scrape:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install requests
      - name: Rodar scraper
        run: python scrape.py
        env:
          SHOPEE_APP_ID: ${{ secrets.SHOPEE_APP_ID }}
          SHOPEE_APP_SECRET: ${{ secrets.SHOPEE_APP_SECRET }}
      - name: Commit e push
        run: |
          git config user.name "github-actions"
          git config user.email "actions@github.com"
          git add ofertas.json
          git diff --staged --quiet || git commit -m "Atualizar ofertas"
          git push
EOF

# ─── README.md ────────────────────────────────────────────
cat > README.md << 'EOF'
# Meu Site de Ofertas

Site estático: Shopee (automatizado) + ML/Amazon (manual via painel admin).

## Setup
1. Ative GitHub Pages (Settings → Pages → main)
2. Cadastre na Shopee Afiliados
3. Adicione Secrets: SHOPEE_APP_ID e SHOPEE_APP_SECRET
4. Edite KEYWORDS em scrape.py

## Admin
Acesse /admin.html → 2FA por email → gerencie ofertas manuais.

## Custo: R$ 0
EOF

echo ""
echo "✅ Todos os arquivos atualizados!"
echo ""
echo "Agora commit e push:"
echo "  git add ."
echo "  git commit -m '2FA EmailJS + admin completo'"
echo "  git push"   
