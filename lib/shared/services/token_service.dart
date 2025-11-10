import 'dart:async';
import 'package:coopengageplus/features/screens/LoginScreen.dart';
import 'package:coopengageplus/main.dart';
import 'package:coopengageplus/shared/services/GlobalData.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart';

class TokenService {
  static Timer? _tokenCheckTimer;
  static const Duration _checkInterval =
      Duration(minutes: 1); // Check every minute
  static final GlobalData _globalData = GlobalData();

  /// Start monitoring token expiration
  static void startTokenMonitoring() {
    // Cancel any existing timer
    stopTokenMonitoring();

    // Start new timer
    _tokenCheckTimer = Timer.periodic(_checkInterval, (timer) {
      _checkTokenExpiration();
    });

    // Also check immediately
    _checkTokenExpiration();
  }

  /// Stop monitoring token expiration
  static void stopTokenMonitoring() {
    _tokenCheckTimer?.cancel();
    _tokenCheckTimer = null;
  }

  /// Check if current token is expired and logout if needed
  static Future<void> _checkTokenExpiration() async {
    try {
      final token = await _globalData.storage.read(key: "token");

      if (token == null || token.isEmpty) {
        // No token found, user should be logged out
        await _performLogout();
        return;
      }

      // Check if token is expired
      if (JwtDecoder.isExpired(token)) {
        print("Token expired, logging out user automatically");
        await _performLogout();
        return;
      }

      // Check if token will expire soon (within 5 minutes)
      final timeToExpiry = JwtDecoder.getRemainingTime(token);
      if (timeToExpiry.inMinutes <= 5) {
        print("Token will expire in ${timeToExpiry.inMinutes} minutes");
        // You can show a warning notification here if needed
        // _showTokenExpirationWarning();
      }
    } catch (e) {
      print("Error checking token expiration: $e");
      // If there's an error decoding the token, it's likely invalid
      await _performLogout();
    }
  }

  /// Perform logout and navigate to login screen
  static Future<void> _performLogout() async {
    try {
      // Clear all stored data
      await _globalData.storage.delete(key: "token");
      await _globalData.storage.delete(key: "username");
      await _globalData.storage.delete(key: "role");
      await _globalData.storage.delete(key: "userId");

      // Clear any other app-specific data
      await _clearAppData();

      // Stop token monitoring
      stopTokenMonitoring();

      // Navigate to login screen using global navigator
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Loginscreen()),
          (Route<dynamic> route) => false,
        );

        // Show logout message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.orange,
            duration: Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e) {
      print("Error during automatic logout: $e");
    }
  }

  /// Clear app-specific data on logout
  static Future<void> _clearAppData() async {
    // Add any additional cleanup here
    // For example, clear cached data, reset providers, etc.
    try {
      // Clear any cached user data
      _globalData.username = null;
      _globalData.firstLetter = null;
      _globalData.role = null;
      _globalData.userId = null;
      GlobalData.UserId = null;

      // You can add more cleanup here as needed
      // For example: clear any Riverpod providers, cached data, etc.
    } catch (e) {
      print("Error clearing app data: $e");
    }
  }

  /// Show warning when token is about to expire
  // static void _showTokenExpirationWarning() {
  //   // For now, just print a warning.
  //   // You can implement UI notification when you have access to context
  //   print("Warning: Token will expire soon!");
  // }

  // /// Handle token refresh (implement based on your API)
  // static Future<void> _handleTokenRefresh() async {
  //   try {
  //     // Implement token refresh logic here
  //     // This would typically involve calling your API's refresh endpoint
  //     print("Token refresh requested - implement based on your API");

  //     // Example implementation:
  //     // final refreshToken = await _globalData.storage.read(key: "refreshToken");
  //     // if (refreshToken != null) {
  //     //   final response = await NetworkHandler().post('/auth/refresh', {
  //     //     'refreshToken': refreshToken
  //     //   });
  //     //   if (response.statusCode == 200) {
  //     //     final data = jsonDecode(response.body);
  //     //     await _globalData.storage.write(key: "token", value: data['token']);
  //     //     print("Token refreshed successfully");
  //     //   }
  //     // }
  //   } catch (e) {
  //     print("Error refreshing token: $e");

  //   }
  // }

  /// Manually check if current token is valid
  static Future<bool> isTokenValid() async {
    try {
      final token = await _globalData.storage.read(key: "token");

      if (token == null || token.isEmpty) {
        return false;
      }

      return !JwtDecoder.isExpired(token);
    } catch (e) {
      print("Error checking token validity: $e");
      return false;
    }
  }

  /// Get remaining time until token expires
  static Future<Duration?> getTokenRemainingTime() async {
    try {
      final token = await _globalData.storage.read(key: "token");

      if (token == null || token.isEmpty) {
        return null;
      }

      if (JwtDecoder.isExpired(token)) {
        return Duration.zero;
      }

      return JwtDecoder.getRemainingTime(token);
    } catch (e) {
      print("Error getting token remaining time: $e");
      return null;
    }
  }

  /// Initialize token service (call this when app starts and user is logged in)
  static Future<void> initialize(BuildContext context) async {
    final isValid = await isTokenValid();
    if (isValid) {
      startTokenMonitoring();
      print("Token service initialized and monitoring started");
    } else {
      //  await forceLogoutWithContext(context);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Loginscreen()),
        (Route<dynamic> route) => false,
      );

      print("No valid token found, token monitoring not started");
    }
  }

  /// Force logout with context (call this from UI when you have context available)
  static Future<void> forceLogoutWithContext(BuildContext context) async {
    await _performLogout();

    // Navigate to login screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Loginscreen()),
      (Route<dynamic> route) => false,
    );

    // Show logout message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expired. Please login again.'),
        backgroundColor: Colors.orange,
        duration: Duration(milliseconds: 300),
      ),
    );
  }

  /// Show token expiration warning with context
  static void showTokenExpirationWarningWithContext(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child:
                  Text('Your session will expire soon. Please save your work.'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(milliseconds: 300),
        // action: SnackBarAction(
        //   label: 'Refresh',
        //   textColor: Colors.white,
        //   onPressed: () {
        //     // You can implement token refresh logic here if your API supports it
        //     _handleTokenRefresh();
        //   },
        // ),
      ),
    );
  }
}
