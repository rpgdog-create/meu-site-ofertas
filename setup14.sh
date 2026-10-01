cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

# ─── index.html: chips dinâmicos ──────────────────────────
python3 << 'PYEOF'
with open("index.html", "r") as f:
    content = f.read()

# Substitui os chips fixos por um container vazio (preenchido via JS)
old_chips_block = '''<div class="chips" id="chips">
    <span class="chip active" data-cat="all">Todos</span>
    <span class="chip" data-cat="Celulares">Celulares & Tablets</span>
    <span class="chip" data-cat="Informatica">Informática</span>
    <span class="chip" data-cat="Games">Games & Consoles</span>
    <span class="chip" data-cat="Moveis">Móveis & Decoração</span>
    <span class="chip" data-cat="Cozinha">Cozinha & Utensílios</span>
    <span class="chip" data-cat="Moda">Moda</span>
    <span class="chip" data-cat="Beleza">Beleza & Saúde</span>
    <span class="chip" data-cat="Esportes">Esportes & Fitness</span>
    <span class="chip" data-cat="Pet">Pet</span>
    <span class="chip" data-cat="Infantil">Brinquedos & Infantil</span>
    <span class="chip" data-cat="Automotivo">Automotivo</span>
    <span class="chip" data-cat="Ferramentas">Ferramentas</span>
    <span class="chip" data-cat="Livros">Livros & Papelaria</span>
    <span class="chip" data-cat="Outros">Outros</span>
  </div>'''

new_chips_block = '''<div class="chips" id="chips">
    <span class="chip active" data-cat="all">Todos</span>
  </div>'''

if old_chips_block in content:
    content = content.replace(old_chips_block, new_chips_block)
    print("✅ Chips fixos removidos")
else:
    print("⚠️  Bloco de chips não encontrado (já pode ser dinâmico)")

# Substitui o script inteiro por uma versão com chips dinâmicos
old_script_start = '  <script>\n    const grid = document.getElementById'
old_script_end = '  </script>\n</body>'

new_script = '''  <script>
    const grid = document.getElementById('grid-all');
    const searchInput = document.getElementById('search-input');
    const chipsContainer = document.getElementById('chips');
    const resultsCount = document.getElementById('results-count');
    let allOffers = [];
    let activeCat = 'all';
    let searchTerm = '';

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
      // Re-bind "Todos"
      chipsContainer.querySelector('[data-cat="all"]').addEventListener('click', () => {
        chipsContainer.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
        chipsContainer.querySelector('[data-cat="all"]').classList.add('active');
        activeCat = 'all';
        renderGrid();
      });
    }

    function renderGrid() {
      let filtered = allOffers;
      if (activeCat !== 'all') {
        filtered = filtered.filter(p => (p.categoria || p.categoriaAuto || '') === activeCat);
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
      resultsCount.textContent = filtered.length + ' oferta(s)';
    }

    searchInput.addEventListener('input', () => {
      searchTerm = searchInput.value.trim();
      renderGrid();
    });

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
</body>'''

# Faz o replace do script
import re
pattern = r'  <script>\s*\n    const grid = document\.getElementById.*?  </script>\s*\n</body>'
content = re.sub(pattern, new_script, content, flags=re.DOTALL)
print("✅ Script atualizado com chips dinâmicos")

with open("index.html", "w") as f:
    f.write(content)

# ─── admin.html: usa categoria bruta do ML ────────────────
with open("admin.html", "r") as f:
    content = f.read()

# Remove o mapeamento fixo e usa a categoria bruta
old_map = '''const catMap = {
          "celulares": "Celulares", "telefones": "Celulares", "celulares e telefones": "Celulares",
          "informática": "Informatica", "informatica": "Informatica", "notebooks": "Informatica",
          "games": "Games", "consoles": "Games", "games e consoles": "Games",
          "móveis": "Moveis", "moveis": "Moveis", "decoration": "Moveis", "decoração": "Moveis",
          "cozinha": "Cozinha", "mesa": "Cozinha", "utensílios": "Cozinha",
          "moda": "Moda", "acessórios": "Moda", "moda e acessórios": "Moda", "roupas": "Moda",
          "beleza": "Beleza", "saúde": "Beleza", "beleza e saúde": "Beleza", "perfumaria": "Beleza",
          "esportes": "Esportes", "fitness": "Esportes", "esportes e fitness": "Esportes",
          "animais": "Pet", "estimação": "Pet", "pet": "Pet",
          "brinquedos": "Infantil", "jogos": "Infantil", "infantil": "Infantil",
          "automotivo": "Automotivo", "auto": "Automotivo",
          "ferramentas": "Ferramentas", "construção": "Ferramentas",
          "livros": "Livros", "filmes": "Livros", "músicas": "Livros", "papelaria": "Livros"
        };
        function mapCategory(mlCat) {
          if (!mlCat) return "";
          const lower = mlCat.toLowerCase();
          for (const key in catMap) {
            if (lower.includes(key)) return catMap[key];
          }
          return "";
        }'''

new_map = '''function mapCategory(mlCat) {
          return mlCat || "";
        }'''

if old_map in content:
    content = content.replace(old_map, new_map)
    print("✅ Mapeamento fixo removido (agora usa categoria bruta)")
else:
    print("⚠️  Mapeamento não encontrado (pode já estar atualizado)")

with open("admin.html", "w") as f:
    f.write(content)

print("✅ Tudo salvo!")
PYEOF

echo ""
echo "Agora:"
echo "  git add ."
echo "  git commit -m 'Categorias dinâmicas - criadas automaticamente'"
echo "  git push"   
