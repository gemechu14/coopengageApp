import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // Create a secure HTTP client with proper SSL validation
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // In production, NEVER bypass certificate validation
        // This prevents man-in-the-middle attacks
        print('Certificate validation failed for $host:$port');
        print('Certificate subject: ${cert.subject}');
        print('Certificate issuer: ${cert.issuer}');
        print('Certificate valid from: ${cert.startValidity} to ${cert.endValidity}');
        
        // Return false to reject invalid certificates
        // This ensures your app only connects to trusted servers
        return false;
      };
  }
}
