cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

python3 << 'PYEOF'
import re
with open('admin.html','r') as f:
    c = f.read()

new_map = '''function mapCategory(mlCat) {
          if (!mlCat) return "";
          var clean = mlCat.trim();
          if (clean.length < 3) return "";
          if (clean.length > 50) return "";
          if (clean.indexOf("@") !== -1) return "";
          var lower = clean.toLowerCase();
          if (lower.indexOf("vender") !== -1) return "";
          if (lower.indexOf("igual") !== -1) return "";
          if (lower.indexOf("comprar") !== -1) return "";
          if (lower.indexOf("oferta") !== -1) return "";
          if (lower.indexOf("imperd") !== -1) return "";
          if (lower.indexOf("mais vendido") !== -1) return "";
          if (clean.charAt(0) >= "0" && clean.charAt(0) <= "9") return "";
          return clean;
        }'''

c = re.sub(
    r'function mapCategory\(mlCat\)\s*\{.*?\n\s*\}',
    new_map,
    c,
    flags=re.DOTALL
)
with open('admin.html','w') as f:
    f.write(c)
print('OK')
PYEOF   
