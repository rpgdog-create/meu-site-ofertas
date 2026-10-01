cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

# ─── index.html (com busca + filtros) ─────────────────────
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ofertas do Dia</title>
  <link rel="stylesheet" href="style.css">
  <style>
    .search-bar { max-width: 1200px; margin: 1rem auto 0; padding: 0 1rem; }
    .search-bar input { width: 100%; padding: 0.8rem 1rem; border: 1px solid #ddd; border-radius: 8px; font-size: 1rem; }
    .search-bar input:focus { outline: none; border-color: #ee4d2d; box-shadow: 0 0 0 3px rgba(238,77,45,0.1); }
    .chips { max-width: 1200px; margin: 0.8rem auto 0; padding: 0 1rem; display: flex; flex-wrap: wrap; gap: 0.4rem; }
    .chip { padding: 0.4rem 0.9rem; border: 1px solid #ddd; border-radius: 20px; background: #fff; cursor: pointer; font-size: 0.8rem; transition: all 0.2s; }
    .chip:hover { border-color: #ee4d2d; color: #ee4d2d; }
    .chip.active { background: #ee4d2d; color: #fff; border-color: #ee4d2d; }
    .results-count { max-width: 1200px; margin: 0.8rem auto 0; padding: 0 1rem; font-size: 0.85rem; color: #888; }
  </style>
</head>
<body>
  <header>
    <h1>🔥 Ofertas do Dia</h1>
    <p class="subtitle">As melhores ofertas dos marketplaces</p>
  </header>

  <div class="search-bar">
    <input type="text" id="search-input" placeholder="🔍 Buscar produto...">
  </div>

  <div class="chips" id="chips">
    <span class="chip active" data-cat="all">Todos</span>
    <span class="chip" data-cat="Eletronicos">Eletrônicos</span>
    <span class="chip" data-cat="Casa">Casa & Cozinha</span>
    <span class="chip" data-cat="Moda">Moda</span>
    <span class="chip" data-cat="Beleza">Beleza</span>
    <span class="chip" data-cat="Esportes">Esportes</span>
    <span class="chip" data-cat="Outros">Outros</span>
  </div>

  <p class="results-count" id="results-count"></p>

  <main>
    <div id="grid-all" class="grid"></div>
  </main>

  <footer>
    <p>Site de afiliados — comissões ajudam a manter o projeto.</p>
    <p style="margin-top:0.5rem;"><a href="admin.html">⚙️ Admin</a></p>
  </footer>

  <script>
    const grid = document.getElementById('grid-all');
    const searchInput = document.getElementById('search-input');
    const chips = document.querySelectorAll('.chip');
    const resultsCount = document.getElementById('results-count');
    let allOffers = [];
    let activeCat = 'all';
    let searchTerm = '';

    // ─── BADGE ────────────────────────────────────────────
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

    // ─── RENDER ───────────────────────────────────────────
    function renderCard(p) {
      const div = document.createElement('div');
      div.className = 'card';
      const badge = getBadge(p);
      const tag = p.tag ? `<span class="tag">${p.tag}</span>` : '';
      const img = p.imagem ? `<img src="${p.imagem}" alt="" class="card-img" loading="lazy">` : '';
      const frete = p.frete ? `<p class="frete">🚚 ${p.frete}</p>` : '';
      const desc = p.descricao ? `<p class="desc">${p.descricao}</p>` : '';
      const cat = p.categoria ? `<p class="meta">📂 ${p.categoria}</p>` : '';
      div.innerHTML = `
        ${badge}
        ${tag}
        ${img}
        <h3>${p.productName || p.nome}</h3>
        <p class="price">R$ ${Number(p.price || p.preco).toFixed(2)}</p>
        <p class="commission">${p.commissionRate ? 'Comissão: ' + p.commissionRate + '%' : ''}</p>
        <p class="meta">${p.rating ? '⭐ ' + p.rating : ''} ${p.salesCount ? '| ' + p.salesCount + ' vendidos' : ''}</p>
        ${frete}
        ${cat}
        ${desc}
        <a href="${p.offerLink || p.link}" target="_blank" rel="noopener">Ver oferta →</a>
      `;
      return div;
    }

    function renderGrid() {
      let filtered = allOffers;
      if (activeCat !== 'all') {
        filtered = filtered.filter(p => (p.categoria || 'Outros') === activeCat);
      }
      if (searchTerm) {
        const term = searchTerm.toLowerCase();
        filtered = filtered.filter(p => {
          const nome = (p.productName || p.nome || '').toLowerCase();
          const desc = (p.descricao || '').toLowerCase();
          return nome.includes(term) || desc.includes(term);
        });
      }
      grid.innerHTML = '';
      if (filtered.length === 0) {
        grid.innerHTML = '<p style="grid-column:1/-1;color:#888;">Nenhuma oferta encontrada.</p>';
      } else {
        filtered.forEach(p => grid.appendChild(renderCard(p)));
      }
      resultsCount.textContent = `${filtered.length} oferta(s)`;
    }

    // ─── EVENTOS ──────────────────────────────────────────
    searchInput.addEventListener('input', () => {
      searchTerm = searchInput.value.trim();
      renderGrid();
    });

    chips.forEach(chip => {
      chip.addEventListener('click', () => {
        chips.forEach(c => c.classList.remove('active'));
        chip.classList.add('active');
        activeCat = chip.dataset.cat;
        renderGrid();
      });
    });

    // ─── LOAD ─────────────────────────────────────────────
    async function loadAll() {
      try {
        const [r1, r2] = await Promise.all([
          fetch('manual.json?t=' + Date.now()),
          fetch('ofertas.json?t=' + Date.now())
        ]);
        const manual = await r1.json().catch(() => []);
        const shopee = await r2.json().catch(() => []);
        allOffers = [...manual, ...shopee];
        renderGrid();
      } catch (e) {
        grid.innerHTML = '<p style="grid-column:1/-1;color:#888;">Erro ao carregar ofertas.</p>';
      }
    }

    loadAll();
  </script>
</body>
</html>
EOF

# ─── Atualiza admin.html: adiciona campo categoria ────────
python3 << 'PYEOF'
with open("admin.html", "r") as f:
    content = f.read()

# Adiciona select de categoria antes do botão "Adicionar todos"
old = '<button class="btn btn-primary" onclick="confirmBatch()">✅ Adicionar todos</button>'
new = '''<div class="form-group" style="margin-top:0.8rem;">
          <label>Categoria (aplicada a todos os produtos do lote)</label>
          <select id="batch-categoria" style="width:100%;padding:0.6rem;border:1px solid #ddd;border-radius:6px;font-size:0.9rem;">
            <option value="Outros">Outros</option>
            <option value="Eletronicos">Eletrônicos</option>
            <option value="Casa">Casa & Cozinha</option>
            <option value="Moda">Moda</option>
            <option value="Beleza">Beleza</option>
            <option value="Esportes">Esportes</option>
          </select>
        </div>
        <button class="btn btn-primary" onclick="confirmBatch()">✅ Adicionar todos</button>'''

if old in content:
    content = content.replace(old, new)
    print("✅ Select de categoria adicionado")
else:
    print("⚠️  Botão não encontrado")

# Atualiza confirmBatch pra incluir categoria
old2 = '''valid.forEach(item => {
        const offer = { nome: item.nome, preco: item.preco, link: item.link };
        if (item.imagem) offer.imagem = item.imagem;
        const lk = (item.link || '').toLowerCase();
        if (lk.includes('mercadolivre') || lk.includes('meli.la')) offer.marketplace = 'ML';
        else if (lk.includes('shopee')) offer.marketplace = 'Shopee';
        else if (lk.includes('amazon')) offer.marketplace = 'Amazon';'''

new2 = '''const cat = document.getElementById("batch-categoria").value;
      valid.forEach(item => {
        const offer = { nome: item.nome, preco: item.preco, link: item.link, categoria: cat };
        if (item.imagem) offer.imagem = item.imagem;
        const lk = (item.link || '').toLowerCase();
        if (lk.includes('mercadolivre') || lk.includes('meli.la')) offer.marketplace = 'ML';
        else if (lk.includes('shopee')) offer.marketplace = 'Shopee';
        else if (lk.includes('amazon')) offer.marketplace = 'Amazon';'''

if old2 in content:
    content = content.replace(old2, new2)
    print("✅ confirmBatch atualizado com categoria")
else:
    print("⚠️  confirmBlock não encontrado (pode já estar atualizado)")

with open("admin.html", "w") as f:
    f.write(content)
print("✅ admin.html salvo!")
PYEOF

echo ""
echo "✅ Tudo atualizado!"
echo ""
echo "Agora:"
echo "  git add ."
echo "  git commit -m 'Busca + filtros por categoria'"
echo "  git push"   
