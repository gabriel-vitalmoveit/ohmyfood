# 🚀 Guia de Deploy no cPanel - OhMyFood

Este guia detalha todos os passos necessários para fazer deploy completo no cPanel.

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

## 📦 Passo 1: Build das Aplicações

### Flutter Web Apps

Execute estes comandos **antes** de fazer upload:

```bash
# 1. Customer App (ohmyfood.eu)
cd apps/customer_app
flutter clean
flutter pub get
flutter build web --dart-define=ENV=prod --release
# Output: build/web/

# 2. Restaurant App (restaurante.ohmyfood.eu)
cd ../restaurant_app
flutter clean
flutter pub get
flutter build web --dart-define=ENV=prod --release
# Output: build/web/

# 3. Admin Panel (admin.ohmyfood.eu)
cd ../admin_panel
flutter clean
flutter pub get
flutter build web --dart-define=ENV=prod --release
# Output: build/web/
```

### Backend NestJS

```bash
cd backend/api
npm install --production
npm run build
# Output: dist/
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

1. **Backend API:**
   - Upload pasta `backend/api/dist/` → `public_html/api/dist/`
   - Upload `backend/api/package.json` → `public_html/api/`
   - Upload `backend/api/prisma/` → `public_html/api/prisma/`
   - Criar `.env` em `public_html/api/.env`

2. **Customer App:**
   - Upload conteúdo de `apps/customer_app/build/web/` → `public_html/customer/`

3. **Restaurant App:**
   - Upload conteúdo de `apps/restaurant_app/build/web/` → `public_html/restaurant/`

4. **Admin Panel:**
   - Upload conteúdo de `apps/admin_panel/build/web/` → `public_html/admin/`

---

## ⚙️ Passo 3: Configuração no cPanel

### 3.1. Base de Dados PostgreSQL

1. **Criar Base de Dados:**
   - cPanel → PostgreSQL Databases
   - Criar database: `ohmyfood_db`
   - Criar user: `ohmyfood_user`
   - Atribuir user à database

2. **Executar SQL:**
   - Gerar SQL: `cd backend/api && npm run db:generate-sql`
   - Copiar conteúdo de `schema.sql`
   - cPanel → PostgreSQL → SQL Tool
   - Colar e executar SQL

3. **Seed (Opcional):**
   - Via SSH: `cd api && npm run db:seed`

### 3.2. Variáveis de Ambiente (.env)

Criar `public_html/api/.env`:

```env
# Porta (cPanel geralmente usa 3000 ou porta específica)
PORT=3000

# Database
DATABASE_URL=postgresql://ohmyfood_user:password@localhost:5432/ohmyfood_db

# CORS - URLs permitidas
CORS_ORIGINS=https://ohmyfood.eu,https://www.ohmyfood.eu,https://admin.ohmyfood.eu,https://restaurante.ohmyfood.eu

# JWT Secrets (GERE NOVOS!)
JWT_ACCESS_SECRET=seu-secret-super-seguro-aqui
JWT_REFRESH_SECRET=seu-refresh-secret-super-seguro-aqui
JWT_ACCESS_TTL=15m
JWT_REFRESH_TTL=7d

# Stripe
STRIPE_API_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Mapbox
MAPBOX_API_KEY=pk.eyJ1...

# Redis (se disponível)
REDIS_URL=redis://localhost:6379

# File Storage
FILE_BUCKET_URL=https://seu-bucket-url
```

### 3.3. Node.js App (Backend)

1. **Criar Node.js App:**
   - cPanel → Node.js App
   - Node.js Version: 18.x ou 20.x
   - Application Root: `api`
   - Application URL: `api.ohmyfood.eu` (ou subdomínio)
   - Application Startup File: `dist/main.js`
   - Environment Variables: Copiar do `.env`

2. **Instalar Dependências:**
   - Na interface Node.js App, clique em "Run NPM Install"
   - Ou via SSH: `cd api && npm install --production`

3. **Iniciar App:**
   - Clique em "Start App" na interface Node.js

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

