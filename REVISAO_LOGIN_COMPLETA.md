# 🔍 Revisão Completa: Problema de Login

## 📋 Resumo Executivo

**Problema Principal**: Erro P2021 do Prisma - Tabelas do banco de dados não existem porque as migrations não foram executadas no Railway.

**Status**: 
- ✅ Código revisado e melhorado
- ⚠️ **AÇÃO NECESSÁRIA**: Executar migrations no Railway

## 🔍 Análise dos Erros

### 1. Erro P2021 (Crítico)
- **Causa**: Tabelas não existem no banco de dados
- **Sintoma**: Erro 500 ao registrar, erro ao fazer login
- **Solução**: Executar `npx prisma migrate deploy` no Railway

### 2. Erro 400 no Login
- **Possíveis Causas**:
  - Validação de DTO falhando (email/password inválidos)
  - Dados não enviados corretamente do frontend
- **Status**: ValidationPipe configurado corretamente, mas precisa verificar dados enviados

## ✅ Correções Implementadas

### 1. Tratamento de Erros Melhorado (`auth.service.ts`)

#### Antes:
```typescript
catch (error: any) {
  this.logger.error('Erro ao registrar usuário', error);
  // Tratamento genérico
}
```

#### Depois:
```typescript
catch (error: any) {
  this.logger.error('Erro ao registrar usuário', error);
  
  if (error?.code && typeof error.code === 'string' && error.code.startsWith('P')) {
    // P2002 = Email já existe
    if (error.code === 'P2002') {
      throw new UnauthorizedException('Este email já está registado');
    }
    // P2021 = Tabela não existe (MIGRATIONS NÃO EXECUTADAS)
    if (error.code === 'P2021') {
      this.logger.error('Tabela não existe! Migrations não foram executadas.', error.meta);
      throw new InternalServerErrorException('Base de dados não configurada. Execute as migrations primeiro.');
    }
    // Outros erros do Prisma
    this.logger.error(`Prisma error code: ${error.code}`, error.meta);
    throw new InternalServerErrorException(`Erro ao criar conta (${error.code}). Verifique a conexão com a base de dados.`);
  }
  
  throw error;
}
```

### 2. Execução Automática de Migrations (`package.json`)

```json
{
  "scripts": {
    "start:prod": "prisma migrate deploy && node dist/main.js"
  }
}
```

**IMPORTANTE**: Certifique-se de que o Railway está usando `npm run start:prod` como comando de start.

### 3. Mensagens de Erro Mais Claras

- **P2002**: "Este email já está registado"
- **P2021**: "Base de dados não configurada. Execute as migrations primeiro."
- **Outros**: Incluem código do erro para facilitar diagnóstico

## 📊 Código Revisado

### ✅ Backend (`backend/api/src/modules/auth/`)

1. **`auth.service.ts`** ✅
   - Tratamento específico para P2021
   - Tratamento específico para P2002
   - Logs detalhados
   - Mensagens de erro claras

2. **`auth.controller.ts`** ✅
   - Endpoints corretos
   - DTOs validados

3. **`dto/login.dto.ts`** ✅
   - Validação de email (`@IsEmail`)
   - Validação de password (`@MinLength(6)`)

4. **`dto/register.dto.ts`** ✅
   - Validação completa
   - Role opcional com default

5. **`main.ts`** ✅
   - ValidationPipe configurado
   - CORS configurado
   - Prefixo `/api` configurado

### ✅ Frontend (`apps/customer_app/lib/src/`)

1. **`services/auth_service.dart`** ✅
   - Tratamento de erros de conexão
   - Timeout configurado (10 segundos)
   - Mensagens de erro claras

2. **`services/providers/auth_providers.dart`** ✅
   - Estado de autenticação gerenciado
   - Tratamento de erros no estado

3. **`features/auth/login_screen.dart`** ✅
   - Exibição de erros na UI
   - Validação de campos

## 🚨 Ações Necessárias (CRÍTICO)

### 1. Executar Migrations no Railway

**Opção A: Via Railway CLI**
```bash
npm i -g @railway/cli
railway login
cd backend/api
railway link
railway run npx prisma migrate deploy
```

**Opção B: Via Railway Dashboard**
1. Acesse Railway Dashboard
2. Vá para o serviço **ohmyfood** (backend)
3. Abra o terminal
4. Execute: `npx prisma migrate deploy`

**Opção C: Automático (se configurado)**
- Certifique-se de que o Railway está usando `npm run start:prod`
- As migrations serão executadas automaticamente no deploy

### 2. Verificar DATABASE_URL

1. Railway Dashboard → Variáveis de Ambiente
2. Verifique se `DATABASE_URL` está definida
3. Formato: `postgresql://user:password@host:port/database`
4. Se usar PostgreSQL do Railway: `${{Postgres.DATABASE_URL}}`

### 3. Verificar Tabelas Criadas

Após executar migrations:
```bash
npx prisma studio
```

Ou via SQL:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';
```

## 🧪 Testes Recomendados

Após executar as migrations:

1. **Teste de Registro**
   - Criar nova conta
   - Verificar se retorna tokens
   - Verificar se usuário é salvo

2. **Teste de Login**
   - Fazer login com credenciais válidas
   - Verificar se retorna tokens
   - Verificar se estado de autenticação é atualizado

3. **Teste de Erros**
   - Tentar registrar email duplicado (deve retornar P2002)
   - Tentar login com credenciais inválidas (deve retornar 401)
   - Verificar mensagens de erro na UI

## 📝 Checklist Final

- [x] Código revisado
- [x] Tratamento de erros melhorado
- [x] Mensagens de erro claras
- [x] Execução automática de migrations configurada
- [ ] **EXECUTAR MIGRATIONS NO RAILWAY** ⚠️
- [ ] Verificar DATABASE_URL
- [ ] Verificar tabelas criadas
- [ ] Testar registro
- [ ] Testar login

## 🔗 Documentos Relacionados

- `FIX_LOGIN_P2021.md` - Guia detalhado para resolver P2021
- `PRISMA_ERROR_FIX.md` - Guia geral de erros do Prisma
- `TESTE_LOCAL.md` - Guia para testes locais

## 💡 Próximos Passos

1. **IMEDIATO**: Executar migrations no Railway
2. **APÓS MIGRATIONS**: Testar registro e login
3. **SE AINDA HOUVER ERROS**: Verificar logs detalhados e mensagens de erro

---

**Última Atualização**: 2025-12-23
**Status**: Aguardando execução de migrations no Railway

