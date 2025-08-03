// Example usage of the embedded WebView Fayda authentication
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/national_id_auth_widget.dart';

class EmbeddedWebViewExample extends StatelessWidget {
  const EmbeddedWebViewExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Embedded Fayda Auth',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('National ID Authentication'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: const NationalIdAuthWidget(),
        ),
      ),
    );
  }
}

/*
EMBEDDED WEBVIEW FEATURES:

✅ Authentication URL embedded in the app (no external browser)
✅ Automatic callback detection and processing
✅ Clean UI with status indicators
✅ WebView header with close button
✅ Automatic state management
✅ Error handling and retry functionality
✅ User data display after successful authentication
✅ Auto-advance to next step in stepper flow

FLOW SUMMARY:
1. User taps "Start National ID Authentication"
2. WebSocket connects and registers client
3. Authentication URL is fetched
4. WebView opens automatically with the auth URL
5. User completes authentication in embedded WebView
6. Callback is detected automatically
7. WebView closes and shows success with user data
8. Automatically advances to next step in stepper

CONFIGURATION:
- Base URL is set to 'http://10.8.100.111:9062/' (as updated by user)
- WebSocket URL: 'ws://10.8.100.111:9062/ws/fayda'
- Client ID: '12344'
- All URLs and parameters follow your exact specifications

WEBVIEW BENEFITS:
- Keeps user within your app
- Better user experience (no app switching)
- Automatic callback handling
- Branded experience with custom header
- Better security (no external browser redirects)
- Responsive design that works on all screen sizes
*/ 