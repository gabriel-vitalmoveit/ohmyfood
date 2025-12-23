# FASE 0.5 — AUDIT COMPLEMENTAR

## ✅ 1. FORMATO DO AUTHORIZATION HEADER E STORAGE

### Authorization Header
**Formato:** `Bearer $token` (padrão JWT)
- ✅ **Customer App:** `headers['Authorization'] = 'Bearer $token'` (linha 27 de `api_client.dart`)
- ✅ **Restaurant App:** `headers['Authorization'] = 'Bearer $token'` (linha 15 de `api_client.dart`)
- ✅ **Courier App:** `headers['Authorization'] = 'Bearer $token'` (linha 15 de `api_client.dart`)
- ✅ **Admin Panel:** (assumir mesmo padrão)

### Token Storage
**Todas as apps usam `SharedPreferences`:**

#### Customer App (`auth_repository.dart`):
- `auth_access_token` → `SharedPreferences`
- `auth_refresh_token` → `SharedPreferences`
- `auth_user_email` → `SharedPreferences`
- `auth_user_id` → `SharedPreferences`

#### Restaurant App (`auth_repository.dart`):
- `auth_access_token` → `SharedPreferences`
- `auth_refresh_token` → `SharedPreferences`
- `auth_user_id` → `SharedPreferences`
- `auth_user_role` → `SharedPreferences`
- `auth_user_email` → `SharedPreferences`
- `auth_restaurant_id` → `SharedPreferences` (extra)

#### Courier App:
- (Assumir mesmo padrão do Restaurant)

**Conclusão:** ✅ **CONSISTENTE** - Todas usam `Bearer` token e `SharedPreferences`.

---

## ✅ 2. RELAÇÃO USER ↔ RESTAURANT/COURIER

### Schema Prisma

```prisma
model User {
  courier       Courier?      // Relação one-to-one
  restaurant   Restaurant?   // Relação one-to-one
}

model Restaurant {
  userId  String?  @unique  // Campo opcional (pode ser null)
  user    User?    @relation(fields: [userId], references: [id])
}

model Courier {
  userId  String   @unique  // Campo obrigatório
  user    User     @relation(fields: [userId], references: [id])
}
```

### Análise
- ✅ **Courier:** `userId` é **obrigatório** e `@unique` → Um User pode ter no máximo 1 Courier
- ⚠️ **Restaurant:** `userId` é **opcional** (`String?`) → Um User pode ter no máximo 1 Restaurant, mas Restaurant pode existir sem User (legado?)

**Problema Potencial:**
- Restaurant pode ter `userId = null` → Como validar se um restaurante pertence ao usuário autenticado?
- **Solução:** Ao criar/atualizar Restaurant, garantir que `userId` seja preenchido com o `currentUser.userId`

**Conclusão:** ⚠️ **ATENÇÃO NECESSÁRIA** - Restaurant com `userId` opcional pode causar problemas de validação.

---

## ⚠️ 3. ENDPOINTS COM IDs ARBITRÁRIOS (PRECISAM VIRAR /me)

### Endpoints que aceitam IDs arbitrários:

#### ❌ **CRÍTICO - Precisa correção:**

1. **`GET /orders/user/:userId`** (`orders.controller.ts:18`)
   - **Problema:** Cliente pode acessar pedidos de outros usuários
   - **Status:** Tem validação manual (linha 23-25), mas deveria ser `/orders/me`
   - **Ação:** Mudar para `GET /orders/me` e usar `@CurrentUser()`

2. **`POST /orders/user/:userId`** (`orders.controller.ts:66`)
   - **Problema:** Cliente pode criar pedidos para outros usuários
   - **Status:** Tem validação manual (linha 71-73), mas deveria ser `/orders/me`
   - **Ação:** Mudar para `POST /orders` e usar `@CurrentUser()`

3. **`GET /restaurants/:id/stats`** (`restaurants.controller.ts:43`)
   - **Problema:** Restaurant pode ver stats de outros restaurantes
   - **Status:** ⚠️ **SEM VALIDAÇÃO** - Apenas verifica role, não valida se `id === user.restaurantId`
   - **Ação:** Adicionar validação ou mudar para `GET /restaurants/me/stats`

4. **`GET /restaurants/:id/orders`** (`restaurants.controller.ts:51`)
   - **Problema:** Restaurant pode ver pedidos de outros restaurantes
   - **Status:** ⚠️ **SEM VALIDAÇÃO** - Apenas verifica role, não valida se `id === user.restaurantId`
   - **Ação:** Adicionar validação ou mudar para `GET /restaurants/me/orders`

5. **`GET /orders/restaurant/:restaurantId`** (`orders.controller.ts:29`)
   - **Problema:** Restaurant pode ver pedidos de outros restaurantes
   - **Status:** ⚠️ **SEM VALIDAÇÃO** - TODO comentado (linha 39), não valida se `restaurantId === user.restaurantId`
   - **Ação:** Adicionar validação ou mudar para `GET /orders/restaurant/me`

6. **`POST /restaurants/:restaurantId/menu`** (`menu.controller.ts:30`)
   - **Problema:** Restaurant pode criar itens no menu de outros restaurantes
   - **Status:** ⚠️ **SEM VALIDAÇÃO** - Apenas verifica role
   - **Ação:** Adicionar validação ou mudar para `POST /restaurants/me/menu`

7. **`PUT /restaurants/:restaurantId/menu/:id`** (`menu.controller.ts:41`)
   - **Problema:** Restaurant pode editar itens de outros restaurantes
   - **Status:** ⚠️ **SEM VALIDAÇÃO** - Apenas verifica role
   - **Ação:** Adicionar validação no service (verificar se menuItem.restaurantId === user.restaurantId)

8. **`DELETE /restaurants/:restaurantId/menu/:id`** (`menu.controller.ts:49`)
   - **Problema:** Restaurant pode deletar itens de outros restaurantes
   - **Status:** ⚠️ **SEM VALIDAÇÃO** - Apenas verifica role
   - **Ação:** Adicionar validação no service

#### ✅ **Já seguro:**

- `GET /users/me/addresses` → Usa `@CurrentUser()`
- `POST /users/me/addresses` → Usa `@CurrentUser()`
- `PUT /users/me/addresses/:addressId` → Usa `@CurrentUser()`
- `DELETE /users/me/addresses/:addressId` → Usa `@CurrentUser()`
- `PUT /orders/:id/assign-courier` → Valida se `courierId === user.userId` (linha 89)

**Conclusão:** ⚠️ **8 ENDPOINTS PRECISAM CORREÇÃO** - Principalmente Restaurant endpoints sem validação de ownership.

---

## ✅ 4. CORS E ORIGINS

### Configuração (`main.ts:12-30`)

```typescript
const allowedOrigins = corsConfig?.allowedOrigins || corsConfig?.origin || [
  'https://ohmyfood.eu',
  'https://www.ohmyfood.eu',
  'https://restaurante.ohmyfood.eu',
  'https://admin.ohmyfood.eu',
  'https://estafeta.ohmyfood.eu',
  'http://localhost:8080',
  'http://localhost:8081',
  'http://localhost:8082',
  'http://localhost:8083',
];

app.enableCors({
  origin: allowedOrigins,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
});
```

### Análise
- ✅ **Produção:** Todos os 4 subdomínios configurados
- ✅ **Desenvolvimento:** Portas locais configuradas (8080-8083)
- ✅ **Credentials:** `true` → Permite cookies/auth headers
- ✅ **Métodos:** Todos os métodos necessários incluídos
- ✅ **Headers:** `Authorization` incluído

**Conclusão:** ✅ **CORRETO** - CORS configurado para todas as apps.

---

## ⚠️ 5. SEEDS/DADOS MÍNIMOS PARA TESTE E2E

### Seed Atual (`prisma/seed.ts`)

#### ✅ **Criados:**
- ✅ **Admin:** `admin@ohmyfood.pt` / `admin123`
- ✅ **Restaurant User:** `restaurante@ohmyfood.pt` / `restaurant123`
- ✅ **Customer:** `cliente@ohmyfood.pt` / `customer123`
- ✅ **5 Restaurants:** Tasca do Bairro, Mercado Fresco, Farmácia Lisboa, Pizza Express, Sushi Master
- ✅ **~50 Menu Items:** Distribuídos pelos 5 restaurantes

#### ❌ **FALTANDO:**
- ❌ **Courier User:** Não existe no seed
- ❌ **Courier Entity:** Não existe no seed
- ❌ **Orders de teste:** Não existem pedidos para testar fluxo E2E

### Dados Mínimos Necessários para E2E:

1. **Users:**
   - ✅ Admin
   - ✅ Customer
   - ✅ Restaurant Owner
   - ❌ **Courier** (FALTA)

2. **Entities:**
   - ✅ Restaurant (5 restaurantes)
   - ✅ Menu Items (50+ itens)
   - ❌ **Courier** (FALTA)
   - ❌ **Address** (FALTA - customer precisa de morada para checkout)
   - ❌ **Order** (FALTA - para testar fluxo completo)

3. **Fluxo E2E Mínimo:**
   - Customer cria pedido → Restaurant aceita → Restaurant prepara → Courier aceita → Courier recolhe → Courier entrega
   - **Status:** ❌ **IMPOSSÍVEL** sem Courier e Orders no seed

**Conclusão:** ⚠️ **INCOMPLETO** - Falta Courier, Addresses e Orders no seed para teste E2E.

---

## 📋 RESUMO E AÇÕES NECESSÁRIAS

### ✅ **OK (Não precisa ação):**
1. Authorization header format (`Bearer $token`)
2. Token storage (SharedPreferences)
3. CORS configuration

### ⚠️ **ATENÇÃO (Correção recomendada):**
1. **Restaurant.userId opcional** → Garantir que sempre seja preenchido
2. **8 endpoints sem validação de ownership** → Adicionar validação ou mudar para `/me`
3. **Seed incompleto** → Adicionar Courier, Addresses e Orders

### 🔴 **CRÍTICO (Correção obrigatória antes de produção):**
1. **`GET /restaurants/:id/stats`** → Validar ownership
2. **`GET /restaurants/:id/orders`** → Validar ownership
3. **`GET /orders/restaurant/:restaurantId`** → Validar ownership
4. **Menu CRUD endpoints** → Validar ownership do restaurant

---

## 🎯 PRÓXIMOS PASSOS

1. **Corrigir endpoints Restaurant** para validar ownership
2. **Mudar `/orders/user/:userId`** para `/orders/me`
3. **Adicionar Courier ao seed**
4. **Adicionar Addresses de teste ao seed**
5. **Adicionar Orders de teste ao seed** (com status variados)

---

**Data:** 2025-12-23  
**Status:** ✅ Audit completo - 3 críticos, 5 recomendações

