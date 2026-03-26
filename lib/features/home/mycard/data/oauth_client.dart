import 'package:dio/dio.dart';

/// Fetches OAuth2 access tokens with Basic auth; caches until [expiresIn] skew.
class OAuthClient {
  OAuthClient(this._dio);

  final Dio _dio;

  final Map<String, _Cached> _cache = {};

  Future<String> getAccessToken({
    required String tokenUrl,
    required String basicAuthorizationHeader,
  }) async {
    final key = tokenUrl;
    final now = DateTime.now();
    final c = _cache[key];
    if (c != null && c.expiresAt.isAfter(now)) {
      return c.accessToken;
    }

    final response = await _dio.post<dynamic>(
      tokenUrl,
      data: 'grant_type=client_credentials',
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'Authorization': 'Basic $basicAuthorizationHeader',
        },
        responseType: ResponseType.json,
        validateStatus: (s) => s != null && s < 600,
      ),
    );

    final data = response.data;
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw StateError('OAuth failed: HTTP ${response.statusCode} $data');
    }
    if (data is! Map) {
      throw StateError('OAuth: unexpected response');
    }
    final map = Map<String, dynamic>.from(data);
    final token = map['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError('OAuth: missing access_token');
    }
    final expiresIn = (map['expires_in'] as num?)?.toInt() ?? 3600;
    _cache[key] = _Cached(
      accessToken: token,
      expiresAt: now.add(Duration(seconds: expiresIn - 60)),
    );
    return token;
  }

  void clearCache() => _cache.clear();
}

class _Cached {
  _Cached({required this.accessToken, required this.expiresAt});

  final String accessToken;
  final DateTime expiresAt;
}
