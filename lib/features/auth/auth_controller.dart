import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/features/auth/data/auth_repository.dart';
import 'package:coopengageplus/models/user.dart';

import 'auth_state.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthInitial()) {
    _init();
  }

  final Ref _ref;

  void _init() async {
    final user = await _ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      state = Authenticated(user);
    } else {
      state = const Unauthenticated();
    }
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).logout();
    state = const Unauthenticated();
  }

  void onLoginSuccess(User user) {
    state = Authenticated(user);
  }
} 