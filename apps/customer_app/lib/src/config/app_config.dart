class AppConfig {
  // URLs de produção
  static const String productionApiUrl = 'https://api.ohmyfood.eu';
  static const String productionWebUrl = 'https://ohmyfood.eu';
  
  // URLs de desenvolvimento
  static const String developmentApiUrl = 'http://localhost:3000';
  static const String developmentWebUrl = 'http://localhost:8080';
  
  // Determina se está em produção baseado no flavor ou variável de ambiente
  static bool get isProduction {
    // Pode ser configurado via flavor ou variável de ambiente
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'prod' || env == 'production';
  }
  
  // URL da API baseada no ambiente
  static String get apiUrl {
    return isProduction ? productionApiUrl : developmentApiUrl;
  }
  
  // URL base da aplicação web
  static String get webUrl {
    return isProduction ? productionWebUrl : developmentWebUrl;
  }
}

