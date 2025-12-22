class AppConfig {
  // URLs de produção
  static const String productionApiUrl = 'https://api.ohmyfood.eu';
  static const String productionWebUrl = 'https://admin.ohmyfood.eu';
  
  // URLs de desenvolvimento
  static const String developmentApiUrl = 'http://localhost:3000';
  static const String developmentWebUrl = 'http://localhost:8082';
  
  // Determina se está em produção
  static bool get isProduction {
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'prod' || env == 'production';
  }
  
  static String get apiUrl {
    return isProduction ? productionApiUrl : developmentApiUrl;
  }
  
  static String get webUrl {
    return isProduction ? productionWebUrl : developmentWebUrl;
  }
}

