import 'dart:convert';
import 'dart:typed_data';

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
    String? email,
  }) async {
    // Build the URL manually so that '@' in the email is NOT percent-encoded
    // to '%40' — Dio's queryParameters would encode it automatically.
    final base = '$_apiBase/merchants/premium-puids'
        '?search=$search&page=$page&size=$size';
    final url =
        (email != null && email.isNotEmpty) ? '$base&email=$email' : base;
    final res = await _dio.get<Map<String, dynamic>>(
      url,
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

  Future<MerchantResponse> createMerchant(
    Map<String, dynamic> body, {
    String? email,
  }) async {
    final payload = Map<String, dynamic>.fromEntries(
      body.entries.where((e) => e.value != null),
    );
    // Append email as a raw query param so '@' is not encoded to '%40'
    final url = (email != null && email.isNotEmpty)
        ? '$_apiBase/merchants?email=$email'
        : '$_apiBase/merchants';
    final res = await _dio.post<Map<String, dynamic>>(
      url,
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

  /// Lists merchants registered under a branch (paginated).
  /// Pass [qrRequested] = false for ready-to-request, true for already requested, null for all.
  Future<({List<MerchantResponse> merchants, int totalPages, int totalElements})>
      listMerchantsByBranch({
    required String branchCode,
    bool? qrRequested,
    int page = 0,
    int size = 20,
  }) async {
    final params = <String, dynamic>{
      'branchCode': branchCode,
      'page': page,
      'size': size,
    };
    if (qrRequested != null) params['qrRequested'] = qrRequested;

    final res = await _dio.get<Map<String, dynamic>>(
      '$_apiBase/merchants/mobile/by-branch',
      queryParameters: params,
      options: Options(headers: await _headers()),
    );
    final body = res.data ?? {};
    final code = body['code']?.toString();
    if (code != '0') {
      throw MerchantApiException(
        body['msg']?.toString() ?? 'Failed to load merchants',
        code: code,
      );
    }
    final data = body['data'];
    final dataMap = data is Map<String, dynamic>
        ? data
        : (data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{});
    final content = dataMap['content'];
    final merchants = content is List
        ? content
            .whereType<Map>()
            .map((e) => MerchantResponse.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <MerchantResponse>[];
    return (
      merchants: merchants,
      totalPages: (dataMap['totalPages'] as num?)?.toInt() ?? 1,
      totalElements: (dataMap['totalElements'] as num?)?.toInt() ?? merchants.length,
    );
  }

  /// Submits QR code requests for one or more merchants to Head Office for approval.
  Future<String> requestQrCodes({
    required String branchCode,
    required List<({String merchantId, int acrylicQuantity, int stickerQuantity})> requests,
  }) async {
    final body = {
      'requests': requests
          .map((r) => {
                'merchantId': r.merchantId,
                'acrylicQuantity': r.acrylicQuantity,
                'stickerQuantity': r.stickerQuantity,
              })
          .toList(),
    };
    final res = await _dio.post<Map<String, dynamic>>(
      '$_apiBase/merchants/mobile/qr-request',
      data: body,
      options: Options(headers: await _headers(branchCode: branchCode)),
    );
    final resBody = res.data ?? {};
    final code = resBody['code']?.toString();
    if (code != '0') {
      throw MerchantApiException(
        resBody['msg']?.toString() ?? 'QR request failed',
        code: code,
      );
    }
    return resBody['data']?.toString() ?? 'QR request submitted successfully.';
  }

  /// Fetches the raw QR poster image bytes for a merchant.
  /// [templateType]: 'acrylic' or 'sticker'. [fileType]: 'png', 'jpg', or 'jpeg'.
  Future<Uint8List> getQrPosterBytes({
    required String merchantId,
    required String branchCode,
    String templateType = 'acrylic',
    String fileType = 'png',
  }) async {
    final headers = await _headers(branchCode: branchCode, jsonContent: false);
    headers['Accept'] = 'image/*';

    final res = await _dio.get<List<int>>(
      '$_apiBase/merchants/$merchantId/qr-poster',
      queryParameters: {'templateType': templateType, 'fileType': fileType},
      options: Options(
        headers: headers,
        responseType: ResponseType.bytes,
      ),
    );
    final statusCode = res.statusCode ?? 0;
    if (statusCode == 401) throw MerchantApiException('Unauthorized. Check API key.', code: '401');
    if (statusCode == 400) throw MerchantApiException('Branch code required.', code: '400');
    if (statusCode == 403) {
      throw MerchantApiException('Merchant does not belong to this branch.', code: '403');
    }
    if (statusCode == 404) throw MerchantApiException('Merchant not found.', code: '404');
    if (statusCode < 200 || statusCode >= 300) {
      throw MerchantApiException('Failed to load QR poster (HTTP $statusCode).', code: '$statusCode');
    }
    final bytes = res.data;
    if (bytes == null || bytes.isEmpty) {
      throw MerchantApiException('Empty QR poster response.');
    }
    return Uint8List.fromList(bytes);
  }
}
