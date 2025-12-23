# 🧪 Guia de Teste Local - OhMyFood

Este guia mostra como rodar a aplicação web localmente com dados mockados.

---

## 📋 Pré-requisitos

✅ Node.js instalado  
✅ PostgreSQL instalado e rodando  
✅ Flutter instalado  
✅ Prisma CLI instalado (`npm i -g prisma`)

---

## 🗄️ Passo 1: Configurar Base de Dados Local

### 1.1 Criar Base de Dados PostgreSQL

```bash
# Conectar ao PostgreSQL
psql -U postgres

# Criar base de dados
CREATE DATABASE ohmyfood;

# Sair
\q
```

### 1.2 Configurar DATABASE_URL

Crie um arquivo `.env` em `backend/api/`:

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/ohmyfood"
PORT=3000
JWT_ACCESS_SECRET=your-secret-key-here
JWT_REFRESH_SECRET=your-refresh-secret-here
```

---

## 🚀 Passo 2: Setup do Backend

### 2.1 Instalar Dependências

```bash
cd backend/api
npm install
```

### 2.2 Executar Migrations

```bash
# Gerar Prisma Client
npx prisma generate

# Executar migrations
npx prisma migrate dev --name init
```

### 2.3 Popular Base de Dados (Seed)

```bash
# Executar seed com dados mockados
npm run db:seed
```

**Credenciais criadas:**
- **Admin:** `admin@ohmyfood.pt` / `admin123`
- **Restaurante:** `restaurante@ohmyfood.pt` / `restaurant123`
- **Cliente:** `cliente@ohmyfood.pt` / `customer123`

**Restaurantes criados:**
- Tasca do Bairro (Restaurante Português)
- Mercado Fresco (Mercearia Bio)
- Farmácia Lisboa 24h (Farmácia)

### 2.4 Iniciar Backend

```bash
# Modo desenvolvimento (com hot reload)
npm run start:dev

# Ou modo produção
npm run start
```

O backend estará disponível em: `http://localhost:3000`

**Verificar:** Acesse `http://localhost:3000/api/docs` para ver a documentação Swagger.

---

## 🌐 Passo 3: Rodar Frontend Web

### 3.1 Build já está pronto!

O build já foi feito com `API_BASE_URL=http://localhost:3000` e está em:
```
apps/customer_app/build/web/
```

### 3.2 Servir os arquivos

**Opção A: Usar Flutter (Recomendado)**

```bash
cd apps/customer_app
flutter run -d chrome --web-port=8080
```

**Opção B: Usar servidor HTTP simples**

```bash
# Python
cd apps/customer_app/build/web
python -m http.server 8080

# Ou Node.js (http-server)
npx http-server -p 8080

# Ou PHP
php -S localhost:8080
```

### 3.3 Acessar

Abra no navegador: `http://localhost:8080`

---

## 🧪 Testar Funcionalidades

### 1. Landing Page
- Acesse: `http://localhost:8080/`
- Deve mostrar a landing page com botões de Login/Registro

### 2. Registro
- Clique em "Criar Conta" ou "Regista-te"
- Crie uma nova conta ou use: `cliente@ohmyfood.pt` / `customer123`

### 3. Login
- Use uma das credenciais:
  - Cliente: `cliente@ohmyfood.pt` / `customer123`
  - Admin: `admin@ohmyfood.pt` / `admin123`
  - Restaurante: `restaurante@ohmyfood.pt` / `restaurant123`

### 4. Home Page
- Após login, deve mostrar a home com restaurantes mockados
- Deve ver: Tasca do Bairro, Mercado Fresco, Farmácia Lisboa 24h

### 5. Ver Restaurante
- Clique em um restaurante
- Deve mostrar o menu com itens

### 6. Adicionar ao Carrinho
- Adicione itens ao carrinho
- Verifique o carrinho

---

## 🔄 Re-executar Seed (Limpar e Recriar)

Se quiser limpar e recriar os dados:

```bash
cd backend/api

# Resetar banco (CUIDADO: apaga tudo!)
npx prisma migrate reset

# Executar seed novamente
npm run db:seed
```

---

## 🛠️ Troubleshooting

### ❌ Erro: "Can't reach database server"
- Verifique se PostgreSQL está rodando
- Verifique se `DATABASE_URL` está correta
- Teste conexão: `psql -U postgres -d ohmyfood`

### ❌ Erro: "Table does not exist"
- Execute migrations: `npx prisma migrate dev`
- Verifique se o banco foi criado

### ❌ Erro: "Port 3000 already in use"
- Mude a porta no `.env`: `PORT=3001`
- Ou pare o processo que está usando a porta 3000

### ❌ Frontend não conecta ao backend
- Verifique se o backend está rodando em `http://localhost:3000`
- Verifique se `API_BASE_URL` no build está correto
- Verifique CORS no backend (deve permitir `http://localhost:8080`)

### ❌ Erro CORS
- O backend já está configurado para permitir `http://localhost:8080`
- Se usar outra porta, adicione em `backend/api/src/main.ts`

---

## 📝 Estrutura de Dados Mockados

### Usuários
- **Admin:** `admin@ohmyfood.pt` / `admin123`
- **Restaurante:** `restaurante@ohmyfood.pt` / `restaurant123`
- **Cliente:** `cliente@ohmyfood.pt` / `customer123`

### Restaurantes
1. **Tasca do Bairro**
   - Categorias: Restaurantes, Português, Tradicional
   - Menu: Bitoque Clássico, Bacalhau à Brás, Pastel de Nata

2. **Mercado Fresco**
   - Categorias: Mercearia, Bio
   - Menu: Cabaz Bio Lisboa, Granola Artesanal

3. **Farmácia Lisboa 24h**
   - Categorias: Farmácia, Saúde
   - Menu: Kit Constipação, Pack Testes Antigénio

---

## 🚀 Comandos Rápidos

```bash
# Backend
cd backend/api
npm install                    # Instalar dependências
npx prisma migrate dev         # Executar migrations
npm run db:seed               # Popular banco
npm run start:dev             # Rodar backend

# Frontend
cd apps/customer_app
flutter run -d chrome --web-port=8080  # Rodar Flutter web
```

---

## ✅ Checklist

- [ ] PostgreSQL instalado e rodando
- [ ] Base de dados `ohmyfood` criada
- [ ] `.env` configurado com `DATABASE_URL`
- [ ] Dependências do backend instaladas
- [ ] Migrations executadas
- [ ] Seed executado (dados mockados criados)
- [ ] Backend rodando em `http://localhost:3000`
- [ ] Frontend rodando em `http://localhost:8080`
- [ ] Testado login/registro
- [ ] Testado visualização de restaurantes

---

**Status:** ✅ Pronto para testes locais  
**Última atualização:** 23/12/2025

