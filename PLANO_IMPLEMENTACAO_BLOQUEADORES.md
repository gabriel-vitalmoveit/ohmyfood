# 🚀 PLANO DE IMPLEMENTAÇÃO - BLOQUEADORES CRÍTICOS

## ✅ 1. VALIDAÇÃO DE TRANSIÇÕES DE ESTADO (IMPLEMENTADO)

**Arquivo:** `backend/api/src/modules/orders/orders.service.ts`

**O que foi feito:**
- ✅ Método `isValidTransition()` que valida transições válidas
- ✅ Transições definidas:
  - `DRAFT` → `AWAITING_ACCEPTANCE`, `CANCELLED`
  - `AWAITING_ACCEPTANCE` → `PREPARING`, `CANCELLED`
  - `PREPARING` → `PICKUP`, `CANCELLED`
  - `PICKUP` → `ON_THE_WAY`, `CANCELLED`
  - `ON_THE_WAY` → `DELIVERED`, `CANCELLED`
  - `DELIVERED` → (final)
  - `CANCELLED` → (final)
- ✅ `updateStatus()` agora valida antes de atualizar
- ✅ Histórico atualizado como array de objetos

---

## 📋 2. PRÓXIMOS BLOQUEADORES A IMPLEMENTAR

### A) Auth Completo em Todas as Apps

#### Restaurant App:
- [ ] Criar `auth_screen.dart` (login)
- [ ] Integrar com `AuthService`
- [ ] Adicionar guard no router
- [ ] Verificar role RESTAURANT

#### Courier App:
- [ ] Criar `auth_screen.dart` (login)
- [ ] Integrar com `AuthService`
- [ ] Adicionar guard no router
- [ ] Verificar role COURIER

#### Admin Panel:
- [ ] Criar `auth_screen.dart` (login)
- [ ] Integrar com `AuthService`
- [ ] Adicionar guard no router
- [ ] Verificar role ADMIN

#### Backend:
- [ ] Criar `JwtAuthGuard`
- [ ] Criar `RolesGuard`
- [ ] Aplicar guards nos controllers
- [ ] Endpoint para verificar role do usuário

---

### B) Moradas no Customer App

#### Backend:
- [ ] Endpoint `GET /users/:id/addresses`
- [ ] Endpoint `POST /users/:id/addresses`
- [ ] Endpoint `PUT /users/:id/addresses/:addressId`
- [ ] Endpoint `DELETE /users/:id/addresses/:addressId`

#### Frontend:
- [ ] Tela de gestão de moradas (`addresses_screen.dart`)
- [ ] Integrar com mapa para pin
- [ ] Campo de instruções
- [ ] Seleção de morada no checkout
- [ ] Atualizar `checkout_screen.dart` para usar moradas reais

---

### C) Extras/Modificadores UI

#### Customer App:
- [ ] Mostrar `OptionGroup` e `Option` no item detail
- [ ] Permitir seleção de extras
- [ ] Adicionar extras ao carrinho
- [ ] Mostrar extras no checkout

#### Restaurant App:
- [ ] CRUD de `OptionGroup` no menu management
- [ ] CRUD de `Option` dentro de cada grupo
- [ ] UI para definir min/max select

---

### D) Suporte Básico

#### Backend:
- [ ] Model `SupportTicket` no Prisma
- [ ] Endpoint `POST /support/tickets`
- [ ] Endpoint `GET /support/tickets` (admin)
- [ ] Endpoint `PUT /support/tickets/:id` (admin)

#### Frontend:
- [ ] Tela de reportar problema (`support_screen.dart`)
- [ ] Formulário com tipo, descrição, pedido (opcional)
- [ ] Integração com API

---

### E) Admin Panel Funcional

#### Backend:
- [ ] Endpoint `GET /admin/restaurants` (com filtros)
- [ ] Endpoint `PUT /admin/restaurants/:id/approve`
- [ ] Endpoint `PUT /admin/restaurants/:id/suspend`
- [ ] Endpoint `GET /admin/couriers`
- [ ] Endpoint `PUT /admin/couriers/:id/approve`
- [ ] Endpoint `PUT /admin/couriers/:id/suspend`
- [ ] Endpoint `GET /admin/orders`
- [ ] Endpoint `PUT /admin/orders/:id/cancel`
- [ ] Endpoint `PUT /admin/orders/:id/reassign-courier`

#### Frontend:
- [ ] Implementar `entities_screen.dart` com dados reais
- [ ] Implementar `live_ops_screen.dart` com pedidos
- [ ] Ações: aprovar, suspender, cancelar, reatribuir

---

## 🎯 ORDEM DE IMPLEMENTAÇÃO RECOMENDADA

1. ✅ **Validação de transições** (FEITO)
2. **Auth completo** (bloqueador crítico)
3. **Moradas** (necessário para checkout funcional)
4. **Extras/modificadores** (melhora UX)
5. **Suporte** (necessário para produção)
6. **Admin Panel** (último, mas importante)

---

## 📝 NOTAS

- Implementar de forma simples (MVP), mas funcional
- Sem placeholders - tudo deve funcionar
- Testar cada feature end-to-end antes de passar para próxima
- Documentar mudanças em `CHANGELOG.md`

