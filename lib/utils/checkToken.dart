import 'dart:convert';

bool isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;

    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final payloadMap = json.decode(payload);

    if (payloadMap is! Map<String, dynamic>) return true;

    final exp = payloadMap['exp'];
    if (exp == null) return true;

    final expiryDate =
        DateTime.fromMillisecondsSinceEpoch(exp * 1000); // JWT uses seconds
    return DateTime.now().isAfter(expiryDate);
  } catch (e) {
    print('Error decoding token: $e');
    return true;
  }
}
