class AppConfig {
  // URL da API - Railway ou variável de ambiente
  static String get apiUrl {
    const String envApiUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    
    if (envApiUrl.isNotEmpty) {
      // Garantir que a URL termina com /api
      return _ensureApiPrefix(envApiUrl);
    }
    
    const String railwayUrl = String.fromEnvironment(
      'RAILWAY_API_URL',
      defaultValue: '',
    );
    
    if (railwayUrl.isNotEmpty) {
      return _ensureApiPrefix(railwayUrl);
    }
    
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    if (env == 'prod' || env == 'production') {
      // Produção: pode ser sobrescrito por `API_BASE_URL`, senão usa Railway.
      // Nota: se estiverem a usar `api.ohmyfood.eu`, passar `--dart-define=API_BASE_URL=https://api.ohmyfood.eu`
      return 'https://ohmyfood-production-800c.up.railway.app/api';
    }
    
    return 'http://localhost:3000/api';
  }
  
  // Garante que a URL termina com /api (sem duplicar)
  static String _ensureApiPrefix(String url) {
    final cleanUrl = url.trim();
    if (cleanUrl.endsWith('/api')) {
      return cleanUrl;
    }
    if (cleanUrl.endsWith('/')) {
      return '${cleanUrl}api';
    }
    return '$cleanUrl/api';
  }
  
  // Subdomínio de produção (estafetas)
  static const String productionWebUrl = 'https://estafetas.ohmyfood.eu';
  static const String developmentWebUrl = 'http://localhost:8083';
  
  static bool get isProduction {
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'prod' || env == 'production';
  }
  
  static String get webUrl {
    return isProduction ? productionWebUrl : developmentWebUrl;
  }

  // HERE Maps API Key
  static String get hereMapsApiKey {
    const String envKey = String.fromEnvironment(
      'HERE_MAPS_API_KEY',
      defaultValue: '',
    );
    
    if (envKey.isNotEmpty) {
      return envKey;
    }
    
    // Não commitar key no código. Se não for fornecida, o app usa fallback (rota simples).
    return '';
  }
}

