# 🌐 Configuração de URLs - OhMyFood

Este documento descreve todas as URLs do projeto OhMyFood e como configurá-las.

## 📍 URLs de Produção

### Aplicações Web (Flutter Web)

| Aplicação | URL Produção | Descrição |
|-----------|--------------|-----------|
| **Cliente** | `https://ohmyfood.eu` | App principal para clientes |
| **Restaurante** | `https://restaurante.ohmyfood.eu` | Dashboard web para restaurantes |
| **Admin** | `https://admin.ohmyfood.eu` | Painel administrativo |
| **Estafeta** | `https://estafeta.ohmyfood.eu` | App web para estafetas (opcional) |

### API Backend

| Serviço | URL Produção | Descrição |
|---------|--------------|-----------|
| **API REST** | `https://api.ohmyfood.eu` | API principal NestJS |
| **Swagger Docs** | `https://api.ohmyfood.eu/docs` | Documentação da API |
| **WebSocket** | `wss://api.ohmyfood.eu/chat` | WebSocket para chat/tracking |

---

## 🔧 URLs de Desenvolvimento

### Aplicações Web (Local)

| Aplicação | URL Local | Porta |
|-----------|-----------|-------|
| **Cliente** | `http://localhost:8080` | 8080 |
| **Restaurante** | `http://localhost:8081` | 8081 |
| **Admin** | `http://localhost:8082` | 8082 |
| **Estafeta** | `http://localhost:8083` | 8083 |

### API Backend (Local)

| Serviço | URL Local | Porta |
|---------|-----------|-------|
| **API REST** | `http://localhost:3000` | 3000 |
| **Swagger Docs** | `http://localhost:3000/docs` | 3000 |
| **WebSocket** | `ws://localhost:3000/chat` | 3000 |

---

## ⚙️ Configuração

### 1. Flutter Apps (Client-side)

Cada app tem um arquivo `lib/src/config/app_config.dart` que define as URLs:

```dart
// Exemplo: customer_app/lib/src/config/app_config.dart
class AppConfig {
  static const String productionApiUrl = 'https://api.ohmyfood.eu';
  static const String developmentApiUrl = 'http://localhost:3000';
  
  static bool get isProduction {
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'prod';
  }
  
  static String get apiUrl {
    return isProduction ? productionApiUrl : developmentApiUrl;
  }
}
```

**Uso:**
```dart
final apiClient = ApiClient(); // Usa AppConfig.apiUrl automaticamente
```

### 2. Backend (Server-side)

Configure no arquivo `.env`:

```env
# Porta da API
PORT=3000

# CORS - URLs permitidas (separadas por vírgula)
CORS_ORIGINS=https://ohmyfood.eu,https://www.ohmyfood.eu,https://admin.ohmyfood.eu,https://restaurante.ohmyfood.eu

# Ou use CORS_ORIGIN para uma única URL
CORS_ORIGIN=https://ohmyfood.eu

# Database
DATABASE_URL=postgresql://user:pass@host:port/db
```

---

## 🚀 Build para Produção

### Flutter Web Apps

Para build de produção, use o flavor `prod`:

```bash
# Customer App
cd apps/customer_app
flutter build web --dart-define=ENV=prod --release

# Restaurant App
cd apps/restaurant_app
flutter build web --dart-define=ENV=prod --release

# Admin Panel
cd apps/admin_panel
flutter build web --dart-define=ENV=prod --release
```

### Backend API

```bash
cd backend/api
npm run build
npm start
```

Ou com PM2:
```bash
pm2 start dist/main.js --name ohmyfood-api
```

---

## 📋 Checklist de Deploy

### Domínios e DNS

- [ ] `ohmyfood.eu` → aponta para customer app
- [ ] `www.ohmyfood.eu` → aponta para customer app
- [ ] `restaurante.ohmyfood.eu` → aponta para restaurant app
- [ ] `admin.ohmyfood.eu` → aponta para admin panel
- [ ] `api.ohmyfood.eu` → aponta para backend API
- [ ] SSL/HTTPS configurado para todos os domínios

### Configurações

- [ ] `.env` do backend configurado com `CORS_ORIGINS`
- [ ] Apps Flutter buildadas com `ENV=prod`
- [ ] `ApiClient` usando `AppConfig.apiUrl`
- [ ] WebSocket configurado com `wss://` em produção

### Testes

- [ ] Customer app acessa `https://api.ohmyfood.eu`
- [ ] Restaurant app acessa `https://api.ohmyfood.eu`
- [ ] Admin panel acessa `https://api.ohmyfood.eu`
- [ ] CORS funcionando corretamente
- [ ] WebSocket conectando em produção

---

## 🔍 Verificação de URLs

### Testar API

```bash
# Testar se API está online
curl https://api.ohmyfood.eu/restaurants

# Testar Swagger
curl https://api.ohmyfood.eu/docs
```

### Testar CORS

No browser console:
```javascript
fetch('https://api.ohmyfood.eu/restaurants')
  .then(r => r.json())
  .then(console.log)
  .catch(console.error);
```

---

## 🛠️ Troubleshooting

### Erro: CORS bloqueado

**Problema:** Browser bloqueia requisições por CORS.

**Solução:**
1. Verifique `CORS_ORIGINS` no `.env` do backend
2. Certifique-se que a URL está na lista
3. Reinicie o backend

### Erro: API não encontrada

**Problema:** App não consegue conectar à API.

**Solução:**
1. Verifique `AppConfig.apiUrl` na app
2. Certifique-se que build foi feito com `ENV=prod`
3. Verifique se `api.ohmyfood.eu` está acessível

### Erro: WebSocket não conecta

**Problema:** WebSocket falha em produção.

**Solução:**
1. Use `wss://` (WebSocket Secure) em produção
2. Configure proxy reverso (Nginx) para WebSocket
3. Verifique firewall/portas

---

## 📚 Estrutura de Domínios Recomendada

```
ohmyfood.eu                    → Customer App (Flutter Web)
www.ohmyfood.eu                → Customer App (redirect)
restaurante.ohmyfood.eu        → Restaurant Dashboard (Flutter Web)
admin.ohmyfood.eu              → Admin Panel (Flutter Web)
api.ohmyfood.eu                → Backend API (NestJS)
```

---

## 🔐 Segurança

- ✅ Use HTTPS em produção (`https://`)
- ✅ Use WSS para WebSocket (`wss://`)
- ✅ Configure CORS corretamente (não use `*` em produção)
- ✅ Valide origem das requisições no backend
- ✅ Use variáveis de ambiente para URLs sensíveis

---

## 📝 Notas

- As URLs de desenvolvimento usam `localhost` por padrão
- Em produção, todas as URLs devem usar HTTPS
- O backend deve estar acessível em `api.ohmyfood.eu`
- Apps Flutter detectam ambiente via `ENV` variable

