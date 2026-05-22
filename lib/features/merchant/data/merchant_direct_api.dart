import 'dart:convert';
import 'dart:io';

import 'package:coopengageplus/core/config/config.dart';
import 'package:flutter/foundation.dart';

import 'merchant_secrets.dart';

/// One-off HTTP client for debugging: trusts all TLS certs, no Dio.
class _TrustAllTlsOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) {
        debugPrint('[MerchantDirect] accept TLS for $host:$port');
        return true;
      };
  }
}

/// Direct `dart:io` POST — used by the debug test button only.
class MerchantDirectApi {
  static Future<Map<String, dynamic>> verifyAccount({
    required String accountNumber,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.ethQrApiUrl}/merchants/verify-account',
    );

    final previousOverrides = HttpOverrides.current;
    HttpOverrides.global = _TrustAllTlsOverrides();
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 60)
      ..idleTimeout = const Duration(seconds: 60);

    try {
      debugPrint('[MerchantDirect] ──► POST $uri (no cert verify)');
      final request = await client.postUrl(uri);
      request.headers.set('Accept', 'application/json');
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('X-API-Key', MerchantSecrets.mobileIntegrationApiKey);
      request.headers.set('User-Agent', 'CoopEngagePlus/1.0-direct');

      final payload = jsonEncode({'accountNumber': accountNumber});
      debugPrint('[MerchantDirect]     request: $payload');
      request.write(payload);

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      debugPrint('[MerchantDirect] ◄── HTTP ${response.statusCode}');
      debugPrint('[MerchantDirect]     response: $body');

      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw Exception('Unexpected response: $body');
      }
      final map = Map<String, dynamic>.from(decoded);
      final code = map['code']?.toString();
      if (code != '0') {
        throw Exception(map['msg']?.toString() ?? 'API error code $code');
      }
      final data = map['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } finally {
      client.close(force: true);
      HttpOverrides.global = previousOverrides;
    }
  }
}
