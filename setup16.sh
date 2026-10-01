cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

python3 << 'PYEOF'
import re

with open("admin.html", "r") as f:
    content = f.read()

# ─── 1. Substitui mapCategory (regex: da "function mapCategory" até a próxima linha com "}") ──
new_map = '''function mapCategory(mlCat) {
          if (!mlCat) return "";
          var clean = mlCat.trim();
          if (clean.length < 3) return "";
          if (clean.length > 50) return "";
          if (clean.includes("@")) return "";
          if (clean.toLowerCase().includes("vender")) return "";
          if (clean.toLowerCase().includes("igual")) return "";
          if (clean.toLowerCase().includes("comprar")) return "";
          if (clean.toLowerCase().includes("oferta")) return "";
          if (clean.toLowerCase().includes("imperd")) return "";
          if (clean.toLowerCase().includes("mais vendido")) return "";
          if (clean.match(/^[0-9]/)) return "";
          if (clean.match(/[|<>{}\\[\\]]/)) return "";
          return clean;
        }'''

content = re.sub(
    r'function mapCategory\(mlCat\)\s*\{.*?\n\s*\}',
    new_map,
    content,
    flags=re.DOTALL
)
print("1. mapCategory substituído")

# ─── 2. Substitui confirmBatch inteiro ─────────────────────
new_confirm = '''    function confirmBatch() {
      const catSel = document.getElementById("batch-categoria").value;
      const validItems = batchItems.filter(i => !i.erro);
      let blocked = 0;
      validItems.forEach(item => {
        const cat = (item.categoriaAuto && catSel === "Outros") ? item.categoriaAuto : catSel;
        if (!cat || (cat === "Outros" && !item.categoriaAuto)) {
          blocked++;
          return;
        }
        const offer = { nome: item.nome, preco: item.preco, link: item.link, categoria: cat };
        if (item.imagem) offer.imagem = item.imagem;
        const lk = (item.link || '').toLowerCase();
        if (lk.includes('mercadolivre') || lk.includes('meli.la') || lk.includes('rpgdog')) offer.marketplace = 'ML';
        else if (lk.includes('shopee')) offer.marketplace = 'Shopee';
        else if (lk.includes('amazon')) offer.marketplace = 'Amazon';
        if (item.frete) offer.frete = item.frete;
        offers.push(offer);
      });
      if (blocked > 0) {
        alert(blocked + " produto(s) NÃO adicionados: sem categoria válida.\\n\\nEscolha uma categoria no select acima e clique em Adicionar todos de novo, ou remova os produtos sem categoria.");
      }
      renderList();
      clearBatch();
    }'''

content = re.sub(
    r'    function confirmBatch\(\)\s*\{.*?\n    \}',
    new_confirm,
    content,
    flags=re.DOTALL
)
print("2. confirmBatch substituído")

# ─── 3. Remove auto-select (se existir) ────────────────────
content = re.sub(
    r'\n\s*const cats = batchItems\.map\(i => i\.categoriaAuto\).*?\n\s*\}',
    '',
    content,
    flags=re.DOTALL
)
print("3. Auto-select removido")

with open("admin.html", "w") as f:
    f.write(content)
print("\n✅ admin.html salvo!")
PYEOF

echo ""
echo "Agora:"
echo "  git add ."
echo "  git commit -m 'Validação de categoria + bloqueio'"
echo "  git push"   
