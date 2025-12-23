# FASE 0 — AUDIT FINAL

**Data:** 2025-12-23

## ENDPOINTS ANTIGOS VS /me

### Customer App:
- ❌ `POST /api/orders/user/:userId` → Migrar para `POST /api/orders`
- ❌ `GET /api/orders/user/:userId` → Migrar para `GET /api/orders/me` (com fallback)

### Restaurant App:
- ❌ `GET /api/restaurants/:id/stats` → Migrar para `GET /api/restaurants/me/stats` (com fallback)
- ❌ `GET /api/restaurants/:id/orders` → Migrar para `GET /api/restaurants/me/orders` (com fallback)
- ❌ `GET /api/orders/restaurant/:restaurantId` → Migrar para `GET /api/orders/restaurant/me` (com fallback)

### Courier App:
- ✅ `GET /api/orders/available/courier` - OK
- ✅ `PUT /api/orders/:id/assign-courier` - OK
- ✅ `PUT /api/orders/:id/status` - OK
- ❌ Botão "Aceitar" não funcional (onPressed vazio)

### Admin Panel:
- ❌ Tudo usa `mock_data.dart` - Precisa criar `AdminApiClient` e conectar ao backend

## AUTH /auth/me

### Status:
- ❌ Nenhuma app chama `/auth/me` após login
- ❌ Nenhuma app persiste `role`, `restaurantId`, `courierId`
- ❌ Nenhuma app tem validação de role no router

## FICHEIROS A ALTERAR

### FASE 1 (Auth):
- `apps/restaurant_app/lib/src/services/auth_service.dart` - Adicionar `getMe()`
- `apps/courier_app/lib/src/services/auth_service.dart` - Adicionar `getMe()`
- `apps/admin_panel/lib/src/services/auth_service.dart` - Adicionar `getMe()`
- `apps/*/lib/src/services/auth_repository.dart` - Persistir role/ids
- `apps/*/lib/src/services/providers/auth_providers.dart` - Chamar getMe após login
- `apps/*/lib/router.dart` - Adicionar role guard
- `apps/*/lib/src/features/auth/access_denied_screen.dart` - Criar tela

### FASE 2 (Customer Order):
- `apps/customer_app/lib/src/services/api_client.dart` - Linha 194: mudar para `POST /api/orders`

### FASE 3 (Migração /me):
- `apps/customer_app/lib/src/services/api_client.dart` - `getOrders()` usar `/me`
- `apps/restaurant_app/lib/src/services/api_client.dart` - `getStats()`, `getOrders()` usar `/me`
- `apps/restaurant_app/lib/src/features/dashboard/restaurant_dashboard_screen.dart` - Usar novos endpoints
- `apps/restaurant_app/lib/src/features/orders/order_board_screen.dart` - Usar novos endpoints

### FASE 4 (Courier):
- `apps/courier_app/lib/src/features/orders/available_orders_screen.dart` - Linha 98: implementar onPressed
- `apps/courier_app/lib/src/features/order_detail/order_detail_screen.dart` - Botões de status

### FASE 5 (Admin):
- `apps/admin_panel/lib/src/services/api_client.dart` - Criar AdminApiClient
- `apps/admin_panel/lib/src/features/entities/entities_screen.dart` - Substituir mock
- `apps/admin_panel/lib/src/features/live_ops/live_ops_screen.dart` - Substituir mock

### FASE 6 (Location):
- `apps/courier_app/lib/src/services/location_service.dart` - Criar
- `apps/customer_app/lib/src/services/location_service.dart` - Criar (se necessário)
- `apps/courier_app/lib/src/widgets/order_map_widget.dart` - Usar LocationService
- `apps/customer_app/lib/src/features/tracking/tracking_screen.dart` - Usar LocationService

