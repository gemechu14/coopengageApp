import 'dart:async';
import 'dart:convert';

import 'package:coopengageplus/core/config/config.dart';
import 'package:coopengageplus/core/database/database_helper.dart';
import 'package:coopengageplus/core/network/network_handler.dart';
import 'package:coopengageplus/shared/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
final authRepositoryProvider = Provider((ref) => AuthRepository(ref));

class AuthRepository {
  AuthRepository(this._ref);

  final Ref _ref;
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding),
  );
  final _dbHelper = DatabaseHelper();
  final _networkHandler = NetworkHandler();

  Future<User> login(String username, String password) async {
    final data = {
      "username": username,
      "password": password,
    };

    final response = await _networkHandler
        .post('${AppConstants.baseURL}/login', data)
        .timeout(const Duration(seconds: 19));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final output = json.decode(response.body);
      final token = output["access_token"] as String;

      await _secureStorage.write(key: "token", value: token);
      // await _dbHelper.insertToken(token);

      final decodedToken = json.decode(utf8.decode(
        base64Url.decode(base64Url.normalize(token.split(".")[1])),
      ));

      final user = User.fromMap(decodedToken);

      // bool userExists = await _dbHelper.userExists(username);
      //
      // if (!userExists) {
      //   await _dbHelper.insertUser1(
      //     username: username,
      //     password: password,
      //     userId: user.userId,
      //     clientId: user.clientId,
      //     role: user.role,
      //     branches: user.branches,
      //   );
      // }

      // await _syncAccountTypes();

      return user;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> _syncAccountTypes() async {
    final accountTypesResponse =
        await _networkHandler.get('/api/v1/account-types');
    if (accountTypesResponse is List<dynamic>) {
      int localCount = await _dbHelper.getAccountTypeCount();
      int incomingCount = accountTypesResponse.length;

      if (localCount < incomingCount) {
        await _dbHelper.clearAccountTypesTable();
        final typesToSave = accountTypesResponse.map((e) {
          return {
            "id": e["id"].toString(),
            "name": e["name"] ?? "",
            "description": e["description"] ?? "",
            "category": e["category"] ?? "",
            "bankingType": e["bankingType"] ?? "",
            "origin": e["origin"] ?? "",
            "minAge": e["minAge"].toString(),
            "maxAge": e["maxAge"].toString(),
            "minBalance": e["minBalance"].toString(),
          };
        }).toList();

        await _dbHelper.insertAccountTypes(typesToSave);
      }
    }
  }

  Future<User?> get currentUser async {
    final token = await _secureStorage.read(key: 'token');
    if (token == null) {
      return null;
    }
    final decodedToken = json.decode(utf8.decode(
      base64Url.decode(base64Url.normalize(token.split(".")[1])),
    ));

    return User.fromMap(decodedToken);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'token');
  }
}
