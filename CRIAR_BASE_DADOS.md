# 🗄️ Guia Completo: Criar Base de Dados

Este guia explica como criar a base de dados para o projeto OhMyFood usando Prisma.

## 📋 Pré-requisitos

1. **PostgreSQL instalado e rodando** (local ou remoto)
2. **Node.js e npm instalados**
3. **Dependências do projeto instaladas** (`npm install`)

## 🚀 Métodos Disponíveis

### Método 1: Script Automatizado (Recomendado)

#### Windows (PowerShell)
```powershell
cd backend/api
.\scripts\create-database.ps1
```

Ou com DATABASE_URL específica:
```powershell
.\scripts\create-database.ps1 "postgresql://user:password@host:port/database"
```

#### Linux/Mac (Bash)
```bash
cd backend/api
chmod +x scripts/create-database.sh
./scripts/create-database.sh
```

Ou com DATABASE_URL específica:
```bash
./scripts/create-database.sh "postgresql://user:password@host:port/database"
```

---

### Método 2: Comandos Manuais

#### Passo 1: Configurar DATABASE_URL

**Opção A: Variável de Ambiente**
```bash
# Windows PowerShell
$env:DATABASE_URL="postgresql://postgres:postgres@localhost:5432/ohmyfood"

# Linux/Mac
export DATABASE_URL="postgresql://postgres:postgres@localhost:5432/ohmyfood"
```

**Opção B: Arquivo .env**
Crie um arquivo `.env` em `backend/api/`:
```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/ohmyfood
```

#### Passo 2: Gerar Prisma Client
```bash
cd backend/api
npx prisma generate
```

#### Passo 3: Criar Migrations
```bash
npx prisma migrate dev --name init
```

Isso irá:
- Criar a pasta `prisma/migrations/`
- Gerar os arquivos SQL das migrations
- Aplicar as migrations no banco de dados

#### Passo 4: Verificar
```bash
# Abrir Prisma Studio (interface visual)
npx prisma studio

# Ou verificar via SQL
npx prisma db pull
```

---

### Método 3: Para Produção (Railway/cPanel)

#### Railway

**Opção A: Via Railway CLI**
```bash
# Instalar Railway CLI
npm i -g @railway/cli

# Login e conectar
railway login
cd backend/api
railway link

# Executar migrations
railway run npx prisma migrate deploy
```

**Opção B: Via Railway Dashboard**
1. Acesse [Railway Dashboard](https://railway.app)
2. Vá para o serviço do backend
3. Abra o terminal
4. Execute: `npx prisma migrate deploy`

**Opção C: Automático no Deploy**
Configure o `package.json`:
```json
{
  "scripts": {
    "start:prod": "prisma migrate deploy && node dist/main.js"
  }
}
```

#### cPanel

1. **Criar Base de Dados**
   - Acesse cPanel → PostgreSQL Databases
   - Crie uma nova base de dados
   - Crie um utilizador e atribua permissões

2. **Configurar DATABASE_URL**
   - Formato: `postgresql://username:password@host:port/database`
   - Adicione no `.env` ou variáveis de ambiente

3. **Executar SQL**
   - Gere o SQL: `npx prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma --script > schema.sql`
   - Execute o `schema.sql` no phpMyAdmin/PostgreSQL Admin do cPanel

---

## 🔧 Formato da DATABASE_URL

```
postgresql://[user]:[password]@[host]:[port]/[database]
```

### Exemplos:

**Local (desenvolvimento)**
```
postgresql://postgres:postgres@localhost:5432/ohmyfood
```

**Railway**
```
postgresql://postgres:password@containers-us-west-xxx.railway.app:5432/railway
```

**cPanel**
```
postgresql://username_dbuser:password@localhost:5432/username_ohmyfood_db
```

---

## 📊 Estrutura da Base de Dados

O schema Prisma cria as seguintes tabelas:

- **User** - Utilizadores do sistema
- **Courier** - Estafetas
- **CourierLocation** - Localizações dos estafetas
- **Restaurant** - Restaurantes
- **MenuItem** - Itens do menu
- **OptionGroup** - Grupos de opções
- **Option** - Opções individuais
- **Order** - Pedidos
- **OrderItem** - Itens de cada pedido
- **Payment** - Pagamentos
- **Promo** - Promoções
- **PromoRedemption** - Utilizações de promoções
- **Chat** - Conversas por pedido
- **Message** - Mensagens

---

## 🌱 Seed (Dados Iniciais)

Após criar a base de dados, você pode popular com dados de teste:

```bash
cd backend/api
npm run db:seed
```

Isso cria:
- Utilizadores de teste (admin, restaurante, cliente)
- Restaurantes de exemplo
- Dados para desenvolvimento

---

## ✅ Verificação

### Verificar se as Tabelas Foram Criadas

**Opção 1: Prisma Studio**
```bash
npx prisma studio
```
Abre uma interface web em `http://localhost:5555`

**Opção 2: SQL Direto**
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';
```

**Opção 3: Prisma CLI**
```bash
npx prisma db pull
```

---

## 🆘 Troubleshooting

### Erro: "Can't reach database server"
- Verifique se o PostgreSQL está rodando
- Verifique se a DATABASE_URL está correta
- Verifique firewall/portas

### Erro: "Database does not exist"
- Crie a base de dados primeiro
- Verifique o nome da base na DATABASE_URL

### Erro: "Permission denied"
- Verifique se o utilizador tem permissões
- Verifique se a base de dados existe

### Erro: "Migration already applied"
- Isso é normal se as migrations já foram executadas
- Use `npx prisma migrate reset` para resetar (⚠️ apaga todos os dados!)

---

## 📝 Scripts Úteis

### Gerar SQL do Schema
```bash
npx prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma --script > schema.sql
```

### Aplicar Migrations
```bash
npx prisma migrate deploy
```

### Reset da Base (⚠️ CUIDADO!)
```bash
# ⚠️ APAGA TODOS OS DADOS!
npx prisma migrate reset
```

### Seed
```bash
npm run db:seed
```

### Prisma Studio
```bash
npx prisma studio
```

---

## 🎯 Checklist

- [ ] PostgreSQL instalado e rodando
- [ ] DATABASE_URL configurada
- [ ] Dependências instaladas (`npm install`)
- [ ] Prisma Client gerado (`npx prisma generate`)
- [ ] Migrations criadas (`npx prisma migrate dev`)
- [ ] Migrations aplicadas (`npx prisma migrate deploy`)
- [ ] Tabelas verificadas (Prisma Studio ou SQL)
- [ ] Seed executado (opcional)

---

## 📚 Referências

- [Prisma Migrate](https://www.prisma.io/docs/concepts/components/prisma-migrate)
- [Prisma Schema](https://www.prisma.io/docs/concepts/components/prisma-schema)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

**Última Atualização**: 2025-12-23

