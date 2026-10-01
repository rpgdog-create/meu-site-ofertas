cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

python3 << 'PYEOF'
# ─── index.html: substitui os chips ───────────────────────
with open("index.html", "r") as f:
    content = f.read()

old_chips = '''<span class="chip active" data-cat="all">Todos</span>
    <span class="chip" data-cat="Eletronicos">Eletrônicos</span>
    <span class="chip" data-cat="Casa">Casa & Cozinha</span>
    <span class="chip" data-cat="Moda">Moda</span>
    <span class="chip" data-cat="Beleza">Beleza</span>
    <span class="chip" data-cat="Esportes">Esportes</span>
    <span class="chip" data-cat="Outros">Outros</span>'''

new_chips = '''<span class="chip active" data-cat="all">Todos</span>
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
    <span class="chip" data-cat="Outros">Outros</span>'''

if old_chips in content:
    content = content.replace(old_chips, new_chips)
    print("✅ Chips atualizados no index.html")
else:
    print("⚠️  Chips não encontrados (verifique se já foram alterados)")

with open("index.html", "w") as f:
    f.write(content)

# ─── admin.html: substitui o select ───────────────────────
with open("admin.html", "r") as f:
    content = f.read()

old_select = '''<select id="batch-categoria" style="width:100%;padding:0.6rem;border:1px solid #ddd;border-radius:6px;font-size:0.9rem;">
            <option value="Outros">Outros</option>
            <option value="Eletronicos">Eletrônicos</option>
            <option value="Casa">Casa & Cozinha</option>
            <option value="Moda">Moda</option>
            <option value="Beleza">Beleza</option>
            <option value="Esportes">Esportes</option>
          </select>'''

new_select = '''<select id="batch-categoria" style="width:100%;padding:0.6rem;border:1px solid #ddd;border-radius:6px;font-size:0.9rem;">
            <option value="Outros">Outros</option>
            <option value="Celulares">Celulares & Tablets</option>
            <option value="Informatica">Informática</option>
            <option value="Games">Games & Consoles</option>
            <option value="Moveis">Móveis & Decoração</option>
            <option value="Cozinha">Cozinha & Utensílios</option>
            <option value="Moda">Moda</option>
            <option value="Beleza">Beleza & Saúde</option>
            <option value="Esportes">Esportes & Fitness</option>
            <option value="Pet">Pet</option>
            <option value="Infantil">Brinquedos & Infantil</option>
            <option value="Automotivo">Automotivo</option>
            <option value="Ferramentas">Ferramentas</option>
            <option value="Livros">Livros & Papelaria</option>
          </select>'''

if old_select in content:
    content = content.replace(old_select, new_select)
    print("✅ Select atualizado no admin.html")
else:
    print("⚠️  Select não encontrado (verifique se já foi alterado)")

with open("admin.html", "w") as f:
    f.write(content)

print("✅ Tudo salvo!")
PYEOF

echo ""
echo "Agora:"
echo "  git add ."
echo "  git commit -m 'Mais categorias de produtos'"
echo "  git push"   
