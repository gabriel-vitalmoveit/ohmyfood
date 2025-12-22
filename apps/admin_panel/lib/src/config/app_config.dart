class AppConfig {
  // URL da API - Railway ou variável de ambiente
  static String get apiUrl {
    const String envApiUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    
    if (envApiUrl.isNotEmpty) {
      return envApiUrl;
    }
    
    const String railwayUrl = String.fromEnvironment(
      'RAILWAY_API_URL',
      defaultValue: '',
    );
    
    if (railwayUrl.isNotEmpty) {
      return railwayUrl;
    }
    
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    if (env == 'prod' || env == 'production') {
      return 'https://api.ohmyfood.eu';
    }
    
    return 'http://localhost:3000';
  }
  
  static const String productionWebUrl = 'https://admin.ohmyfood.eu';
  static const String developmentWebUrl = 'http://localhost:8082';
  
  static bool get isProduction {
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'prod' || env == 'production';
  }
  
  static String get webUrl {
    return isProduction ? productionWebUrl : developmentWebUrl;
  }
}

