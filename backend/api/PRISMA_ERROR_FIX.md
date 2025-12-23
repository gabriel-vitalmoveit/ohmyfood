# 🔧 Fix para Erros do Prisma (500 Internal Server Error)

## 🐛 Problema Identificado

Erros `PrismaClientKnownRequestError` ocorrendo nos endpoints `/api/auth/register` e `/api/auth/login`, resultando em **500 Internal Server Error**.

### Possíveis Causas:

1. **Migrations não executadas** - As tabelas do banco de dados não existem
2. **Conexão com banco de dados** - DATABASE_URL incorreta ou banco inacessível
3. **Prisma Client não gerado** - O cliente do Prisma não foi gerado corretamente

## ✅ Solução Implementada

### 1. Melhor Tratamento de Erros

Adicionado tratamento específico para erros do Prisma no `AuthService`:
- Logs detalhados dos erros
- Mensagens de erro mais claras
- Tratamento específico para códigos de erro do Prisma (P2002, etc.)

### 2. Verificar Migrations no Railway

**IMPORTANTE:** As migrations do Prisma precisam ser executadas no banco de dados do Railway.

#### Opção A: Executar via Railway CLI

```bash
# Instalar Railway CLI (se ainda não tiver)
npm i -g @railway/cli

# Login no Railway
railway login

# Conectar ao projeto
railway link

# Executar migrations
cd backend/api
railway run npx prisma migrate deploy
```

#### Opção B: Executar via Script no Railway

Adicionar um script de build no `package.json` que executa as migrations:

```json
{
  "scripts": {
    "build": "prisma generate && prisma migrate deploy && nest build",
    "start": "node dist/main.js"
  }
}
```

#### Opção C: Executar Manualmente via Railway Dashboard

1. Acesse o Railway Dashboard
2. Vá para o serviço da API
3. Abra o terminal/console
4. Execute:
   ```bash
   npx prisma migrate deploy
   ```

### 3. Verificar DATABASE_URL

Certifique-se de que a variável de ambiente `DATABASE_URL` está configurada corretamente no Railway:

1. Acesse Railway Dashboard → Seu Projeto → Variáveis de Ambiente
2. Verifique se `DATABASE_URL` está definida
3. Formato esperado: `postgresql://user:password@host:port/database`

### 4. Gerar Prisma Client

Se o Prisma Client não foi gerado, execute:

```bash
cd backend/api
npx prisma generate
```

## 🔍 Diagnóstico

### Verificar se as Tabelas Existem

Execute no Railway terminal:

```bash
npx prisma studio
```

Ou conecte diretamente ao banco e verifique:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';
```

### Verificar Logs do Railway

1. Acesse Railway Dashboard
2. Vá para Deployments → Logs
3. Procure por erros relacionados ao Prisma

## 📝 Códigos de Erro Comuns do Prisma

- **P2002**: Unique constraint violation (email já existe)
- **P2025**: Record not found
- **P1001**: Can't reach database server
- **P1002**: Database server timed out
- **P1003**: Database does not exist

## 🚀 Próximos Passos

1. ✅ Código atualizado com melhor tratamento de erros
2. ⏳ Executar migrations no Railway
3. ⏳ Verificar DATABASE_URL
4. ⏳ Testar endpoints novamente

## 📚 Referências

- [Prisma Migrate Deploy](https://www.prisma.io/docs/concepts/components/prisma-migrate/migrate-development-production#production-and-testing-environments)
- [Railway Environment Variables](https://docs.railway.app/develop/variables)

