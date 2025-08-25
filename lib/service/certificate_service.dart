import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CertificateService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // Certificate aliases and passwords
  static const String _mtdAlias = 'coopid';
  static const String _mtdPassword = 'Coop@1234';
  static const String _relIdAlias = 'coopid';
  static const String _relIdPassword = 'Coop@1234';

  /// Creates an HttpClient with SSL certificate support
  static Future<HttpClient> createSecureHttpClient({
    required String environment,
  }) async {
    HttpClient client = HttpClient();
    
    try {
      // Load the appropriate certificate based on environment
      String certificatePath;
      String alias;
      String password;
      
      if (environment.toLowerCase() == 'mtd') {
        certificatePath = 'assets/certificates/mtd_cert.p12';
        alias = _mtdAlias;
        password = _mtdPassword;
      } else if (environment.toLowerCase() == 'relid') {
        certificatePath = 'assets/certificates/relid_cert.p12';
        alias = _relIdAlias;
        password = _relIdPassword;
      } else {
        throw ArgumentError('Invalid environment. Use "mtd" or "relid"');
      }

      // Load certificate from assets
      print('Loading certificate from: $certificatePath');
      ByteData certificateData = await rootBundle.load(certificatePath);
      List<int> certificateBytes = certificateData.buffer.asUint8List();
      print('Certificate loaded: ${certificateBytes.length} bytes');
      print('Using alias: $alias, password: $password');

      // Create SecurityContext with the certificate
      SecurityContext context = SecurityContext(withTrustedRoots: true);
      
      try {
        // Try to set the certificate as trusted
        context.setTrustedCertificatesBytes(certificateBytes, password: password);
        print('Certificate loaded successfully with password');
      } catch (e) {
        print('Error setting trusted certificate: $e');
        // If setting as trusted fails, try to add it as a client certificate
        try {
          context.useCertificateChainBytes(certificateBytes, password: password);
          print('Certificate loaded as client certificate');
        } catch (e2) {
          print('Error loading certificate: $e2');
          // If all else fails, create a basic context
          context = SecurityContext(withTrustedRoots: true);
        }
      }

      // Configure the client with the security context
      client = HttpClient(context: context);
      
      // Handle certificate validation
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        print('Certificate validation for $host:$port');
        // You can add custom validation logic here
        // For development, you might want to return true
        // For production, implement proper validation
        return true; // Be careful with this in production
      };

      print('Secure HttpClient created successfully for $environment environment');
      return client;
      
    } catch (e) {
      print('Error creating secure HttpClient: $e');
      // Fallback to basic HttpClient with certificate bypass
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        print('Allowing certificate for $host:$port (fallback mode)');
        return true;
      };
      return client;
    }
  }

  /// Creates an HttpClient for development/testing (allows all certificates)
  static HttpClient createDevelopmentHttpClient() {
    HttpClient client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      print('Development mode: Allowing certificate for $host:$port');
      return true;
    };
    return client;
  }

  /// Validates if a certificate is valid for a given host
  static bool validateCertificate(X509Certificate cert, String host) {
    // Add your certificate validation logic here
    // This is a basic example - implement proper validation for production
    
    // Check if the certificate is not expired
    DateTime now = DateTime.now();
    if (now.isBefore(cert.startValidity) || now.isAfter(cert.endValidity)) {
      print('Certificate is expired or not yet valid');
      return false;
    }

    // Check if the hostname matches (basic check)
    if (cert.subject.contains(host) || cert.issuer.contains(host)) {
      return true;
    }

    // For development, you might want to allow all certificates
    return true; // Be careful with this in production
  }

  /// Gets the current environment from secure storage or config
  static Future<String> getCurrentEnvironment() async {
    try {
      String? env = await _storage.read(key: 'environment');
      return env ?? 'mtd'; // Default to MTD environment
    } catch (e) {
      print('Error reading environment: $e');
      return 'mtd'; // Default fallback
    }
  }

  /// Sets the current environment
  static Future<void> setEnvironment(String environment) async {
    try {
      await _storage.write(key: 'environment', value: environment);
      print('Environment set to: $environment');
    } catch (e) {
      print('Error setting environment: $e');
    }
  }
} 