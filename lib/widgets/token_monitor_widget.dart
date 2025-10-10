import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../main.dart';

/// Widget that monitors token expiration and handles automatic logout
/// Add this widget to your main app screens to enable token monitoring
class TokenMonitorWidget extends StatefulWidget {
  final Widget child;
  
  const TokenMonitorWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<TokenMonitorWidget> createState() => _TokenMonitorWidgetState();
}

class _TokenMonitorWidgetState extends State<TokenMonitorWidget>
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize token monitoring when widget is created
    _initializeTokenMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground, check token immediately
        _checkTokenOnResume();
        break;
      case AppLifecycleState.paused:
        // App going to background
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        TokenService.stopTokenMonitoring();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeTokenMonitoring() async {
    // Initialize the token service
    await TokenService.initialize(context);
  }

  Future<void> _checkTokenOnResume() async {
    // Check token validity when app resumes
    final isValid = await TokenService.isTokenValid();
    if (!isValid) {
      // Token is invalid, force logout using global navigator if this context is unavailable
      final context = navigatorKey.currentContext;
      if (context != null) {
        await TokenService.forceLogoutWithContext(context);
      } else if (mounted) {
        await TokenService.forceLogoutWithContext(this.context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 