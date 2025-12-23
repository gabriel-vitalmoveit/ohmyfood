class AppConfig {
  // URL da API - Railway ou variável de ambiente
  static String get apiUrl {
    // Prioridade: variável de ambiente > Railway URL > produção > desenvolvimento
    const String envApiUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    
    if (envApiUrl.isNotEmpty) {
      // Garantir que a URL termina com /api
      return _ensureApiPrefix(envApiUrl);
    }
    
    // URL do Railway (será configurada no deploy)
    const String railwayUrl = String.fromEnvironment(
      'RAILWAY_API_URL',
      defaultValue: '',
    );
    
    if (railwayUrl.isNotEmpty) {
      return _ensureApiPrefix(railwayUrl);
    }
    
    // Fallback para produção/desenvolvimento
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    if (env == 'prod' || env == 'production') {
      // URL do Railway em produção
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

