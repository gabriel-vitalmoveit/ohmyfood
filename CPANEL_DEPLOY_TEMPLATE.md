# 📦 Template de Deploy para cPanel - OhMyFood

## 🎯 Objetivo

Este guia mostra como fazer deploy do(s) app(s) Flutter Web compilado(s) no cPanel GoDaddy.

---

## 📋 Pré-requisitos

✅ Backend deployado no Railway: `https://ohmyfood-production-800c.up.railway.app`  
✅ Flutter instalado localmente  
✅ Acesso ao cPanel GoDaddy  
✅ Repositório GitHub atualizado  

---

## 🏗️ Estrutura do Projeto

```
ohmyfood/
├── apps/
│   ├── customer_app/    → App Cliente (Principal)
│   ├── restaurant_app/  → App Restaurante  
│   ├── courier_app/     → App Entregador
│   └── admin_panel/     → Painel Admin
├── backend/api/         → Backend NestJS (Railway)
└── public_html/         → Deploy cPanel
```

---

## 🚀 Passo a Passo - Deploy cPanel

### 📍 Passo 1: Build Flutter Web Localmente

#### Opção A: Customer App (Principal)
```bash
cd apps/customer_app
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=https://ohmyfood-production-800c.up.railway.app
```

#### Opção B: Restaurant App
```bash
cd apps/restaurant_app
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=https://ohmyfood-production-800c.up.railway.app
```

#### Opção C: Courier App  
```bash
cd apps/courier_app
flutter pub get  
flutter build web --release --dart-define=API_BASE_URL=https://ohmyfood-production-800c.up.railway.app
```

#### Opção D: Admin Panel
```bash
cd apps/admin_panel
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=https://ohmyfood-production-800c.up.railway.app
```

**📁 Output:** `apps/[app_name]/build/web/`

---

### 📍 Passo 2: Preparar Arquivos para Upload

1. **Navegar até a pasta build:**
   ```bash
   cd apps/customer_app/build/web
   ```

2. **Verificar conteúdo:**
   - ✅ `index.html`
   - ✅ `main.dart.js`
   - ✅ `flutter.js`
   - ✅ `assets/` (pasta)
   - ✅ `canvaskit/` (pasta)
   - ✅ `icons/` (pasta)

3. **Compactar (opcional, recomendado):**
   ```bash
   # Windows PowerShell
   Compress-Archive -Path * -DestinationPath ohmyfood-customer.zip
   
   # Linux/Mac
   zip -r ohmyfood-customer.zip *
   ```

---

### 📍 Passo 3: Upload para cPanel

#### Via File Manager (Recomendado)

1. **Acessar cPanel:**
   - URL: `https://host.godaddy.com`
   - Login com suas credenciais

2. **Abrir File Manager:**
   - cPanel → Files → **File Manager**

3. **Navegar para `/public_html`:**
   - Clique na pasta `public_html`

4. **Limpar pasta (CUIDADO!):**
   - Selecione todos os arquivos antigos
   - Clique em **Delete**
   - **⚠️ IMPORTANTE:** Mantenha `.htaccess` e `ads.txt` se existirem!

5. **Upload de arquivos:**
   
   **Opção A: Upload do ZIP**
   - Clique em **Upload**
   - Selecione `ohmyfood-customer.zip`
   - Aguarde upload completar
   - Clique com botão direito no ZIP → **Extract**
   - Delete o arquivo ZIP após extrair
   
   **Opção B: Upload direto**
   - Clique em **Upload**
   - Selecione todos os arquivos da pasta `build/web/`
   - Aguarde upload completar

6. **Verificar estrutura final:**
   ```
   /public_html/
   ├── index.html
   ├── main.dart.js
   ├── flutter.js
   ├── assets/
   ├── canvaskit/
   ├── icons/
   ├── .htaccess (manter!)
   └── ads.txt (manter!)
   ```

---

### 📍 Passo 4: Configurar .htaccess (SPA Routing)

Se o arquivo `.htaccess` não existir ou estiver vazio, crie/atualize com:

**Via File Manager:**
1. Clique em **+ File**
2. Nome: `.htaccess`
3. Clique com botão direito → **Edit**
4. Cole o conteúdo abaixo:

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

5. Salvar (Ctrl+S ou "Save Changes")

---

### 📍 Passo 5: Testar Deploy

1. **Abrir no navegador:**
   - URL: `https://ohmyfood.eu`
   - Ou: `https://www.ohmyfood.eu`

2. **Verificar:**
   - ✅ Página carrega sem erros
   - ✅ Logo e imagens aparecem
   - ✅ Navegação funciona (routing)
   - ✅ Chamadas à API funcionam

3. **Verificar DevTools (F12):**
   - ✅ Console sem erros críticos
   - ✅ Network mostra chamadas para Railway
   - ✅ Recursos carregando (200 OK)

---

## 🔄 Deploy de Múltiplos Apps (Subdomínios)

Para hospedar diferentes apps em subdomínios:

### Estrutura Recomendada:

```
/public_html/                  → Customer App (principal)
/public_html/restaurante/      → Restaurant App  
/public_html/entregador/       → Courier App
/public_html/admin/            → Admin Panel
```

### Passos:

1. **Criar subpastas:**
   - File Manager → `/public_html/`
   - Clique **+ Folder**
   - Nomes: `restaurante`, `entregador`, `admin`

2. **Upload de cada app:**
   - Repetir Passo 3 para cada pasta
   - Cada pasta deve ter seu próprio `.htaccess`

3. **Configurar Subdomínios (opcional):**
   - cPanel → **Subdomains**
   - Criar: `restaurante.ohmyfood.eu` → `/public_html/restaurante`
   - Criar: `entregador.ohmyfood.eu` → `/public_html/entregador`
   - Criar: `admin.ohmyfood.eu` → `/public_html/admin`

**URLs Finais:**
- Customer: `https://ohmyfood.eu`
- Restaurant: `https://ohmyfood.eu/restaurante` ou `https://restaurante.ohmyfood.eu`
- Courier: `https://ohmyfood.eu/entregador` ou `https://entregador.ohmyfood.eu`
- Admin: `https://ohmyfood.eu/admin` ou `https://admin.ohmyfood.eu`

---

## 🔧 Troubleshooting

### ❌ Página em branco
- Verificar se `index.html` está na raiz de `/public_html/`
- Verificar console do navegador (F12) para erros
- Verificar se todos os assets foram upados

### ❌ Erro 404 ao navegar
- Verificar se `.htaccess` existe e está configurado
- Rewrite rules do Apache podem estar desabilitadas

### ❌ Assets não carregam (imagens, fontes)
- Verificar se pasta `assets/` foi upada
- Verificar permissões (devem ser 755 para pastas, 644 para arquivos)

### ❌ API não conecta (CORS)
- Verificar se `API_BASE_URL` foi definido no build
- Verificar se Railway está online
- Verificar CORS no backend Railway

---

## ✅ Checklist Final

- [ ] Backend Railway online e acessível
- [ ] Flutter Web compilado com API_BASE_URL correto
- [ ] Arquivos upados para `/public_html/`
- [ ] `.htaccess` configurado para SPA routing
- [ ] `ads.txt` mantido (se existir)
- [ ] Site abre em `https://ohmyfood.eu`
- [ ] Navegação funciona sem recarregar
- [ ] Chamadas à API funcionando
- [ ] Console sem erros críticos

---

## 📚 Recursos Adicionais

- **Backend Railway:** https://railway.com/project/...
- **cPanel GoDaddy:** https://host.godaddy.com
- **Documentação Flutter Web:** https://docs.flutter.dev/platform-integration/web

---

**Status:** ✅ Template completo e pronto para uso  
**Última atualização:** 22/12/2025
