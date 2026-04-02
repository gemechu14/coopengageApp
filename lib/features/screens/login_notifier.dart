import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coopengageplus/core/database/database_helper.dart';
import 'package:coopengageplus/core/network/network_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class LoginScreenState {
  final bool isLoading;
  final bool hidePassword;
  final String? errorMessage;
  final bool shouldNavigate;

  const LoginScreenState({
    this.isLoading = false,
    this.hidePassword = true,
    this.errorMessage,
    this.shouldNavigate = false,
  });

  LoginScreenState copyWith({
    bool? isLoading,
    bool? hidePassword,
    Object? errorMessage = _sentinel,
    bool? shouldNavigate,
  }) {
    return LoginScreenState(
      isLoading: isLoading ?? this.isLoading,
      hidePassword: hidePassword ?? this.hidePassword,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      shouldNavigate: shouldNavigate ?? this.shouldNavigate,
    );
  }

  static const _sentinel = Object();
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

final loginNotifierProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginScreenState>(
  (ref) => LoginNotifier(),
);

class LoginNotifier extends StateNotifier<LoginScreenState> {
  LoginNotifier() : super(const LoginScreenState());

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );
  final _dbHelper = DatabaseHelper();

  // -- UI actions -----------------------------------------------------------

  void togglePasswordVisibility() {
    state = state.copyWith(hidePassword: !state.hidePassword);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearNavigation() {
    state = state.copyWith(shouldNavigate: false);
  }

  // -- Login ----------------------------------------------------------------

  Future<void> login(String username, String password) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      shouldNavigate: false,
    );

    try {
      if (await _isOnline()) {
        await _onlineLogin(username, password);
      } else {
        await _offlineLogin(username, password);
      }
    } on TimeoutException {
      _emitError('Request timed out. Please try again.');
    } catch (e) {
      _emitError('Something went wrong. Please try again.');
    }
  }

  // -- Online login ---------------------------------------------------------

  Future<void> _onlineLogin(String username, String password) async {
    final networkHandler = NetworkHandler();
    final data = {'username': username, 'password': password};

    final response = await networkHandler
        .post('/login', data)
        .timeout(const Duration(seconds: 70));

    if (response.statusCode != 200 && response.statusCode != 201) {
      _emitError('Invalid Username or Password.');
      return;
    }

    final output = json.decode(response.body);
    final token = output['access_token'] as String;
    await _storage.write(key: 'token', value: token);

    final userDataStored =
        await _fetchAndStoreUserData(networkHandler, username, password, token);
    if (!userDataStored) return;

    await _fetchAndStoreAccountTypes(networkHandler);
    await _verifyDataIntegrity(token);
  }

  // -- Fetch user data with retry -------------------------------------------

  Future<bool> _fetchAndStoreUserData(
    NetworkHandler networkHandler,
    String username,
    String password,
    String token,
  ) async {
    const maxRetries = 3;

    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final userResponse = await networkHandler
            .get('/api/v1/users/me')
            .timeout(const Duration(seconds: 70));

        final userData = _parseUserResponse(userResponse);
        final userId = userData['userId'];
        if (userId == null) throw Exception('Missing user ID');

        final role = userData['role'] ?? '';
        final clientData = userData['client'] ?? {};
        final clientId = clientData['id']?.toString();
        if (clientId == null || clientId.isEmpty) {
          throw Exception('Missing client information');
        }

        final normalizedBranches = _normalizeBranches(userData['branches']);
        final mainBranch = _extractMainBranch(userData);

        await _dbHelper.clearBranchesForUser(userId);
        await _persistUser(
          username: username,
          password: password,
          userId: userId,
          token: token,
          role: role,
          clientId: clientId,
          userData: userData,
          clientData: clientData,
          normalizedBranches: normalizedBranches,
          mainBranch: mainBranch,
        );

        final verifyUser = await _dbHelper.getUserByToken(token);
        if (verifyUser != null && verifyUser['userId'] == userId) {
          return true;
        }
        throw Exception('Failed to verify user data storage');
      } catch (e) {
        if (attempt >= maxRetries) {
          _emitError(
              'Failed to load user data after $maxRetries attempts. Please try again.');
          return false;
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    return false;
  }

  Map<String, dynamic> _parseUserResponse(dynamic userResponse) {
    if (userResponse is http.Response) {
      if (userResponse.statusCode == 200) {
        return json.decode(userResponse.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to fetch user data. Status: ${userResponse.statusCode}');
    }
    if (userResponse is Map<String, dynamic>) return userResponse;
    if (userResponse != null) {
      return json.decode(userResponse.toString()) as Map<String, dynamic>;
    }
    throw Exception('Received null response from user data API');
  }

  List<Map<String, dynamic>> _normalizeBranches(dynamic branchesData) {
    if (branchesData is! List) return [];

    final branches = List<Map<String, dynamic>>.from(branchesData);
    return branches.map((b) {
      final fallbackName =
          b['name'] ?? b['branchName'] ?? b['companyName'] ?? 'Unknown Branch';
      return {
        'id': b['id'],
        'userId': b['userId'],
        'name': fallbackName,
        'branchName': b['branchName'] ?? fallbackName,
        'companyName': b['companyName'] ?? fallbackName,
        'branchCode': b['branchCode'] ?? '',
      };
    }).toList();
  }

  Map<String, dynamic> _extractMainBranch(Map<String, dynamic> userData) {
    final mainBranch = userData['mainBranch'] ?? {};
    return {
      'id': mainBranch['id'],
      'name': mainBranch['name'] ?? mainBranch['branchName'] ?? '',
      'code': mainBranch['branchCode'] ?? '',
    };
  }

  Future<void> _persistUser({
    required String username,
    required String password,
    required int userId,
    required String token,
    required String role,
    required String clientId,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> clientData,
    required List<Map<String, dynamic>> normalizedBranches,
    required Map<String, dynamic> mainBranch,
  }) async {
    final params = {
      'fullName': userData['fullName'] ?? '',
      'email': userData['email'] ?? '',
      'status': userData['status'] ?? '',
      'lastLoggedIn': userData['lastLoggedIn'] ?? '',
      'registeredAt': userData['registeredAt'] ?? '',
      'updatedAt': userData['updatedAt'] ?? '',
      'clientName': clientData['name'] ?? '',
      'clientDescription': clientData['description'] ?? '',
    };

    final userExists = await _dbHelper.userExists(username);
    await _dbHelper.insertToken(token);

    if (!userExists) {
      await _dbHelper.clearBranchesForUser(userId);
      await _dbHelper.insertUser1(
        username: username,
        password: password,
        userId: userId,
        clientId: clientId,
        token: token,
        role: role,
        branches: normalizedBranches,
        fullName: params['fullName'],
        email: params['email'],
        status: params['status'],
        lastLoggedIn: params['lastLoggedIn'],
        registeredAt: params['registeredAt'],
        updatedAt: params['updatedAt'],
        clientName: params['clientName'],
        clientDescription: params['clientDescription'],
        mainBranchId: mainBranch['id'],
        mainBranchName: mainBranch['name'],
        mainBranchCode: mainBranch['code'],
      );
    } else {
      await _dbHelper.updateUser(
        username: username,
        userId: userId,
        clientId: clientId,
        token: token,
        role: role,
        branches: normalizedBranches,
        fullName: params['fullName'],
        email: params['email'],
        status: params['status'],
        lastLoggedIn: params['lastLoggedIn'],
        registeredAt: params['registeredAt'],
        updatedAt: params['updatedAt'],
        clientName: params['clientName'],
        clientDescription: params['clientDescription'],
        mainBranchId: mainBranch['id'],
        mainBranchName: mainBranch['name'],
        mainBranchCode: mainBranch['code'],
      );
    }
  }

  // -- Fetch account types with retry ---------------------------------------

  Future<void> _fetchAndStoreAccountTypes(NetworkHandler networkHandler) async {
    const maxRetries = 3;

    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await networkHandler
            .get('/api/v1/account-types')
            .timeout(const Duration(seconds: 60));

        if (response is! List<dynamic>) {
          if (response == null) throw Exception('Null response');
          throw Exception('Response is not a valid list');
        }

        final validatedTypes = _validateAccountTypes(response);
        if (validatedTypes.isEmpty) return;

        final localCount = await _dbHelper.getAccountTypeCount();
        if (localCount < response.length || attempt == 1) {
          await _dbHelper.clearAccountTypesTable();
          await _dbHelper.insertAccountTypes(validatedTypes);
        }
        return;
      } catch (e) {
        if (attempt >= maxRetries) return;
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
  }

  List<Map<String, dynamic>> _validateAccountTypes(List<dynamic> raw) {
    return raw
        .whereType<Map<String, dynamic>>()
        .where((a) => a['id'] != null && a['name'] != null)
        .map((a) => {
              'id': a['id'].toString(),
              'name': a['name'].toString(),
              'description': a['description']?.toString() ?? '',
              'category': a['category']?.toString() ?? '',
              'bankingType': a['bankingType']?.toString() ?? '',
              'origin': a['origin']?.toString() ?? '',
              'minAge': a['minAge']?.toString() ?? '',
              'maxAge': a['maxAge']?.toString() ?? '',
              'minAmount': a['minAmount']?.toString() ?? '',
              'sex': a['sex']?.toString() ?? '',
              'status': a['status']?.toString() ?? '',
              'code': a['code']?.toString() ?? '',
            })
        .toList();
  }

  // -- Data integrity check -------------------------------------------------

  Future<void> _verifyDataIntegrity(String token) async {
    final storedToken = await _storage.read(key: 'token');
    if (storedToken != token) {
      _emitError('Security error: Token verification failed.');
      return;
    }

    final user = await _dbHelper.getUserByToken(token);
    if (user == null) {
      _emitError('Data integrity error: User data not accessible.');
      return;
    }

    state = state.copyWith(isLoading: false, shouldNavigate: true);
  }

  // -- Offline login --------------------------------------------------------

  Future<void> _offlineLogin(String username, String password) async {
    final userExists = await _dbHelper.userExists(username);
    if (!userExists) {
      _emitError('User is offline and not registered locally..');
      return;
    }

    try {
      final users =
          await _dbHelper.getUsers().timeout(const Duration(seconds: 4));
      final match = users
          .any((u) => u['username'] == username && u['password'] == password);

      if (match) {
        state = state.copyWith(isLoading: false, shouldNavigate: true);
      } else {
        _emitError('Invalid Username or Password.');
      }
    } on TimeoutException {
      _emitError('Timeout accessing local data.');
    } catch (_) {
      _emitError('Local login error');
    }
  }

  // -- Helpers --------------------------------------------------------------

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);
  }

  void _emitError(String message) {
    state = state.copyWith(isLoading: false, errorMessage: message);
  }
}
