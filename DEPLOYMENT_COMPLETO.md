# 🚀 Deployment Completo - OhMyFood

## ✅ Status dos Builds

Todas as apps foram construídas com sucesso:

- ✅ **Customer App** - `apps/customer_app/build/web/`
- ✅ **Restaurant App** - `apps/restaurant_app/build/web/`
- ✅ **Courier App** - `apps/courier_app/build/web/`
- ✅ **Admin Panel** - `apps/admin_panel/build/web/`

---

## 📋 Estrutura de Deployment

### Domínios e Subdomínios

| App | URL Produção | Diretório cPanel |
|-----|--------------|------------------|
| **Customer App** | `https://ohmyfood.eu` | `public_html/` |
| **Restaurant App** | `https://restaurante.ohmyfood.eu` | `public_html/restaurante/` |
| **Courier App** | `https://estafeta.ohmyfood.eu` | `public_html/estafeta/` |
| **Admin Panel** | `https://admin.ohmyfood.eu` | `public_html/admin/` |

---

## 📦 Passo a Passo - Upload para cPanel

### 1️⃣ Customer App (Principal)

**Diretório:** `public_html/`

1. **Acessar cPanel File Manager**
2. **Navegar para:** `public_html/`
3. **Fazer backup** dos arquivos existentes (se houver)
4. **Deletar** todos os arquivos antigos (exceto `.htaccess` se existir)
5. **Upload** todos os arquivos de `apps/customer_app/build/web/`
6. **Criar/Atualizar `.htaccess`** (ver seção abaixo)

### 2️⃣ Restaurant App

**Diretório:** `public_html/restaurante/`

1. **Criar diretório** `restaurante/` em `public_html/` (se não existir)
2. **Upload** todos os arquivos de `apps/restaurant_app/build/web/`
3. **Criar `.htaccess`** no diretório `restaurante/`

### 3️⃣ Courier App

**Diretório:** `public_html/estafeta/`

1. **Criar diretório** `estafeta/` em `public_html/` (se não existir)
2. **Upload** todos os arquivos de `apps/courier_app/build/web/`
3. **Criar `.htaccess`** no diretório `estafeta/`

### 4️⃣ Admin Panel

**Diretório:** `public_html/admin/`

1. **Criar diretório** `admin/` em `public_html/` (se não existir)
2. **Upload** todos os arquivos de `apps/admin_panel/build/web/`
3. **Criar `.htaccess`** no diretório `admin/`

---

## 🔧 Configuração `.htaccess`

### Para Customer App (raiz - `public_html/.htaccess`)

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  
  # Redirecionar para HTTPS
  RewriteCond %{HTTPS} off
  RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
  
  # SPA Routing - redirecionar todas as rotas para index.html
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule ^(.*)$ /index.html [L]
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

### Para Subdomínios (Restaurant, Courier, Admin)

**Criar `.htaccess` em cada diretório:**

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /[nome-do-dir]/
  
  # SPA Routing
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule ^(.*)$ /[nome-do-dir]/index.html [L]
</IfModule>
```

**Substituir `[nome-do-dir]` por:**
- `restaurante` para Restaurant App
- `estafeta` para Courier App
- `admin` para Admin Panel

---

## 📁 Estrutura Final no cPanel

```
public_html/
├── .htaccess                    (Customer App)
├── index.html                   (Customer App)
├── main.dart.js                 (Customer App)
├── flutter.js                   (Customer App)
├── assets/                      (Customer App)
├── canvaskit/                   (Customer App)
├── icons/                       (Customer App)
│
├── restaurante/
│   ├── .htaccess
│   ├── index.html
│   ├── main.dart.js
│   ├── flutter.js
│   ├── assets/
│   ├── canvaskit/
│   └── icons/
│
├── estafeta/
│   ├── .htaccess
│   ├── index.html
│   ├── main.dart.js
│   ├── flutter.js
│   ├── assets/
│   ├── canvaskit/
│   └── icons/
│
└── admin/
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

### Customer App
- [ ] Backup dos arquivos antigos
- [ ] Upload de `apps/customer_app/build/web/` para `public_html/`
- [ ] Criar/atualizar `.htaccess` na raiz
- [ ] Testar `https://ohmyfood.eu`
- [ ] Verificar se API está conectando corretamente

### Restaurant App
- [ ] Criar diretório `public_html/restaurante/`
- [ ] Upload de `apps/restaurant_app/build/web/` para `public_html/restaurante/`
- [ ] Criar `.htaccess` em `restaurante/`
- [ ] Testar `https://restaurante.ohmyfood.eu`
- [ ] Verificar se API está conectando corretamente

### Courier App
- [ ] Criar diretório `public_html/estafeta/`
- [ ] Upload de `apps/courier_app/build/web/` para `public_html/estafeta/`
- [ ] Criar `.htaccess` em `estafeta/`
- [ ] Testar `https://estafeta.ohmyfood.eu`
- [ ] Verificar se API está conectando corretamente

### Admin Panel
- [ ] Criar diretório `public_html/admin/`
- [ ] Upload de `apps/admin_panel/build/web/` para `public_html/admin/`
- [ ] Criar `.htaccess` em `admin/`
- [ ] Testar `https://admin.ohmyfood.eu`
- [ ] Verificar se API está conectando corretamente

---

## 🔍 Verificação Pós-Deployment

### 1. Testar URLs

```bash
# Customer App
https://ohmyfood.eu

# Restaurant App
https://restaurante.ohmyfood.eu

# Courier App
https://estafeta.ohmyfood.eu

# Admin Panel
https://admin.ohmyfood.eu
```

### 2. Verificar Console do Navegador

- Abrir DevTools (F12)
- Verificar se há erros no Console
- Verificar se as requisições à API estão funcionando
- Verificar se a URL da API está correta: `https://ohmyfood-production-800c.up.railway.app/api`

### 3. Testar Funcionalidades

**Customer App:**
- [ ] Landing page carrega
- [ ] Login funciona
- [ ] Registro funciona
- [ ] Lista de restaurantes carrega
- [ ] Navegação funciona

**Restaurant App:**
- [ ] Onboarding aparece (se necessário)
- [ ] Dashboard carrega
- [ ] Pedidos aparecem
- [ ] Menu management funciona

**Courier App:**
- [ ] Onboarding aparece (se necessário)
- [ ] Dashboard carrega
- [ ] Toggle online/offline funciona
- [ ] Pedidos disponíveis aparecem

**Admin Panel:**
- [ ] Live Ops carrega
- [ ] Entidades aparecem
- [ ] Navegação funciona

---

## 🐛 Troubleshooting

### Erro 404 em rotas
- **Causa:** `.htaccess` não configurado ou incorreto
- **Solução:** Verificar se `.htaccess` está presente e correto

### API não conecta
- **Causa:** URL da API incorreta
- **Solução:** Verificar `AppConfig.apiUrl` em cada app

### Assets não carregam
- **Causa:** Caminhos incorretos ou arquivos faltando
- **Solução:** Verificar se todos os arquivos foram uploadados

### CORS Error
- **Causa:** Backend não permite origem
- **Solução:** Verificar CORS no backend (já configurado)

---

## 📝 Notas Importantes

1. **Backend:** Já está deployado no Railway: `https://ohmyfood-production-800c.up.railway.app`
2. **API URL:** Todas as apps estão configuradas para usar a URL do Railway
3. **Builds:** Todos os builds foram feitos com `ENV=prod`
4. **HTTPS:** Certifique-se de que os domínios têm SSL configurado

---

**Última Atualização:** 2025-12-23

