cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ofertas do Dia</title>
  <link rel="stylesheet" href="style.css">
  <style>
    .filters-bar { max-width: 1200px; margin: 1rem auto 0; padding: 0 1rem; }
    .search-bar { display: flex; gap: 0.5rem; }
    .search-bar input[type="text"] { flex: 1; padding: 0.8rem 1rem; border: 1px solid #ddd; border-radius: 8px; font-size: 1rem; }
    .search-bar input[type="text"]:focus { outline: none; border-color: #ee4d2d; box-shadow: 0 0 0 3px rgba(238,77,45,0.1); }
    .filter-row { display: flex; flex-wrap: wrap; gap: 0.5rem; align-items: center; margin-top: 0.6rem; }
    .filter-row label { font-size: 0.8rem; color: #666; }
    .filter-row input[type="number"] { width: 90px; padding: 0.4rem 0.6rem; border: 1px solid #ddd; border-radius: 6px; font-size: 0.85rem; }
    .filter-row select { padding: 0.4rem 0.6rem; border: 1px solid #ddd; border-radius: 6px; font-size: 0.85rem; background: #fff; }
    .filter-row .checkbox-wrap { display: flex; align-items: center; gap: 0.3rem; font-size: 0.8rem; color: #555; }
    .filter-row .checkbox-wrap input { width: 16px; height: 16px; }
    .chips { max-width: 1200px; margin: 0.6rem auto 0; padding: 0 1rem; display: flex; flex-wrap: wrap; gap: 0.4rem; }
    .chip { padding: 0.4rem 0.9rem; border: 1px solid #ddd; border-radius: 20px; background: #fff; cursor: pointer; font-size: 0.8rem; transition: all 0.2s; }
    .chip:hover { border-color: #ee4d2d; color: #ee4d2d; }
    .chip.active { background: #ee4d2d; color: #fff; border-color: #ee4d2d; }
    .results-bar { max-width: 1200px; margin: 0.8rem auto 0; padding: 0 1rem; display: flex; justify-content: space-between; align-items: center; }
    .results-bar .count { font-size: 0.85rem; color: #888; }
    .results-bar select { padding: 0.4rem 0.6rem; border: 1px solid #ddd; border-radius: 6px; font-size: 0.85rem; background: #fff; }
  </style>
</head>
<body>
  <header>
    <h1>🔥 Ofertas do Dia</h1>
    <p class="subtitle">As melhores ofertas dos marketplaces</p>
  </header>

  <div class="filters-bar">
    <div class="search-bar">
      <input type="text" id="search-input" placeholder="🔍 Buscar produto, marca, modelo...">
    </div>
    <div class="filter-row">
      <label>Preço:</label>
      <input type="number" id="price-min" placeholder="Mín" min="0" step="0.01">
      <span style="color:#888;">—</span>
      <input type="number" id="price-max" placeholder="Máx" min="0" step="0.01">
      <label class="checkbox-wrap">
        <input type="checkbox" id="frete-gratis"> Frete grátis
      </label>
      <select id="sort-select">
        <option value="recentes">Mais recentes</option>
        <option value="menor-preco">Menor preço</option>
        <option value="maior-preco">Maior preço</option>
      </select>
    </div>
  </div>

  <div class="chips" id="chips">
    <span class="chip active" data-cat="all">Todos</span>
  </div>

  <div class="results-bar">
    <span class="count" id="results-count"></span>
  </div>

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
    const priceMin = document.getElementById('price-min');
    const priceMax = document.getElementById('price-max');
    const freteGratis = document.getElementById('frete-gratis');
    const sortSelect = document.getElementById('sort-select');
    const chipsContainer = document.getElementById('chips');
    const resultsCount = document.getElementById('results-count');
    let allOffers = [];
    let activeCat = 'all';
    let searchTerm = '';
    let minPrice = 0;
    let maxPrice = Infinity;
    let freteOnly = false;
    let sortBy = 'recentes';

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

    function buildChips() {
      const cats = new Set();
      allOffers.forEach(p => {
        const c = p.categoria || p.categoriaAuto;
        if (c) cats.add(c);
      });
      const sorted = [...cats].sort((a, b) => a.localeCompare(b, 'pt-BR'));
      chipsContainer.innerHTML = '<span class="chip active" data-cat="all">Todos</span>';
      sorted.forEach(cat => {
        const chip = document.createElement('span');
        chip.className = 'chip';
        chip.dataset.cat = cat;
        chip.textContent = cat;
        chip.addEventListener('click', () => {
          chipsContainer.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
          chip.classList.add('active');
          activeCat = cat;
          renderGrid();
        });
        chipsContainer.appendChild(chip);
      });
      chipsContainer.querySelector('[data-cat="all"]').addEventListener('click', () => {
        chipsContainer.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
        chipsContainer.querySelector('[data-cat="all"]').classList.add('active');
        activeCat = 'all';
        renderGrid();
      });
    }

    function renderGrid() {
      let filtered = allOffers.slice();

      // Categoria
      if (activeCat !== 'all') {
        filtered = filtered.filter(p => (p.categoria || p.categoriaAuto || '') === activeCat);
      }

      // Busca por texto
      if (searchTerm) {
        const term = searchTerm.toLowerCase();
        filtered = filtered.filter(p => {
          const nome = (p.productName || p.nome || '').toLowerCase();
          const desc = (p.descricao || '').toLowerCase();
          const cat = (p.categoria || '').toLowerCase();
          return nome.includes(term) || desc.includes(term) || cat.includes(term);
        });
      }

      // Preço
      if (minPrice > 0) {
        filtered = filtered.filter(p => Number(p.price || p.preco || 0) >= minPrice);
      }
      if (maxPrice < Infinity) {
        filtered = filtered.filter(p => Number(p.price || p.preco || 0) <= maxPrice);
      }

      // Frete grátis
      if (freteOnly) {
        filtered = filtered.filter(p => /gr[aá]tis/i.test(p.frete || ''));
      }

      // Ordenação
      if (sortBy === 'menor-preco') {
        filtered.sort((a, b) => Number(a.price || a.preco || 0) - Number(b.price || b.preco || 0));
      } else if (sortBy === 'maior-preco') {
        filtered.sort((a, b) => Number(b.price || b.preco || 0) - Number(a.price || a.preco || 0));
      }

      grid.innerHTML = '';
      if (filtered.length === 0) {
        grid.innerHTML = '<p style="grid-column:1/-1;color:#888;">Nenhuma oferta encontrada com os filtros atuais.</p>';
      } else {
        filtered.forEach(p => grid.appendChild(renderCard(p)));
      }
      resultsCount.textContent = filtered.length + ' oferta(s)';
    }

    // Eventos
    searchInput.addEventListener('input', () => { searchTerm = searchInput.value.trim(); renderGrid(); });
    priceMin.addEventListener('input', () => { minPrice = parseFloat(priceMin.value) || 0; renderGrid(); });
    priceMax.addEventListener('input', () => { maxPrice = parseFloat(priceMax.value) || Infinity; renderGrid(); });
    freteGratis.addEventListener('change', () => { freteOnly = freteGratis.checked; renderGrid(); });
    sortSelect.addEventListener('change', () => { sortBy = sortSelect.value; renderGrid(); });

    async function loadAll() {
      try {
        const [r1, r2] = await Promise.all([
          fetch('manual.json?t=' + Date.now()),
          fetch('ofertas.json?t=' + Date.now())
        ]);
        const manual = await r1.json().catch(() => []);
        const shopee = await r2.json().catch(() => []);
        allOffers = [...manual, ...shopee];
        buildChips();
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

git add .
git commit -m "Filtros completos: preço, frete grátis, ordenação"
git push   
