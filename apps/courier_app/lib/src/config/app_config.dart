class AppConfig {
  static String _normalizeApiUrl(String url) {
    final trimmed = url.trim().replaceAll(RegExp(r'/*$'), '');
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.endsWith('/api')) return trimmed;
    return '$trimmed/api';
  }

  // URL da API - Railway ou variável de ambiente
  static String get apiUrl {
    const String envApiUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    
    if (envApiUrl.isNotEmpty) {
      return _normalizeApiUrl(envApiUrl);
    }
    
    const String railwayUrl = String.fromEnvironment(
      'RAILWAY_API_URL',
      defaultValue: '',
    );
    
    if (railwayUrl.isNotEmpty) {
      return _normalizeApiUrl(railwayUrl);
    }
    
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    if (env == 'prod' || env == 'production') {
      return _normalizeApiUrl('https://api.ohmyfood.eu/api');
    }
    
    return _normalizeApiUrl('http://localhost:3000/api');
  }
  
  static const String productionWebUrl = 'https://estafeta.ohmyfood.eu';
  static const String developmentWebUrl = 'http://localhost:8083';
  
  static bool get isProduction {
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'prod' || env == 'production';
  }
  
  static String get webUrl {
    return isProduction ? productionWebUrl : developmentWebUrl;
  }
}

