# 🔧 Fix: DATABASE_URL Error no Railway

## ❌ Erro Atual

```
PrismaClientInitializationError: error: Environment variable not found: DATABASE_URL.
errorCode: 'P1012'
```

## ✅ Solução

### Passo 1: Verificar PostgreSQL Service no Railway

1. No Railway, vá em **"Architecture"** ou **"Services"**
2. Verifique se o serviço **Postgres** está criado e **Online**
3. Se não estiver, clique em **"+ New"** → **"Database"** → **"Add PostgreSQL"**

### Passo 2: Configurar DATABASE_URL

#### Opção A: Usar Variável Automática do Railway

1. No serviço **Postgres**, clique em **"Variables"**
2. Procure pela variável `DATABASE_URL` ou `POSTGRES_URL`
3. Copie o valor completo

#### Opção B: Criar Variável Manualmente

1. No serviço **ohmyfood** (backend), vá em **"Variables"**
2. Clique em **"+ New Variable"**
3. Nome: `DATABASE_URL`
4. Valor: Use a referência do Railway:
   ```
   ${{Postgres.DATABASE_URL}}
   ```
   
   Ou se o serviço PostgreSQL tiver outro nome:
   ```
   ${{NomeDoServicoPostgres.DATABASE_URL}}
   ```

### Passo 3: Verificar Nome do Serviço PostgreSQL

Se você renomeou o serviço PostgreSQL, ajuste a referência:

1. Veja o nome exato do serviço PostgreSQL no Railway
2. Use: `${{NomeExatoDoServico.DATABASE_URL}}`

### Passo 4: Adicionar Prisma Generate no Build

O Railway precisa gerar o Prisma Client durante o build. Atualize o `package.json`:

```json
{
  "scripts": {
    "build": "prisma generate && nest build",
    "start:prod": "node dist/main.js"
  }
}
```

Ou crie um arquivo `railway.toml` na raiz do `backend/api`:

```toml
[build]
builder = "nixpacks"
buildCommand = "npm install && npx prisma generate && npm run build"

[deploy]
startCommand = "npm run start:prod"
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10
```

### Passo 5: Verificar Todas as Variáveis Necessárias

Certifique-se que estas variáveis estão configuradas no Railway:

```env
# Database (CRÍTICO - deve estar configurado)
DATABASE_URL=${{Postgres.DATABASE_URL}}

# Porta (Railway define automaticamente)
PORT=${{PORT}}

# CORS
CORS_ORIGINS=https://ohmyfood.eu,https://www.ohmyfood.eu,https://restaurante.ohmyfood.eu,https://admin.ohmyfood.eu

# JWT Secrets
JWT_ACCESS_SECRET=seu-secret-aqui
JWT_REFRESH_SECRET=seu-refresh-secret-aqui
JWT_ACCESS_TTL=15m
JWT_REFRESH_TTL=7d

# Stripe (opcional para testes)
STRIPE_API_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Mapbox (opcional)
MAPBOX_API_KEY=pk.eyJ1...

# Redis (opcional, se adicionar)
REDIS_URL=${{Redis.REDIS_URL}}
```

## 🔍 Como Verificar

1. No Railway, vá em **"Variables"** do serviço **ohmyfood**
2. Verifique se `DATABASE_URL` está listada
3. O valor deve começar com `postgresql://` ou usar `${{Postgres.DATABASE_URL}}`

## 🚀 Após Configurar

1. **Redeploy** o serviço (Railway fará automaticamente ao salvar variáveis)
2. Verifique os logs em **"Deploy Logs"**
3. Deve aparecer: `🚀 OhMyFood API pronta em...`

## ⚠️ Nota Importante

Se o PostgreSQL foi criado **depois** do serviço ohmyfood, você precisa:

1. Adicionar a variável `DATABASE_URL` manualmente
2. Ou fazer **Redeploy** do serviço ohmyfood para pegar as variáveis do PostgreSQL

---

**Status:** Aguardando configuração de `DATABASE_URL` no Railway

