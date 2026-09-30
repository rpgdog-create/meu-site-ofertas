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
