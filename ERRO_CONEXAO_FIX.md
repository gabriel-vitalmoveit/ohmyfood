# 🔧 Fix - Erro de Conexão ao Criar Conta

## 🐛 Problema Identificado

Ao tentar criar conta ou fazer login, aparece erro de conexão porque:
1. **Backend não está rodando** - O servidor na porta 3000 não está ativo
2. **PostgreSQL não está disponível** - O backend precisa do banco de dados para funcionar
3. **Mensagens de erro pouco claras** - Erros genéricos não ajudam a diagnosticar

## ✅ Correções Aplicadas

### 1. Melhor Tratamento de Erros no Frontend

Atualizado `auth_service.dart` para:
- ✅ Detectar erros de conexão específicos (connection refused, timeout, etc.)
- ✅ Mostrar mensagens mais claras: "Backend não está disponível. Verifique se está rodando em http://localhost:3000/api"
- ✅ Adicionar timeout de 10 segundos nas requisições
- ✅ Melhor parsing de erros do backend

### 2. Build Atualizado

- ✅ Build refeito com `API_BASE_URL=http://localhost:3000`
- ✅ Mensagens de erro melhoradas já incluídas

## 🚀 Como Resolver

### Opção 1: Iniciar Backend com PostgreSQL (Recomendado)

**1. Instalar/Iniciar PostgreSQL:**
```bash
# Via Docker (mais rápido)
docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=ohmyfood postgres

# Ou instalar PostgreSQL localmente
# Download: https://www.postgresql.org/download/windows/
```

**2. Configurar Backend:**
```bash
cd backend/api

# Verificar .env
# DATABASE_URL=postgresql://postgres:postgres@localhost:5432/ohmyfood

# Executar migrations
npx prisma migrate dev

# Popular banco
npm run db:seed

# Iniciar backend
npm run start:dev
```

**3. Verificar:**
- Backend rodando: http://localhost:3000/api/docs
- Frontend rodando: http://localhost:8080

### Opção 2: Usar Backend do Railway (Temporário)

Se não quiser configurar PostgreSQL localmente, pode usar o backend do Railway:

```bash
cd apps/customer_app
flutter build web --release --dart-define=API_BASE_URL=https://ohmyfood-production-800c.up.railway.app
```

## 🔍 Verificar Erros

### No Navegador (F12 → Console)
- Erro: "Backend não está disponível..."
  - **Solução:** Iniciar backend local ou usar Railway

### No Backend (Terminal)
- Erro: "Can't reach database server"
  - **Solução:** Iniciar PostgreSQL ou usar Docker

- Erro: "Table does not exist"
  - **Solução:** Executar `npx prisma migrate dev`

## 📝 Status Atual

- ✅ Frontend: Rodando em http://localhost:8080
- ⚠️ Backend: Precisa ser iniciado
- ⚠️ PostgreSQL: Precisa estar rodando

## 🎯 Próximos Passos

1. **Iniciar PostgreSQL** (Docker ou local)
2. **Executar migrations** no backend
3. **Executar seed** para popular dados
4. **Iniciar backend** (`npm run start:dev`)
5. **Testar criar conta** no frontend

---

**Mensagens de erro agora são mais claras e ajudam a diagnosticar o problema!**

