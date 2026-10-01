cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

python3 << 'PYEOF'
with open("admin.html", "r") as f:
    content = f.read()

# Adiciona a função de mapeamento + atualiza o parsing do bookmarklet
old_parse = '''if (lines[0].includes("|||")) {
        batchItems = lines.map(line => {
          const parts = line.split("|||");
          return {
            nome: (parts[0] || "Sem nome").trim(),
            preco: (parts[1] || "0").trim(),
            imagem: (parts[2] || "").trim(),
            frete: (parts[3] || "Consultar frete").trim(),
            link: (parts[4] || "").trim()
          };
        });'''

new_parse = '''if (lines[0].includes("|||")) {
        const catMap = {
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
        }
        batchItems = lines.map(line => {
          const parts = line.split("|||");
          const mlCat = (parts[5] || "").trim();
          const mapped = mapCategory(mlCat);
          return {
            nome: (parts[0] || "Sem nome").trim(),
            preco: (parts[1] || "0").trim(),
            imagem: (parts[2] || "").trim(),
            frete: (parts[3] || "Consultar frete").trim(),
            link: (parts[4] || "").trim(),
            categoriaAuto: mapped || ""
          };
        });
        // Auto-seleciona categoria no select se todos forem a mesma
        const cats = batchItems.map(i => i.categoriaAuto).filter(c => c);
        if (cats.length > 0 && cats.every(c => c === cats[0])) {
          const sel = document.getElementById("batch-categoria");
          if (sel) sel.value = cats[0];
        }'''

if old_parse in content:
    content = content.replace(old_parse, new_parse)
    print("✅ Parsing atualizado com mapeamento de categoria")
else:
    print("⚠️  Bloco de parsing não encontrado")

# Atualiza confirmBatch pra usar categoriaAuto se o select estiver em "Outros"
old_confirm = '''const cat = document.getElementById("batch-categoria").value;
      valid.forEach(item => {
        const offer = { nome: item.nome, preco: item.preco, link: item.link, categoria: cat };'''

new_confirm = '''const catSel = document.getElementById("batch-categoria").value;
      valid.forEach(item => {
        const cat = (item.categoriaAuto && catSel === "Outros") ? item.categoriaAuto : catSel;
        const offer = { nome: item.nome, preco: item.preco, link: item.link, categoria: cat };'''

if old_confirm in content:
    content = content.replace(old_confirm, new_confirm)
    print("✅ confirmBatch atualizado")
else:
    print("⚠️  confirmBatch não encontrado")

with open("admin.html", "w") as f:
    f.write(content)
print("✅ admin.html salvo!")
PYEOF

echo ""
echo "Agora:"
echo "  git add ."
echo "  git commit -m 'Categoria automática do ML'"
echo "  git push"   
