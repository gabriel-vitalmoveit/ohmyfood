# 🗺️ Configuração HERE Maps - Courier App

## 📋 Resumo

A integração do HERE Maps foi implementada no Courier App para:
- ✅ Calcular rotas entre restaurante e cliente
- ✅ Calcular distância e ETA (Estimated Time of Arrival)
- ✅ Mostrar mapa com marcadores de pickup e delivery
- ✅ Suporte para localização do courier

## 🔑 Configuração da API Key

### 1. Obter API Key do HERE Maps

1. Acesse [HERE Developer Portal](https://developer.here.com/)
2. Crie uma conta ou faça login
3. Crie um novo projeto
4. Gere uma API Key (REST API Key)

### 2. Configurar no Flutter

#### Opção 1: Variável de Ambiente (Recomendado)

Ao fazer build do app, passe a API key:

```bash
flutter build web --release --dart-define=HERE_MAPS_API_KEY=sua_api_key_aqui
```

#### Opção 2: Arquivo de Configuração

Edite `apps/courier_app/lib/src/config/app_config.dart` e adicione:

```dart
static String get hereMapsApiKey {
  // Substitua pela sua API key
  return 'sua_api_key_aqui';
}
```

⚠️ **IMPORTANTE**: Não commite a API key diretamente no código! Use variáveis de ambiente.

## 📁 Arquivos Criados/Modificados

### Novos Arquivos:
- `apps/courier_app/lib/src/services/here_maps_service.dart` - Serviço para HERE Maps API
- `apps/courier_app/lib/src/widgets/order_map_widget.dart` - Widget do mapa

### Arquivos Modificados:
- `apps/courier_app/lib/src/config/app_config.dart` - Adicionado `hereMapsApiKey`
- `apps/courier_app/lib/src/features/order_detail/order_detail_screen.dart` - Integrado mapa
- `apps/courier_app/pubspec.yaml` - Adicionado `http` (já estava)

## 🚀 Funcionalidades Implementadas

### 1. Cálculo de Rotas
```dart
final route = await hereMapsService.calculateRoute(
  startLat: 38.7369,
  startLng: -9.1377,
  endLat: 38.7469,
  endLng: -9.1477,
);
```

Retorna:
- `distance`: Distância em km
- `duration`: Duração estimada (Duration)
- `polyline`: Lista de pontos da rota

### 2. Cálculo de ETA
```dart
final eta = await hereMapsService.calculateETA(
  startLat: courierLat,
  startLng: courierLng,
  endLat: restaurantLat,
  endLng: restaurantLng,
);
```

### 3. Cálculo de Distância
```dart
final distance = await hereMapsService.calculateDistance(
  startLat: restaurantLat,
  startLng: restaurantLng,
  endLat: deliveryLat,
  endLng: deliveryLng,
);
```

## 🎨 Widget do Mapa

O `OrderMapWidget` exibe:
- Mapa com marcadores de restaurante e entrega
- Distância e tempo estimado
- Localização do courier (se disponível)
- Fallback visual se API key não estiver configurada

## 🔄 Fallback

Se a API key não estiver configurada ou houver erro na API:
- Usa cálculo simples de distância (fórmula de Haversine)
- Assume velocidade média de 30 km/h em cidade
- Mostra mapa simplificado com informações básicas

## 📝 Exemplo de Uso

```dart
// No provider
final hereMapsServiceProvider = Provider<HereMapsService>((ref) {
  return HereMapsService();
});

// No widget
final mapsService = ref.watch(hereMapsServiceProvider);
final route = await mapsService.calculateRoute(
  startLat: 38.7369,
  startLng: -9.1377,
  endLat: 38.7469,
  endLng: -9.1477,
);
```

## 🧪 Testando

1. Configure a API key
2. Acesse a tela de detalhes de um pedido
3. O mapa deve aparecer com:
   - Marcador do restaurante (laranja)
   - Marcador de entrega (azul)
   - Distância e tempo estimado
   - Localização do courier (se disponível)

## 🔗 Documentação HERE Maps

- [HERE Routing API v8](https://developer.here.com/documentation/routing-api/8.16.0/dev_guide/index.html)
- [HERE Developer Portal](https://developer.here.com/)

## ⚠️ Limitações Atuais

1. **Mapa Visual**: O widget atual mostra um placeholder. Para mapa interativo completo, considere usar:
   - HERE Maps SDK para Flutter (requer configuração adicional)
   - Google Maps Flutter Plugin (alternativa)
   - OpenStreetMap com flutter_map

2. **Polyline**: A decodificação completa do polyline não está implementada. Apenas pontos principais são extraídos.

3. **Geocoding**: Conversão de endereços para coordenadas não está implementada. Usa coordenadas diretas do pedido.

## 🎯 Próximos Passos

1. Implementar geocoding para converter endereços em coordenadas
2. Adicionar mapa interativo (HERE Maps SDK ou alternativa)
3. Implementar navegação turn-by-turn
4. Adicionar atualização de localização do courier em tempo real

---

**Última Atualização:** 2025-12-23

