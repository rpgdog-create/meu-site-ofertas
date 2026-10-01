cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

python3 -c "
with open('admin.html','r') as f:
    c = f.read()
old = 'sem categoria.\n\nUse o select'
new = 'sem categoria. \\n\\n Use o select'
if old in c:
    c = c.replace(old, new)
    with open('admin.html','w') as f:
        f.write(c)
    print('OK')
else:
    print('NAO ENCONTRADO')
"   
