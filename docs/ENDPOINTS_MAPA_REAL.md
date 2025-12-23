# MAPA REAL DOS ENDPOINTS (Swagger OpenAPI)

**Fonte:** https://ohmyfood-production-800c.up.railway.app/api/docs-json  
**Data:** 2025-12-23

## ENDPOINTS POR CATEGORIA

### 🔐 AUTH (4 endpoints)
- `POST /api/auth/register` - ❌ Sem auth
- `POST /api/auth/login` - ❌ Sem auth
- `POST /api/auth/refresh` - ❌ Sem auth
- `GET /api/auth/me` - ✅ **COM AUTH** (Bearer)

### 👤 USERS (6 endpoints)
- `GET /api/users` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `GET /api/users/{id}` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `GET /api/users/me/addresses` - ✅ **COM AUTH** (Bearer) - CUSTOMER/ADMIN
- `POST /api/users/me/addresses` - ✅ **COM AUTH** (Bearer) - CUSTOMER/ADMIN
- `PUT /api/users/me/addresses/{addressId}` - ✅ **COM AUTH** (Bearer) - CUSTOMER/ADMIN
- `DELETE /api/users/me/addresses/{addressId}` - ✅ **COM AUTH** (Bearer) - CUSTOMER/ADMIN

### 🍽️ RESTAURANTS (5 endpoints)
- `GET /api/restaurants` - ❌ Sem auth (público)
- `GET /api/restaurants/{id}` - ❌ Sem auth (público)
- `POST /api/restaurants` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `GET /api/restaurants/{id}/stats` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: SEM VALIDAÇÃO OWNERSHIP**
- `GET /api/restaurants/{id}/orders` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: SEM VALIDAÇÃO OWNERSHIP**

### 📋 MENU (10 endpoints)
- `GET /api/restaurants/{restaurantId}/menu` - ❌ Sem auth (público)
- `GET /api/restaurants/{restaurantId}/menu/{id}` - ❌ Sem auth (público)
- `POST /api/restaurants/{restaurantId}/menu` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: SEM VALIDAÇÃO OWNERSHIP**
- `PUT /api/restaurants/{restaurantId}/menu/{id}` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: SEM VALIDAÇÃO OWNERSHIP**
- `DELETE /api/restaurants/{restaurantId}/menu/{id}` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: SEM VALIDAÇÃO OWNERSHIP**
- `POST /api/restaurants/{restaurantId}/menu/{menuItemId}/option-groups` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: SEM VALIDAÇÃO OWNERSHIP**
- `PUT /api/restaurants/{restaurantId}/menu/option-groups/{optionGroupId}` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: SEM VALIDAÇÃO OWNERSHIP**
- `DELETE /api/restaurants/{restaurantId}/menu/option-groups/{optionGroupId}` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: SEM VALIDAÇÃO OWNERSHIP**
- `POST /api/restaurants/{restaurantId}/menu/option-groups/{optionGroupId}/options` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: SEM VALIDAÇÃO OWNERSHIP**
- `PUT /api/restaurants/{restaurantId}/menu/options/{optionId}` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: SEM VALIDAÇÃO OWNERSHIP**
- `DELETE /api/restaurants/{restaurantId}/menu/options/{optionId}` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: SEM VALIDAÇÃO OWNERSHIP**

### 📦 ORDERS (7 endpoints)
- `GET /api/orders/user/{userId}` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: TEM VALIDAÇÃO MANUAL, MAS DEVERIA SER /me**
- `POST /api/orders/user/{userId}` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: TEM VALIDAÇÃO MANUAL, MAS DEVERIA SER /me**
- `GET /api/orders/restaurant/{restaurantId}` - ✅ **COM AUTH** (Bearer) - ⚠️ **CRÍTICO: SEM VALIDAÇÃO OWNERSHIP**
- `GET /api/orders/available/courier` - ✅ **COM AUTH** (Bearer) - COURIER/ADMIN
- `GET /api/orders/{id}` - ✅ **COM AUTH** (Bearer)
- `PUT /api/orders/{id}/status` - ✅ **COM AUTH** (Bearer) - RESTAURANT/COURIER/ADMIN
- `PUT /api/orders/{id}/assign-courier` - ✅ **COM AUTH** (Bearer) - COURIER/ADMIN (tem validação)

### 🎫 SUPPORT (4 endpoints)
- `POST /api/support/tickets` - ✅ **COM AUTH** (Bearer)
- `GET /api/support/tickets` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `GET /api/support/tickets/{id}` - ✅ **COM AUTH** (Bearer)
- `PUT /api/support/tickets/{id}` - ✅ **COM AUTH** (Bearer) - ADMIN only

### 👨‍💼 ADMIN (11 endpoints)
- `GET /api/admin/summary` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `GET /api/admin/live-orders` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `GET /api/admin/restaurants` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `PUT /api/admin/restaurants/{id}/approve` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `PUT /api/admin/restaurants/{id}/suspend` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `GET /api/admin/couriers` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `PUT /api/admin/couriers/{id}/approve` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `PUT /api/admin/couriers/{id}/suspend` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `GET /api/admin/orders` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `PUT /api/admin/orders/{id}/cancel` - ✅ **COM AUTH** (Bearer) - ADMIN only
- `PUT /api/admin/orders/{id}/reassign-courier` - ✅ **COM AUTH** (Bearer) - ADMIN only

### 🎁 PROMOS (1 endpoint)
- `GET /api/promos` - ❌ Sem auth (público)

### 💳 PAYMENTS (1 endpoint)
- `POST /payments/stripe/webhook` - ❌ Sem auth (webhook externo)

---

## RESUMO DE PROBLEMAS CRÍTICOS

### 🔴 ENDPOINTS SEM VALIDAÇÃO DE OWNERSHIP (8 críticos):
1. `GET /api/restaurants/{id}/stats` - Restaurant pode ver stats de outros
2. `GET /api/restaurants/{id}/orders` - Restaurant pode ver pedidos de outros
3. `GET /api/orders/restaurant/{restaurantId}` - Restaurant pode ver pedidos de outros
4. `POST /api/restaurants/{restaurantId}/menu` - Restaurant pode criar itens em outros menus
5. `PUT /api/restaurants/{restaurantId}/menu/{id}` - Restaurant pode editar itens de outros
6. `DELETE /api/restaurants/{restaurantId}/menu/{id}` - Restaurant pode deletar itens de outros
7. `GET /api/orders/user/{userId}` - Deveria ser `/me` (tem validação manual, mas não ideal)
8. `POST /api/orders/user/{userId}` - Deveria ser `/me` (tem validação manual, mas não ideal)

### ⚠️ ENDPOINTS COM VALIDAÇÃO MANUAL (mas deveriam ser /me):
- `GET /api/orders/user/{userId}` - Linha 23-25 do controller valida manualmente
- `POST /api/orders/user/{userId}` - Linha 71-73 do controller valida manualmente

---

## ENDPOINTS QUE PRECISAM DE /me (NOVOS):
- `GET /api/orders/me` - Substituir `GET /api/orders/user/{userId}`
- `POST /api/orders` - Substituir `POST /api/orders/user/{userId}`
- `GET /api/restaurants/me/stats` - Alternativa segura para `GET /api/restaurants/{id}/stats`
- `GET /api/restaurants/me/orders` - Alternativa segura para `GET /api/restaurants/{id}/orders`

---

**Total de endpoints:** 49  
**Endpoints com auth:** 35  
**Endpoints críticos sem validação:** 8

