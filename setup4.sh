cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

# Gera um patch: substitui a função fetchProductData no admin.html
python3 << 'PYEOF'
import re

with open("admin.html", "r") as f:
    content = f.read()

old_func = '''    async function fetchProductData(url) {
      let productUrl = url;

      // Resolve meli.la
      if (url.includes("meli.la")) {
        const res = await fetch(CORS_PROXY + encodeURIComponent(url), { redirect: "follow" });
        productUrl = res.url;
        if (!productUrl.includes("mercadolivre.com")) {
          const html = await res.text();
          const match = html.match(/https?:\\/\\/(?:www\\.)?(?:produto\\.)?mercadolivre\\.com\\.br\\/[^\\s"']+/);
          if (match) productUrl = match[0];
        }
      }

      const idMatch = productUrl.match(/MLB\\d+/);
      if (!idMatch) throw new Error("ID não encontrado na URL");
      const itemId = idMatch[0];

      // Tenta API ML
      let data = null;
      try {
        const apiUrl = CORS_PROXY + encodeURIComponent(`https://api.mercadolibre.com/items/${itemId}`);
        const apiRes = await fetch(apiUrl);
        if (apiRes.ok) data = await apiRes.json();
      } catch(e) {}

      // Fallback: página HTML
      if (!data || !data.title) {
        const pageRes = await fetch(CORS_PROXY + encodeURIComponent(`https://www.mercadolivre.com.br/p/${itemId}`));
        const html = await pageRes.text();
        data = parseMLPage(html);
      }

      if (!data || (!data.nome && !data.title)) throw new Error("Dados não encontrados");

      const nome = data.nome || data.title || "Produto sem nome";
      const preco = data.preco || data.price || "0";
      const imagem = data.imagem || data.image || "";
      const freeShip = /frete\\s*gr[aá]tis/i.test(html || (data.shipping || ""));
      const frete = freeShip ? "Grátis" : "Consultar frete";

      return { nome, preco: String(preco), imagem, frete, link: url };
    }'''

new_func = '''    async function fetchProductData(url) {
      let itemId = null;
      let pageHtml = "";

      // Extrai ID
      if (url.includes("meli.la")) {
        // Proxy segue redirect e retorna HTML da página final
        const res = await fetch(CORS_PROXY + encodeURIComponent(url));
        pageHtml = await res.text();
        const idMatch = pageHtml.match(/MLB\\d{6,}/);
        if (idMatch) itemId = idMatch[0];
      } else if (url.includes("mercadolivre.com")) {
        const idMatch = url.match(/MLB\\d{6,}/);
        if (idMatch) itemId = idMatch[0];
      }

      if (!itemId) throw new Error("ID MLB não encontrado");

      // Tenta API ML (mais confiável)
      let data = null;
      try {
        const apiUrl = CORS_PROXY + encodeURIComponent(`https://api.mercadolibre.com/items/${itemId}`);
        const apiRes = await fetch(apiUrl);
        if (apiRes.ok) data = await apiRes.json();
      } catch(e) {}

      // Fallback: HTML (usa o já baixado se vier do meli.la)
      if (!data || !data.title) {
        if (!pageHtml) {
          const pageRes = await fetch(CORS_PROXY + encodeURIComponent(`https://www.mercadolivre.com.br/p/${itemId}`));
          pageHtml = await pageRes.text();
        }
        data = parseMLPage(pageHtml);
      }

      if (!data || (!data.nome && !data.title)) throw new Error("Dados não encontrados");

      const nome = data.nome || data.title || "Produto sem nome";
      const preco = data.preco || data.price || "0";
      const imagem = data.imagem || data.image || "";
      const freeShip = /frete\\s*gr[aá]tis/i.test(pageHtml || (data.shipping || ""));
      const frete = freeShip ? "Grátis" : "Consultar frete";

      return { nome, preco: String(preco), imagem, frete, link: url };
    }'''

if old_func in content:
    content = content.replace(old_func, new_func)
    with open("admin.html", "w") as f:
        f.write(content)
    print("✅ fetchProductData corrigido!")
else:
    print("⚠️  Função antiga não encontrada. Tente o método manual abaixo.")
PYEOF

echo ""
echo "Agora:"
echo "  git add ."
echo "  git commit -m 'Fix: extrair ID MLB do HTML retornado pelo proxy'"
echo "  git push"   
