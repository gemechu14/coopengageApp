import 'package:coopengageplus/models/user.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthLoading extends AuthState {
  const AuthLoading();
} 