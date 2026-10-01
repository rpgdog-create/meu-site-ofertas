with open('admin.html', 'r') as f:
    lines = f.readlines()

# Linha 524 (índice 523) termina com quebra de linha
# Linha 525 (índice 524) começa com "Use o select..."
# Junta as duas em uma linha com \n literal

# Procura a linha com "sem categoria." que tem quebra
for i in range(len(lines) - 1):
    if 'sem categoria.' in lines[i] and 'Use o select' in lines[i+1]:
        lines[i] = lines[i].rstrip('\n') + '\\n' + lines[i+1].lstrip()
        del lines[i+1]
        print(f'OK: linha {i+1} corrigida')
        break
else:
    print('NAO ENCONTRADO')

with open('admin.html', 'w') as f:
    f.writelines(lines)   
