# CORREÇÕES FASE 0.5 - COMPLETAS

**Data:** 2025-12-23  
**Status:** ✅ Todas as fases implementadas

---

## 📋 RESUMO DAS CORREÇÕES

### ✅ FASE 0 - MAPA REAL DOS ENDPOINTS
- ✅ OpenAPI JSON baixado de `https://ohmyfood-production-800c.up.railway.app/api/docs-json`
- ✅ Documento `docs/ENDPOINTS_MAPA_REAL.md` criado com todos os 49 endpoints
- ✅ Identificados 8 endpoints críticos sem validação de ownership

### ✅ FASE 1 - AUTH/ME BASE
- ✅ `/auth/me` já implementado e retorna `restaurantId` e `courierId` corretamente
- ✅ Guards (`JwtAuthGuard`, `RolesGuard`) já implementados
- ✅ `@CurrentUser` decorator já implementado

### ✅ FASE 2 - OWNERSHIP FIX (8 ENDPOINTS CRÍTICOS)

#### Restaurants:
1. ✅ `GET /api/restaurants/:id/stats` - Adicionada validação de ownership
2. ✅ `GET /api/restaurants/:id/orders` - Adicionada validação de ownership
3. ✅ `GET /api/restaurants/me/stats` - Novo endpoint seguro
4. ✅ `GET /api/restaurants/me/orders` - Novo endpoint seguro

#### Menu:
5. ✅ `POST /api/restaurants/:restaurantId/menu` - Adicionada validação de ownership
6. ✅ `PUT /api/restaurants/:restaurantId/menu/:id` - Adicionada validação de ownership
7. ✅ `DELETE /api/restaurants/:restaurantId/menu/:id` - Adicionada validação de ownership
8. ✅ Todos os endpoints de OptionGroups/Options - Adicionada validação de ownership

#### Orders:
9. ✅ `GET /api/orders/restaurant/:restaurantId` - Adicionada validação de ownership
10. ✅ `GET /api/orders/restaurant/me` - Novo endpoint seguro
11. ✅ `GET /api/orders/me` - Novo endpoint seguro (substitui `/user/:userId`)
12. ✅ `POST /api/orders` - Novo endpoint seguro (substitui `/user/:userId`)

**Nota:** Endpoints antigos mantidos para compatibilidade, mas agora com validação forte.

### ✅ FASE 3 - RESTAURANT.userId OPCIONAL
- ✅ `RestaurantsService.create()` agora garante que `userId` seja preenchido quando user é RESTAURANT
- ✅ `RestaurantsController.create()` permite RESTAURANT role e preenche `userId` automaticamente
- ✅ Seed atualizado para garantir que `demo-restaurant` tenha `userId` do `restaurantUser`

### ✅ FASE 4 - SEEDS E2E COMPLETOS
- ✅ Courier User criado: `courier@ohmyfood.pt` / `courier123`
- ✅ Courier Entity criada com location
- ✅ Address criada para customer: `customer-address-1` com lat/lng e instructions
- ✅ Order A criado: Status `AWAITING_ACCEPTANCE` (para testar aceitação)
- ✅ Order B criado: Status `PREPARING` (para testar tracking)

---

## 📁 FICHEIROS ALTERADOS

### Backend:
- `backend/api/src/modules/restaurants/restaurants.service.ts` - Validação de ownership
- `backend/api/src/modules/restaurants/restaurants.controller.ts` - Endpoints `/me` e validação
- `backend/api/src/modules/menu/menu.service.ts` - Validação de ownership em todos os métodos
- `backend/api/src/modules/menu/menu.controller.ts` - Passa `userId` para validação
- `backend/api/src/modules/orders/orders.service.ts` - Validação de ownership
- `backend/api/src/modules/orders/orders.controller.ts` - Endpoints `/me` e validação
- `backend/api/prisma/seed.ts` - Courier, Addresses e Orders adicionados

### Documentação:
- `docs/ENDPOINTS_MAPA_REAL.md` - Mapa completo dos endpoints
- `docs/openapi.json` - Snapshot do OpenAPI
- `FASE0_5_AUDIT_COMPLEMENTAR.md` - Audit complementar

---

## 🔒 REGRAS DE OWNERSHIP APLICADAS

### Customer:
- ✅ Só pode ver/criar pedidos do próprio `userId`
- ✅ Endpoints `/me` garantem acesso apenas aos próprios dados

### Restaurant:
- ✅ Só pode ver stats/orders do próprio restaurante (`restaurant.userId === user.userId`)
- ✅ Só pode criar/editar/deletar menu items do próprio restaurante
- ✅ Admin pode acessar qualquer restaurant

### Courier:
- ✅ Só pode atribuir pedidos a si mesmo (`courierId === user.userId`)
- ✅ Admin pode atribuir a qualquer courier

---

## 🧪 COMO TESTAR E2E

### 1. Rodar Seed:
```bash
cd backend/api
npm run db:seed
```

### 2. Credenciais de Teste:
- **Admin:** `admin@ohmyfood.pt` / `admin123`
- **Restaurant:** `restaurante@ohmyfood.pt` / `restaurant123`
- **Customer:** `cliente@ohmyfood.pt` / `customer123`
- **Courier:** `courier@ohmyfood.pt` / `courier123`

### 3. Fluxo E2E:
1. **Customer login** → `POST /api/auth/login` com `cliente@ohmyfood.pt`
2. **Customer cria pedido** → `POST /api/orders` (usa `/me` automaticamente)
3. **Restaurant login** → `POST /api/auth/login` com `restaurante@ohmyfood.pt`
4. **Restaurant vê pedidos** → `GET /api/restaurants/me/orders`
5. **Restaurant aceita** → `PUT /api/orders/:id/status` com `PREPARING`
6. **Restaurant prepara** → `PUT /api/orders/:id/status` com `PICKUP`
7. **Courier login** → `POST /api/auth/login` com `courier@ohmyfood.pt`
8. **Courier lista available** → `GET /api/orders/available/courier`
9. **Courier aceita** → `PUT /api/orders/:id/assign-courier`
10. **Courier entrega** → `PUT /api/orders/:id/status` com `DELIVERED`
11. **Customer tracking** → `GET /api/orders/me` (vê status atualizado)

---

## 📊 ENDPOINTS NOVOS CRIADOS

### Seguros (usam `/me`):
- `GET /api/restaurants/me/stats` - Stats do próprio restaurante
- `GET /api/restaurants/me/orders` - Pedidos do próprio restaurante
- `GET /api/orders/me` - Pedidos do próprio user
- `POST /api/orders` - Criar pedido (usa `userId` do token)
- `GET /api/orders/restaurant/me` - Pedidos do próprio restaurante

### Endpoints Antigos (mantidos para compatibilidade):
- Todos os endpoints antigos continuam funcionando, mas agora com validação de ownership
- Retornam `403 Forbidden` se o user não for o dono (exceto Admin)

---

## ✅ CHECKLIST FINAL

- [x] FASE 0 - Mapa real dos endpoints
- [x] FASE 1 - Auth/me base
- [x] FASE 2 - Ownership fix (8 endpoints críticos)
- [x] FASE 3 - Restaurant.userId sempre preenchido
- [x] FASE 4 - Seeds E2E completos
- [x] FASE 5 - Documentação
- [ ] Deployment das apps web (próximo passo)

---

## 🚀 PRÓXIMOS PASSOS

1. **Testar localmente** com `npm run db:seed` e fluxo E2E
2. **Deployment backend** no Railway (push automático)
3. **Build das apps Flutter** para web
4. **Upload para cPanel** nos subdomínios

---

**Commit:** Todas as correções implementadas e prontas para deployment.

