with open('admin.html', 'r') as f:
    lines = f.readlines()

# Junta linhas 524, 525, 526 (indices 523, 524, 525) em uma só
for i in range(len(lines) - 2):
    if 'sem categoria.' in lines[i] and 'Use o select' in lines[i+2]:
        # Remove quebras e junta com \n literal
        part1 = lines[i].rstrip('\n').rstrip()
        part2 = lines[i+2].rstrip('\n').lstrip()
        lines[i] = part1 + '\\n\\n' + part2 + '\n'
        del lines[i+1]
        del lines[i+1]
        print(f'OK: linhas {i+1}-{i+3} juntadas')
        break
else:
    print('NAO ENCONTRADO')

with open('admin.html', 'w') as f:
    f.writelines(lines)   
