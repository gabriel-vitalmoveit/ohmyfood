# 🚨 Fix: Erro 502 Bad Gateway no Railway

## ❌ Problema

Ao acessar `https://ohmyfood-production-800c.up.railway.app/api/docs`, você recebe:

```
Status Code: 502 Bad Gateway
```

## 🔍 Possíveis Causas

Um erro **502 Bad Gateway** indica que o gateway (Railway) não consegue se comunicar com o servidor backend. As principais causas são:

### 0. 🚨 **PROBLEMA IDENTIFICADO NOS LOGS** - Mismatch de Porta (Seu Caso)

**Sintomas nos seus logs:**
```
🚀 OhMyFood API pronta em http://localhost:8080
📡 Porta configurada: 8080 (PORT=8080)
```

**Problema:** O backend está rodando na porta **8080**, mas o gateway do Railway pode estar configurado para rotear para outra porta.

**Solução Rápida:**
1. No Railway, vá em **Settings** → **Networking**
2. Verifique a **"Public Port"** ou **"Port"** configurada
3. Se for diferente de **8080**, altere para **8080**
4. OU remova a variável `PORT=8080` e deixe o Railway definir automaticamente via `${{PORT}}`

**📚 Ver guia detalhado:** `RAILWAY_502_PORT_MISMATCH.md`

---

### 1. ⚠️ Serviço Não Está Rodando (Mais Comum)

**Sintomas:**
- Status do serviço no Railway mostra "Crashed" ou "Offline"
- Logs mostram erros de inicialização

**Soluções:**

#### A. Verificar Status do Serviço
1. No Railway, vá para o projeto
2. Verifique o status do serviço `ohmyfood` (ou nome do seu serviço)
3. Se estiver "Crashed" ou "Offline", veja os logs

#### B. Verificar Logs de Erro
1. Clique no serviço
2. Vá em **"Deploy Logs"** ou **"Logs"**
3. Procure por erros como:
   - `PrismaClientInitializationError` → Falta `DATABASE_URL`
   - `Cannot find module` → Build falhou
   - `Port already in use` → Conflito de porta
   - `EADDRINUSE` → Porta já está em uso

#### C. Verificar Variáveis de Ambiente
No Railway, vá em **Variables** e verifique se estão configuradas:

```env
# OBRIGATÓRIAS:
DATABASE_URL=${{Postgres.DATABASE_URL}}
PORT=${{PORT}}

# IMPORTANTES:
CORS_ORIGINS=https://ohmyfood.eu,https://www.ohmyfood.eu,https://restaurante.ohmyfood.eu,https://admin.ohmyfood.eu
JWT_ACCESS_SECRET=seu-secret-aqui
JWT_REFRESH_SECRET=seu-refresh-secret-aqui
```

**⚠️ IMPORTANTE:** Se o serviço PostgreSQL tiver outro nome (não "Postgres"), ajuste:
- Veja o nome exato em **"Architecture"**
- Use: `${{NomeDoServico.DATABASE_URL}}`

### 2. 🔧 Problema de Porta

**Sintomas:**
- Serviço aparece como "Online" mas ainda dá 502
- Logs mostram que o servidor iniciou em uma porta diferente

**Solução:**

O código já está configurado para usar `process.env.PORT` automaticamente:

```57:62:ohmyfood/backend/api/src/main.ts
  // Usar PORT do Railway ou fallback para 3000
  // Railway define PORT automaticamente, então usamos process.env.PORT diretamente
  const port = parseInt(process.env.PORT || '3000', 10);
  await app.listen(port);
  Logger.log(`🚀 OhMyFood API pronta em http://localhost:${port}`, 'Bootstrap');
  Logger.log(`📡 Porta configurada: ${port} (PORT=${process.env.PORT || 'não definido'})`, 'Bootstrap');
```

**Verificar:**
1. No Railway, vá em **Settings** → **Networking**
2. Verifique qual porta pública está configurada
3. Certifique-se que a variável `PORT=${{PORT}}` está definida nas **Variables**

### 3. 🏗️ Build Falhou

**Sintomas:**
- Logs mostram erros durante `npm install` ou `npm run build`
- Arquivo `dist/main.js` não existe

**Solução:**

1. Verifique os logs de build no Railway
2. Se houver erros de dependências, pode ser necessário:
   - Limpar cache: No Railway, vá em **Settings** → **Clear Build Cache**
   - Verificar se `package.json` está correto
   - Verificar se `railway.json` está configurado

### 4. 🗄️ Problema de Database

**Sintomas:**
- Logs mostram: `PrismaClientInitializationError: Environment variable not found: DATABASE_URL`
- Erro `P1012` do Prisma

**Solução:**

1. Verifique se o serviço PostgreSQL está **Online** (verde) em **Architecture**
2. Adicione a variável `DATABASE_URL` nas **Variables**:
   ```
   DATABASE_URL=${{Postgres.DATABASE_URL}}
   ```
3. Se o PostgreSQL tiver outro nome, use o nome correto
4. Após adicionar, o Railway fará redeploy automático

### 5. 🔄 Serviço Reiniciando

**Sintomas:**
- Status alterna entre "Online" e "Restarting"
- Logs mostram reinicializações constantes

**Solução:**

1. Verifique os logs para identificar o erro que causa o crash
2. Pode ser:
   - Erro de inicialização (ver variáveis de ambiente)
   - Erro de conexão com database
   - Erro de memória (verificar limites do plano Railway)

## ✅ Checklist de Diagnóstico

Siga esta ordem para diagnosticar:

- [ ] **1. Verificar Status do Serviço**
  - Railway → Projeto → Serviço
  - Status deve ser "Online" (verde)

- [ ] **2. Verificar Logs**
  - Railway → Serviço → **Deploy Logs** ou **Logs**
  - Procure por erros ou mensagens de sucesso: `🚀 OhMyFood API pronta em...`

- [ ] **3. Verificar Variáveis de Ambiente**
  - Railway → Serviço → **Variables**
  - Verificar: `DATABASE_URL`, `PORT`, `CORS_ORIGINS`, `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET`

- [ ] **4. Verificar PostgreSQL**
  - Railway → **Architecture**
  - PostgreSQL deve estar "Online" (verde)

- [ ] **5. Verificar Build**
  - Railway → Serviço → **Deploy Logs**
  - Verificar se `npm run build` completou com sucesso
  - Verificar se `dist/main.js` foi gerado

- [ ] **6. Verificar Networking**
  - Railway → Serviço → **Settings** → **Networking**
  - Verificar porta pública configurada

## 🚀 Solução Rápida (Passo a Passo)

### Passo 1: Verificar Status e Logs
1. Acesse [railway.app](https://railway.app)
2. Vá para o projeto
3. Clique no serviço que está dando erro
4. Verifique o **status** (deve ser "Online")
5. Veja os **logs** mais recentes

### Passo 2: Adicionar Variáveis Faltantes
1. No serviço, vá em **Variables**
2. Adicione/verifique:
   ```
   DATABASE_URL=${{Postgres.DATABASE_URL}}
   PORT=${{PORT}}
   CORS_ORIGINS=https://ohmyfood.eu,https://www.ohmyfood.eu,https://restaurante.ohmyfood.eu,https://admin.ohmyfood.eu
   JWT_ACCESS_SECRET=seu-secret-aqui
   JWT_REFRESH_SECRET=seu-refresh-secret-aqui
   ```

### Passo 3: Redeploy
1. Após adicionar variáveis, o Railway fará redeploy automático
2. Aguarde alguns minutos
3. Verifique os logs novamente
4. Deve aparecer: `🚀 OhMyFood API pronta em http://localhost:XXXX`

### Passo 4: Testar
```bash
# Testar endpoint
curl https://ohmyfood-production-800c.up.railway.app/api/restaurants

# Testar Swagger
curl https://ohmyfood-production-800c.up.railway.app/api/docs
```

## 🔍 Comandos Úteis (Railway CLI)

Se você tiver Railway CLI instalado:

```bash
# Ver logs em tempo real
railway logs

# Ver variáveis de ambiente
railway variables

# Conectar via SSH
railway connect

# Executar comando no container
railway run npm run prisma:deploy
```

## 📚 Referências

- [Railway Docs - Troubleshooting](https://docs.railway.app/guides/troubleshooting)
- [Railway Docs - Environment Variables](https://docs.railway.app/develop/variables)
- Ver também: `RAILWAY_QUICK_FIX.md` e `RAILWAY_PORT_FIX.md`

---

**Status:** 📝 Guia de diagnóstico
**Última atualização:** Baseado na configuração atual do projeto

