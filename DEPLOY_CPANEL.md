# 🚀 Guia de Deploy no cPanel - OhMyFood

**⚠️ IMPORTANTE:** Devido às limitações do cPanel (Node.js 14.21.1 desatualizado), o **backend será deployado no Railway.app** e apenas o **frontend Flutter Web será deployado no cPanel**.

Este guia detalha todos os passos necessários para fazer deploy completo.

## ✅ Checklist Pré-Deploy

### 1. Código no Repositório
- [x] Código commitado e pushed para GitHub
- [x] URLs configuradas para produção
- [x] Configurações de ambiente preparadas

### 2. Preparação Local
- [ ] Build das apps Flutter Web
- [ ] Build do backend NestJS
- [ ] Testes locais funcionando

---

## 📦 Passo 1: Deploy do Backend no Railway

**O backend NÃO será deployado no cPanel.** Siga o guia em `RAILWAY_DEPLOY.md` para fazer deploy no Railway.app.

Após o deploy, você terá uma URL como: `https://backend-production-xxxx.up.railway.app`

## 📦 Passo 2: Build das Aplicações Flutter

### Opção A: Script Automatizado (Recomendado)

```bash
# Windows PowerShell
.\scripts\build-for-cpanel.ps1 https://seu-backend.up.railway.app

# Linux/Mac
./scripts/build-for-cpanel.sh https://seu-backend.up.railway.app
```

### Opção B: Manual

Execute estes comandos **antes** de fazer upload:

```bash
# 1. Customer App (ohmyfood.eu)
cd apps/customer_app
flutter clean
flutter pub get
flutter build web --release --dart-define=ENV=prod --dart-define=API_BASE_URL=https://seu-backend.up.railway.app
# Output: build/web/

# 2. Restaurant App (restaurante.ohmyfood.eu)
cd ../restaurant_app
flutter clean
flutter pub get
flutter build web --release --dart-define=ENV=prod --dart-define=API_BASE_URL=https://seu-backend.up.railway.app
# Output: build/web/

# 3. Admin Panel (admin.ohmyfood.eu)
cd ../admin_panel
flutter clean
flutter pub get
flutter build web --release --dart-define=ENV=prod --dart-define=API_BASE_URL=https://seu-backend.up.railway.app
# Output: build/web/
```

---

## 📤 Passo 2: Upload para cPanel

### Estrutura de Pastas no cPanel

```
public_html/
├── api/                    # Backend NestJS
│   ├── dist/              # Código compilado
│   ├── prisma/            # Schema e migrations
│   ├── package.json
│   └── .env               # Variáveis de ambiente
├── customer/              # Customer App (ohmyfood.eu)
│   └── build/web/         # Flutter build output
├── restaurant/            # Restaurant App (restaurante.ohmyfood.eu)
│   └── build/web/         # Flutter build output
└── admin/                 # Admin Panel (admin.ohmyfood.eu)
    └── build/web/         # Flutter build output
```

### Upload via File Manager

**⚠️ NOTA:** Backend está no Railway, não precisa fazer upload!

1. **Customer App:**
   - Upload **TODO o conteúdo** de `apps/customer_app/build/web/` → `public_html/`
   - Copiar `public_html/.htaccess` para `public_html/.htaccess`

2. **Restaurant App:**
   - Criar pasta `public_html/restaurant/` (se não existir)
   - Upload **TODO o conteúdo** de `apps/restaurant_app/build/web/` → `public_html/restaurant/`
   - Copiar `public_html/.htaccess` para `public_html/restaurant/.htaccess`

3. **Admin Panel:**
   - Criar pasta `public_html/admin/` (se não existir)
   - Upload **TODO o conteúdo** de `apps/admin_panel/build/web/` → `public_html/admin/`
   - Copiar `public_html/.htaccess` para `public_html/admin/.htaccess`

---

## ⚙️ Passo 3: Configuração no cPanel

### 3.1. Base de Dados

**⚠️ Base de dados está no Railway PostgreSQL.** Não precisa configurar no cPanel.

Se precisar acessar a base de dados:
- Use Prisma Studio localmente apontando para `DATABASE_URL` do Railway
- Ou use Railway CLI: `railway connect postgres`

### 3.4. Domínios e Subdomínios

1. **Criar Subdomínios:**
   - cPanel → Subdomains
   - `api.ohmyfood.eu` → `public_html/api`
   - `restaurante.ohmyfood.eu` → `public_html/restaurant`
   - `admin.ohmyfood.eu` → `public_html/admin`
   - `ohmyfood.eu` → `public_html/customer`

2. **SSL/HTTPS:**
   - cPanel → SSL/TLS
   - Instalar certificado Let's Encrypt (gratuito)
   - Ativar para todos os domínios

### 3.5. Configurar .htaccess (se necessário)

Para Flutter Web Apps, criar `.htaccess` em cada pasta:

**public_html/customer/.htaccess:**
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

Repetir para `restaurant/` e `admin/`.

---

## 🔍 Passo 4: Verificações Pós-Deploy

### 4.1. Testar Backend API

```bash
# Testar se API está online
curl https://api.ohmyfood.eu/docs

# Testar endpoint
curl https://api.ohmyfood.eu/restaurants
```

### 4.2. Testar Apps Web

1. **Customer App:**
   - Acessar: `https://ohmyfood.eu`
   - Verificar se carrega
   - Verificar se conecta à API

2. **Restaurant App:**
   - Acessar: `https://restaurante.ohmyfood.eu`
   - Verificar login

3. **Admin Panel:**
   - Acessar: `https://admin.ohmyfood.eu`
   - Verificar login

### 4.3. Verificar CORS

No browser console de qualquer app:
```javascript
fetch('https://api.ohmyfood.eu/restaurants')
  .then(r => r.json())
  .then(console.log)
  .catch(console.error);
```

Se der erro de CORS, verificar `CORS_ORIGINS` no `.env`.

### 4.4. Verificar Base de Dados

Via SSH ou Prisma Studio:
```bash
cd api
npx prisma studio
# Acessar http://localhost:5555
```

---

## 🛠️ Passo 5: Comandos Úteis (SSH)

Se tiver acesso SSH:

```bash
# Ir para pasta da API
cd ~/public_html/api

# Instalar dependências
npm install --production

# Gerar Prisma Client
npx prisma generate

# Aplicar migrations
npx prisma migrate deploy

# Seed database
npm run db:seed

# Ver logs
pm2 logs ohmyfood-api
# ou
tail -f ~/logs/nodejs/ohmyfood-api.log
```

---

## ⚠️ Problemas Comuns

### 1. API não inicia

**Sintomas:** Node.js app não inicia

**Soluções:**
- Verificar logs em cPanel → Node.js App → Logs
- Verificar se `dist/main.js` existe
- Verificar se `.env` está correto
- Verificar se porta está disponível

### 2. CORS bloqueado

**Sintomas:** Browser bloqueia requisições

**Soluções:**
- Verificar `CORS_ORIGINS` no `.env`
- Adicionar URL exata (com/sem www)
- Reiniciar Node.js app

### 3. Base de dados não conecta

**Sintomas:** Erro de conexão PostgreSQL

**Soluções:**
- Verificar `DATABASE_URL` no `.env`
- Verificar se user tem permissões
- Verificar se database existe
- Testar conexão via SSH

### 4. Flutter apps não carregam

**Sintomas:** Página em branco ou 404

**Soluções:**
- Verificar se arquivos estão em `build/web/`
- Verificar `.htaccess` para routing
- Verificar console do browser para erros
- Verificar se `index.html` existe

### 5. WebSocket não funciona

**Sintomas:** Chat/tracking não conecta

**Soluções:**
- Verificar se usa `wss://` (HTTPS)
- Configurar proxy reverso no cPanel
- Verificar firewall/portas

---

## 📋 Checklist Final

### Antes de Fazer Upload
- [ ] Build de todas as apps Flutter Web feito
- [ ] Build do backend NestJS feito
- [ ] Testes locais passando
- [ ] `.env` preparado com valores de produção

### No cPanel
- [ ] Base de dados PostgreSQL criada
- [ ] SQL executado (schema criado)
- [ ] Subdomínios criados
- [ ] SSL/HTTPS configurado
- [ ] Node.js App criado e iniciado
- [ ] Arquivos Flutter Web uploadados
- [ ] `.htaccess` configurado

### Após Deploy
- [ ] API acessível em `https://api.ohmyfood.eu/docs`
- [ ] Customer app acessível em `https://ohmyfood.eu`
- [ ] Restaurant app acessível em `https://restaurante.ohmyfood.eu`
- [ ] Admin panel acessível em `https://admin.ohmyfood.eu`
- [ ] CORS funcionando
- [ ] Base de dados conectada
- [ ] Login funcionando

---

## 🚨 Importante

1. **Segurança:**
   - Gere novos secrets JWT (não use os de desenvolvimento)
   - Use HTTPS em tudo
   - Configure CORS corretamente
   - Proteja `.env` (não commitar)

2. **Performance:**
   - Ative cache no cPanel
   - Configure CDN se possível
   - Otimize imagens

3. **Backup:**
   - Configure backup automático da base de dados
   - Faça backup antes de mudanças grandes

---

## 📞 Suporte

Se encontrar problemas:
1. Verificar logs no cPanel
2. Verificar console do browser
3. Verificar Network tab (F12)
4. Consultar documentação do cPanel

---

**Última atualização:** Agora
**Status:** ✅ Pronto para deploy

