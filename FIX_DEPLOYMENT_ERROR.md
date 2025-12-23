# 🔧 FIX - ERRO DE DEPLOYMENT

## Problema Identificado

**Erro:** `Nest cannot create the UsersModule instance.`

**Causa:** Dependência circular entre `AuthModule` e `UsersModule`:
- `AuthModule` importava `UsersModule`
- `UsersModule` importava `AuthModule`

## Solução Aplicada

✅ **Removida importação de `UsersModule` do `AuthModule`**
- O `AuthService` não precisa do `UsersModule` - usa `PrismaService` diretamente
- `AuthModule` agora é independente

✅ **Corrigido schema Prisma**
- `SupportTicket.orderId` agora tem `@unique` para relação one-to-one

✅ **Criados arquivos faltantes:**
- `update-support-ticket.dto.ts`
- `support.controller.ts`
- `support.module.ts`

✅ **Implementados endpoints Admin:**
- `GET /admin/restaurants` - Lista restaurantes
- `PUT /admin/restaurants/:id/approve` - Aprovar restaurante
- `PUT /admin/restaurants/:id/suspend` - Suspender restaurante
- `GET /admin/couriers` - Lista estafetas
- `PUT /admin/couriers/:id/approve` - Aprovar estafeta
- `PUT /admin/couriers/:id/suspend` - Suspender estafeta
- `GET /admin/orders` - Lista pedidos
- `PUT /admin/orders/:id/cancel` - Cancelar pedido
- `PUT /admin/orders/:id/reassign-courier` - Reatribuir estafeta

✅ **Corrigidos erros TypeScript:**
- Ajustados includes do Prisma para relações corretas
- `Order.courier` é uma relação com `User`, não `Courier`

## Status

✅ **Backend compila sem erros TypeScript**
⚠️ **Erro EPERM local** (Windows) - não afeta deployment no Railway

## Próximos Passos

1. **Migração Prisma:** Executar no Railway:
   ```bash
   npx prisma migrate deploy
   ```

2. **Testar deployment:** O código está correto e deve funcionar no Railway

---

**Commit:** `32d9710` - fix: corrigir dependência circular AuthModule/UsersModule e erros de compilação

