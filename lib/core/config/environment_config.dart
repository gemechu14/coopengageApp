class EnvironmentConfig {
  static const String MTD = 'mtd';
  static const String RELID = 'relid';
  
  static const String DEFAULT_ENVIRONMENT = MTD;
  static const Map<String, String> BASE_URLS = {
    MTD: 'https://your-mtd-server.com', 
    RELID: 'https://your-relid-server.com', 
  };
  static String getBaseUrl(String environment) {
    return BASE_URLS[environment] ?? BASE_URLS[DEFAULT_ENVIRONMENT]!;
  }
  static bool isValidEnvironment(String environment) {
    return BASE_URLS.containsKey(environment);
  }
  static List<String> getSupportedEnvironments() {
    return BASE_URLS.keys.toList();
  }
} 