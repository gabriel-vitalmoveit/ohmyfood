# 🚀 DEPLOYMENT CPANEL - APPS WEB

**Data:** 2025-12-23  
**Status:** ✅ Todas as apps buildadas e prontas para upload

---

## ✅ BUILD CONCLUÍDO

Todas as 4 apps Flutter foram buildadas com sucesso:

1. ✅ **Customer App** → `apps/customer_app/build/web/`
2. ✅ **Restaurant App** → `apps/restaurant_app/build/web/`
3. ✅ **Courier App** → `apps/courier_app/build/web/`
4. ✅ **Admin Panel** → `apps/admin_panel/build/web/`

**API Base URL:** `https://ohmyfood-production-800c.up.railway.app`

---

## 📤 INSTRUÇÕES DE UPLOAD PARA CPANEL

### 1. Customer App (ohmyfood.eu)
**Pasta no cPanel:** `/public_html/` (raiz do domínio principal)

**Passos:**
1. Acessar cPanel File Manager
2. Navegar para `/public_html/`
3. **Backup:** Fazer backup da pasta atual (se existir)
4. **Upload:** Fazer upload de **TODO o conteúdo** de `apps/customer_app/build/web/`
5. **Verificar:** Confirmar que `index.html` está na raiz de `/public_html/`
6. **.htaccess:** Verificar se existe `.htaccess` com configuração SPA (já deve existir)

### 2. Restaurant App (restaurante.ohmyfood.eu)
**Pasta no cPanel:** `/public_html/restaurante.ohmyfood.eu/`

**Passos:**
1. Acessar cPanel File Manager
2. Navegar para `/public_html/restaurante.ohmyfood.eu/`
3. **Backup:** Fazer backup da pasta atual (se existir)
4. **Upload:** Fazer upload de **TODO o conteúdo** de `apps/restaurant_app/build/web/`
5. **Verificar:** Confirmar que `index.html` está na raiz
6. **.htaccess:** Verificar se existe `.htaccess` (já deve existir em `public_html/restaurante.ohmyfood.eu/.htaccess`)

### 3. Courier App (estafeta.ohmyfood.eu)
**Pasta no cPanel:** `/public_html/estafeta.ohmyfood.eu/`

**Passos:**
1. Acessar cPanel File Manager
2. Navegar para `/public_html/estafeta.ohmyfood.eu/`
3. **Backup:** Fazer backup da pasta atual (se existir)
4. **Upload:** Fazer upload de **TODO o conteúdo** de `apps/courier_app/build/web/`
5. **Verificar:** Confirmar que `index.html` está na raiz
6. **.htaccess:** Verificar se existe `.htaccess` (já deve existir em `public_html/estafeta.ohmyfood.eu/.htaccess`)

### 4. Admin Panel (admin.ohmyfood.eu)
**Pasta no cPanel:** `/public_html/admin.ohmyfood.eu/` (ou criar subdomínio se necessário)

**Passos:**
1. Acessar cPanel File Manager
2. Navegar para `/public_html/admin.ohmyfood.eu/` (ou criar pasta se não existir)
3. **Upload:** Fazer upload de **TODO o conteúdo** de `apps/admin_panel/build/web/`
4. **Verificar:** Confirmar que `index.html` está na raiz
5. **.htaccess:** Criar `.htaccess` com configuração SPA (ver template abaixo)

---

## 📄 CONFIGURAÇÃO .htaccess (SPA Routing)

Se o `.htaccess` não existir ou precisar ser atualizado, usar este conteúdo:

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  
  # Redirecionar todas as requisições para index.html (exceto arquivos existentes)
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule ^(.*)$ index.html [QSA,L]
</IfModule>

# Headers de segurança
<IfModule mod_headers.c>
  Header set X-Content-Type-Options "nosniff"
  Header set X-Frame-Options "SAMEORIGIN"
  Header set X-XSS-Protection "1; mode=block"
</IfModule>

# Cache para assets estáticos
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType image/jpg "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType image/gif "access plus 1 year"
  ExpiresByType text/css "access plus 1 month"
  ExpiresByType application/javascript "access plus 1 month"
</IfModule>
```

---

## ✅ CHECKLIST PÓS-DEPLOYMENT

Após fazer upload de todas as apps:

- [ ] **Customer App** acessível em `https://ohmyfood.eu`
- [ ] **Restaurant App** acessível em `https://restaurante.ohmyfood.eu`
- [ ] **Courier App** acessível em `https://estafeta.ohmyfood.eu`
- [ ] **Admin Panel** acessível em `https://admin.ohmyfood.eu` (ou subdomínio configurado)
- [ ] Todas as apps carregam sem erros no console do browser
- [ ] Login funciona em todas as apps
- [ ] API conecta corretamente (`https://ohmyfood-production-800c.up.railway.app/api`)

---

## 🔧 TROUBLESHOOTING

### Erro 404 em rotas internas:
- **Causa:** `.htaccess` não configurado ou mod_rewrite desabilitado
- **Solução:** Verificar se `.htaccess` existe e se `mod_rewrite` está ativo no cPanel

### Erro de CORS:
- **Causa:** Backend não permite origem do subdomínio
- **Solução:** Verificar CORS no backend (`backend/api/src/main.ts`) - já configurado

### Erro de conexão com API:
- **Causa:** API URL incorreta ou backend offline
- **Solução:** Verificar se `https://ohmyfood-production-800c.up.railway.app/api` está acessível

### Assets não carregam:
- **Causa:** Caminhos relativos incorretos
- **Solução:** Verificar se todos os arquivos foram uploadados corretamente

---

## 📊 ESTRUTURA DE PASTAS ESPERADA

### Customer App (`/public_html/`):
```
/public_html/
├── index.html
├── main.dart.js
├── flutter.js
├── assets/
│   ├── AssetManifest.json
│   └── ...
└── .htaccess
```

### Restaurant App (`/public_html/restaurante.ohmyfood.eu/`):
```
/public_html/restaurante.ohmyfood.eu/
├── index.html
├── main.dart.js
├── flutter.js
├── assets/
│   ├── AssetManifest.json
│   └── ...
└── .htaccess
```

### Courier App (`/public_html/estafeta.ohmyfood.eu/`):
```
/public_html/estafeta.ohmyfood.eu/
├── index.html
├── main.dart.js
├── flutter.js
├── assets/
│   ├── AssetManifest.json
│   └── ...
└── .htaccess
```

### Admin Panel (`/public_html/admin.ohmyfood.eu/`):
```
/public_html/admin.ohmyfood.eu/
├── index.html
├── main.dart.js
├── flutter.js
├── assets/
│   ├── AssetManifest.json
│   └── ...
└── .htaccess
```

---

## 🎯 PRÓXIMOS PASSOS APÓS DEPLOYMENT

1. **Testar login** em todas as apps com credenciais de seed
2. **Testar fluxo E2E** completo (customer → restaurant → courier)
3. **Verificar tracking** de pedidos em tempo real
4. **Monitorar logs** do backend no Railway
5. **Configurar SSL** se ainda não estiver configurado (cPanel geralmente faz automaticamente)

---

**Status:** ✅ Pronto para deployment no cPanel!

