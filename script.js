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
