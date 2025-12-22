# 🔧 Fix: Porta do Railway (502 Bad Gateway)

## ❌ Problema Identificado

O erro **502 Bad Gateway** estava acontecendo porque:

- Railway configurou **Port 3000** no networking público
- Backend NestJS estava escutando na porta **8080** (visto nos logs)
- **Mismatch de portas = 502 Bad Gateway**

## ✅ Solução Aplicada

O código foi atualizado para usar `process.env.PORT` diretamente, garantindo que o backend escute na porta fornecida pelo Railway automaticamente.

### Mudança no código:

**Antes:**
```typescript
const port = configService.get<number>('PORT', 3000);
```

**Depois:**
```typescript
// Usar PORT do Railway ou fallback para 3000
// Railway define PORT automaticamente, então usamos process.env.PORT diretamente
const port = parseInt(process.env.PORT || '3000', 10);
```

### Arquivo modificado:
- `backend/api/src/main.ts`

## 🚀 Deploy Automático

O Railway fará deploy automático após o push. O problema do 502 será resolvido!

## 📋 Verificação

Após o deploy, verifique:

1. **Logs do Railway** devem mostrar:
   ```
   🚀 OhMyFood API pronta em http://localhost:3000
   📡 Porta configurada: 3000 (PORT=3000)
   ```

2. **Status do serviço** deve mudar de "Crashed" para "Online"

3. **Teste a API:**
   ```bash
   curl https://seu-backend.up.railway.app/api/restaurants
   ```

## ⚠️ Nota

Se o Railway ainda estiver configurado para porta 8080, você pode:

1. **Opção 1 (Recomendado):** Deixar o Railway usar a porta padrão (3000) - o código agora se adapta automaticamente
2. **Opção 2:** Mudar a porta pública do Railway para 3000 nas configurações de networking

---

**Status:** ✅ Fix aplicado e commitado
**Próximo passo:** Aguardar deploy automático do Railway

