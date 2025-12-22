# 📱 Estado Atual das Apps Mobile - OhMyFood

## 📊 Resumo Executivo

| App | Status UI | Status API | Funcionalidades | Pronto para Deploy? |
|-----|----------|------------|-----------------|---------------------|
| **Customer App** | ✅ 90% | ⚠️ 30% | Estrutura completa, dados mock | ⚠️ Parcial |
| **Courier App** | ✅ 80% | ❌ 0% | Estrutura completa, dados mock | ❌ Não |

---

## 🛒 Customer App (Cliente)

### ✅ O que está implementado

#### UI/UX (90% completo)
- ✅ **Onboarding Screen** - Tela de introdução
- ✅ **Home Screen** - Tela principal com:
  - Hero banner com localização
  - Barra de pesquisa
  - Filtro por categorias
  - Cards de promoções animados
  - Lista de restaurantes com imagens cached
  - Animações suaves (staggered animations)
- ✅ **Restaurant Screen** - Detalhes do restaurante:
  - AppBar com imagem de fundo
  - Menu organizado por categorias
  - Animações staggered para itens
- ✅ **Cart Screen** - Carrinho de compras:
  - Lista de itens
  - Stepper de quantidade
  - Botão de limpar carrinho com confirmação
  - Animações
- ✅ **Checkout Screen** - Finalização de pedido:
  - Cards informativos (endereço, pagamento)
  - Seletor de método de pagamento
  - Feedback visual de confirmação
- ✅ **Orders Screen** - Histórico de pedidos
- ✅ **Profile Screen** - Perfil do usuário
- ✅ **Tracking Screen** - Rastreamento de pedido
- ✅ **Bottom Navigation** - Navegação principal
- ✅ **Design System** - Componentes reutilizáveis
- ✅ **Cached Images** - Otimização de imagens
- ✅ **Shimmer Loading** - Placeholders animados

#### Integração API (30% completo)
- ✅ **ApiClient criado** - Cliente HTTP configurado
- ✅ **Configuração de URLs** - AppConfig com suporte a Railway
- ✅ **Métodos básicos**:
  - `getRestaurants()` - Buscar restaurantes
  - `getRestaurantById()` - Detalhes do restaurante
  - `getMenuItems()` - Itens do menu
  - `createOrder()` - Criar pedido
- ⚠️ **Fallback para mock data** - Se API falhar, usa dados mock
- ❌ **Não está sendo usado** - Telas ainda usam `mock_data.dart` diretamente

### ❌ O que falta

#### Integração API
- ❌ Substituir `mock_data.dart` por chamadas reais da API
- ❌ Criar Providers (Riverpod) para gerenciar estado da API
- ❌ Tratamento de erros robusto
- ❌ Loading states nas telas
- ❌ Refresh/pull-to-refresh
- ❌ Cache local (opcional)

#### Funcionalidades
- ❌ Autenticação (login/registro)
- ❌ Integração com Stripe (pagamentos)
- ❌ Integração com Mapbox (mapas)
- ❌ WebSocket para tracking em tempo real
- ❌ Notificações push
- ❌ Chat com restaurante/estafeta

#### Testes
- ❌ Testes unitários
- ❌ Testes de integração
- ❌ Testes E2E

---

## 🚴 Courier App (Estafeta)

### ✅ O que está implementado

#### UI/UX (80% completo)
- ✅ **Onboarding Screen** - Tela de introdução
- ✅ **Dashboard Screen** - Dashboard principal:
  - Status online/offline (switch)
  - Próximo pedido disponível
  - Estatísticas do dia
- ✅ **Available Orders Screen** - Lista de pedidos disponíveis
- ✅ **Order Detail Screen** - Detalhes do pedido
- ✅ **Earnings Screen** - Ganhos e estatísticas
- ✅ **Profile Screen** - Perfil do estafeta
- ✅ **Bottom Navigation** - Navegação principal
- ✅ **Design System** - Componentes reutilizáveis

#### Integração API (0% completo)
- ❌ **ApiClient não criado** - Não há cliente HTTP
- ❌ **Sem configuração de API** - AppConfig existe mas não é usado
- ❌ **Tudo é mock data** - Todas as telas usam dados estáticos

### ❌ O que falta

#### Integração API (CRÍTICO)
- ❌ Criar `ApiClient` para Courier App
- ❌ Endpoints necessários:
  - `GET /orders/available` - Pedidos disponíveis
  - `POST /orders/:id/accept` - Aceitar pedido
  - `GET /orders/:id` - Detalhes do pedido
  - `POST /orders/:id/start` - Iniciar entrega
  - `POST /orders/:id/complete` - Completar entrega
  - `GET /couriers/me/stats` - Estatísticas
  - `GET /couriers/me/earnings` - Ganhos
- ❌ Providers (Riverpod) para estado
- ❌ WebSocket para receber pedidos em tempo real

#### Funcionalidades
- ❌ Autenticação (login/registro)
- ❌ Upload de documentos (CC/BI, carta de condução)
- ❌ Integração com Mapbox (navegação)
- ❌ Tracking de localização em tempo real
- ❌ Chat com cliente/restaurante
- ❌ Notificações push para novos pedidos

#### UI/UX
- ⚠️ Melhorar animações
- ⚠️ Adicionar loading states
- ⚠️ Melhorar feedback visual

---

## 🔧 Dependências

### Customer App
```yaml
✅ http: ^1.2.0                    # Cliente HTTP
✅ cached_network_image: ^3.3.1   # Imagens cached
✅ shimmer: ^3.0.0                # Loading placeholders
✅ go_router: ^12.1.1             # Navegação
✅ hooks_riverpod: ^2.5.1         # Estado
```

### Courier App
```yaml
✅ go_router: ^12.1.1             # Navegação
✅ hooks_riverpod: ^2.5.1         # Estado
❌ http: ^1.2.0                    # FALTA - Cliente HTTP
❌ cached_network_image: ^3.3.1   # FALTA - Imagens cached
❌ shimmer: ^3.0.0                # FALTA - Loading placeholders
```

---

## 📋 Próximos Passos Prioritários

### 1. Customer App - Integração API (Alta Prioridade)

```dart
// Criar providers para substituir mock_data
final restaurantsProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  final apiClient = ApiClient();
  return await apiClient.getRestaurants();
});

// Usar nas telas
final restaurants = ref.watch(restaurantsProvider);
```

**Tarefas:**
1. Criar Providers (Riverpod) para cada endpoint
2. Substituir `mock_data.dart` por chamadas reais
3. Adicionar loading states
4. Adicionar error handling
5. Testar com backend Railway

### 2. Courier App - Criar ApiClient (Alta Prioridade)

```dart
// Criar api_client.dart similar ao customer_app
class CourierApiClient {
  Future<List<Order>> getAvailableOrders() async { ... }
  Future<void> acceptOrder(String orderId) async { ... }
  // ...
}
```

**Tarefas:**
1. Criar `ApiClient` para Courier App
2. Adicionar dependências (`http`, `cached_network_image`, `shimmer`)
3. Criar Providers (Riverpod)
4. Substituir mock data
5. Testar com backend Railway

### 3. Autenticação (Média Prioridade)

- Implementar login/registro
- Gerenciar tokens JWT
- Refresh tokens
- Logout

### 4. Funcionalidades Avançadas (Baixa Prioridade)

- Integração Stripe
- Integração Mapbox
- WebSocket
- Notificações push

---

## 🚀 Deploy Mobile

### Status Atual
- ✅ Scripts de build criados (`build-mobile.sh`, `build-mobile.ps1`)
- ✅ Configuração de URLs pronta
- ⚠️ Apps ainda não testadas com backend real
- ❌ Apps não publicadas nas stores

### Para Publicar

#### Android
```bash
# Customer App
./scripts/build-mobile.sh https://seu-backend.up.railway.app customer_app android
# APK em: apps/customer_app/build/app/outputs/flutter-apk/app-release.apk

# Courier App
./scripts/build-mobile.sh https://seu-backend.up.railway.app courier_app android
```

#### iOS
```bash
# Customer App
./scripts/build-mobile.sh https://seu-backend.up.railway.app customer_app ios
# Build em: apps/customer_app/build/ios/
```

---

## 📊 Métricas de Progresso

### Customer App
- **UI/UX:** 90% ✅
- **API Integration:** 30% ⚠️
- **Funcionalidades Core:** 60% ⚠️
- **Testes:** 0% ❌
- **Overall:** 45% ⚠️

### Courier App
- **UI/UX:** 80% ✅
- **API Integration:** 0% ❌
- **Funcionalidades Core:** 30% ❌
- **Testes:** 0% ❌
- **Overall:** 27% ❌

---

## 🎯 Conclusão

### Customer App
**Status:** ⚠️ **Parcialmente Pronto**

- UI moderna e completa ✅
- Estrutura de API pronta ✅
- Falta conectar UI com API real ❌
- Falta autenticação e funcionalidades avançadas ❌

**Estimativa para produção:** 2-3 semanas (com foco em integração API)

### Courier App
**Status:** ❌ **Não Pronto**

- UI básica implementada ✅
- Falta toda integração com API ❌
- Falta funcionalidades core ❌

**Estimativa para produção:** 4-6 semanas (criar ApiClient + integração completa)

---

## 📝 Notas

1. **Backend Railway está pronto** - APIs disponíveis, só falta conectar
2. **Design System completo** - Componentes reutilizáveis prontos
3. **Navegação funcionando** - GoRouter configurado em ambas apps
4. **Estado gerenciado** - Riverpod configurado, falta criar providers para API

---

**Última atualização:** 22/12/2025

