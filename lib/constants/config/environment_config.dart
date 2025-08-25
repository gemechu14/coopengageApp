class EnvironmentConfig {
  // Environment types
  static const String MTD = 'mtd';
  static const String RELID = 'relid';
  
  // Default environment
  static const String DEFAULT_ENVIRONMENT = MTD;
  
  // Certificate configurations
  static const Map<String, Map<String, String>> CERTIFICATE_CONFIG = {
    MTD: {
      'alias': 'coopid',
      'password': 'Coop@1234',
      'certificatePath': 'assets/certificates/mtd_cert.p12',
    },
    RELID: {
      'alias': 'coopid',
      'password': 'Coop@1234',
      'certificatePath': 'assets/certificates/relid_cert.p12',
    },
  };
  
  // Base URLs for different environments
  static const Map<String, String> BASE_URLS = {
    MTD: 'https://your-mtd-server.com', // Replace with your actual MTD server URL
    RELID: 'https://your-relid-server.com', // Replace with your actual RELID server URL
  };
  
  /// Gets the certificate configuration for a specific environment
  static Map<String, String> getCertificateConfig(String environment) {
    return CERTIFICATE_CONFIG[environment] ?? CERTIFICATE_CONFIG[DEFAULT_ENVIRONMENT]!;
  }
  
  /// Gets the base URL for a specific environment
  static String getBaseUrl(String environment) {
    return BASE_URLS[environment] ?? BASE_URLS[DEFAULT_ENVIRONMENT]!;
  }
  
  /// Validates if an environment is supported
  static bool isValidEnvironment(String environment) {
    return CERTIFICATE_CONFIG.containsKey(environment);
  }
  
  /// Gets all supported environments
  static List<String> getSupportedEnvironments() {
    return CERTIFICATE_CONFIG.keys.toList();
  }
} 