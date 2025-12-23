# FASE 0 - AUDIT DETALHADO

## 1. ROTAS/GoRouter POR APP

### Customer App
- `/` - LandingPage
- `/onboarding` - OnboardingScreen
- `/login` - LoginScreen ✅
- `/register` - RegisterScreen ✅
- `/home` - HomeScreen (lista restaurantes)
- `/home/restaurants/:id` - RestaurantScreen
- `/home/cart` - CartScreen
- `/home/cart/checkout` - CheckoutScreen
- `/orders` - OrdersScreen
- `/tracking/:id` - TrackingScreen
- `/profile` - ProfileScreen

### Restaurant App
- `/onboarding` - RestaurantOnboardingScreen
- `/dashboard` - RestaurantDashboardScreen
- `/orders` - OrderBoardScreen
- `/orders/:id` - RestaurantOrderDetailScreen
- `/menu` - MenuManagementScreen
- `/analytics` - AnalyticsScreen
- `/settings` - RestaurantSettingsScreen
- ❌ **FALTA:** `/login` - AuthScreen

### Courier App
- `/onboarding` - CourierOnboardingScreen
- `/dashboard` - DashboardScreen
- `/orders` - AvailableOrdersScreen
- `/orders/:id` - CourierOrderDetailScreen
- `/earnings` - EarningsScreen
- `/profile` - CourierProfileScreen
- ❌ **FALTA:** `/login` - AuthScreen

### Admin Panel
- `/live` - LiveOpsScreen
- `/entities` - EntitiesScreen
- `/campaigns` - CampaignsScreen
- `/finance` - FinanceScreen
- `/settings` - AdminSettingsScreen
- ❌ **FALTA:** `/login` - AuthScreen

## 2. AUTH SERVICE / API CLIENT EXISTENTES

### Customer App
- ✅ `AuthService` - login, register, refreshToken
- ✅ `AuthRepository` - persistência de tokens
- ✅ `ApiClient` - com refresh automático

### Restaurant/Courier/Admin Apps
- ❌ **FALTA:** AuthService específico (pode reutilizar do customer)

## 3. ENDPOINTS BACKEND EXISTENTES

### Auth
- ✅ `POST /auth/register`
- ✅ `POST /auth/login`
- ✅ `POST /auth/refresh`
- ❌ **FALTA:** `GET /auth/me`

### Orders
- ✅ `GET /orders/user/:userId`
- ✅ `GET /orders/restaurant/:restaurantId`
- ✅ `GET /orders/available/courier`
- ✅ `GET /orders/:id`
- ✅ `POST /orders/user/:userId`
- ✅ `PUT /orders/:id/status`
- ✅ `PUT /orders/:id/assign-courier`

### Restaurants
- ✅ `GET /restaurants`
- ✅ `GET /restaurants/:id`
- ✅ `GET /restaurants/:id/stats`
- ✅ `GET /restaurants/:id/orders`

### Menu
- ✅ `GET /restaurants/:id/menu`
- ✅ `POST /restaurants/:id/menu`
- ✅ `PUT /restaurants/:id/menu/:itemId`
- ✅ `DELETE /restaurants/:id/menu/:itemId`
- ❌ **FALTA:** CRUD de OptionGroups/Options

### Users
- ❌ **FALTA:** Endpoints de moradas

### Admin
- ❌ **FALTA:** Todos os endpoints

### Support
- ❌ **FALTA:** Todos os endpoints

## 4. PRISMA SCHEMA ATUAL

### Models Existentes:
- ✅ User (com role, addresses Json?)
- ✅ Restaurant
- ✅ Courier
- ✅ Order (com statusHistory Json?)
- ✅ OrderItem (com addons Json?)
- ✅ MenuItem
- ✅ OptionGroup
- ✅ Option
- ❌ **FALTA:** Address (model separado)
- ❌ **FALTA:** SupportTicket

## 5. MATRIZ DE FEATURES

| Feature | App/Backend | Status | Evidência | O que fazer |
|---------|-------------|--------|-----------|-------------|
| **FASE 1 - BACKEND AUTH + ROLES** |
| JwtAuthGuard | Backend | ❌ FALTA | - | Criar guard |
| RolesGuard | Backend | ❌ FALTA | - | Criar guard + decorator |
| GET /auth/me | Backend | ❌ FALTA | - | Criar endpoint |
| Guards em controllers | Backend | ❌ FALTA | - | Aplicar guards |
| **FASE 2 - FRONTEND AUTH** |
| Auth screen Restaurant | Restaurant App | ❌ FALTA | - | Criar auth_screen.dart |
| Auth screen Courier | Courier App | ❌ FALTA | - | Criar auth_screen.dart |
| Auth screen Admin | Admin App | ❌ FALTA | - | Criar auth_screen.dart |
| Router guards | Restaurant/Courier/Admin | ❌ FALTA | - | Adicionar redirects |
| **FASE 3 - MORADAS** |
| Address model | Prisma | ❌ FALTA | - | Criar model |
| Endpoints moradas | Backend | ❌ FALTA | - | CRUD endpoints |
| Addresses screen | Customer App | ❌ FALTA | - | Criar screen |
| Checkout com morada | Customer App | ⚠️ PARCIAL | checkout_screen.dart | Usar morada real |
| **FASE 4 - ATRIBUIÇÃO COURIER** |
| assignCourier atômico | Backend | ⚠️ PARCIAL | orders.service.ts:171 | Melhorar com transação |
| Validação status PICKUP | Backend | ❌ FALTA | - | Adicionar validação |
| Aceitar pedido | Courier App | ⚠️ PARCIAL | order_detail_screen.dart | Melhorar |
| **FASE 5 - EXTRAS/MODIFICADORES** |
| CRUD OptionGroups | Backend | ❌ FALTA | - | Criar endpoints |
| CRUD Options | Backend | ❌ FALTA | - | Criar endpoints |
| UI extras Customer | Customer App | ❌ FALTA | - | Criar UI |
| UI extras Restaurant | Restaurant App | ❌ FALTA | - | Criar UI |
| **FASE 6 - SUPORTE + ADMIN** |
| SupportTicket model | Prisma | ❌ FALTA | - | Criar model |
| Endpoints suporte | Backend | ❌ FALTA | - | Criar endpoints |
| Admin endpoints | Backend | ❌ FALTA | - | Criar endpoints |
| Admin UI funcional | Admin App | ❌ FALTA | - | Implementar |

---

**AUDIT CONCLUÍDO. INICIANDO FASE 1...**

