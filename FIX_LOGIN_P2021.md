# 🔧 Fix: Erro P2021 - Não é possível fazer login

## 🐛 Problema Identificado

**Erro P2021 do Prisma**: "Table does not exist" - As tabelas do banco de dados não existem porque as migrations não foram executadas no Railway.

### Sintomas:
- ❌ Erro 500 ao tentar registrar usuário
- ❌ Erro 400 ao tentar fazer login
- ❌ Logs mostram: `Prisma error code: P2021`
- ❌ Mensagem: "Table does not exist in the current database"

## ✅ Solução Completa

### Passo 1: Executar Migrations no Railway

As migrations precisam ser executadas no banco de dados do Railway. Existem 3 opções:

#### Opção A: Via Railway CLI (Recomendado)

```bash
# 1. Instalar Railway CLI (se ainda não tiver)
npm i -g @railway/cli

# 2. Login no Railway
railway login

# 3. Conectar ao projeto
cd backend/api
railway link

# 4. Executar migrations
railway run npx prisma migrate deploy
```

#### Opção B: Via Railway Dashboard (Terminal)

1. Acesse [Railway Dashboard](https://railway.app)
2. Vá para o serviço **ohmyfood** (backend)
3. Clique na aba **"Deploy Logs"** ou **"Terminal"**
4. Execute:
   ```bash
   npx prisma migrate deploy
   ```

#### Opção C: Automático no Deploy (Já Configurado)

O `package.json` foi atualizado para executar migrations automaticamente no `start:prod`:

```json
"start:prod": "prisma migrate deploy && node dist/main.js"
```

**IMPORTANTE**: Certifique-se de que o Railway está usando `npm run start:prod` como comando de start.

### Passo 2: Verificar DATABASE_URL

Certifique-se de que a variável `DATABASE_URL` está configurada no Railway:

1. Railway Dashboard → Seu Projeto → Variáveis de Ambiente
2. Verifique se `DATABASE_URL` está definida
3. Formato esperado: `postgresql://user:password@host:port/database`
4. Se usar PostgreSQL do Railway, use: `${{Postgres.DATABASE_URL}}`

### Passo 3: Verificar se as Tabelas Foram Criadas

Após executar as migrations, verifique se as tabelas existem:

```bash
# Via Railway Terminal
npx prisma studio
```

Ou conecte diretamente ao banco e execute:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';
```

Deve mostrar tabelas como: `User`, `Restaurant`, `Order`, etc.

## 🔍 Melhorias Implementadas no Código

### 1. Tratamento Específico para P2021

O `AuthService` agora detecta e trata especificamente o erro P2021:

```typescript
if (error.code === 'P2021') {
  this.logger.error('Tabela não existe! Migrations não foram executadas.', error.meta);
  throw new InternalServerErrorException('Base de dados não configurada. Execute as migrations primeiro.');
}
```

### 2. Mensagens de Erro Mais Claras

- Erro P2002: "Este email já está registado"
- Erro P2021: "Base de dados não configurada. Execute as migrations primeiro."
- Outros erros: Incluem o código do erro para facilitar diagnóstico

### 3. Execução Automática de Migrations

O `package.json` foi atualizado para executar migrations automaticamente no start de produção:

```json
"start:prod": "prisma migrate deploy && node dist/main.js"
```

## 📋 Checklist de Verificação

Após executar as migrations, verifique:

- [ ] Migrations executadas com sucesso (sem erros)
- [ ] Tabelas criadas no banco de dados
- [ ] `DATABASE_URL` configurada corretamente
- [ ] Backend reiniciado após executar migrations
- [ ] Teste de registro de usuário funciona
- [ ] Teste de login funciona

## 🚀 Próximos Passos

1. ✅ Código atualizado com melhor tratamento de erros
2. ⏳ **EXECUTAR MIGRATIONS NO RAILWAY** (CRÍTICO)
3. ⏳ Verificar se as tabelas foram criadas
4. ⏳ Testar registro e login

## 📝 Notas Importantes

- **P2021** = Tabela não existe (migrations não executadas)
- **P2002** = Violação de constraint único (email já existe)
- **P1001** = Não consegue conectar ao banco de dados
- As migrations devem ser executadas **ANTES** de usar a API

## 🔗 Referências

- [Prisma Migrate Deploy](https://www.prisma.io/docs/concepts/components/prisma-migrate/migrate-development-production#production-and-testing-environments)
- [Railway Environment Variables](https://docs.railway.app/develop/variables)
- [Railway CLI](https://docs.railway.app/develop/cli)

