# 🔍 AUDIT COMPLETO - OhMyFood Platform

**Data:** 2025-12-23  
**Objetivo:** Validar se o projeto está mínimo funcional e operacional tipo Uber Eats/Glovo

---

## 📊 1. INVENTÁRIO POR APP

### A) Customer App (Cliente Final)

#### Rotas/Páginas Existentes:
- ✅ `/` - Landing Page
- ✅ `/onboarding` - Onboarding
- ✅ `/login` - Login
- ✅ `/register` - Registo
- ✅ `/home` - Home (lista restaurantes + pesquisa)
- ✅ `/home/restaurants/:id` - Detalhe restaurante (menu)
- ✅ `/home/cart` - Carrinho
- ✅ `/home/cart/checkout` - Checkout
- ✅ `/orders` - Histórico de pedidos
- ✅ `/tracking/:id` - Tracking em tempo real
- ✅ `/profile` - Perfil

#### Componentes e Serviços:
- ✅ `ApiClient` - Cliente HTTP com refresh token automático
- ✅ `AuthService` - Login, registo, refresh token
- ✅ `AuthRepository` - Persistência de tokens
- ✅ `HereMapsService` - Cálculo de rotas e ETA
- ✅ `TrackingMapWidget` - Widget de mapa para tracking
- ✅ `CartController` - Gestão de carrinho

#### Endpoints API Usados:
- ✅ `GET /restaurants` - Lista restaurantes (com search e category)
- ✅ `GET /restaurants/:id` - Detalhe restaurante
- ✅ `GET /restaurants/:id/menu` - Menu do restaurante
- ✅ `POST /auth/register` - Registo
- ✅ `POST /auth/login` - Login
- ✅ `POST /auth/refresh` - Refresh token
- ✅ `GET /orders/user/:userId` - Pedidos do usuário
- ✅ `GET /orders/:id` - Detalhe do pedido
- ✅ `POST /orders/user/:userId` - Criar pedido

#### Guards/Permissions:
- ✅ Redirect baseado em `authStateProvider`
- ✅ Proteção de rotas (redireciona para `/` se não autenticado)
- ⚠️ **FALTA:** Validação de role (qualquer usuário autenticado pode acessar)

---

### B) Restaurant App (Restaurante)

#### Rotas/Páginas Existentes:
- ✅ `/onboarding` - Onboarding wizard
- ✅ `/dashboard` - Dashboard com estatísticas
- ✅ `/orders` - Order board (kanban)
- ✅ `/orders/:id` - Detalhe do pedido
- ✅ `/menu` - Gestão de menu (CRUD)
- ✅ `/analytics` - Analytics
- ✅ `/settings` - Definições

#### Componentes e Serviços:
- ✅ `RestaurantApiClient` - Cliente HTTP
- ✅ `RestaurantProviders` - Providers Riverpod
- ✅ Stream providers para polling em tempo real

#### Endpoints API Usados:
- ✅ `GET /restaurants/:id/stats` - Estatísticas
- ✅ `GET /orders/restaurant/:restaurantId` - Pedidos do restaurante
- ✅ `GET /orders/:id` - Detalhe do pedido
- ✅ `PUT /orders/:id/status` - Atualizar status
- ✅ `GET /restaurants/:id/menu` - Menu items
- ✅ `POST /restaurants/:id/menu` - Criar item
- ✅ `PUT /restaurants/:id/menu/:itemId` - Atualizar item
- ✅ `DELETE /restaurants/:id/menu/:itemId` - Deletar item

#### Guards/Permissions:
- ⚠️ **FALTA:** Auth completo (apenas onboarding check)
- ⚠️ **FALTA:** Validação de role RESTAURANT

---

### C) Courier App (Estafeta)

#### Rotas/Páginas Existentes:
- ✅ `/onboarding` - Onboarding
- ✅ `/dashboard` - Dashboard
- ✅ `/orders` - Pedidos disponíveis
- ✅ `/orders/:id` - Detalhe do pedido
- ✅ `/earnings` - Ganhos
- ✅ `/profile` - Perfil

#### Componentes e Serviços:
- ✅ `CourierApiClient` - Cliente HTTP
- ✅ `HereMapsService` - Cálculo de rotas
- ✅ `OrderMapWidget` - Widget de mapa
- ✅ Stream providers para polling

#### Endpoints API Usados:
- ✅ `GET /orders/available/courier` - Pedidos disponíveis
- ✅ `GET /orders/:id` - Detalhe do pedido
- ✅ `PUT /orders/:id/status` - Atualizar status
- ✅ `PUT /orders/:id/assign-courier` - Atribuir estafeta

#### Guards/Permissions:
- ⚠️ **FALTA:** Auth completo
- ⚠️ **FALTA:** Validação de role COURIER
- ⚠️ **FALTA:** Toggle online/offline funcional

---

### D) Admin Panel (Backoffice)

#### Rotas/Páginas Existentes:
- ✅ `/live` - Live Ops
- ✅ `/entities` - Entidades
- ✅ `/campaigns` - Campanhas
- ✅ `/finance` - Financeiro
- ✅ `/settings` - Definições

#### Componentes e Serviços:
- ⚠️ **FALTA:** API Client específico
- ⚠️ **FALTA:** Providers para dados reais

#### Endpoints API Usados:
- ❌ **FALTA:** Endpoints específicos de admin

#### Guards/Permissions:
- ❌ **FALTA:** Auth completo
- ❌ **FALTA:** Validação de role ADMIN

---

## 📋 2. MATRIZ DE FEATURES vs STATUS

### CUSTOMER APP

| Feature | Status | Evidência | Observações |
|---------|-------|-----------|-------------|
| **Auth & Conta** |
| Registo | ✅ OK | `register_screen.dart` | Funcional |
| Login | ✅ OK | `login_screen.dart` | Funcional |
| Recuperar password | ❌ FALTA | - | Não implementado |
| Perfil | ⚠️ PARCIAL | `profile_screen.dart` | UI existe, mas edição não funcional |
| **Moradas** |
| Criar/editar | ❌ FALTA | - | Checkout usa endereço hardcoded |
| Pin no mapa | ❌ FALTA | - | Não implementado |
| Instruções | ❌ FALTA | - | Não implementado |
| **Descoberta** |
| Lista restaurantes | ✅ OK | `home_screen.dart` | Funcional |
| Pesquisa | ✅ OK | `home_screen.dart` | Funcional com debounce |
| Filtros (aberto, taxa, tempo, rating) | ⚠️ PARCIAL | `home_screen.dart` | Apenas categoria, falta filtros avançados |
| **Menu** |
| Categorias | ✅ OK | `restaurant_screen.dart` | Funcional |
| Item detail | ✅ OK | `restaurant_screen.dart` | Funcional |
| Extras/modificadores | ⚠️ PARCIAL | Schema tem `OptionGroup`, mas UI não mostra |
| Observações | ❌ FALTA | - | Não implementado |
| **Carrinho** |
| Editar quantidades | ✅ OK | `cart_screen.dart` | Funcional |
| Validar mínimo | ⚠️ PARCIAL | - | Não validado |
| Taxas e total | ✅ OK | `cart_controller.dart` | Calculado |
| **Checkout** |
| Escolher morada | ❌ FALTA | `checkout_screen.dart` | Hardcoded |
| Método pagamento | ⚠️ PARCIAL | `checkout_screen.dart` | UI existe, mas não funcional |
| Confirmar pedido | ✅ OK | `checkout_screen.dart` | Cria pedido via API |
| **Tracking** |
| Timeline de estados | ✅ OK | `tracking_screen.dart` | Funcional |
| Mapa (quando em entrega) | ✅ OK | `tracking_screen.dart` | HERE Maps integrado |
| Dados do estafeta | ✅ OK | `tracking_screen.dart` | Mostra quando atribuído |
| **Suporte** |
| Reportar problema | ❌ FALTA | - | Não implementado |
| **Histórico** |
| Pedidos | ✅ OK | `orders_screen.dart` | Funcional |
| Detalhe | ⚠️ PARCIAL | - | Não há tela de detalhe do histórico |
| Repetir pedido | ❌ FALTA | `orders_screen.dart` | Botão existe mas não funcional |
| **Avaliações** |
| Restaurante | ❌ FALTA | - | Não implementado |
| Estafeta | ❌ FALTA | - | Não implementado |

---

### COURIER APP

| Feature | Status | Evidência | Observações |
|---------|-------|-----------|-------------|
| **Auth** |
| Registo/login | ⚠️ PARCIAL | - | Não há tela de auth |
| **Disponibilidade** |
| Online/offline | ⚠️ PARCIAL | `dashboard_screen.dart` | Toggle existe, mas não persiste |
| **Receber Entregas** |
| Lista pedidos disponíveis | ✅ OK | `available_orders_screen.dart` | Funcional |
| Aceitar/recusar | ⚠️ PARCIAL | `order_detail_screen.dart` | Aceitar existe, recusar não |
| Timer | ❌ FALTA | - | Não implementado |
| **Navegação** |
| Mapa + rota | ✅ OK | `order_map_widget.dart` | HERE Maps integrado |
| **Fluxo** |
| Cheguei ao restaurante | ⚠️ PARCIAL | `order_detail_screen.dart` | Status update existe |
| Recolhido | ✅ OK | `order_detail_screen.dart` | Funcional |
| Cheguei ao cliente | ⚠️ PARCIAL | `order_detail_screen.dart` | Status update existe |
| Entregue | ✅ OK | `order_detail_screen.dart` | Funcional |
| **Contacto** |
| Ligar/chat | ⚠️ PARCIAL | `order_detail_screen.dart` | Botão existe mas não funcional |
| **Ganhos** |
| Histórico | ⚠️ PARCIAL | `earnings_screen.dart` | UI existe, mas dados mock |
| Totais | ⚠️ PARCIAL | `earnings_screen.dart` | UI existe, mas dados mock |
| **Suporte** |
| Contacto | ❌ FALTA | - | Não implementado |

---

### RESTAURANT APP

| Feature | Status | Evidência | Observações |
|---------|-------|-----------|-------------|
| **Auth** |
| Login | ⚠️ PARCIAL | - | Não há tela de auth |
| **Config** |
| Dados | ⚠️ PARCIAL | `restaurant_settings_screen.dart` | UI existe, mas não funcional |
| Horários | ❌ FALTA | - | Não implementado |
| Estado aberto/fechado | ❌ FALTA | - | Não implementado |
| **Menu** |
| Categorias | ⚠️ PARCIAL | `menu_management_screen.dart` | CRUD existe, mas categorias não |
| Itens | ✅ OK | `menu_management_screen.dart` | CRUD completo |
| Extras/modificadores | ⚠️ PARCIAL | Schema tem, mas UI não gerencia |
| Stock/indisponível | ✅ OK | `menu_management_screen.dart` | Toggle disponível |
| **Pedidos (Board)** |
| Kanban | ✅ OK | `order_board_screen.dart` | Funcional |
| Aceitar/recusar | ✅ OK | `order_detail_screen.dart` | Funcional |
| Definir tempo prep | ❌ FALTA | - | Não implementado |
| Marcar pronto | ✅ OK | `order_detail_screen.dart` | Funcional |
| **Detalhe Pedido** |
| Itens + observações | ✅ OK | `order_detail_screen.dart` | Funcional |
| Contacto | ✅ OK | `order_detail_screen.dart` | Mostra dados do cliente |
| **Histórico** |
| Pedidos concluídos | ⚠️ PARCIAL | `order_board_screen.dart` | Mostra, mas sem filtro |
| **Suporte** |
| Contacto | ❌ FALTA | - | Não implementado |

---

### ADMIN PANEL

| Feature | Status | Evidência | Observações |
|---------|-------|-----------|-------------|
| **Auth + Roles** |
| Login admin | ❌ FALTA | - | Não implementado |
| Roles | ❌ FALTA | - | Não implementado |
| **Gestão Restaurantes** |
| Criar/aprovar/suspender | ⚠️ PARCIAL | `entities_screen.dart` | UI existe, mas não funcional |
| Ver menus | ❌ FALTA | - | Não implementado |
| **Gestão Estafetas** |
| Aprovar/suspender | ⚠️ PARCIAL | `entities_screen.dart` | UI existe, mas não funcional |
| Ver status | ❌ FALTA | - | Não implementado |
| **Gestão Pedidos** |
| Listar | ❌ FALTA | - | Não implementado |
| Ver timeline/logs | ❌ FALTA | - | Não implementado |
| Cancelar | ❌ FALTA | - | Não implementado |
| Reatribuir estafeta | ❌ FALTA | - | Não implementado |
| **Pagamentos** |
| Marcar pagos | ❌ FALTA | - | Não implementado |
| Exportar | ❌ FALTA | - | Não implementado |
| Taxas | ❌ FALTA | - | Não implementado |
| **Suporte** |
| Tickets | ❌ FALTA | - | Não implementado |
| Disputas | ❌ FALTA | - | Não implementado |
| Reembolsos | ❌ FALTA | - | Não implementado |
| **Config Plataforma** |
| Taxas | ❌ FALTA | - | Não implementado |
| Zonas | ❌ FALTA | - | Não implementado |
| Limites | ❌ FALTA | - | Não implementado |
| **Auditoria** |
| Logs | ❌ FALTA | - | Não implementado |

---

## 🚨 3. BLOQUEADORES END-TO-END

### Fluxo Completo de Pedido:

1. **Cliente cria pedido** ✅
   - Checkout funciona
   - Cria pedido via API
   - Status: `DRAFT` → `AWAITING_ACCEPTANCE`

2. **Restaurante aceita** ✅
   - Order board mostra pedido
   - Pode aceitar/recusar
   - Status: `AWAITING_ACCEPTANCE` → `PREPARING`

3. **Restaurante marca pronto** ✅
   - Pode marcar como pronto
   - Status: `PREPARING` → `PICKUP`

4. **Estafeta aceita** ⚠️ PARCIAL
   - Vê pedidos disponíveis
   - Pode aceitar
   - ⚠️ **FALTA:** Atribuição automática/manual

5. **Estafeta recolhe** ✅
   - Pode confirmar recolha
   - Status: `PICKUP` → `ON_THE_WAY`

6. **Estafeta entrega** ✅
   - Pode marcar como entregue
   - Status: `ON_THE_WAY` → `DELIVERED`

7. **Cliente vê tracking** ✅
   - Timeline funciona
   - Mapa funciona
   - Polling em tempo real

8. **Cliente avalia** ❌ FALTA
   - Não implementado

---

## ⚠️ 4. PROBLEMAS CRÍTICOS

### Estados de Pedido:
- ✅ Schema tem: `DRAFT`, `AWAITING_ACCEPTANCE`, `PREPARING`, `PICKUP`, `ON_THE_WAY`, `DELIVERED`, `CANCELLED`
- ⚠️ **FALTA:** Validação de transições (pode pular estados)
- ⚠️ **FALTA:** `REJECTED` status (restaurante recusa)

### Atribuição de Estafeta:
- ⚠️ **FALTA:** Lógica automática (primeiro que aceitar)
- ⚠️ **FALTA:** Lógica manual (admin atribui)

### Notificações:
- ✅ Polling implementado (5-10 segundos)
- ❌ **FALTA:** WebSocket/Push notifications
- ❌ **FALTA:** Badge de notificações
- ❌ **FALTA:** Som de notificação

### Cálculo de Preço:
- ✅ Subtotal calculado
- ✅ Taxa entrega calculada
- ✅ Taxa serviço calculada
- ✅ Total calculado
- ⚠️ **FALTA:** Validação de valores mínimos

### Segurança:
- ✅ Auth com JWT
- ✅ Refresh token
- ⚠️ **FALTA:** Guards por role no backend
- ⚠️ **FALTA:** Rate limiting
- ⚠️ **FALTA:** Validação server-side completa

### Observabilidade:
- ⚠️ **FALTA:** Logs estruturados
- ⚠️ **FALTA:** Error tracking (Sentry)
- ⚠️ **FALTA:** Métricas

---

## 📝 5. CHECKLIST FINAL

### Customer App: 60% Completo
- ✅ Auth básico
- ✅ Descoberta e menu
- ✅ Carrinho e checkout
- ✅ Tracking
- ❌ Moradas
- ❌ Extras/modificadores UI
- ❌ Avaliações
- ❌ Suporte

### Courier App: 50% Completo
- ✅ Lista pedidos
- ✅ Mapa e navegação
- ✅ Fluxo de entrega
- ❌ Auth
- ❌ Online/offline persistente
- ❌ Ganhos reais
- ❌ Contacto funcional

### Restaurant App: 70% Completo
- ✅ Order board
- ✅ Menu CRUD
- ✅ Aceitar/recusar
- ❌ Auth
- ❌ Horários
- ❌ Estado aberto/fechado
- ❌ Extras/modificadores UI

### Admin Panel: 10% Completo
- ⚠️ UI básica
- ❌ Tudo funcional

---

## 🎯 6. PRIORIDADES PARA MVP FUNCIONAL

### BLOQUEADORES (Implementar AGORA):

1. **Auth completo em todas as apps**
   - Login/registo em Restaurant, Courier, Admin
   - Guards por role no backend
   - Proteção de rotas no frontend

2. **Moradas no Customer App**
   - CRUD de moradas
   - Seleção no checkout
   - Pin no mapa

3. **Validação de transições de estado**
   - Backend: validar transições válidas
   - Frontend: desabilitar ações inválidas

4. **Atribuição de estafeta**
   - Lógica: primeiro que aceitar
   - Ou: admin atribui manualmente

5. **Extras/modificadores UI**
   - Customer: selecionar extras no item
   - Restaurant: gerir extras no menu

6. **Suporte básico**
   - Formulário de reportar problema
   - Endpoint de suporte

7. **Admin Panel funcional**
   - Gestão de restaurantes
   - Gestão de estafetas
   - Gestão de pedidos

---

**PRÓXIMO PASSO:** Implementar bloqueadores em ordem de prioridade.

