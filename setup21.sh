cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

python3 << 'PYEOF'
with open("admin.html", "r") as f:
    c = f.read()

# Substitui o CAT_OPTIONS
old_options = 'var CAT_OPTIONS = ["Celulares","Informatica","Games","Moveis","Cozinha","Moda","Beleza","Esportes","Pet","Infantil","Automotivo","Ferramentas","Livros","Outros"];'

new_options = '''var CAT_OPTIONS = [
  "Acessórios para Veículos",
  "Agro",
  "Alimentos e Bebidas",
  "Animais",
  "Antiguidades e Coleções",
  "Arte, Papelaria e Armarinho",
  "Bebês",
  "Beleza e Cuidado Pessoal",
  "Brinquedos e Hobbies",
  "Calçados, Roupas e Bolsas",
  "Carros, Motos e Outros",
  "Casa, Móveis e Decoração",
  "Celulares e Telefones",
  "Câmeras e Acessórios",
  "Construção",
  "Eletrodomésticos",
  "Eletrônicos, Áudio e Vídeo",
  "Esportes e Fitness",
  "Ferramentas",
  "Festas e Lembrancinhas",
  "Games",
  "Indústria e Comércio",
  "Ingressos",
  "Instrumentos Musicais",
  "Joias e Relógios",
  "Livros, Revistas e Comics",
  "Música, Filmes e Seriados",
  "Saúde",
  "Serviços",
  "Televisores",
  "Informática",
  "Outros"
];'''

if old_options in c:
    c = c.replace(old_options, new_options)
    print("1. CAT_OPTIONS atualizado")
else:
    print("1. CAT_OPTIONS nao encontrado")

# Substitui o select global (batch-categoria)
old_select = '''<select id="batch-categoria">
              <option value="">Nenhuma (exige categoria individual)</option>
              <option value="Celulares">Celulares e Tablets</option>
              <option value="Informatica">Informatica</option>
              <option value="Games">Games e Consoles</option>
              <option value="Moveis">Moveis e Decoracao</option>
              <option value="Cozinha">Cozinha e Utensilios</option>
              <option value="Moda">Moda</option>
              <option value="Beleza">Beleza e Saude</option>
              <option value="Esportes">Esportes e Fitness</option>
              <option value="Pet">Pet</option>
              <option value="Infantil">Brinquedos e Infantil</option>
              <option value="Automotivo">Automotivo</option>
              <option value="Ferramentas">Ferramentas</option>
              <option value="Livros">Livros e Papelaria</option>
              <option value="Outros">Outros</option>
            </select>'''

new_select = '''<select id="batch-categoria">
              <option value="">Nenhuma (exige categoria individual)</option>
              <option value="Acessórios para Veículos">Acessórios para Veículos</option>
              <option value="Agro">Agro</option>
              <option value="Alimentos e Bebidas">Alimentos e Bebidas</option>
              <option value="Animais">Animais (Pet)</option>
              <option value="Antiguidades e Coleções">Antiguidades e Coleções</option>
              <option value="Arte, Papelaria e Armarinho">Arte, Papelaria e Armarinho</option>
              <option value="Bebês">Bebês</option>
              <option value="Beleza e Cuidado Pessoal">Beleza e Cuidado Pessoal</option>
              <option value="Brinquedos e Hobbies">Brinquedos e Hobbies</option>
              <option value="Calçados, Roupas e Bolsas">Calçados, Roupas e Bolsas</option>
              <option value="Carros, Motos e Outros">Carros, Motos e Outros</option>
              <option value="Casa, Móveis e Decoração">Casa, Móveis e Decoração</option>
              <option value="Celulares e Telefones">Celulares e Telefones</option>
              <option value="Câmeras e Acessórios">Câmeras e Acessórios</option>
              <option value="Construção">Construção</option>
              <option value="Eletrodomésticos">Eletrodomésticos</option>
              <option value="Eletrônicos, Áudio e Vídeo">Eletrônicos, Áudio e Vídeo</option>
              <option value="Esportes e Fitness">Esportes e Fitness</option>
              <option value="Ferramentas">Ferramentas</option>
              <option value="Festas e Lembrancinhas">Festas e Lembrancinhas</option>
              <option value="Games">Games</option>
              <option value="Indústria e Comércio">Indústria e Comércio</option>
              <option value="Ingressos">Ingressos</option>
              <option value="Instrumentos Musicais">Instrumentos Musicais</option>
              <option value="Joias e Relógios">Joias e Relógios</option>
              <option value="Livros, Revistas e Comics">Livros, Revistas e Comics</option>
              <option value="Música, Filmes e Seriados">Música, Filmes e Seriados</option>
              <option value="Saúde">Saúde</option>
              <option value="Serviços">Serviços</option>
              <option value="Televisores">Televisores</option>
              <option value="Informática">Informática</option>
              <option value="Outros">Outros</option>
            </select>'''

if old_select in c:
    c = c.replace(old_select, new_select)
    print("2. Select global atualizado")
else:
    print("2. Select global nao encontrado (verificar)")

with open("admin.html", "w") as f:
    f.write(c)
print("\nOK")
PYEOF

echo ""
echo "Agora:"
echo "  git add ."
echo "  git commit -m 'Todas as categorias do ML'"
echo "  git push"   
