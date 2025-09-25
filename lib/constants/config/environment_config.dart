class EnvironmentConfig {
  // Environment types
  static const String MTD = 'mtd';
  static const String RELID = 'relid';
  
  // Default environment
  static const String DEFAULT_ENVIRONMENT = MTD;
  
  // Base URLs for different environments
  static const Map<String, String> BASE_URLS = {
    MTD: 'https://your-mtd-server.com', // Replace with your actual MTD server URL
    RELID: 'https://your-relid-server.com', // Replace with your actual RELID server URL
  };
  
  /// Gets the base URL for a specific environment
  static String getBaseUrl(String environment) {
    return BASE_URLS[environment] ?? BASE_URLS[DEFAULT_ENVIRONMENT]!;
  }
  
  /// Validates if an environment is supported
  static bool isValidEnvironment(String environment) {
    return BASE_URLS.containsKey(environment);
  }
  
  /// Gets all supported environments
  static List<String> getSupportedEnvironments() {
    return BASE_URLS.keys.toList();
  }
} 