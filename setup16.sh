cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

python3 << 'PYEOF'
with open("admin.html", "r") as f:
    content = f.read()

# ─── 1. Remove o auto-select (se existir) ─────────────────
old_autoselect = '''        const cats = batchItems.map(i => i.categoriaAuto).filter(c => c);
        if (cats.length > 0 && cats.every(c => c === cats[0])) {
          const sel = document.getElementById("batch-categoria");
          if (sel) sel.value = cats[0];
        }'''
if old_autoselect in content:
    content = content.replace(old_autoselect, '')
    print("1. Auto-select removido")
else:
    print("1. Auto-select já não existe")

# ─── 2. Substitui a função mapCategory por uma com validação ─
old_map = '''function mapCategory(mlCat) {
          return mlCat || "";
        }'''

new_map = '''function mapCategory(mlCat) {
          if (!mlCat) return "";
          var clean = mlCat.trim();
          if (clean.length < 3) return "";
          if (clean.length > 50) return "";
          if (clean.includes("@")) return "";
          if (clean.includes("vender")) return "";
          if (clean.includes("igual")) return "";
          if (clean.includes("comprar")) return "";
          if (clean.includes("oferta")) return "";
          if (clean.includes("promo")) return "";
          if (clean.includes("imperd")) return "";
          if (clean.includes("mais vendido")) return "";
          if (clean.match(/^[0-9]/)) return "";
          if (clean.match(/\\s{3,}/)) return "";
          if (clean.match(/[|<>{}\\[\\]]/)) return "";
          return clean;
        }'''

if old_map in content:
    content = content.replace(old_map, new_map)
    print("2. mapCategory com validação")
else:
    print("2. mapCategory não encontrado (verificar)")

# ─── 3. Atualiza confirmBatch: impede sem categoria ───────
old_confirm = '''    function confirmBatch() {
      const catSel = document.getElementById("batch-categoria").value;
      valid.forEach(item => {
        const cat = (item.categoriaAuto && catSel === "Outros") ? item.categoriaAuto : catSel;
        const offer = { nome: item.nome, preco: item.preco, link: item.link, categoria: cat };'''

new_confirm = '''    function confirmBatch() {
      const catSel = document.getElementById("batch-categoria").value;
      const valid = batchItems.filter(i => !i.erro);
      let blocked = 0;
      const added = [];
      valid.forEach(item => {
        const cat = (item.categoriaAuto && catSel === "Outros") ? item.categoriaAuto : catSel;
        if (!cat || cat === "Outros" && !item.categoriaAuto) {
          blocked++;
          return;
        }
        const offer = { nome: item.nome, preco: item.preco, link: item.link, categoria: cat };'''

if old_confirm in content:
    content = content.replace(old_confirm, new_confirm)
    print("3. confirmBatch: bloqueio sem categoria")
else:
    print("3. confirmBatch antigo não encontrado, tentando outro...")
    # Tenta o padrão original (sem categoriaAuto)
    old_confirm2 = '''    function confirmBatch() {
      const catSel = document.getElementById("batch-categoria").value;
      valid.forEach(item => {
        const cat = (item.categoriaAuto && catSel === "Outros") ? item.categoriaAuto : catSel;
        const offer = { nome: item.nome, preco: item.preco, link: item.link, categoria: cat };'''
    if old_confirm2 in content:
        content = content.replace(old_confirm2, new_confirm)
        print("3. confirmBatch: bloqueio sem categoria (v2)")

# ─── 4. Adiciona o aviso de bloqueio no final do confirmBatch ──
old_push = '''        if (item.frete) offer.frete = item.frete;
        offers.push(offer);
      });
      renderList();
      clearBatch();
    }'''

new_push = '''        if (item.frete) offer.frete = item.frete;
        added.push(offer);
      });
      added.forEach(o => offers.push(o));
      if (blocked > 0) {
        alert(blocked + " produto(s) NÃO foram adicionados por não terem categoria válida.\\n\\nOpções:\\n• Escolha uma categoria no select e clique em Adicionar todos de novo\\n• Ou remova os produtos sem categoria da lista");
      }
      renderList();
      clearBatch();
    }'''

if old_push in content:
    content = content.replace(old_push, new_push)
    print("4. Aviso de bloqueio adicionado")
else:
    print("4. Bloco de push não encontrado")

with open("admin.html", "w") as f:
    f.write(content)
print("\\n✅ admin.html salvo!")
PYEOF

echo ""
echo "Agora:"
echo "  git add ."
echo "  git commit -m 'Validação de categoria + bloqueio de produtos sem categoria'"
echo "  git push"   
