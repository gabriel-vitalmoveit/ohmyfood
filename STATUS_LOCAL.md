# ✅ Status - Serviços Locais

## 🚀 Serviços Iniciados

### Backend
- **Status:** Rodando em background
- **URL:** http://localhost:3000
- **Swagger:** http://localhost:3000/api/docs

### Frontend  
- **Status:** Servidor iniciado
- **URL:** http://localhost:8080

---

## ⚠️ IMPORTANTE - Base de Dados

O backend está rodando, mas **precisa do PostgreSQL** para funcionar completamente.

### Se o PostgreSQL não estiver rodando:

**Opção 1: Instalar e iniciar PostgreSQL**
1. Baixe: https://www.postgresql.org/download/windows/
2. Instale e inicie o serviço
3. Crie a base de dados:
   ```sql
   CREATE DATABASE ohmyfood;
   ```

**Opção 2: Usar Docker (mais rápido)**
```bash
docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=ohmyfood postgres
```

**Opção 3: Executar migrations e seed manualmente**
```bash
cd backend/api
npx prisma migrate dev
npm run db:seed
```

---

## 🔑 Credenciais de Teste

Após executar o seed:
- **Cliente:** `cliente@ohmyfood.pt` / `customer123`
- **Admin:** `admin@ohmyfood.pt` / `admin123`
- **Restaurante:** `restaurante@ohmyfood.pt` / `restaurant123`

---

## 📍 Acessar

1. **Frontend:** http://localhost:8080
2. **Backend API:** http://localhost:3000/api
3. **Swagger Docs:** http://localhost:3000/api/docs

---

## 🛑 Parar Serviços

Para parar os serviços, feche as janelas do PowerShell ou use:
```powershell
# Encontrar processos
Get-Process | Where-Object {$_.ProcessName -like "*node*" -or $_.ProcessName -like "*python*"} | Stop-Process
```

