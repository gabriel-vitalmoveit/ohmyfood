# 🗄️ Guia de Setup da Base de Dados - cPanel

Este guia explica como criar a base de dados PostgreSQL no cPanel usando o Prisma.

## 📋 Opções Disponíveis

### Opção 1: Usar Prisma Migrate (Recomendado)

O Prisma Migrate gera arquivos SQL que podem ser executados diretamente no cPanel.

#### Passo 1: Gerar as Migrations

```bash
cd backend/api
npx prisma migrate dev --name init
```

Isso cria uma pasta `prisma/migrations/` com arquivos SQL.

#### Passo 2: Executar no cPanel

1. Acesse o **phpMyAdmin** ou **PostgreSQL** no cPanel
2. Crie a base de dados manualmente (se necessário)
3. Execute o SQL gerado em `prisma/migrations/[timestamp]_init/migration.sql`

---

### Opção 2: Gerar SQL do Schema Atual

Crie um script que gera o SQL completo do schema:

```bash
cd backend/api
npx prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma --script > schema.sql
```

Isso gera um arquivo `schema.sql` que pode ser executado diretamente no cPanel.

---

### Opção 3: Usar Prisma db push (Desenvolvimento)

**⚠️ ATENÇÃO**: Esta opção é apenas para desenvolvimento. Não use em produção!

```bash
cd backend/api
DATABASE_URL="postgresql://user:password@host:port/database" npx prisma db push
```

---

### Opção 4: Script SQL Manual

Execute o SQL gerado manualmente no cPanel PostgreSQL.

---

## 🚀 Setup Completo no cPanel

### 1. Criar Base de Dados no cPanel

1. Acesse **cPanel → PostgreSQL Databases**
2. Crie uma nova base de dados (ex: `ohmyfood_db`)
3. Crie um utilizador e atribua permissões
4. Anote as credenciais:
   - Host: `localhost` (ou o fornecido)
   - Port: `5432` (ou o fornecido)
   - Database: `username_ohmyfood_db`
   - User: `username_dbuser`
   - Password: `[sua_password]`

### 2. Configurar DATABASE_URL

A `DATABASE_URL` deve seguir este formato:

```
postgresql://username_dbuser:password@host:port/username_ohmyfood_db
```

Exemplo:
```
postgresql://ohmyfood_user:MyP@ssw0rd@localhost:5432/ohmyfood_db
```

### 3. Executar Migrations

#### Método A: Via phpMyAdmin/PostgreSQL Admin

1. Acesse o **PostgreSQL** no cPanel
2. Selecione a base de dados criada
3. Vá em **SQL** ou **Query Tool**
4. Cole o conteúdo do arquivo SQL gerado
5. Execute

#### Método B: Via Terminal SSH (se disponível)

```bash
cd ~/backend/api
export DATABASE_URL="postgresql://user:pass@host:port/db"
npx prisma migrate deploy
```

---

## 📝 Scripts Úteis

### Gerar SQL do Schema

```bash
# Gera SQL completo do schema
npx prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma --script > schema.sql
```

### Aplicar Migrations

```bash
# Aplica todas as migrations pendentes
npx prisma migrate deploy
```

### Reset da Base de Dados (⚠️ CUIDADO!)

```bash
# ⚠️ APAGA TODOS OS DADOS!
npx prisma migrate reset
```

### Seed da Base de Dados

```bash
# Popula a base com dados iniciais
npm run db:seed
```

---

## 🔧 Estrutura da Base de Dados

O schema Prisma cria as seguintes tabelas:

- `User` - Utilizadores do sistema
- `Courier` - Estafetas
- `CourierLocation` - Localizações dos estafetas
- `Restaurant` - Restaurantes
- `MenuItem` - Itens do menu
- `OptionGroup` - Grupos de opções (ex: tamanhos)
- `Option` - Opções individuais
- `Order` - Pedidos
- `OrderItem` - Itens de cada pedido
- `Payment` - Pagamentos
- `Promo` - Promoções
- `PromoRedemption` - Utilizações de promoções
- `Chat` - Conversas por pedido
- `Message` - Mensagens

---

## ✅ Checklist de Deploy

- [ ] Base de dados criada no cPanel
- [ ] Utilizador criado com permissões
- [ ] `DATABASE_URL` configurada no `.env`
- [ ] SQL executado ou migrations aplicadas
- [ ] Seed executado (opcional, para dados demo)
- [ ] Testar conexão com `npx prisma studio`

---

## 🆘 Troubleshooting

### Erro: "relation does not exist"
- As migrations não foram executadas
- Execute o SQL manualmente ou use `prisma migrate deploy`

### Erro: "permission denied"
- Verifique se o utilizador tem permissões na base de dados
- No cPanel, certifique-se que o utilizador está atribuído à base

### Erro: "connection refused"
- Verifique o host e port
- Alguns cPanels usam `localhost` ou um IP específico
- Verifique se o PostgreSQL está ativo

---

## 📚 Recursos

- [Prisma Migrate Docs](https://www.prisma.io/docs/concepts/components/prisma-migrate)
- [PostgreSQL cPanel Guide](https://docs.cpanel.net/cpanel/databases/postgresql-databases/)

