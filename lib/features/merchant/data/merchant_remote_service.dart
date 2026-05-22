import 'dart:convert';

import 'package:coopengageplus/core/config/config.dart';
import 'package:dio/dio.dart';
import 'merchant_models.dart';
import 'merchant_secrets.dart';

class MerchantRemoteService {
  MerchantRemoteService(this._dio);

  final Dio _dio;

  static const _apiBase = AppConstants.ethQrApiUrl;

  /// Mobile integration: `X-API-Key` only (matches Postman). JWT is omitted so the
  /// server uses MOBILE_INTEGRATION auth, not branch-user JWT precedence.
  /// `X-Branch-Code` on update/address/document calls when [branchCode] is set.
  Future<Map<String, String>> _headers({
    String? branchCode,
    bool jsonContent = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'X-API-Key': MerchantSecrets.mobileIntegrationApiKey,
      'User-Agent': 'CoopEngagePlus/1.0',
    };
    if (jsonContent) {
      headers['Content-Type'] = 'application/json';
    }

    if (branchCode != null && branchCode.trim().isNotEmpty) {
      headers['X-Branch-Code'] = branchCode.trim();
    }

    return headers;
  }

  Map<String, dynamic> _unwrapEnvelope(Map<String, dynamic> body) {
    final code = body['code']?.toString();
    if (code != '0') {
      throw MerchantApiException(
        body['msg']?.toString() ?? 'Request failed',
        code: code,
      );
    }
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  List<Map<String, dynamic>> _unwrapListEnvelope(Map<String, dynamic> body) {
    final code = body['code']?.toString();
    if (code != '0') {
      throw MerchantApiException(
        body['msg']?.toString() ?? 'Request failed',
        code: code,
      );
    }
    final data = body['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Future<List<BranchOption>> fetchBranches() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '$_apiBase/branches',
      options: Options(headers: await _headers()),
    );
    final list = _unwrapListEnvelope(res.data ?? {});
    return list.map(BranchOption.fromJson).toList();
  }

  Future<Map<String, dynamic>> verifyAccount(String accountNumber) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '$_apiBase/merchants/verify-account',
      data: {'accountNumber': accountNumber},
      options: Options(headers: await _headers()),
    );
    return _unwrapEnvelope(res.data ?? {});
  }

  Future<List<String>> searchPremiumPuids({
    String search = '',
    int page = 0,
    int size = 48,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '$_apiBase/merchants/premium-puids',
      queryParameters: {'search': search, 'page': page, 'size': size},
      options: Options(headers: await _headers()),
    );
    final data = _unwrapEnvelope(res.data ?? {});
    final content = data['content'];
    if (content is List) {
      return content.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> checkPremiumPuidAvailability(String puid) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '$_apiBase/merchants/premium-puids/availability',
      queryParameters: {'puid': puid},
      options: Options(headers: await _headers()),
    );
    return _unwrapEnvelope(res.data ?? {});
  }

  Future<MerchantResponse> createMerchant(Map<String, dynamic> body) async {
    final payload = Map<String, dynamic>.fromEntries(
      body.entries.where((e) => e.value != null),
    );
    final res = await _dio.post<Map<String, dynamic>>(
      '$_apiBase/merchants',
      data: payload,
      options: Options(headers: await _headers()),
    );
    final data = _unwrapEnvelope(res.data ?? {});
    return MerchantResponse.fromJson(data);
  }

  Future<MerchantResponse> updateMerchant(
    String merchantId,
    Map<String, dynamic> body, {
    required String branchCode,
  }) async {
    final payload = Map<String, dynamic>.fromEntries(
      body.entries.where((e) => e.value != null),
    );
    final res = await _dio.put<Map<String, dynamic>>(
      '$_apiBase/merchants/$merchantId',
      data: payload,
      options: Options(
        headers: await _headers(branchCode: branchCode),
      ),
    );
    final data = _unwrapEnvelope(res.data ?? {});
    return MerchantResponse.fromJson(data);
  }

  Future<MerchantResponse> uploadRegistrationDocuments({
    required String merchantId,
    required String branchCode,
    MerchantDocumentFile? tradeLicense,
    MerchantDocumentFile? tradeRegistration,
    MerchantDocumentFile? plcEstablishment,
    MerchantDocumentFile? merchantContract,
  }) async {
    final form = FormData();
    void addFile(String key, MerchantDocumentFile? file) {
      if (file == null) return;
      form.files.add(MapEntry(
        key,
        MultipartFile.fromBytes(
          file.bytes,
          filename: file.name,
          contentType: DioMediaType.parse(file.mimeType),
        ),
      ));
    }

    addFile('tradeLicense', tradeLicense);
    addFile('tradeRegistration', tradeRegistration);
    addFile('plcEstablishment', plcEstablishment);
    addFile('merchantContract', merchantContract);

    if (form.files.isEmpty) {
      throw MerchantApiException('No documents selected.');
    }

    final headers = await _headers(branchCode: branchCode, jsonContent: false);

    final res = await _dio.post<Map<String, dynamic>>(
      '$_apiBase/merchants/$merchantId/registration-documents',
      data: form,
      options: Options(headers: headers),
    );
    final data = _unwrapEnvelope(res.data ?? {});
    return MerchantResponse.fromJson(data);
  }

  Future<List<RegionOption>> fetchRegions() async {
    final res = await _dio.get<dynamic>(
      '$_apiBase/data/regions',
      options: Options(headers: {'Accept': 'application/json'}),
    );
    final body = res.data;
    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => RegionOption.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (body is String) {
      final decoded = jsonDecode(body);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => RegionOption.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
    return [];
  }

  Future<MerchantResponse> addAddress(
    String merchantId,
    Map<String, dynamic> address, {
    required String branchCode,
  }) async {
    final payload = Map<String, dynamic>.fromEntries(
      address.entries.where((e) {
        final v = e.value;
        if (v == null) return false;
        return v.toString().trim().isNotEmpty;
      }),
    );
    final res = await _dio.post<Map<String, dynamic>>(
      '$_apiBase/merchants/$merchantId/address',
      data: payload,
      options: Options(
        headers: await _headers(branchCode: branchCode),
      ),
    );
    final data = _unwrapEnvelope(res.data ?? {});
    return MerchantResponse.fromJson(data);
  }
}
