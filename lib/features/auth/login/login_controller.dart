import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coopengageplus/features/auth/auth_controller.dart';
// import 'package:coopengageplus/features/auth/auth_state.dart';
import 'package:coopengageplus/features/auth/data/auth_repository.dart';
import 'package:coopengageplus/features/auth/login/login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, LoginState>(
  (ref) => LoginController(ref),
);

class LoginController extends StateNotifier<LoginState> {
  LoginController(this._ref) : super(const LoginInitial());

  final Ref _ref;

  Future<void> login(String username, String password) async {
    state = const LoginLoading();
    try {
      if (await _isOnline()) {
        final user = await _ref
            .read(authRepositoryProvider)
            .login(username, password);
        _ref.read(authControllerProvider.notifier).onLoginSuccess(user);
        state = const LoginSuccess();
      } else {
        // OFFLINE LOGIN
        // bool isValid = await _ref.read(authRepositoryProvider).offlineLogin(loginData);
        // if (isValid) {
        //   state = const LoginSuccess();
        // } else {
        //   state = const LoginError("User Not Registered for Offline Usage");
        // }
        state = const LoginError("No internet connection");
      }
    } on TimeoutException {
      state = const LoginError("Request Timeout. Please try again.");
    } catch (e) {
      state = const LoginError("Invalid Username or Password.");
    }
  }

  Future<bool> _isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }
    return false;
  }
}
