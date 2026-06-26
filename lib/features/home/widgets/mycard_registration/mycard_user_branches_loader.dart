import 'dart:convert';

import 'package:coopengageplus/core/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

/// Loads main + other branches for the logged-in user (profile / MyCard / merchant).
///
/// 1. `GET /api/v1/users/me` — same source as [ProfileScreen] and [BranchSelector]
/// 2. JWT fallback — `mainBranch` + `branch` / `branches` claims
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

    final fromApi = await _loadFromUsersMe(token);
    if (fromApi.isNotEmpty) return fromApi;

    return _loadFromJwt(token);
  }

  static Future<List<Map<String, dynamic>>> _loadFromUsersMe(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print(
          'MycardUserBranchesLoader: /users/me HTTP ${response.statusCode}',
        );
        return [];
      }

      final userData = jsonDecode(response.body) as Map<String, dynamic>;
      return _branchesFromUserPayload(userData);
    } catch (e) {
      print('MycardUserBranchesLoader: /users/me failed: $e');
      return [];
    }
  }

  static List<Map<String, dynamic>> _loadFromJwt(String token) {
    try {
      final decoded = Map<String, dynamic>.from(JwtDecoder.decode(token) as Map);
      return _branchesFromJwtPayload(decoded);
    } catch (e) {
      print('MycardUserBranchesLoader: JWT decode failed: $e');
      return [];
    }
  }

  /// API body: `mainBranch` + `branches` (profile screen shape).
  static List<Map<String, dynamic>> _branchesFromUserPayload(
    Map<String, dynamic> userData,
  ) {
    final result = <Map<String, dynamic>>[];
    final seenIds = <int>{};

    int? mainId;
    String? mainName;
    String? mainCode;

    if (userData['mainBranch'] is Map) {
      final mb = Map<String, dynamic>.from(userData['mainBranch'] as Map);
      mainId = _coerceInt(mb['id']);
      mainName = mb['name']?.toString() ?? mb['companyName']?.toString();
      mainCode = mb['branchCode']?.toString();
    }

    if (mainCode != null && mainCode.isNotEmpty) {
      result.add(_branchMap(
        id: mainId,
        name: mainName,
        branchCode: mainCode,
        isMain: true,
      ));
      if (mainId != null) seenIds.add(mainId);
    }

    if (userData['branches'] is List) {
      for (final raw in userData['branches'] as List) {
        if (raw is! Map) continue;
        final b = Map<String, dynamic>.from(raw);
        final id = _coerceInt(b['id']);
        if (mainId != null && id == mainId) continue;
        if (id != null && seenIds.contains(id)) continue;
        final code = b['branchCode']?.toString() ?? '';
        if (code.isEmpty) continue;
        result.add(_branchMap(
          id: id,
          name: b['name']?.toString() ?? b['companyName']?.toString(),
          branchCode: code,
        ));
        if (id != null) seenIds.add(id);
      }
    }

    // No mainBranch — treat first entry in branches as main (profile fallback).
    if (result.isEmpty && userData['branches'] is List) {
      final list = userData['branches'] as List;
      for (var i = 0; i < list.length; i++) {
        if (list[i] is! Map) continue;
        final b = Map<String, dynamic>.from(list[i] as Map);
        final code = b['branchCode']?.toString() ?? '';
        if (code.isEmpty) continue;
        result.add(_branchMap(
          id: _coerceInt(b['id']),
          name: b['name']?.toString() ?? b['companyName']?.toString(),
          branchCode: code,
          isMain: i == 0,
        ));
      }
    }

    return result;
  }

  /// JWT: `mainBranch` + `branch` array (legacy token shape).
  static List<Map<String, dynamic>> _branchesFromJwtPayload(
    Map<String, dynamic> decoded,
  ) {
    final branchList = decoded['branches'] is List
        ? List<Map<String, dynamic>>.from(decoded['branches'] as List)
        : List<Map<String, dynamic>>.from(decoded['branch'] ?? []);

    final result = <Map<String, dynamic>>[];
    int? mainId;
    String? mainName;
    String? mainCode;

    if (decoded['mainBranch'] is Map) {
      final mb = Map<String, dynamic>.from(decoded['mainBranch'] as Map);
      if (mb.isNotEmpty) {
        mainId = _coerceInt(mb['id']);
        mainName = mb['companyName']?.toString() ?? mb['name']?.toString();
        mainCode = mb['branchCode']?.toString();
      }
    }

    if (mainCode != null && mainCode.isNotEmpty) {
      result.add(_branchMap(
        id: mainId,
        name: mainName,
        branchCode: mainCode,
        isMain: true,
      ));

      for (final b in branchList) {
        final bid = _coerceInt(b['id']);
        if (mainId != null && bid == mainId) continue;
        final code = b['branchCode']?.toString() ?? '';
        if (code.isEmpty) continue;
        result.add(_branchMap(
          id: bid,
          name: b['name']?.toString() ?? b['companyName']?.toString(),
          branchCode: code,
        ));
      }
      return result;
    }

    if (branchList.isEmpty) return result;

    for (var i = 0; i < branchList.length; i++) {
      final b = branchList[i];
      final code = b['branchCode']?.toString() ?? '';
      if (code.isEmpty) continue;
      result.add(_branchMap(
        id: _coerceInt(b['id']),
        name: b['name']?.toString() ?? b['companyName']?.toString(),
        branchCode: code,
        isMain: i == 0,
      ));
    }

    return result;
  }

  static Map<String, dynamic> _branchMap({
    int? id,
    String? name,
    required String branchCode,
    bool isMain = false,
  }) {
    final label = name?.trim().isNotEmpty == true ? name!.trim() : 'Branch';
    return {
      'id': id,
      'name': label,
      'branchCode': branchCode,
      'companyName': label,
      if (isMain) 'isMain': true,
    };
  }

  static int? _coerceInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
