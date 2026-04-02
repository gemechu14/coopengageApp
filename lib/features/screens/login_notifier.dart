import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coopengageplus/core/network/network_handler.dart';
import 'package:coopengageplus/shared/services/session_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
        _emitError('No internet connection. Please check your network.');
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
        .timeout(const Duration(seconds: 19));

    if (response.statusCode != 200 && response.statusCode != 201) {
      _emitError('Invalid Username or Password.');
      return;
    }

    final output = json.decode(response.body);
    final token = output['access_token'] as String;
    await _storage.write(key: 'token', value: token);

    SessionManager.instance.startSession();

    state = state.copyWith(isLoading: false, shouldNavigate: true);
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
