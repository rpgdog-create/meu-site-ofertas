cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

# ─── style.css (adiciona badges) ──────────────────────────
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
.card-img { width: 100%; height: 140px; object-fit: contain; border-radius: 6px; margin-bottom: 0.5rem; }
.card .tag { align-self: flex-start; background: #ee4d2d; color: #fff; padding: 0.15rem 0.5rem; border-radius: 4px; font-size: 0.7rem; font-weight: 600; }
.card .mp-badge { align-self: flex-start; padding: 0.15rem 0.6rem; border-radius: 4px; font-size: 0.7rem; font-weight: 600; }
.card .mp-ml { background: #FFE600; color: #333; }
.card .mp-shopee { background: #EE4D2D; color: #fff; }
.card .mp-amazon { background: #232F3E; color: #fff; }
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

# ─── script.js (renderiza badge por marketplace) ──────────
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

function getBadge(p) {
  const mp = (p.marketplace || '').toUpperCase();
  if (mp === 'ML' || mp === 'MERCADO LIVRE') return '<span class="mp-badge mp-ml">Mercado Livre</span>';
  if (mp === 'SHOPEE') return '<span class="mp-badge mp-shopee">Shopee</span>';
  if (mp === 'AMAZON') return '<span class="mp-badge mp-amazon">Amazon</span>';
  // Detecta pelo link se não tiver campo
  const link = (p.link || p.offerLink || '').toLowerCase();
  if (link.includes('mercadolivre') || link.includes('meli.la')) return '<span class="mp-badge mp-ml">Mercado Livre</span>';
  if (link.includes('shopee')) return '<span class="mp-badge mp-shopee">Shopee</span>';
  if (link.includes('amazon')) return '<span class="mp-badge mp-amazon">Amazon</span>';
  return '';
}

function renderCard(p) {
  const div = document.createElement('div');
  div.className = 'card';
  const badge = getBadge(p);
  const tag = p.tag ? `<span class="tag">${p.tag}</span>` : '';
  const img = p.imagem ? `<img src="${p.imagem}" alt="" class="card-img">` : '';
  const frete = p.frete ? `<p class="frete">🚚 ${p.frete}</p>` : '';
  const desc = p.descricao ? `<p class="desc">${p.descricao}</p>` : '';
  div.innerHTML = `
    ${badge}
    ${tag}
    ${img}
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
    if (ofertas.length === 0) { gridShopee.innerHTML = '<p style="grid-column:1/-1;color:#888;">Nenhuma oferta Shopee ainda.</p>'; return; }
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
    if (ofertas.length === 0) { gridManual.innerHTML = '<p style="grid-column:1/-1;color:#888;">Nenhuma oferta ainda.</p>'; return; }
    ofertas.forEach(p => gridManual.appendChild(renderCard(p)));
  } catch (e) {
    gridManual.innerHTML = '<p style="grid-column:1/-1;color:#888;">Nenhuma oferta ainda.</p>';
  }
}

loadShopee();
loadManual();
EOF

# ─── index.html (remove tabs, uma única grid) ─────────────
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
    <p class="subtitle">As melhores ofertas dos marketplaces</p>
  </header>

  <main>
    <div id="grid-all" class="grid"></div>
  </main>

  <footer>
    <p>Site de afiliados — comissões ajudam a manter o projeto.</p>
    <p style="margin-top:0.5rem;"><a href="admin.html">⚙️ Admin</a></p>
  </footer>

  <script>
    const grid = document.getElementById('grid-all');

    function getBadge(p) {
      const mp = (p.marketplace || '').toUpperCase();
      if (mp === 'ML' || mp === 'MERCADO LIVRE') return '<span class="mp-badge mp-ml">Mercado Livre</span>';
      if (mp === 'SHOPEE') return '<span class="mp-badge mp-shopee">Shopee</span>';
      if (mp === 'AMAZON') return '<span class="mp-badge mp-amazon">Amazon</span>';
      const link = (p.link || p.offerLink || '').toLowerCase();
      if (link.includes('mercadolivre') || link.includes('meli.la')) return '<span class="mp-badge mp-ml">Mercado Livre</span>';
      if (link.includes('shopee')) return '<span class="mp-badge mp-shopee">Shopee</span>';
      if (link.includes('amazon')) return '<span class="mp-badge mp-amazon">Amazon</span>';
      return '';
    }

    function renderCard(p) {
      const div = document.createElement('div');
      div.className = 'card';
      const badge = getBadge(p);
      const tag = p.tag ? `<span class="tag">${p.tag}</span>` : '';
      const img = p.imagem ? `<img src="${p.imagem}" alt="" class="card-img">` : '';
      const frete = p.frete ? `<p class="frete">🚚 ${p.frete}</p>` : '';
      const desc = p.descricao ? `<p class="desc">${p.descricao}</p>` : '';
      div.innerHTML = `
        ${badge}
        ${tag}
        ${img}
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

    async function loadAll() {
      try {
        const [r1, r2] = await Promise.all([
          fetch('manual.json?t=' + Date.now()),
          fetch('ofertas.json?t=' + Date.now())
        ]);
        const manual = await r1.json().catch(() => []);
        const shopee = await r2.json().catch(() => []);
        const all = [...manual, ...shopee];
        grid.innerHTML = '';
        if (all.length === 0) { grid.innerHTML = '<p style="grid-column:1/-1;color:#888;">Nenhuma oferta ainda.</p>'; return; }
        all.forEach(p => grid.appendChild(renderCard(p)));
      } catch (e) {
        grid.innerHTML = '<p style="grid-column:1/-1;color:#888;">Erro ao carregar ofertas.</p>';
      }
    }

    loadAll();
  </script>
</body>
</html>
EOF

# ─── Atualiza admin.html: adiciona marketplace auto-detect ─
python3 << 'PYEOF'
with open("admin.html", "r") as f:
    content = f.read()

# No confirmBatch, adiciona marketplace auto-detect
old = 'const offer = { nome: item.nome, preco: item.preco, link: item.link };'
new = '''const offer = { nome: item.nome, preco: item.preco, link: item.link };
        if (item.imagem) offer.imagem = item.imagem;
        const lk = (item.link || '').toLowerCase();
        if (lk.includes('mercadolivre') || lk.includes('meli.la')) offer.marketplace = 'ML';
        else if (lk.includes('shopee')) offer.marketplace = 'Shopee';
        else if (lk.includes('amazon')) offer.marketplace = 'Amazon';'''

if old in content:
    content = content.replace(old, new)
    print("✅ admin.html: marketplace auto-detect adicionado")
else:
    print("⚠️  Bloco não encontrado no admin.html")

with open("admin.html", "w") as f:
    f.write(content)
PYEOF

echo ""
echo "✅ Tudo atualizado!"
echo ""
echo "Agora:"
echo "  git add ."
echo "  git commit -m 'Badge por marketplace + grid única'"
echo "  git push"   
