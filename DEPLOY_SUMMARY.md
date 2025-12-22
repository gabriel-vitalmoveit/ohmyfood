# ✅ Resumo das Adaptações para cPanel + Railway

## 🎯 Estratégia Implementada

Devido às limitações do GoDaddy cPanel (Node.js 14.21.1 desatualizado), implementamos uma **arquitetura híbrida**:

- **Backend (NestJS)**: Deploy no **Railway.app**
- **Frontend (Flutter Web)**: Deploy no **cPanel** como arquivos estáticos
- **Database**: PostgreSQL no Railway (gratuito)

---

## ✅ Mudanças Implementadas

### 1. Backend (NestJS)

#### Prefixo Global `/api`
- ✅ Adicionado `app.setGlobalPrefix('api')` em `main.ts`
- ✅ Todos os endpoints agora são: `/api/restaurants`, `/api/orders`, etc.
- ✅ Swagger disponível em: `/api/docs`
- ✅ Webhook Stripe excluído do prefixo: `/payments/stripe/webhook`

#### Configuração Railway
- ✅ `railway.json` criado para deploy automático
- ✅ Script `start:prod` adicionado ao `package.json`
- ✅ CORS configurado para aceitar `ohmyfood.eu` e subdomínios

#### Correções
- ✅ Erro TypeScript no `PrismaService` corrigido
- ✅ Erro TypeScript no `PaymentsService` corrigido

### 2. Frontend (Flutter Apps)

#### Configuração de URLs
- ✅ `AppConfig` atualizado em todas as apps
- ✅ Suporte a `API_BASE_URL` via variável de ambiente
- ✅ Fallback automático para Railway URL ou produção
- ✅ URLs de desenvolvimento: `http://localhost:3000/api`

#### Scripts de Build
- ✅ `build-for-cpanel.sh` (Linux/Mac)
- ✅ `build-for-cpanel.ps1` (Windows)
- ✅ Scripts adicionam `/api` automaticamente se necessário

### 3. Configuração cPanel

#### Arquivos Criados
- ✅ `public_html/.htaccess` - SPA routing e cache
- ✅ Configuração para compressão GZIP
- ✅ Headers de segurança

---

## 📋 Estrutura de URLs

### Produção

| Serviço | URL |
|---------|-----|
| **Customer App** | `https://ohmyfood.eu` |
| **Restaurant App** | `https://restaurante.ohmyfood.eu` |
| **Admin Panel** | `https://admin.ohmyfood.eu` |
| **Backend API** | `https://seu-backend.up.railway.app/api` |
| **Swagger Docs** | `https://seu-backend.up.railway.app/api/docs` |

### Desenvolvimento

| Serviço | URL |
|---------|-----|
| **Customer App** | `http://localhost:8080` |
| **Restaurant App** | `http://localhost:8081` |
| **Admin Panel** | `http://localhost:8082` |
| **Backend API** | `http://localhost:3000/api` |
| **Swagger Docs** | `http://localhost:3000/api/docs` |

---

## 🚀 Próximos Passos

### 1. Deploy Backend no Railway

Siga o guia completo em `RAILWAY_DEPLOY.md`:

1. Criar projeto no Railway
2. Conectar repositório GitHub
3. Adicionar PostgreSQL database
4. Configurar variáveis de ambiente
5. Obter URL pública (ex: `https://backend-xxxx.up.railway.app`)

### 2. Build Frontend

```bash
# Windows
.\scripts\build-for-cpanel.ps1 https://seu-backend.up.railway.app

# Linux/Mac
./scripts/build-for-cpanel.sh https://seu-backend.up.railway.app
```

### 3. Upload para cPanel

1. Upload `apps/customer_app/build/web/` → `public_html/`
2. Upload `apps/restaurant_app/build/web/` → `public_html/restaurant/`
3. Upload `apps/admin_panel/build/web/` → `public_html/admin/`
4. Copiar `.htaccess` para cada pasta

---

## 📚 Documentação

- `RAILWAY_DEPLOY.md` - Guia completo de deploy no Railway
- `DEPLOY_CPANEL.md` - Guia de deploy no cPanel (atualizado)
- `URLS_CONFIG.md` - Configuração de todas as URLs
- `DATABASE_SETUP.md` - Setup da base de dados
- `CURSOR_DEPLOY_INSTRUCTIONS.md` - Instruções originais

---

## ✅ Status

- ✅ Backend adaptado para Railway
- ✅ Frontend adaptado para cPanel
- ✅ Prefixo `/api` configurado
- ✅ CORS configurado
- ✅ Scripts de build criados
- ✅ `.htaccess` configurado
- ✅ Erros TypeScript corrigidos
- ✅ Build passando

**Tudo pronto para deploy!** 🚀

