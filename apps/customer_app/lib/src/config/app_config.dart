class AppConfig {
  static String _normalizeApiUrl(String url) {
    final trimmed = url.trim().replaceAll(RegExp(r'/*$'), '');
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.endsWith('/api')) return trimmed;
    return '$trimmed/api';
  }

  // URL da API - Railway ou variável de ambiente
  static String get apiUrl {
    // Prioridade: variável de ambiente > Railway URL > produção > desenvolvimento
    const String envApiUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    
    if (envApiUrl.isNotEmpty) {
      return _normalizeApiUrl(envApiUrl);
    }
    
    // URL do Railway (será configurada no deploy)
    const String railwayUrl = String.fromEnvironment(
      'RAILWAY_API_URL',
      defaultValue: '',
    );
    
    if (railwayUrl.isNotEmpty) {
      return _normalizeApiUrl(railwayUrl);
    }
    
    // Fallback para produção/desenvolvimento
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    if (env == 'prod' || env == 'production') {
      return _normalizeApiUrl('https://api.ohmyfood.eu/api');
    }
    
    return _normalizeApiUrl('http://localhost:3000/api');
  }
  
  // URLs de produção
  static const String productionWebUrl = 'https://ohmyfood.eu';
  static const String developmentWebUrl = 'http://localhost:8080';
  
  // Determina se está em produção
  static bool get isProduction {
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'prod' || env == 'production';
  }
  
  // URL base da aplicação web
  static String get webUrl {
    return isProduction ? productionWebUrl : developmentWebUrl;
  }
}

