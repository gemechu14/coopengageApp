import 'dart:io';

import 'package:flutter/foundation.dart';

class MyHttpOverrides extends HttpOverrides {
  static bool _isCoopBankHost(String host) =>
      host.endsWith('coopbankoromiasc.com');

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Debug: trust coopbankoromiasc.com (eth-qr, coopengage, etc.) when
        // corporate TLS inspection or incomplete chains break Android but not Postman.
        if (kDebugMode && _isCoopBankHost(host)) {
          debugPrint('[HttpOverrides] DEBUG trust TLS for $host:$port');
          return true;
        }

        debugPrint('[HttpOverrides] TLS rejected for $host:$port');
        debugPrint('[HttpOverrides] subject: ${cert.subject}');
        debugPrint('[HttpOverrides] issuer: ${cert.issuer}');
        return false;
      };
  }
}
