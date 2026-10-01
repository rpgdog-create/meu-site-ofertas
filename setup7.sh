cd ~/Programação/projetos/Meu_site_ofertas/meu-site-ofertas

python3 << 'PYEOF'
with open("admin.html", "r") as f:
    content = f.read()

# Substitui a seção de batch para aceitar o formato do bookmarklet
old_batch = '''      <!-- BATCH IMPORT -->
      <div class="admin-section">
        <h2>📥 Importar ofertas em lote</h2>
        <p style="font-size:0.85rem;color:#666;margin-bottom:0.8rem;">Cole os links abaixo (um por linha). Aceita <code>meli.la/...</code> ou URLs completas do ML.</p>'''

new_batch = '''      <!-- BATCH IMPORT -->
      <div class="admin-section">
        <h2>📥 Importar ofertas em lote</h2>
        <p style="font-size:0.85rem;color:#666;margin-bottom:0.5rem;"><strong>Método 1:</strong> Cole os dados copiados pelo bookmarklet <code>ML Copy</code> (um produto por linha).</p>
        <p style="font-size:0.85rem;color:#666;margin-bottom:0.8rem;"><strong>Método 2:</strong> Cole apenas os links (um por linha) — busca automática.</p>'''

if old_batch in content:
    content = content.replace(old_batch, new_batch)
    print("✅ Texto atualizado")
else:
    print("⚠️  Bloco não encontrado, tentando outro...")

# Atualiza a função batchFetch para detectar o formato do bookmarklet
old_fetch_start = '    async function batchFetch() {'
new_fetch = '''    async function batchFetch() {
      const raw = document.getElementById("batch-links").value.trim();
      const lines = raw.split("\\n").map(l => l.trim()).filter(l => l.length > 5);
      const statusEl = document.getElementById("batch-status");
      const progress = document.getElementById("progress");
      const fill = document.getElementById("progress-fill");
      const btn = document.getElementById("btn-batch");
      const results = document.getElementById("batch-results");
      const actions = document.getElementById("batch-actions");

      if (lines.length === 0) { alert("Cole pelo menos 1 linha."); return; }
      if (lines.length > 20) { alert("Máximo de 20 por vez."); return; }

      // Detecta formato do bookmarklet (tem |||)
      const isBookmarklet = lines[0].includes("|||");

      if (isBookmarklet) {
        // Formato: NOME|||PRECO|||IMAGEM|||FRETE|||URL
        batchItems = lines.map(line => {
          const parts = line.split("|||");
          return {
            nome: parts[0] || "Sem nome",
            preco: parts[1] || "0",
            imagem: parts[2] || "",
            frete: parts[3] || "Consultar frete",
            link: parts[4] || ""
          };
        });
        statusEl.style.display = "block";
        statusEl.className = "status success";
        statusEl.textContent = `✅ ${batchItems.length} produtos importados da área de transferência!`;
        progress.style.display = "none";
        renderBatchResults();
        actions.style.display = "block";
        return;
      }

      // Formato: links (busca automática via proxy)
      const links = lines;
      btn.disabled = true;
      btn.innerHTML = '<span class="loading"></span>';
      statusEl.style.display = "block";
      statusEl.className = "status info";
      progress.style.display = "block";
      results.innerHTML = "";
      actions.style.display = "none";
      batchItems = [];

      let ok = 0, fail = 0;
      for (let i = 0; i < links.length; i++) {
        const link = links[i];
        statusEl.textContent = `Buscando ${i + 1} de ${links.length}...`;
        fill.style.width = `${Math.round((i / links.length) * 100)}%`;
        try {
          const data = await fetchProductData(link);
          data.link = link;
          batchItems.push(data);
          ok++;
        } catch (e) {
          fail++;
          batchItems.push({ nome: "❌ Erro: " + e.message, preco: "0", link: link, erro: true });
        }
        renderBatchResults();
      }
      fill.style.width = "100%";
      statusEl.textContent = `✅ ${ok} encontrados, ${fail} falhas.`;
      statusEl.className = "status " + (fail === 0 ? "success" : "info");
      if (batchItems.length > 0) actions.style.display = "block";
      btn.disabled = false;
      btn.textContent = "🔍 Buscar todos";
    }'''

# Substitui a função batchFetch inteira
import re
pattern = r'    async function batchFetch\(\) \{.*?\n    \}\n\n    async function fetchProductData'
replacement = new_fetch + '\n\n    async function fetchProductData'
content = re.sub(pattern, replacement, content, flags=re.DOTALL)
print("✅ batchFetch atualizado")

with open("admin.html", "w") as f:
    f.write(content)
print("✅ admin.html salvo!")
PYEOF

echo ""
echo "Agora:"
echo "  git add ."
echo "  git commit -m 'Suporte a bookmarklet ML Copy'"
echo "  git push"   
