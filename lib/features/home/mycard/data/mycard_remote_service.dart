import 'dart:convert';

import 'package:dio/dio.dart';

import 'mycard_endpoints.dart';
import 'mycard_models.dart';
import 'mycard_secrets.dart';
import 'oauth_client.dart';

class MycardRemoteService {
  MycardRemoteService(this._dio, this._oauth);

  final Dio _dio;
  final OAuthClient _oauth;

  /// Same OAuth client credentials → one token for send/verify OTP and internal APIs.
  Future<String> _accessToken() {
    final basic = MycardSecrets.oauthBasicAuth.trim();
    if (basic.isEmpty) {
      throw StateError(MycardSecrets.missingOAuthMessage);
    }
    return _oauth.getAccessToken(
      tokenUrl: MycardEndpoints.oauthToken,
      basicAuthorizationHeader: basic,
    );
  }

  Future<SendOtpResult> sendOtp(String accountNumber) async {
    final token = await _accessToken();
    final res = await _dio.post<Map<String, dynamic>>(
      MycardEndpoints.sendOtp,
      data: {'accountNumber': accountNumber},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    _ensureSuccess(res);
    final body = res.data ?? {};
    if (body['success'] != true) {
      throw StateError('${body['message'] ?? 'sendOtp failed'}');
    }
    return SendOtpResult.fromJson(body);
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    required String accountNumber,
  }) async {
    final token = await _accessToken();
    final res = await _dio.post<Map<String, dynamic>>(
      MycardEndpoints.verifyOtp,
      data: {
        'phoneNumber': phoneNumber,
        'otpCode': otpCode,
        'accountNumber': accountNumber,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    _ensureSuccess(res);
    final body = res.data ?? {};
    if (body['success'] != true) {
      throw StateError('${body['message'] ?? 'verifyOtp failed'}');
    }
  }

  Future<CustomerInfoResult> getCustomerInfo(String accountId) async {
    final token = await _accessToken();
    final res = await _dio.get<Map<String, dynamic>>(
      MycardEndpoints.customerInfoUri(accountId).toString(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    _ensureSuccess(res);
    final body = res.data ?? {};
    if (body['success'] != true) {
      throw StateError('customer info failed');
    }
    return CustomerInfoResult.fromJson(body);
  }

  Future<void> requestNewCard(Map<String, dynamic> body) async {
    final token = await _accessToken();
    final res = await _dio.post<dynamic>(
      MycardEndpoints.requestNewCard,
      data: body,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _ensureSuccess(res);
  }

  void _ensureSuccess(Response<dynamic> res) {
    final code = res.statusCode ?? 0;
    if (code >= 200 && code < 300) return;
    final msg = _errorMessageFromBody(res.data) ?? 'HTTP $code';
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      message: msg,
      type: DioExceptionType.badResponse,
    );
  }

  static String? _errorMessageFromBody(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      final m = data['message'] ??
          data['error'] ??
          data['errorMessage'] ??
          data['description'] ??
          data['detail'];
      if (m != null && '$m'.trim().isNotEmpty) return '$m'.trim();
      final fault = data['fault'];
      if (fault is Map) {
        final fm = fault['message'] ?? fault['description'];
        if (fm != null && '$fm'.trim().isNotEmpty) return '$fm'.trim();
      }
      return data.toString();
    }
    if (data is String) {
      final t = data.trim();
      if (t.isEmpty) return null;
      try {
        final j = jsonDecode(t);
        return _errorMessageFromBody(j);
      } catch (_) {
        return t;
      }
    }
    return data.toString();
  }
}
