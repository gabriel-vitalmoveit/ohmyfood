# IMPLEMENTATION STATUS (Roadmap + Implementações + Ecrãs)

Atualizado: 2025-12-29

Este ficheiro é um **overview real** do estado do projeto, cruzando:
- documentação existente (status/planos)
- estrutura do backend (NestJS + Prisma)
- ecrãs/fluxos existentes nas apps Flutter

## Estado global (resumo executivo)

- **Backend (NestJS + Prisma)**: **muito avançado** e com os módulos core já implementados (Auth/RBAC, Orders, Restaurants, Menu, Admin, Support, Payments, Chat, etc.).
- **Apps Flutter**: **UI forte e extensa**, mas ainda existem pontos críticos de integração end‑to‑end (principalmente token em chamadas protegidas, migração total de mock → API em alguns ecrãs, e alinhamento do workflow de estados do pedido).
- **Deployment cPanel (subdomínios)**: existem pastas/`.htaccess` no repo, mas **o subdomínio de estafetas não está consistente** (estafeta vs estafetas) e não há build publicado dentro da pasta do subdomínio no snapshot do repo.

## Roadmap por fases (estado real)

### Fase 1 — Backend Auth + Roles
**Estado:** ✅ Implementado  
**Inclui:**
- JWT Guard + Roles Guard
- `GET /api/auth/me`
- Proteção e RBAC em controllers relevantes

### Fase 2 — Frontend Auth
**Estado:** ⚠️ Implementado de forma desigual entre apps  

- **Restaurant / Courier / Admin**: ✅ login + validação de role + `/auth/me` + “access denied”.
- **Customer**: ✅ login/registo existem e há suporte a token no `ApiClient`, mas parte do estado/fluxo ainda não está uniformizado com a estratégia das outras apps.

### Fase 3 — Moradas (Addresses)
**Estado:** ✅ Implementado  

- Backend: CRUD em `/api/users/me/addresses` com `isDefault`.
- Customer App: ecrãs de moradas + checkout já consome `getAddresses()`.

### Fase 4 — Courier assignment + transições de estado
**Estado:** ⚠️ Parcial (backend completo, UI precisa alinhar)  

- Backend: `assignCourier()` atómico, valida status e evita dupla atribuição; `updateStatus()` valida transições.
- Courier App: UI de “pedidos disponíveis” e detalhe já existem.
- **Gargalo típico**: chamadas protegidas sem Bearer token geram 401; e o fluxo do pedido tem de estar alinhado com o estado real criado (ex.: `DRAFT` → `AWAITING_ACCEPTANCE`).

### Fase 5 — Extras/Modificadores
**Estado:** ⚠️ Backend pronto, UI pendente  

- Prisma: `OptionGroup`/`Option` já existem.
- Backend: endpoints de option groups/options já existem no `MenuController` e `MenuService`.
- Customer App: carrinho/checkout ainda manda `addons: []` (placeholder).

### Fase 6 — Support + Admin Panel
**Estado:** ⚠️ Backend pronto, UI pendente  

- Prisma: `SupportTicket`.
- Backend: endpoints de suporte e admin já existem.
- Admin Panel Flutter: ecrãs principais ainda usam `mock_data.dart` (não consomem `AdminApiClient` apesar dele existir).

## Ecrãs existentes (por app) + ligação à API

### Customer App (`apps/customer_app`)
**Ecrãs**
- Onboarding, Landing, Login, Registo
- Home
- Detalhe do restaurante
- Carrinho, Checkout
- Pedidos (histórico)
- Tracking
- Perfil
- Moradas (lista + form)

**Ligado à API**
- Home: já usa providers (API real).
- Moradas + Checkout: já chamam `/users/me/addresses` e `POST /orders`.
- Tracking: polling a `GET /orders/:id`.

**Ainda mock / incompleto**
- Detalhe do restaurante (`RestaurantScreen`) usa `mock_data.dart`.
- Histórico de pedidos (`OrdersScreen`) usa `mock_data.dart`.
- `CartController` depende de viewmodels do mock (bloqueia migração total para modelos API sem refactor).

### Restaurant App (`apps/restaurant_app`)
**Ecrãs**
- Login + Access denied, Onboarding
- Dashboard
- Orders board + Order detail
- Menu management, Analytics, Settings

**Ligado à API**
- Providers de stats/orders já usam token do `AuthRepository` e tentam endpoints `/me`.

**Riscos atuais**
- Existem chamadas a endpoints protegidos sem token em alguns ecrãs (tende a 401).
- Hardcodes pontuais (ex.: restaurantId fixo) precisam ser substituídos por `restaurantId` vindo do `/auth/me`.

### Courier App (`apps/courier_app`)
**Ecrãs**
- Login + Access denied, Onboarding
- Dashboard, Pedidos disponíveis, Detalhe do pedido
- Earnings, Perfil

**Ligado à API**
- Existe `CourierApiClient` com endpoints core.

**Risco crítico**
- Providers/ecrãs chamam endpoints protegidos sem Bearer token (tende a 401).

### Admin Panel (`apps/admin_panel`)
**Ecrãs**
- Login + Access denied
- Live Ops, Entities, Campaigns, Finance, Settings

**Ligado à API**
- `AdminApiClient` existe e cobre endpoints de admin.

**Ainda mock**
- Live Ops e Entities (e outros) ainda consomem `mock_data.dart`.

## Backend (módulos principais)

- **Auth**: JWT + refresh + `/auth/me`
- **Users**: addresses `/users/me/addresses`
- **Restaurants**: público + endpoints protegidos + variantes `/me`
- **Menu**: menu público + CRUD protegido + option groups/options
- **Orders**: `/orders/me`, `POST /orders`, status transitions, assign courier
- **Admin**: summary, live-orders, list/approve/suspend restaurants/couriers, list/cancel/reassign orders
- **Support**: tickets (criar, listar, ver, atualizar)
- **Payments**: Stripe intent + webhook
- **Chat/Dispatch/Promos**: presentes (estado varia por feature)

## Bloqueadores para MVP end‑to‑end

1. **Autorização (tokens)**: garantir que todas as chamadas a endpoints protegidos enviam `Authorization: Bearer ...`.
2. **Workflow do pedido**: alinhar UI com estados reais (pedido nasce `DRAFT`; avançar para `AWAITING_ACCEPTANCE` deve estar claro/automatizado).
3. **Customer híbrido mock/API**: migrar Restaurant Detail + Orders History para API e desacoplar o carrinho do mock.
4. **Admin Panel**: trocar mocks por `AdminApiClient`.
5. **Deployment estafetas**: alinhar subdomínio (estafetas) + docroot + `.htaccess` + build web publicado.

