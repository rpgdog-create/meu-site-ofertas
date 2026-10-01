cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

python3 << 'PYEOF'
import re

with open("admin.html", "r") as f:
    c = f.read()

# ─── 1. Substitui renderBatchResults ──────────────────────
new_render = '''    function renderBatchResults() {
      var results = document.getElementById("batch-results");
      var catOptions = ['Outros','Celulares','Informatica','Games','Moveis','Cozinha','Moda','Beleza','Esportes','Pet','Infantil','Automotivo','Ferramentas','Livros'];
      results.innerHTML = batchItems.map(function(item, i) {
        var catHtml;
        if (item.categoriaAuto) {
          catHtml = '<span style="font-size:0.7rem;color:#00a650;">' + item.categoriaAuto + '</span>';
        } else {
          var opts = catOptions.map(function(o) {
            return '<option value="' + o + '">' + o + '</option>';
          }).join('');
          catHtml = '<select onchange="setBatchCat(' + i + ',this.value)" style="font-size:0.75rem;padding:0.2rem;border:1px solid #ddd;border-radius:4px;">' + opts + '</select>';
        }
        return '<div class="batch-item" style="' + (item.erro ? 'opacity:0.5;' : '') + '">' +
          (item.imagem ? '<img src="' + item.imagem + '" alt="">' : '<div style="width:50px;height:50px;background:#eee;border-radius:4px;"></div>') +
          '<div class="bi-info"><h5>' + item.nome + '</h5><p class="bi-frete">' + (item.frete || "") + '</p><p style="margin-top:0.2rem;">' + catHtml + '</p></div>' +
          '<span class="bi-price">R$ ' + Number(item.preco).toFixed(2) + '</span>' +
          (!item.erro ? '<button class="bi-remove" onclick="removeBatchItem(' + i + ')" title="Remover">\u2715</button>' : '') +
          '</div>';
      }).join("");
    }

    function setBatchCat(index, value) {
      if (value === "Outros") {
        batchItems[index].categoriaAuto = "";
      } else {
        batchItems[index].categoriaAuto = value;
      }
      renderBatchResults();
    }'''

c = re.sub(
    r'    function renderBatchResults\(\)\s*\{.*?\n    \}',
    new_render,
    c,
    flags=re.DOTALL
)
print("1. renderBatchResults substituído")

# ─── 2. Substitui confirmBatch ────────────────────────────
new_confirm = '''    function confirmBatch() {
      var catSel = document.getElementById("batch-categoria").value;
      var validItems = batchItems.filter(function(i) { return !i.erro; });
      var blocked = 0;
      validItems.forEach(function(item) {
        var cat = item.categoriaAuto || (catSel !== "Outros" ? catSel : "");
        if (!cat) {
          blocked++;
          return;
        }
        var offer = { nome: item.nome, preco: item.preco, link: item.link, categoria: cat };
        if (item.imagem) offer.imagem = item.imagem;
        var lk = (item.link || "").toLowerCase();
        if (lk.indexOf("mercadolivre") !== -1 || lk.indexOf("meli.la") !== -1 || lk.indexOf("rpgdog") !== -1) offer.marketplace = "ML";
        else if (lk.indexOf("shopee") !== -1) offer.marketplace = "Shopee";
        else if (lk.indexOf("amazon") !== -1) offer.marketplace = "Amazon";
        if (item.frete) offer.frete = item.frete;
        offers.push(offer);
      });
      if (blocked > 0) {
        alert(blocked + " produto(s) NAO adicionados: sem categoria.\\n\\nUse o select ao lado de cada produto para escolher a categoria, ou escolha uma no select global acima.");
      }
      renderList();
      clearBatch();
    }'''

c = re.sub(
    r'    function confirmBatch\(\)\s*\{.*?\n    \}',
    new_confirm,
    c,
    flags=re.DOTALL
)
print("2. confirmBatch substituído")

with open("admin.html", "w") as f:
    f.write(c)
print("\nOK")
PYEOF

echo ""
echo "Agora:"
echo "  git add ."
echo "  git commit -m 'Categoria individual por produto'"
echo "  git push"   
