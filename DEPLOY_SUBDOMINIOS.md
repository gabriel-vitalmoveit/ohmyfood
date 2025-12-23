# 🚀 Deployment dos Subdomínios - Restaurant e Courier Apps

## ✅ Status Atual

- ✅ **Backend Railway:** Online e funcionando
- ✅ **Customer App:** `https://ohmyfood.eu` funcionando
- ✅ **Subdomínios criados no cPanel:**
  - `restaurante.ohmyfood.eu` → `/public_html/restaurante.ohmyfood.eu/`
  - `estafeta.ohmyfood.eu` → `/public_html/estafeta.ohmyfood.eu/`
- ✅ **Builds concluídos:**
  - Restaurant App: `apps/restaurant_app/build/web/`
  - Courier App: `apps/courier_app/build/web/`

---

## 📦 Passo a Passo - Upload

### 1️⃣ Restaurant App

**Diretório cPanel:** `/public_html/restaurante.ohmyfood.eu/`

#### Passo 1: Upload dos Arquivos

1. **Acessar cPanel File Manager**
2. **Navegar para:** `public_html/restaurante.ohmyfood.eu/`
3. **Upload** todos os arquivos de `apps/restaurant_app/build/web/`:
   - `index.html`
   - `main.dart.js`
   - `flutter.js`
   - `assets/` (pasta completa)
   - `canvaskit/` (pasta completa)
   - `icons/` (pasta completa)
   - Todos os outros arquivos

#### Passo 2: Criar `.htaccess`

Criar arquivo `.htaccess` no diretório `restaurante.ohmyfood.eu/` com o conteúdo:

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /restaurante.ohmyfood.eu/
  
  # SPA Routing - redirecionar todas as rotas para index.html
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule ^(.*)$ /restaurante.ohmyfood.eu/index.html [L]
</IfModule>

# Cache para assets estáticos
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType text/css "access plus 1 year"
  ExpiresByType application/javascript "access plus 1 year"
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType image/jpg "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/gif "access plus 1 year"
  ExpiresByType image/svg+xml "access plus 1 year"
</IfModule>
```

**Nota:** O arquivo `.htaccess` já foi criado em `public_html/restaurante.ohmyfood.eu/.htaccess` - basta fazer upload também.

---

### 2️⃣ Courier App (Estafeta)

**Diretório cPanel:** `/public_html/estafeta.ohmyfood.eu/`

#### Passo 1: Upload dos Arquivos

1. **Acessar cPanel File Manager**
2. **Navegar para:** `public_html/estafeta.ohmyfood.eu/`
3. **Upload** todos os arquivos de `apps/courier_app/build/web/`:
   - `index.html`
   - `main.dart.js`
   - `flutter.js`
   - `assets/` (pasta completa)
   - `canvaskit/` (pasta completa)
   - `icons/` (pasta completa)
   - Todos os outros arquivos

#### Passo 2: Criar `.htaccess`

Criar arquivo `.htaccess` no diretório `estafeta.ohmyfood.eu/` com o conteúdo:

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /estafeta.ohmyfood.eu/
  
  # SPA Routing - redirecionar todas as rotas para index.html
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule ^(.*)$ /estafeta.ohmyfood.eu/index.html [L]
</IfModule>

# Cache para assets estáticos
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType text/css "access plus 1 year"
  ExpiresByType application/javascript "access plus 1 year"
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType image/jpg "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/gif "access plus 1 year"
  ExpiresByType image/svg+xml "access plus 1 year"
</IfModule>
```

**Nota:** O arquivo `.htaccess` já foi criado em `public_html/estafeta.ohmyfood.eu/.htaccess` - basta fazer upload também.

---

## 📁 Estrutura Final no cPanel

```
public_html/
├── (arquivos do customer app)
│
├── restaurante.ohmyfood.eu/
│   ├── .htaccess
│   ├── index.html
│   ├── main.dart.js
│   ├── flutter.js
│   ├── assets/
│   ├── canvaskit/
│   └── icons/
│
└── estafeta.ohmyfood.eu/
    ├── .htaccess
    ├── index.html
    ├── main.dart.js
    ├── flutter.js
    ├── assets/
    ├── canvaskit/
    └── icons/
```

---

## ✅ Checklist de Deployment

### Restaurant App
- [x] Build concluído (`apps/restaurant_app/build/web/`)
- [x] `.htaccess` criado
- [ ] Upload dos arquivos para `/public_html/restaurante.ohmyfood.eu/`
- [ ] Upload do `.htaccess` para `/public_html/restaurante.ohmyfood.eu/`
- [ ] Testar `https://restaurante.ohmyfood.eu`
- [ ] Verificar se API está conectando

### Courier App
- [x] Build concluído (`apps/courier_app/build/web/`)
- [x] `.htaccess` criado
- [ ] Upload dos arquivos para `/public_html/estafeta.ohmyfood.eu/`
- [ ] Upload do `.htaccess` para `/public_html/estafeta.ohmyfood.eu/`
- [ ] Testar `https://estafeta.ohmyfood.eu`
- [ ] Verificar se API está conectando

---

## 🔍 Verificação Pós-Deployment

### 1. Testar URLs

```bash
# Restaurant App
https://restaurante.ohmyfood.eu

# Courier App
https://estafeta.ohmyfood.eu
```

### 2. Verificar Console do Navegador

- Abrir DevTools (F12)
- Verificar se há erros no Console
- Verificar se as requisições à API estão funcionando
- Verificar se a URL da API está correta: `https://ohmyfood-production-800c.up.railway.app/api`

### 3. Testar Funcionalidades

**Restaurant App:**
- [ ] Onboarding aparece (se necessário)
- [ ] Dashboard carrega
- [ ] Pedidos aparecem
- [ ] Menu management funciona
- [ ] Navegação entre tabs funciona

**Courier App:**
- [ ] Onboarding aparece (se necessário)
- [ ] Dashboard carrega
- [ ] Toggle online/offline funciona
- [ ] Pedidos disponíveis aparecem
- [ ] Navegação entre tabs funciona

---

## 📝 Notas Importantes

1. **API URL:** Ambas as apps estão configuradas para usar `https://ohmyfood-production-800c.up.railway.app/api`
2. **Builds:** Já foram feitos com `ENV=prod` e URL correta
3. **HTTPS:** Certifique-se de que os subdomínios têm SSL configurado no cPanel
4. **CORS:** Backend já está configurado para aceitar requisições dos subdomínios

---

## 🐛 Troubleshooting

### Erro 404 em rotas
- **Causa:** `.htaccess` não configurado ou incorreto
- **Solução:** Verificar se `.htaccess` está presente e com o caminho correto

### API não conecta
- **Causa:** URL da API incorreta
- **Solução:** Verificar `AppConfig.apiUrl` - deve ser `https://ohmyfood-production-800c.up.railway.app/api`

### Assets não carregam
- **Causa:** Caminhos incorretos ou arquivos faltando
- **Solução:** Verificar se todos os arquivos foram uploadados, especialmente as pastas `assets/`, `canvaskit/`, `icons/`

---

**Última Atualização:** 2025-12-23

