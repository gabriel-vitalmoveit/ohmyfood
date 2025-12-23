# 🚂 Deploy no Railway - Backend OhMyFood

Este guia explica como fazer deploy do backend NestJS no Railway.app.

## 📋 Pré-requisitos

1. Conta no [Railway.app](https://railway.app)
2. Repositório GitHub conectado
3. Backend compilado e testado localmente

## 🚀 Passo a Passo

### 1. Criar Projeto no Railway

1. Acesse [railway.app](https://railway.app)
2. Faça login com GitHub
3. Clique em **"New Project"**
4. Selecione **"Deploy from GitHub repo"**
5. Escolha o repositório `gabriel-vitalmoveit/ohmyfood`
6. Selecione a pasta `backend/api` como root

### 2. Adicionar PostgreSQL Database

1. No projeto Railway, clique em **"+ New"**
2. Selecione **"Database"** → **"Add PostgreSQL"**
3. Railway criará automaticamente um PostgreSQL
4. Anote a variável `DATABASE_URL` gerada

### 3. Configurar Variáveis de Ambiente

No Railway, vá em **Variables** e adicione:

```env
# Database (gerado automaticamente pelo Railway)
DATABASE_URL=${{Postgres.DATABASE_URL}}

# Porta (Railway define automaticamente)
PORT=${{PORT}}

# CORS - URLs permitidas
CORS_ORIGINS=https://ohmyfood.eu,https://www.ohmyfood.eu,https://restaurante.ohmyfood.eu,https://admin.ohmyfood.eu

# JWT Secrets (GERE NOVOS!)
JWT_ACCESS_SECRET=seu-secret-super-seguro-aqui
JWT_REFRESH_SECRET=seu-refresh-secret-super-seguro-aqui
JWT_ACCESS_TTL=15m
JWT_REFRESH_TTL=7d

# Stripe (use suas chaves reais)
STRIPE_API_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Mapbox
MAPBOX_API_KEY=pk.eyJ1...

# Redis (opcional, se adicionar Redis service)
REDIS_URL=${{Redis.REDIS_URL}}

# File Storage
FILE_BUCKET_URL=https://seu-bucket-url
```

### 4. Configurar Build e Deploy

Railway detectará automaticamente:
- `package.json` na raiz
- Script `start:prod` para iniciar
- Build command: `npm install && npm run build`

O arquivo `railway.json` já está configurado.

### 5. Aplicar Migrations

Após o primeiro deploy, execute migrations:

1. No Railway, vá em **Settings** → **Connect**
2. Copie o comando de conexão SSH
3. Execute:
```bash
cd /app
npx prisma migrate deploy
npx prisma generate
npm run db:seed  # Opcional
```

Ou use Railway CLI:
```bash
railway run npx prisma migrate deploy
railway run npm run db:seed
```

### 6. Obter URL Pública

1. No Railway, vá em **Settings** → **Networking**
2. Clique em **"Generate Domain"** ou configure custom domain
3. Copie a URL (ex: `backend-production-xxxx.up.railway.app`)

### 7. Atualizar Frontend

Use a URL do Railway no build do frontend **com** `/api` no final (o NestJS usa prefixo global `/api`):

```bash
# Windows PowerShell
.\scripts\build-for-cpanel.ps1 https://backend-production-xxxx.up.railway.app/api

# Linux/Mac
./scripts/build-for-cpanel.sh https://backend-production-xxxx.up.railway.app/api
```

**Nota:** O backend tem prefixo global `/api`, então os endpoints serão:
- `https://seu-backend.up.railway.app/api/restaurants`
- `https://seu-backend.up.railway.app/api/orders`
- etc.

## ✅ Checklist

- [ ] Projeto criado no Railway
- [ ] PostgreSQL database adicionado
- [ ] Variáveis de ambiente configuradas
- [ ] Deploy automático funcionando
- [ ] Migrations aplicadas
- [ ] URL pública obtida
- [ ] Frontend atualizado com URL Railway
- [ ] CORS configurado corretamente
- [ ] Testes de API funcionando

## 🔍 Verificar Deploy

```bash
# Testar API (Swagger)
curl https://seu-backend.up.railway.app/api/docs

# Testar endpoint
curl https://seu-backend.up.railway.app/api/restaurants
```

**Nota:** Todos os endpoints têm o prefixo `/api` devido ao `setGlobalPrefix('api')` no backend.

## 🛠️ Troubleshooting

### Erro: "Cannot find module"
- Verifique se `npm install` está rodando
- Verifique se `npm run build` está gerando `dist/`

### Erro: "Database connection failed"
- Verifique `DATABASE_URL` nas variáveis
- Certifique-se que PostgreSQL está ativo

### Erro: "Port already in use"
- Railway define `PORT` automaticamente
- Não defina `PORT` manualmente

### Erro: CORS bloqueado
- Adicione todas as URLs em `CORS_ORIGINS`
- Inclua `https://` e `http://` se necessário

## 📚 Recursos

- [Railway Docs](https://docs.railway.app)
- [Railway Discord](https://discord.gg/railway)

---

**Status:** ✅ Configurado e pronto para deploy

