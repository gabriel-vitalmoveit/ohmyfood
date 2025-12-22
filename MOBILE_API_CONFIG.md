# 📱 Configuração Mobile - Backend Railway

## ✅ Resposta Rápida

**SIM!** O backend do Railway fornece dados para **TODAS** as aplicações:

- ✅ **Apps Mobile** (Android/iOS) - `customer_app`, `courier_app`
- ✅ **Apps Web** (Flutter Web) - `customer_app`, `restaurant_app`, `admin_panel`
- ✅ **Qualquer cliente HTTP** que acesse a API

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────┐
│           Backend Railway (NestJS API)                  │
│    https://seu-backend.up.railway.app/api               │
└─────────────────────────────────────────────────────────┘
                    │
                    ├─── Customer App Mobile (Android/iOS)
                    ├─── Customer App Web (Flutter Web)
                    ├─── Restaurant App Web (Flutter Web)
                    ├─── Courier App Mobile (Android/iOS)
                    └─── Admin Panel Web (Flutter Web)
```

**Todas as apps usam a mesma API!**

---

## ⚙️ Como Funciona

### 1. Apps Mobile (Android/iOS)

As apps mobile Flutter já estão configuradas para usar o backend Railway:

```dart
// apps/customer_app/lib/src/config/app_config.dart
class AppConfig {
  static String get apiUrl {
    // Prioridade: variável de ambiente > Railway URL > produção > desenvolvimento
    const String envApiUrl = String.fromEnvironment('API_BASE_URL');
    
    if (envApiUrl.isNotEmpty) {
      return envApiUrl; // Ex: https://seu-backend.up.railway.app/api
    }
    
    // Fallback para produção
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    if (env == 'prod') {
      return 'https://api.ohmyfood.eu/api';
    }
    
    return 'http://localhost:3000/api'; // Desenvolvimento
  }
}
```

### 2. Build para Mobile

#### Android

```bash
cd apps/customer_app

# Build de produção
flutter build apk --release \
  --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://seu-backend.up.railway.app/api

# Ou build para desenvolvimento
flutter build apk --debug \
  --dart-define=API_BASE_URL=http://localhost:3000/api
```

#### iOS

```bash
cd apps/customer_app

# Build de produção
flutter build ios --release \
  --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://seu-backend.up.railway.app/api
```

### 3. Configuração no Código

O `ApiClient` já está configurado para usar `AppConfig.apiUrl`:

```dart
// apps/customer_app/lib/src/services/api_client.dart
class ApiClient {
  static const String baseUrl = AppConfig.apiUrl; // ✅ Usa Railway automaticamente
  
  Future<List<Restaurant>> getRestaurants() async {
    final response = await http.get(Uri.parse('$baseUrl/restaurants'));
    // ...
  }
}
```

---

## 🔒 CORS e Segurança

### Apps Mobile vs Web

| Tipo | CORS Necessário? | Por quê? |
|------|------------------|----------|
| **Mobile (Android/iOS)** | ❌ Não | Apps mobile não rodam em browser, não têm CORS |
| **Web (Flutter Web)** | ✅ Sim | Browsers aplicam política CORS |

### Configuração Atual do Backend

O backend já está configurado para aceitar requisições de **qualquer origem** (incluindo mobile):

```typescript
// backend/api/src/shared/configuration.ts
cors: {
  origin: process.env.CORS_ORIGIN ?? '*', // ✅ Aceita todas as origens
  allowedOrigins: process.env.CORS_ORIGINS
    ? process.env.CORS_ORIGINS.split(',')
    : [
        'https://ohmyfood.eu',
        'https://www.ohmyfood.eu',
        // ... outras URLs web
      ],
}
```

**Nota:** Apps mobile não precisam estar na lista de CORS, mas não faz mal incluir.

---

## 🚀 Deploy Mobile

### Passo 1: Obter URL do Railway

Após deploy no Railway, você terá uma URL como:
```
https://ohmyfood-production-800c.up.railway.app
```

### Passo 2: Build com URL do Railway

```bash
# Customer App Mobile
cd apps/customer_app
flutter build apk --release \
  --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://ohmyfood-production-800c.up.railway.app/api

# Courier App Mobile
cd apps/courier_app
flutter build apk --release \
  --dart-define=ENV=prod \
  --dart-define=API_BASE_URL=https://ohmyfood-production-800c.up.railway.app/api
```

### Passo 3: Publicar nas Stores

- **Google Play Store** (Android)
- **Apple App Store** (iOS)

---

## 🔧 Configuração Dinâmica (Opcional)

Se quiser permitir que o usuário configure a URL da API (útil para testes):

### 1. Criar Tela de Configurações

```dart
// lib/src/features/settings/settings_screen.dart
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiUrlController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Carregar URL salva
    _apiUrlController.text = SharedPreferences.getInstance()
      .then((prefs) => prefs.getString('api_url') ?? AppConfig.apiUrl);
  }
  
  void _saveApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_url', _apiUrlController.text);
    // Reiniciar app ou recarregar configuração
  }
}
```

### 2. Usar URL Configurável

```dart
class AppConfig {
  static Future<String> get apiUrl async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('api_url');
    
    if (savedUrl != null && savedUrl.isNotEmpty) {
      return savedUrl;
    }
    
    // Fallback para configuração padrão
    return _defaultApiUrl;
  }
}
```

---

## 📋 Checklist Mobile

### Antes de Publicar

- [ ] Backend Railway está online e acessível
- [ ] URL do Railway configurada no build
- [ ] Testado em dispositivo real (não só emulador)
- [ ] Testado com dados reais do backend
- [ ] Verificado que requisições HTTP funcionam
- [ ] Verificado que autenticação funciona
- [ ] Verificado que WebSocket funciona (se aplicável)

### Variáveis de Ambiente

- [ ] `API_BASE_URL` configurada no build
- [ ] `ENV=prod` para builds de produção
- [ ] URLs de desenvolvimento funcionando localmente

---

## 🧪 Testar Conexão Mobile

### 1. Teste Básico

Adicione um botão de teste na app:

```dart
ElevatedButton(
  onPressed: () async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/health'),
      );
      print('✅ API conectada: ${response.statusCode}');
    } catch (e) {
      print('❌ Erro: $e');
    }
  },
  child: Text('Testar Conexão API'),
)
```

### 2. Verificar Logs

No Railway, vá em **"Logs"** e veja as requisições chegando:
```
GET /api/restaurants 200 OK
POST /api/orders 201 Created
```

---

## 📚 Resumo

| Pergunta | Resposta |
|----------|----------|
| **Backend Railway serve mobile?** | ✅ Sim, serve todas as apps |
| **Precisa configurar CORS para mobile?** | ❌ Não, mobile não tem CORS |
| **Como configurar URL no mobile?** | Via `--dart-define=API_BASE_URL=...` no build |
| **Apps mobile e web usam mesma API?** | ✅ Sim, exatamente a mesma |
| **Precisa de configuração especial?** | ❌ Não, já está tudo pronto |

---

## 🎯 Conclusão

**O backend Railway é único e serve:**
- ✅ Apps Mobile (Android/iOS)
- ✅ Apps Web (Flutter Web)
- ✅ Qualquer cliente HTTP

**Basta configurar a URL do Railway no build das apps mobile!** 🚀

