import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Loads branches from the JWT token.
class MycardUserBranchesLoader {
  MycardUserBranchesLoader._();

  static final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );

  static Future<List<Map<String, dynamic>>> load() async {
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) return [];

    try {
      final parts = token.split(".");
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final branchList =
          List<Map<String, dynamic>>.from(payload['branch'] ?? []);

      return branchList.map((b) {
        return {
          'id': b['id'],
          'userId': payload['userId'],
          'name': b['name']?.toString() ?? 'Unnamed Branch',
          'branchCode': b['branchCode']?.toString() ?? '',
          'companyName': b['name']?.toString() ?? 'Unnamed Branch',
        };
      }).toList();
    } catch (e) {
      print("MycardUserBranchesLoader: Error loading branches from JWT: $e");
      return [];
    }
  }
}
