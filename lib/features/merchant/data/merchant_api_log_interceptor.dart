import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Console logging for eth-qr merchant onboarding APIs only.
class MerchantApiLogInterceptor extends Interceptor {
  static const _tag = '[MerchantAPI]';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final url = options.uri.toString();
    debugPrint('$_tag ──► $method $url');
    debugPrint('$_tag     headers: ${_safeHeaders(options.headers)}');
    final body = options.data;
    if (body != null) {
      debugPrint('$_tag     request: ${_formatBody(body)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final method = response.requestOptions.method.toUpperCase();
    final url = response.requestOptions.uri.toString();
    debugPrint(
      '$_tag ◄── $method $url → HTTP ${response.statusCode}',
    );
    debugPrint('$_tag     response: ${_formatBody(response.data)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final req = err.requestOptions;
    final method = req.method.toUpperCase();
    final url = req.uri.toString();
    debugPrint('$_tag ✖── $method $url → ${err.type} ${err.message}');
    if (err.response != null) {
      debugPrint(
        '$_tag     HTTP ${err.response?.statusCode} body: ${_formatBody(err.response?.data)}',
      );
    }
    handler.next(err);
  }

  static Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) {
    final out = <String, dynamic>{};
    headers.forEach((key, value) {
      final k = key.toString();
      if (k.toLowerCase() == 'x-api-key') {
        final s = value?.toString() ?? '';
        out[k] = s.length > 12 ? '${s.substring(0, 8)}…(${s.length} chars)' : '***';
      } else {
        out[k] = value;
      }
    });
    return out;
  }

  static String _formatBody(dynamic data) {
    if (data == null) return '(empty)';
    try {
      if (data is FormData) {
        final fields = data.fields.map((e) => '${e.key}=${e.value}').join(', ');
        final files = data.files.map((e) => e.key).join(', ');
        return 'FormData(fields: [$fields], files: [$files])';
      }
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
