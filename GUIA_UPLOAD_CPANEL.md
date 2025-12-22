# 📤 Guia Completo de Upload - Todas as Apps para cPanel

## ✅ Status dos Builds

Todos os builds foram concluídos com sucesso! 🎉

**Localizações dos builds:**
- ✅ Customer App: `apps/customer_app/build/web/`
- ✅ Restaurant App: `apps/restaurant_app/build/web/`
- ✅ Courier App: `apps/courier_app/build/web/`
- ✅ Admin Panel: `apps/admin_panel/build/web/`

---

## 📋 Estrutura Final no cPanel

```
/public_html/                  → Customer App (principal)
/public_html/restaurante/      → Restaurant App  
/public_html/entregador/       → Courier App
/public_html/admin/            → Admin Panel
```

---

## 🚀 Passo a Passo - Upload para cPanel

### 📍 Passo 1: Acessar cPanel

1. Acesse: `https://host.godaddy.com`
2. Faça login com suas credenciais
3. Abra **File Manager** (cPanel → Files → File Manager)

---

### 📍 Passo 2: Preparar Estrutura de Pastas

1. **Navegar para `/public_html`:**
   - Clique na pasta `public_html` no File Manager

2. **Criar subpastas (se não existirem):**
   - Clique em **+ Folder** (ou botão direito → Create Folder)
   - Crie as seguintes pastas:
     - `restaurante`
     - `entregador`
     - `admin`

---

### 📍 Passo 3: Upload Customer App (Principal)

**Localização dos arquivos:** `C:\Users\gabri\ohmyfood\ohmyfood\apps\customer_app\build\web\`

1. **Limpar `/public_html` (CUIDADO!):**
   - Selecione todos os arquivos antigos em `/public_html`
   - Clique em **Delete**
   - ⚠️ **IMPORTANTE:** Mantenha `.htaccess` e `ads.txt` se existirem!

2. **Upload dos arquivos:**
   
   **Opção A: Upload via ZIP (Recomendado)**
   - No Windows Explorer, navegue até: `C:\Users\gabri\ohmyfood\ohmyfood\apps\customer_app\build\web\`
   - Selecione todos os arquivos e pastas
   - Clique com botão direito → **Enviar para** → **Pasta compactada (zip)**
   - Nomeie como: `customer-app.zip`
   - No cPanel File Manager, clique em **Upload**
   - Arraste o arquivo `customer-app.zip` ou clique para selecionar
   - Aguarde upload completar
   - Clique com botão direito no ZIP → **Extract**
   - Delete o arquivo ZIP após extrair
   
   **Opção B: Upload direto**
   - No cPanel File Manager, clique em **Upload**
   - Selecione todos os arquivos e pastas de `apps/customer_app/build/web/`
   - Aguarde upload completar

3. **Verificar estrutura:**
   ```
   /public_html/
   ├── index.html
   ├── main.dart.js
   ├── flutter.js
   ├── flutter_bootstrap.js
   ├── flutter_service_worker.js
   ├── assets/
   ├── canvaskit/
   ├── icons/
   ├── favicon.png
   ├── manifest.json
   └── version.json
   ```

---

### 📍 Passo 4: Upload Restaurant App

**Localização dos arquivos:** `C:\Users\gabri\ohmyfood\ohmyfood\apps\restaurant_app\build\web\`

1. **Navegar para `/public_html/restaurante`:**
   - Clique na pasta `restaurante`

2. **Limpar pasta (se houver conteúdo antigo):**
   - Selecione todos os arquivos
   - Clique em **Delete**

3. **Upload dos arquivos:**
   - Siga o mesmo processo do Passo 3 (Opção A ou B)
   - Upload todos os arquivos de `apps/restaurant_app/build/web/` para `/public_html/restaurante/`

4. **Verificar estrutura:**
   ```
   /public_html/restaurante/
   ├── index.html
   ├── main.dart.js
   ├── flutter.js
   ├── assets/
   ├── canvaskit/
   └── icons/
   ```

---

### 📍 Passo 5: Upload Courier App

**Localização dos arquivos:** `C:\Users\gabri\ohmyfood\ohmyfood\apps\courier_app\build\web\`

1. **Navegar para `/public_html/entregador`:**
   - Clique na pasta `entregador`

2. **Limpar pasta (se houver conteúdo antigo):**
   - Selecione todos os arquivos
   - Clique em **Delete**

3. **Upload dos arquivos:**
   - Siga o mesmo processo do Passo 3
   - Upload todos os arquivos de `apps/courier_app/build/web/` para `/public_html/entregador/`

4. **Verificar estrutura:**
   ```
   /public_html/entregador/
   ├── index.html
   ├── main.dart.js
   ├── flutter.js
   ├── assets/
   ├── canvaskit/
   └── icons/
   ```

---

### 📍 Passo 6: Upload Admin Panel

**Localização dos arquivos:** `C:\Users\gabri\ohmyfood\ohmyfood\apps\admin_panel\build\web\`

1. **Navegar para `/public_html/admin`:**
   - Clique na pasta `admin`

2. **Limpar pasta (se houver conteúdo antigo):**
   - Selecione todos os arquivos
   - Clique em **Delete**

3. **Upload dos arquivos:**
   - Siga o mesmo processo do Passo 3
   - Upload todos os arquivos de `apps/admin_panel/build/web/` para `/public_html/admin/`

4. **Verificar estrutura:**
   ```
   /public_html/admin/
   ├── index.html
   ├── main.dart.js
   ├── flutter.js
   ├── assets/
   ├── canvaskit/
   └── icons/
   ```

---

### 📍 Passo 7: Configurar .htaccess

#### Para `/public_html/` (Customer App)

1. **Verificar se `.htaccess` existe:**
   - Se não existir, clique em **+ File** → Nome: `.htaccess`

2. **Editar `.htaccess`:**
   - Clique com botão direito em `.htaccess` → **Edit**
   - Cole o conteúdo abaixo:

```apache
# Flutter Web SPA Routing
RewriteEngine On
RewriteBase /

# Não reescrever se o arquivo/pasta existe
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d

# Redirecionar tudo para index.html
RewriteRule ^ index.html [L]

# Headers de segurança
Header set X-Content-Type-Options "nosniff"
Header set X-Frame-Options "SAMEORIGIN"
Header set X-XSS-Protection "1; mode=block"

# CORS (se necessário)
<IfModule mod_headers.c>
  Header set Access-Control-Allow-Origin "*"
  Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
</IfModule>

# Cache para assets
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType image/* "access plus 1 year"
  ExpiresByType application/javascript "access plus 1 year"
  ExpiresByType text/css "access plus 1 year"
</IfModule>
```

3. **Salvar:** Ctrl+S ou "Save Changes"

#### Para Subpastas (Restaurant, Courier, Admin)

Repita o processo acima para cada subpasta:
- `/public_html/restaurante/.htaccess`
- `/public_html/entregador/.htaccess`
- `/public_html/admin/.htaccess`

**IMPORTANTE:** Para subpastas, ajuste o `RewriteBase`:

```apache
# Para /public_html/restaurante/.htaccess
RewriteBase /restaurante/

# Para /public_html/entregador/.htaccess
RewriteBase /entregador/

# Para /public_html/admin/.htaccess
RewriteBase /admin/
```

---

### 📍 Passo 8: Verificar Permissões

1. **Selecionar todas as pastas:**
   - Clique com botão direito em cada pasta → **Change Permissions**
   - Defina: **755** (ou marque: Read, Write, Execute para Owner; Read, Execute para Group e Others)

2. **Selecionar todos os arquivos:**
   - Clique com botão direito em cada arquivo → **Change Permissions**
   - Defina: **644** (ou marque: Read, Write para Owner; Read para Group e Others)

---

### 📍 Passo 9: Testar Deploy

#### Customer App (Principal)
1. Abra: `https://ohmyfood.eu`
2. Verifique:
   - ✅ Página carrega sem erros
   - ✅ Logo e imagens aparecem
   - ✅ Navegação funciona (routing)
   - ✅ Chamadas à API funcionam

#### Restaurant App
1. Abra: `https://ohmyfood.eu/restaurante`
2. Verifique os mesmos itens acima

#### Courier App
1. Abra: `https://ohmyfood.eu/entregador`
2. Verifique os mesmos itens acima

#### Admin Panel
1. Abra: `https://ohmyfood.eu/admin`
2. Verifique os mesmos itens acima

#### DevTools (F12)
Para cada app, verifique:
- ✅ Console sem erros críticos
- ✅ Network mostra chamadas para Railway (`https://ohmyfood-production-800c.up.railway.app`)
- ✅ Recursos carregando (200 OK)

---

## 📦 Resumo dos Arquivos para Upload

### Customer App → `/public_html/`
```
C:\Users\gabri\ohmyfood\ohmyfood\apps\customer_app\build\web\
```

### Restaurant App → `/public_html/restaurante/`
```
C:\Users\gabri\ohmyfood\ohmyfood\apps\restaurant_app\build\web\
```

### Courier App → `/public_html/entregador/`
```
C:\Users\gabri\ohmyfood\ohmyfood\apps\courier_app\build\web\
```

### Admin Panel → `/public_html/admin/`
```
C:\Users\gabri\ohmyfood\ohmyfood\apps\admin_panel\build\web\
```

---

## ✅ Checklist Final

### Builds
- [x] Customer App compilado
- [x] Restaurant App compilado
- [x] Courier App compilado
- [x] Admin Panel compilado
- [x] Todos com API_BASE_URL correto

### Upload
- [ ] Customer App upado para `/public_html/`
- [ ] Restaurant App upado para `/public_html/restaurante/`
- [ ] Courier App upado para `/public_html/entregador/`
- [ ] Admin Panel upado para `/public_html/admin/`

### Configuração
- [ ] `.htaccess` configurado em `/public_html/`
- [ ] `.htaccess` configurado em `/public_html/restaurante/`
- [ ] `.htaccess` configurado em `/public_html/entregador/`
- [ ] `.htaccess` configurado em `/public_html/admin/`
- [ ] Permissões corretas (755 pastas, 644 arquivos)

### Testes
- [ ] Customer App funciona em `https://ohmyfood.eu`
- [ ] Restaurant App funciona em `https://ohmyfood.eu/restaurante`
- [ ] Courier App funciona em `https://ohmyfood.eu/entregador`
- [ ] Admin Panel funciona em `https://ohmyfood.eu/admin`
- [ ] Console sem erros
- [ ] API conectando corretamente

---

## 🔧 Troubleshooting

### ❌ Página em branco
- Verificar se `index.html` está na pasta correta
- Verificar console do navegador (F12) para erros
- Verificar se todos os assets foram upados

### ❌ Erro 404 ao navegar
- Verificar se `.htaccess` existe e está configurado
- Verificar se `RewriteBase` está correto para subpastas
- Rewrite rules do Apache podem estar desabilitadas

### ❌ Assets não carregam
- Verificar se pasta `assets/` foi upada
- Verificar permissões (755 para pastas, 644 para arquivos)
- Verificar caminhos no console do navegador

### ❌ API não conecta (CORS)
- Verificar se `API_BASE_URL` foi definido no build (já configurado ✅)
- Verificar se Railway está online
- Verificar CORS no backend Railway

---

## 📚 URLs Finais

- **Customer App:** `https://ohmyfood.eu`
- **Restaurant App:** `https://ohmyfood.eu/restaurante`
- **Courier App:** `https://ohmyfood.eu/entregador`
- **Admin Panel:** `https://ohmyfood.eu/admin`

---

**Status:** ✅ Builds concluídos - Pronto para upload  
**Última atualização:** 22/12/2025

