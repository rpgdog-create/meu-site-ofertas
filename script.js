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
  div.innerHTML = `
    <h3>${p.productName || p.nome}</h3>
    <p class="price">R$ ${Number(p.price || p.preco).toFixed(2)}</p>
    <p class="commission">${p.commissionRate ? 'Comissão: ' + p.commissionRate + '%' : ''}</p>
    <p class="meta">${p.rating ? '⭐ ' + p.rating : ''} ${p.salesCount ? '| ' + p.salesCount + ' vendidos' : ''}</p>
    <a href="${p.offerLink || p.link}" target="_blank" rel="noopener">Ver oferta →</a>
  `;
  return div;
}
async function loadShopee() {
  try {
    const res = await fetch('ofertas.json');
    const ofertas = await res.json();
    gridShopee.innerHTML = '';
    ofertas.forEach(p => gridShopee.appendChild(renderCard(p)));
  } catch (e) { gridShopee.innerHTML = '<p>Nenhuma oferta Shopee ainda.</p>'; }
}
async function loadManual() {
  try {
    const res = await fetch('manual.json');
    const ofertas = await res.json();
    gridManual.innerHTML = '';
    ofertas.forEach(p => gridManual.appendChild(renderCard(p)));
  } catch (e) { gridManual.innerHTML = '<p>Nenhuma oferta manual ainda.</p>'; }
}
loadShopee();
loadManual();
