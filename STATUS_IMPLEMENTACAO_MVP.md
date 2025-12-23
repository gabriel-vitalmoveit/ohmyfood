# STATUS DA IMPLEMENTAÇÃO MVP - END-TO-END

**Data:** 2025-12-23  
**Objetivo:** Finalizar MVP end-to-end nas 4 apps Flutter Web

---

## ✅ FASE 1 — AUTH UI + GUARDS (Restaurant, Courier, Admin)

### ✅ **FEITO:**
- ✅ `login_screen.dart` existe em todas as apps (restaurant, courier, admin)
- ✅ Router guards implementados (redirect para `/login` se não autenticado)
- ✅ `AuthService` e `AuthRepository` existem em todas as apps
- ✅ Token refresh implementado (`POST /api/auth/refresh`)

### ⚠️ **FALTA:**
- ❌ **Chamar `GET /api/auth/me` após login** para persistir `role`, `restaurantId`, `courierId`
- ❌ **Validação de role** no router (redirecionar para "Acesso negado" se role errada)
- ❌ **Tela "Acesso negado"** com botão logout

**Ficheiros a alterar:**
- `apps/restaurant_app/lib/src/services/auth_service.dart` - Adicionar `getMe()`
- `apps/courier_app/lib/src/services/auth_service.dart` - Adicionar `getMe()`
- `apps/admin_panel/lib/src/services/auth_service.dart` - Adicionar `getMe()`
- `apps/*/lib/src/services/auth_repository.dart` - Persistir `role`, `restaurantId`, `courierId`
- `apps/*/lib/router.dart` - Adicionar validação de role

---

## ⚠️ FASE 2 — CUSTOMER: MORADAS + CHECKOUT REAL

### ✅ **FEITO:**
- ✅ `addresses_screen.dart` existe e funciona
- ✅ `checkout_screen.dart` lista e seleciona moradas reais
- ✅ Bloqueia "confirmar" se não houver morada selecionada

### ❌ **FALTA:**
- ❌ **Usar `POST /api/orders`** (sem `userId` na URL) em vez de `POST /api/orders/user/:userId`
- ❌ **Incluir `addressId` no CreateOrderDto** (se backend suportar)

**Ficheiros a alterar:**
- `apps/customer_app/lib/src/services/api_client.dart` - Linha 203: mudar para `POST /api/orders`
- `apps/customer_app/lib/src/features/cart/checkout_screen.dart` - Linha 245: usar novo endpoint

---

## ❌ FASE 3 — MIGRAÇÃO SUAVE PARA /me (sem quebrar)

### ❌ **FALTA TUDO:**
- ❌ **Customer App:** `GET /api/orders/user/:userId` → `GET /api/orders/me`
- ❌ **Restaurant App:** `GET /api/restaurants/:id/orders` → `GET /api/restaurants/me/orders`
- ❌ **Restaurant App:** `GET /api/restaurants/:id/stats` → `GET /api/restaurants/me/stats`
- ❌ **Restaurant App:** `GET /api/orders/restaurant/:restaurantId` → `GET /api/orders/restaurant/me`
- ❌ **Fallback** para endpoints antigos (se `/me` retornar 404)

**Ficheiros a alterar:**
- `apps/customer_app/lib/src/services/api_client.dart` - `getOrders()` usar `/me`
- `apps/restaurant_app/lib/src/services/api_client.dart` - `getStats()`, `getOrders()` usar `/me`
- `apps/restaurant_app/lib/src/features/dashboard/restaurant_dashboard_screen.dart` - Usar novos endpoints
- `apps/restaurant_app/lib/src/features/orders/order_board_screen.dart` - Usar novos endpoints

---

## ⚠️ FASE 4 — COURIER: "ACEITAR" + FLOW COMPLETO

### ✅ **FEITO:**
- ✅ `AvailableOrdersScreen` existe
- ✅ Usa `GET /api/orders/available/courier`
- ✅ `CourierApiClient.assignOrder()` existe e usa `PUT /api/orders/:id/assign-courier`
- ✅ `CourierApiClient.updateOrderStatus()` existe

### ❌ **FALTA:**
- ❌ **Botão "Aceitar" funcional** em `AvailableOrdersScreen` (linha 98: `onPressed: () {}` está vazio)
- ❌ **Integrar `assignOrder()` no botão**
- ❌ **Atualizar status** para `DELIVERED` quando entregar
- ❌ **Customer ver courier atribuído** (tracking screen)

**Ficheiros a alterar:**
- `apps/courier_app/lib/src/features/orders/available_orders_screen.dart` - Implementar `onPressed` do botão
- `apps/courier_app/lib/src/features/order_detail/order_detail_screen.dart` - Botões de status

---

## ❌ FASE 5 — ADMIN PANEL: LIGAR ECRÃS AO BACKEND REAL

### ❌ **FALTA TUDO:**
- ❌ **EntitiesScreen** usa `mock_data.dart` - precisa usar backend real
- ❌ **LiveOpsScreen** usa `mock_data.dart` - precisa usar backend real
- ❌ **Endpoints a implementar:**
  - `GET /api/admin/restaurants` - Listar restaurantes
  - `PUT /api/admin/restaurants/:id/approve` - Aprovar restaurante
  - `PUT /api/admin/restaurants/:id/suspend` - Suspender restaurante
  - `GET /api/admin/couriers` - Listar estafetas
  - `PUT /api/admin/couriers/:id/approve` - Aprovar estafeta
  - `PUT /api/admin/couriers/:id/suspend` - Suspender estafeta
  - `GET /api/admin/live-orders` ou `GET /api/admin/orders` - Listar pedidos
  - `PUT /api/admin/orders/:id/cancel` - Cancelar pedido

**Ficheiros a criar/alterar:**
- `apps/admin_panel/lib/src/services/api_client.dart` - Criar métodos para admin endpoints
- `apps/admin_panel/lib/src/features/entities/entities_screen.dart` - Substituir mock por dados reais
- `apps/admin_panel/lib/src/features/live_ops/live_ops_screen.dart` - Substituir mock por dados reais

---

## 📊 RESUMO POR APP

### Customer App:
- ✅ Auth UI + Guards
- ✅ Moradas (CRUD)
- ⚠️ Checkout usa moradas, mas endpoint antigo
- ❌ Migração para `/me`

### Restaurant App:
- ✅ Auth UI + Guards
- ⚠️ Falta chamar `/auth/me` após login
- ❌ Migração para `/me` endpoints
- ❌ Validação de role

### Courier App:
- ✅ Auth UI + Guards
- ⚠️ Falta chamar `/auth/me` após login
- ⚠️ Botão "Aceitar" não funcional
- ❌ Validação de role

### Admin Panel:
- ✅ Auth UI + Guards
- ⚠️ Falta chamar `/auth/me` após login
- ❌ Tudo usa mock_data (precisa backend real)
- ❌ Validação de role

---

## 🎯 PRIORIDADES

### 🔴 **CRÍTICO (bloqueia E2E):**
1. **FASE 4:** Implementar botão "Aceitar" no Courier App
2. **FASE 2:** Migrar `createOrder` para `POST /api/orders` (sem userId)
3. **FASE 1:** Chamar `/auth/me` após login em todas as apps

### 🟡 **IMPORTANTE:**
4. **FASE 3:** Migrar para endpoints `/me`
5. **FASE 5:** Conectar Admin Panel ao backend

### 🟢 **NICE TO HAVE:**
6. Validação de role no router
7. Tela "Acesso negado"

---

## 📝 PRÓXIMOS PASSOS

1. **Implementar `/auth/me` após login** em todas as apps
2. **Corrigir `createOrder`** no Customer App
3. **Implementar botão "Aceitar"** no Courier App
4. **Migrar para `/me` endpoints** gradualmente
5. **Conectar Admin Panel** ao backend real

---

**Status Geral:** ⚠️ **60% Completo** - Faltam implementações críticas para E2E funcionar

