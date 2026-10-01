cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas
sed -i '' 's|https://api.allorigins.win/raw?url=|https://api.codetabs.com/v1/proxy?quest=|' admin.html
echo "✅ Proxy trocado para codetabs.com"
echo ""
echo "Agora:"
echo "  git add ."
echo "  git commit -m 'Trocar CORS proxy para codetabs'"
echo "  git push"   
