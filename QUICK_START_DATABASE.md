# ⚡ Quick Start: Criar Base de Dados

## 🎯 Opção Mais Rápida

### Para Railway (Produção)

```bash
# Via Railway CLI
railway login
cd backend/api
railway link
railway run npx prisma migrate deploy
```

Ou via Railway Dashboard:
1. Abra o terminal do serviço
2. Execute: `npx prisma migrate deploy`

---

### Para Desenvolvimento Local

#### Windows (PowerShell)
```powershell
cd backend/api

# Opção 1: Script automatizado
.\scripts\create-database.ps1

# Opção 2: Comandos manuais
$env:DATABASE_URL="postgresql://postgres:postgres@localhost:5432/ohmyfood"
npm run db:setup
```

#### Linux/Mac
```bash
cd backend/api

# Opção 1: Script automatizado
chmod +x scripts/create-database.sh
./scripts/create-database.sh

# Opção 2: Comandos manuais
export DATABASE_URL="postgresql://postgres:postgres@localhost:5432/ohmyfood"
npm run db:setup
```

---

## 📋 Comandos NPM Disponíveis

Após configurar a `DATABASE_URL`, você pode usar:

```bash
# Criar base de dados (desenvolvimento)
npm run db:create

# Aplicar migrations (produção)
npm run db:setup

# Popular com dados de teste
npm run db:seed

# Abrir Prisma Studio (interface visual)
npm run prisma:studio
```

---

## 🔧 Configurar DATABASE_URL

### Formato
```
postgresql://[user]:[password]@[host]:[port]/[database]
```

### Exemplos

**Local:**
```bash
postgresql://postgres:postgres@localhost:5432/ohmyfood
```

**Railway:**
```bash
# Use a variável automática do Railway
${{Postgres.DATABASE_URL}}
```

**cPanel:**
```bash
postgresql://username_dbuser:password@localhost:5432/username_ohmyfood_db
```

---

## ✅ Verificar se Funcionou

```bash
# Abrir Prisma Studio
npm run prisma:studio

# Ou verificar via SQL
npx prisma db pull
```

---

## 📚 Documentação Completa

Veja `CRIAR_BASE_DADOS.md` para guia detalhado.
