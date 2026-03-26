import 'package:coopengageplus/core/database/database_helper.dart';
import 'package:coopengageplus/shared/services/GlobalData.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Loads branches the same way as [ProfileScreen._fetchBranchesFromDatabase]:
/// local `Branches` table, main branch moved first when [Users.mainBranchId] matches.
/// If the table is empty, uses the user’s main branch row from [Users], then JWT.
class MycardUserBranchesLoader {
  MycardUserBranchesLoader._();

  static final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );

  static Future<List<Map<String, dynamic>>> load() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final branchResults = await db.query('Branches');

    List<Map<String, dynamic>> formatted = [];
    if (branchResults.isNotEmpty) {
      formatted = branchResults.map((branch) {
        return {
          'id': branch['id'],
          'userId': branch['userId'],
          'name': branch['branchName'] ?? 'Unnamed Branch',
          'branchCode': branch['branchCode'] ?? '',
          'companyName': branch['companyName'] ??
              branch['branchName'] ??
              'Unnamed Branch',
        };
      }).toList();
    }

    final token = await _storage.read(key: 'token');
    Map<String, dynamic>? user;
    if (token != null && token.isNotEmpty) {
      user = await dbHelper.getUserByToken(token);
      if (user != null && formatted.isNotEmpty) {
        final mainId = user['mainBranchId'];
        if (mainId != null) {
          final i = formatted.indexWhere((b) => b['id'] == mainId);
          if (i > 0) {
            final m = formatted.removeAt(i);
            formatted.insert(0, m);
          }
        }
      }
    }

    if (formatted.isNotEmpty) {
      return formatted;
    }

    if (user != null) {
      final mainName = user['mainBranchName']?.toString().trim();
      if (mainName != null && mainName.isNotEmpty) {
        return [
          {
            'id': user['mainBranchId'] ?? 0,
            'userId': user['userId'],
            'name': mainName,
            'branchCode': user['mainBranchCode'] ?? '',
            'companyName': mainName,
          },
        ];
      }
    }

    await GlobalData().fetchToken();
    return List<Map<String, dynamic>>.from(GlobalData().branches);
  }
}
