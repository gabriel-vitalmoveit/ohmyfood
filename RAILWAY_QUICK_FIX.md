# 🚨 Fix Rápido: DATABASE_URL Error no Railway

## ❌ Erro
```
PrismaClientInitializationError: error: Environment variable not found: DATABASE_URL.
errorCode: 'P1012'
```

## ✅ Solução Rápida (2 minutos)

### Passo 1: Adicionar Variável DATABASE_URL

1. No Railway, clique no serviço **ohmyfood** (o que está crashed)
2. Vá na aba **"Variables"** (ou **"Settings"** → **"Variables"**)
3. Clique em **"+ New Variable"** ou **"Add Variable"**
4. Configure:
   - **Name:** `DATABASE_URL`
   - **Value:** `${{Postgres.DATABASE_URL}}`
   
   ⚠️ **IMPORTANTE:** Se o serviço PostgreSQL tiver outro nome (não "Postgres"), use:
   - `${{NomeDoSeuServicoPostgres.DATABASE_URL}}`
   
   Para ver o nome exato:
   - Vá em **"Architecture"**
   - Veja o nome do serviço PostgreSQL (pode ser "Postgres", "PostgreSQL", etc.)

### Passo 2: Verificar se PostgreSQL está Online

1. No Railway, vá em **"Architecture"**
2. Verifique se o serviço **Postgres** está **Online** (verde)
3. Se não estiver, aguarde ou recrie o serviço

### Passo 3: Redeploy

1. Após adicionar a variável, o Railway fará **redeploy automático**
2. Aguarde alguns segundos
3. Verifique os logs em **"Deploy Logs"**
4. Deve aparecer: `🚀 OhMyFood API pronta em...`

## 🔍 Verificação

Após adicionar a variável, verifique:

1. **Variables** do serviço ohmyfood deve mostrar:
   ```
   DATABASE_URL = ${{Postgres.DATABASE_URL}}
   ```

2. **Deploy Logs** não deve mais mostrar erro `P1012`

3. Status do serviço deve mudar de **"Crashed"** para **"Online"**

## ⚠️ Se Ainda Não Funcionar

### Verificar Nome do Serviço PostgreSQL

1. Vá em **"Architecture"**
2. Veja o nome exato do serviço PostgreSQL
3. Use esse nome na variável:
   ```
   ${{NomeExatoAqui.DATABASE_URL}}
   ```

### Adicionar Outras Variáveis Necessárias

Enquanto está nas **Variables**, adicione também:

```env
PORT=${{PORT}}
CORS_ORIGINS=https://ohmyfood.eu,https://www.ohmyfood.eu,https://restaurante.ohmyfood.eu,https://admin.ohmyfood.eu
JWT_ACCESS_SECRET=seu-secret-aqui
JWT_REFRESH_SECRET=seu-refresh-secret-aqui
```

---

**Tempo estimado:** 2-3 minutos
**Dificuldade:** Fácil

