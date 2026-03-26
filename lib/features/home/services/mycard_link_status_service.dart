import 'dart:convert';

import 'package:coopengageplus/core/config/config.dart';
import 'package:coopengageplus/features/home/models/mycard_link_remote_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// GET [AppConstants.baseURL]/api/v1/mycard/link-status — call from the stats screen when backend is ready.
/// Until then the UI uses `MycardLinkRemoteStatus.mockFromApi`.
class MycardLinkStatusService {
  MycardLinkStatusService({
    Dio? dio,
    String? baseUrl,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            ),
        _baseUrl = baseUrl ?? AppConstants.baseURL;

  final Dio _dio;
  final String _baseUrl;

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );

  /// Expected: `{ "data": { ... } }` or a flat map with fields parsed by [MycardLinkRemoteStatus.fromJson].
  Future<MycardLinkRemoteStatus> fetchLinkStatus() async {
    final token = await _storage.read(key: 'token');
    final response = await _dio.get(
      '$_baseUrl/api/v1/mycard/link-status',
      options: Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        validateStatus: (code) => code != null && code < 600,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final dynamic body = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (body is! Map<String, dynamic>) {
        throw Exception('Unexpected link status response shape');
      }
      return MycardLinkRemoteStatus.fromJson(body);
    }

    throw Exception(
      'Link status unavailable (HTTP ${response.statusCode ?? '—'})',
    );
  }
}
