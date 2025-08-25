import 'dart:io';
import 'package:coopengageplus/service/certificate_service.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // Try to create a secure client with certificates
    try {
      // This will be handled by the NetworkHandler for specific requests
      // For global overrides, we'll use a development-friendly approach
      return super.createHttpClient(context)
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          print('Global HTTP Override: Allowing certificate for $host:$port');
          // You can add custom validation logic here
          return true; // Be careful with this in production
        };
    } catch (e) {
      print('Error in HttpOverrides: $e');
      // Fallback to basic client
      return super.createHttpClient(context)
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          print('Fallback HTTP Override: Allowing certificate for $host:$port');
          return true;
        };
    }
  }
}
