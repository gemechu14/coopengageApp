// Example of how to integrate TokenService into your app

import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../widgets/token_monitor_widget.dart';

/// Example of how to use TokenService and TokenMonitorWidget

class ExampleMainScreen extends StatelessWidget {
  const ExampleMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TokenMonitorWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Main Screen'),
          actions: [
            // Manual token check button
            IconButton(
              icon: const Icon(Icons.security),
              onPressed: () => _showTokenInfo(context),
            ),
            // Manual logout button
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _manualLogout(context),
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Your main app content goes here'),
              SizedBox(height: 20),
              Text('Token monitoring is active in the background'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTokenInfo(BuildContext context) async {
    final isValid = await TokenService.isTokenValid();
    final remainingTime = await TokenService.getTokenRemainingTime();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Token Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Token Valid: ${isValid ? "Yes" : "No"}'),
            if (remainingTime != null)
              Text('Time Remaining: ${_formatDuration(remainingTime)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _manualLogout(BuildContext context) async {
    await TokenService.forceLogoutWithContext(context);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

/// Example of how to integrate into your app's main widget
class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Token Service Example',
      home: TokenMonitorWidget(
        child: const ExampleMainScreen(),
      ),
    );
  }
}

/// Example of how to initialize token service when user logs in
class LoginExample {
  static Future<void> handleSuccessfulLogin() async {
    // After successful login and token storage...
    
    // Initialize token monitoring
    await TokenService.initialize();
    
    print("Login successful, token monitoring started");
  }
}

/// Example of how to manually check token in specific screens
class ExampleRegistrationScreen extends StatefulWidget {
  const ExampleRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<ExampleRegistrationScreen> createState() => _ExampleRegistrationScreenState();
}

class _ExampleRegistrationScreenState extends State<ExampleRegistrationScreen> {
  
  @override
  void initState() {
    super.initState();
    _checkTokenBeforeProceeding();
  }

  Future<void> _checkTokenBeforeProceeding() async {
    // Check token before allowing user to proceed with registration
    final isValid = await TokenService.isTokenValid();
    if (!isValid && mounted) {
      // Token is invalid, redirect to login
      await TokenService.forceLogoutWithContext(context);
      return;
    }

    // Check if token will expire soon
    final remainingTime = await TokenService.getTokenRemainingTime();
    if (remainingTime != null && remainingTime.inMinutes <= 10 && mounted) {
      // Show warning that token will expire soon
      // TokenService.showTokenExpirationWarningWithContext(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: const Center(
        child: Text('Registration form goes here'),
      ),
    );
  }
}

/*
INTEGRATION STEPS:

1. Add TokenMonitorWidget to your main screens:
   - Wrap your main content with TokenMonitorWidget
   - This will automatically start token monitoring

2. Initialize token service after login:
   - Call TokenService.initialize() after successful login
   - This starts the background monitoring

3. Manual token checks (optional):
   - Use TokenService.isTokenValid() to check token manually
   - Use TokenService.getTokenRemainingTime() to get remaining time
   - Use TokenService.forceLogoutWithContext() for manual logout

4. Token expiration warnings:
   - Use TokenService.showTokenExpirationWarningWithContext() to show warnings
   - The service automatically prints warnings, but you can show UI notifications

5. Cleanup on app termination:
   - TokenService.stopTokenMonitoring() is called automatically
   - You can also call it manually when needed

FEATURES:

- Automatic token expiration checking every minute
- Automatic logout when token expires
- Warning notifications when token will expire soon (within 5 minutes)
- Manual token validation methods
- App lifecycle awareness (checks token when app resumes)
- Automatic cleanup of stored data on logout
- Context-aware navigation and notifications

CUSTOMIZATION:

- Modify _checkInterval in TokenService to change check frequency
- Customize warning time threshold (currently 5 minutes)
- Implement token refresh logic in _handleTokenRefresh()
- Add more cleanup logic in _clearAppData()
*/ 