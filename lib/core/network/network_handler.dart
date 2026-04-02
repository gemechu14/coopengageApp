// ignore_for_file: unused_local_variable, avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:coopengageplus/core/config/config.dart';
// import 'package:coopengageplus/core/database/database_helper.dart';
import 'package:coopengageplus/shared/services/session_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
class NetworkHandler {
 
  String baseurl = AppConstants.baseURL;
  var log = Logger();
  FlutterSecureStorage storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding),
  );

  /// Read token, verify it hasn't expired, and return it.
  /// Returns null only for unauthenticated endpoints.
  Future<String?> _getValidToken() async {
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) return null;
    if (JwtDecoder.isExpired(token)) {
      await SessionManager.instance.onUnauthorizedResponse();
      return null;
    }
    return token;
  }

  /// Call after every authenticated HTTP response.
  /// If the server returns 401, trigger auto-logout.
  Future<void> _handleResponseStatus(http.BaseResponse response) async {
    if (response.statusCode == 401) {
      await SessionManager.instance.onUnauthorizedResponse();
    }
  }

  Future get(String url) async {
    String? token = await _getValidToken();
    if (token == null) return null;

    url = formater(url);
    var uri = Uri.parse(url);

    var response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    await _handleResponseStatus(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      print("Status code: ${response.statusCode}");
      return null;
    }
  }

  Future getData(String url, String token) async {

    var uri = Uri.parse(url);
    var response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token"},
    );
    return response;
  }

  ///AGENT REGISTRATION
  Future<http.Response> postAgent(String url, Map<String, dynamic> data) async {
    String? token = await _getValidToken();
    url = formater(url);
    var uri = Uri.parse(url);

    var headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    var response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(data),
    );

    await _handleResponseStatus(response);
    return response;
  }

  /// Agent signup at `/api/v1/agents` only. Does not change [postAgent] used elsewhere.
  /// Uses explicit UTF-8, Accept header, and omits null map entries so the body matches strict APIs.
  Future<http.Response> postAgentRegistration(
    String url,
    Map<String, dynamic> data,
  ) async {
    String? token = await _getValidToken();
    url = formater(url);
    final uri = Uri.parse(url);

    final payload = Map<String, dynamic>.fromEntries(
      data.entries.where((e) => e.value != null),
    );
    final bodyStr = json.encode(payload);

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      uri,
      headers: headers,
      body: bodyStr,
      encoding: utf8,
    );

    await _handleResponseStatus(response);
    return response;
  }

  Future<http.Response> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    // Use standard HTTP client for security
    url = formater(url);
    var uri = Uri.parse(url);
    log.d(body);

    var response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "User-Agent": "CoopEngage+ Mobile App/1.0",
        "Accept-Encoding": "gzip, deflate, br",
        "Accept-Language": "en-US,en;q=0.9",
        "Cache-Control": "no-cache",
        "Connection": "keep-alive",
        "Sec-Fetch-Dest": "empty",
        "Sec-Fetch-Mode": "cors",
        "Sec-Fetch-Site": "cross-site",
        // "Authorization": "Bearer $token" // Uncomment if using token
      },
      body: json.encode(body),
    );

    print("ldfkdjfkdfjdkkfd");
    return response;
  }

  Future<http.Response> postData(
      String url, Map<String, dynamic> body, String token) async {
    var uri = Uri.parse(url); 
    log.d(body);

    var response = await http.post(
      uri,
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode(body),
    );

    return response;
  }

  Future<http.Response> postFormData(
      String url, Map<String, dynamic> body, String token) async {
    var uri = Uri.parse(url);

    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    body.forEach((key, value) {
      if (value is Uint8List) {
        final httpFile = http.MultipartFile.fromBytes(
          key,
          value,
          filename: '$key.png', // Replace with appropriate file naming logic
          contentType: MediaType('image', 'png'),
        );
        request.files.add(httpFile);
      } else if (value is String) {
        request.fields[key] = value;
      }
    });
    // Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    return response;
  }

  Future<http.Response> patch(String url, Map<String, String> body) async {
    String? token = await storage.read(key: "token");
    url = formater(url);
    log.d(body);
    var response = await http.patch(
      url as Uri,
      headers: {
        "Content-type": "application/json",
        // "Authorization": "Bearer $token"
      },
      body: json.encode(body),
    );
    return response;
  }

  Future<http.Response> postWithFormData(
      String qrcodeUrl, Map<String, dynamic> body) async {
    var uri = Uri.parse(qrcodeUrl);
    var request = http.MultipartRequest('POST', uri);

    body.forEach((key, value) {
      if (value is String) {
        request.fields[key] = value;
      } else if (value is Uint8List) {
        request.files.add(http.MultipartFile.fromBytes(
          key, // The key for the file field (e.g., 'qr_code')
          value, // The byte data of the image
          filename: '$key.jpg', // You can customize the filename here
          contentType:
              MediaType('image', 'jpeg'), // Content type for JPEG image
        ));
      }
    });

    request.headers['accept'] = 'application/json';

    // Send the request and get the response
    var response = await request.send();

    if (response.statusCode == 307) {
      // Get the new URL from the Location header
      String redirectUrl = response.headers['location']!;
      var redirectRequest =
          http.MultipartRequest('POST', Uri.parse(redirectUrl));
      body.forEach((key, value) {
        if (value is String) {
          redirectRequest.fields[key] = value;
        } else if (value is Uint8List) {
          redirectRequest.files.add(http.MultipartFile.fromBytes(
            key, 
            value, 
            filename: '$key.jpg', 
            contentType:
                MediaType('image', 'jpeg'),
          ));
        }
      });

      redirectRequest.headers['accept'] = 'application/json';

      // Send the redirected request
      var redirectResponse = await redirectRequest.send();

      // Convert the response stream to a regular response object
      final responseData = await http.Response.fromStream(redirectResponse);

      return responseData;
    } else {
      // Convert the response stream to a regular response object if no redirect
      final responseData = await http.Response.fromStream(response);
      return responseData;
    }
  }

  Future<http.Response> post1(String url, Map<String, dynamic> data) async {
    String? token = await _getValidToken();

    if (token == null) {
      throw Exception("Token not found or expired");
    }

    url = formater(url);
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    data.forEach((key, value) {
      if (key == 'signature' && value is Uint8List) {
        final httpFile = http.MultipartFile.fromBytes(
          key,
          value,
          filename: 'signature.png',
          contentType: MediaType.parse('image/png'),
        );
        request.files.add(httpFile);
      } else if (key == 'photo' && value is Uint8List) {
        final httpFile = http.MultipartFile.fromBytes(
          key,
          value,
          filename: 'photo.png',
          contentType: MediaType.parse('image/png'),
        );
        request.files.add(httpFile);
      } else if (key == 'residenceCard' && value is Uint8List) {
        final httpFile = http.MultipartFile.fromBytes(
          key,
          value,
          filename: 'residenceCard.png',
          contentType: MediaType.parse('image/png'),
        );
        request.files.add(httpFile);
      } else if (key == 'confirmationForm' && value is Uint8List) {
        final httpFile = http.MultipartFile.fromBytes(
          key,
          value,
          filename: 'confirmationForm.png',
          contentType: MediaType.parse('image/png'),
        );
        request.files.add(httpFile);
      } else if (key == 'passport' && value is Uint8List) {
        final httpFile = http.MultipartFile.fromBytes(
          key,
          value,
          filename: 'passport.png',
          contentType: MediaType.parse('image/png'),
        );
        request.files.add(httpFile);
      } else if (value is String) {
        request.fields[key] = value;
      }
    });

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    await _handleResponseStatus(response);
    return response;
  }

  Future<http.Response> put1(String url, Map<String, dynamic> data) async {
    String? token = await _getValidToken();

    if (token == null) {
      throw Exception("Token not found or expired");
    }

    url = formater(url);
    var uri = Uri.parse(url);

    var request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token';

    data.forEach((key, value) {
      // Handle both online and offline field names
      if (key.startsWith('customerInfo.')) {
        if (key == 'customerInfo.signature' && value is Uint8List) {
          final httpFile = http.MultipartFile.fromBytes(
            key,
            value,
            filename: 'signature.jpeg',
            contentType: MediaType.parse('image/jpeg'),
          );
          request.files.add(httpFile);
        } else if (key == 'customerInfo.photo' && value is Uint8List) {
          final httpFile = http.MultipartFile.fromBytes(
            key,
            value,
            filename: 'photo.jpeg',
            contentType: MediaType.parse('image/jpeg'),
          );
          request.files.add(httpFile);
        } else if (key == 'customerInfo.residenceCard' && value is Uint8List) {
          final httpFile = http.MultipartFile.fromBytes(
            key,
            value,
            filename: 'residenceCard.jpeg',
            contentType: MediaType.parse('image/jpeg'),
          );
          request.files.add(httpFile);
        } else if (key == 'confirmationForm' && value is Uint8List) {
          // Handle the confirmation form field if present
          final httpFile = http.MultipartFile.fromBytes(
            key, // Field name
            value,
            filename: 'confirmationForm.jpeg',
            contentType: MediaType.parse('image/jpeg'),
          );
          request.files.add(httpFile);
        } else if (key == 'customerInfo.passport' && value is Uint8List) {
          final httpFile = http.MultipartFile.fromBytes(
            key,
            value,
            filename: 'passport.jpeg',
            contentType: MediaType.parse('image/jpeg'),
          );
          request.files.add(httpFile);
        } else if (key == 'customerInfo.residenceCardBack' &&
            value is Uint8List) {
          final httpFile = http.MultipartFile.fromBytes(
            key,
            value,
            filename: 'residenceCardBack.jpeg',
            contentType: MediaType.parse('image/jpeg'),
          );
          request.files.add(httpFile);
        } else if (value is String) {
          request.fields[key] = value;
        }
      } else {
        // Handle non-customerInfo fields (offline mode or other fields)
        if (key == 'signature' && value is Uint8List) {
          final httpFile = http.MultipartFile.fromBytes(
            key,
            value,
            filename: 'signature.jpeg',
            contentType: MediaType.parse('image/jpeg'),
          );
          request.files.add(httpFile);
        } else if (key == 'photo' && value is Uint8List) {
          final httpFile = http.MultipartFile.fromBytes(
            key,
            value,
            filename: 'photo.jpeg',
            contentType: MediaType.parse('image/jpeg'),
          );
          request.files.add(httpFile);
        } else if (key == 'residenceCard' && value is Uint8List) {
          final httpFile = http.MultipartFile.fromBytes(
            key,
            value,
            filename: 'residenceCard.jpeg',
            contentType: MediaType.parse('image/jpeg'),
          );
          request.files.add(httpFile);
        } else if (key == 'confirmationForm' && value is Uint8List) {
          // Handle the confirmation form field if present
          final httpFile = http.MultipartFile.fromBytes(
            key, // Field name
            value,
            filename: 'confirmationForm.jpeg',
            contentType: MediaType.parse('image/jpeg'),
          );
          request.files.add(httpFile);
        } else if (key == 'passport' && value is Uint8List) {
          final httpFile = http.MultipartFile.fromBytes(
            key,
            value,
            filename: 'passport.jpeg',
            contentType: MediaType.parse('image/jpeg'),
          );
          request.files.add(httpFile);
        } else if (key == 'residenceCardBack' && value is Uint8List) {
          final httpFile = http.MultipartFile.fromBytes(
            key,
            value,
            filename: 'residenceCardBack.jpeg',
            contentType: MediaType.parse('image/jpeg'),
          );
          request.files.add(httpFile);
        } else if (value is String) {
          request.fields[key] = value;
        }
      }
    });

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            "Failed to update data. Status code: ${response.statusCode}");
      }

      return response;
    } catch (e) {
      print("Request failed: $e");
      rethrow;
    }
  }

  Future<http.StreamedResponse> patchImage(String url, String filepath) async {
    String? token = await _getValidToken();
    if (token == null) {
      throw Exception("Token not found or expired - please login again");
    }
    
    url = formater(url);
    var request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath("img", filepath));
    request.headers.addAll({
      "Content-type": "multipart/form-data",
      "Authorization": "Bearer $token"
    });
    var response = request.send();
    return response;
  }

  String formater(String url) {
    return baseurl + url;
  }

  NetworkImage getImage(String imageName) {
    String url = formater("/uploads//$imageName.jpeg");
    return NetworkImage(url);
  }

  Future<http.Response> fetchData(String url) async {
    String? token = await _getValidToken();
    if (token == null) {
      throw Exception("Token not found or expired - please login again");
    }
    
    url = formater(url);

    var uri = Uri.parse(url);
    var response = await http.get(
      uri,
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    await _handleResponseStatus(response);
    return response;
  }

  Future<http.Response> getUserData(String url) async {
    String? token = await _getValidToken();
    if (token == null) {
      throw Exception("Token not found or expired - please login again");
    }
    
    url = formater(url);

    var uri = Uri.parse(url);

    var response = await http.get(
      uri,
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    await _handleResponseStatus(response);
    return response;
  }

  Future<List<Map<String, dynamic>>> fetchAccountTypesFromDatabase() async {
    try {
      final result = await get('/api/v1/account-types');
      if (result is List<dynamic>) {
        return result.map((e) {
          final m = e as Map<String, dynamic>;
          return {
            "id": m["id"].toString(),
            "name": m["name"] ?? "",
            "description": m["description"] ?? "",
            "category": m["category"] ?? "",
            "bankingType": m["bankingType"] ?? "",
            "origin": m["origin"] ?? "",
            "minAge": m["minAge"].toString(),
            "maxAge": m["maxAge"].toString(),
            "minBalance": m["minBalance"].toString(),
          };
        }).toList();
      }
      return [];
    } catch (error) {
      print("Error fetching account types from API: $error");
      return [];
    }
  }
}
