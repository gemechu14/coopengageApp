import 'dart:async';

import 'package:coopengageplus/features/screens/LoginScreen.dart';
import 'package:coopengageplus/main.dart';
import 'package:coopengageplus/shared/services/GlobalData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Session manager that handles:
/// - JWT token expiry monitoring (periodic check every 30s)
/// - Automatic logout with navigation to login screen
/// - App lifecycle awareness (checks token on resume from background)
/// - HTTP 401 interception (auto-logout on unauthorized responses)
class SessionManager with WidgetsBindingObserver {
  SessionManager._();
  static final SessionManager _instance = SessionManager._();
  static SessionManager get instance => _instance;

  static const _tokenCheckInterval = Duration(seconds: 30);

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );

  Timer? _tokenCheckTimer;
  bool _isSessionActive = false;
  bool _isLoggingOut = false;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Call after successful login to start all session monitoring.
  void startSession() {
    if (_isSessionActive) return;
    _isSessionActive = true;
    _isLoggingOut = false;

    WidgetsBinding.instance.addObserver(this);
    _startTokenExpiryMonitor();
  }

  /// Call on explicit user logout.
  Future<void> endSession() async {
    if (!_isSessionActive) return;
    _isSessionActive = false;
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    await _clearSessionData();
  }

  /// Quick synchronous check — useful for guards.
  bool get isActive => _isSessionActive;

  /// Async token validity check.
  Future<bool> isSessionValid() async {
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) return false;
    return !JwtDecoder.isExpired(token);
  }

  // ---------------------------------------------------------------------------
  // App lifecycle
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isSessionActive) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        _checkTokenExpiration();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Token expiry monitoring
  // ---------------------------------------------------------------------------

  void _startTokenExpiryMonitor() {
    _tokenCheckTimer?.cancel();
    _tokenCheckTimer = Timer.periodic(_tokenCheckInterval, (_) {
      _checkTokenExpiration();
    });
    _checkTokenExpiration();
  }

  Future<void> _checkTokenExpiration() async {
    if (_isLoggingOut) return;
    try {
      final token = await _storage.read(key: 'token');
      if (token == null || token.isEmpty) {
        await _autoLogout(reason: 'No session token found.');
        return;
      }

      if (JwtDecoder.isExpired(token)) {
        await _autoLogout(reason: 'Your session has expired.');
        return;
      }
    } catch (e) {
      debugPrint('SessionManager: token check error — $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> _autoLogout({required String reason}) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    _isSessionActive = false;
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    await _clearSessionData();
    _navigateToLogin(reason);
  }

  /// Called by NetworkHandler when a 401 is received.
  Future<void> onUnauthorizedResponse() async {
    await _autoLogout(reason: 'Your session is no longer valid. Please log in again.');
  }

  void _navigateToLogin(String reason) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Loginscreen()),
      (route) => false,
    );

    _showSessionEndDialog(ctx, reason);
  }

  void _showSessionEndDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.lock_clock, color: Colors.orange, size: 48),
        title: const Text('Session Ended'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cleanup helpers
  // ---------------------------------------------------------------------------

  void _stopTimer() {
    _tokenCheckTimer?.cancel();
    _tokenCheckTimer = null;
  }

  Future<void> _clearSessionData() async {
    try {
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'username');
      await _storage.delete(key: 'role');
      await _storage.delete(key: 'userId');

      final gd = GlobalData();
      gd.username = null;
      gd.firstLetter = null;
      gd.role = null;
      gd.userId = null;
      GlobalData.UserId = null;
    } catch (e) {
      debugPrint('SessionManager: clear data error — $e');
    }
  }
}
