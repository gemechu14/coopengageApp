# Troubleshooting Guide - Embedded WebView Fayda Authentication

## Common Issues and Solutions

### 1. WebView Not Loading

**Problem**: WebView shows blank screen or loading indefinitely

**Solutions**:
```dart
// Check if webview_flutter dependency is added
dependencies:
  webview_flutter: ^4.4.2
```

**Android**: Add internet permission in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS**: Ensure network requests are allowed in `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 2. Callback Not Detected

**Problem**: WebView doesn't automatically detect callback URL

**Check**:
```dart
// Ensure these patterns are in your callback URL:
- Contains '/callback'
- Contains 'code='
- Contains 'state='

// Debug callback detection:
void _handleCallback(String url) {
  print('URL detected: $url'); // Add this for debugging
  final uri = Uri.parse(url);
  print('Code: ${uri.queryParameters['code']}');
  print('State: ${uri.queryParameters['state']}');
}
```

### 3. WebSocket Connection Failed

**Problem**: Cannot connect to WebSocket

**Solutions**:
```dart
// Verify WebSocket URL is accessible
const wsUrl = "ws://10.8.100.111:9062/ws/fayda";

// Test connection manually:
void testWebSocket() async {
  try {
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    print('WebSocket connected');
    channel.sink.close();
  } catch (e) {
    print('WebSocket error: $e');
  }
}
```

### 4. API Endpoint Not Responding

**Problem**: HTTP requests to API fail

**Check**:
```dart
// Verify base URL is correct
const baseUrl = 'http://10.8.100.111:9062/';

// Test API endpoint:
void testApi() async {
  final url = '${baseUrl}api/v1/fayda/authenticate-url-ws?clientId=12344';
  try {
    final response = await http.get(Uri.parse(url));
    print('API Status: ${response.statusCode}');
    print('API Response: ${response.body}');
  } catch (e) {
    print('API Error: $e');
  }
}
```

### 5. State Not Updating

**Problem**: Riverpod state not reflecting changes

**Solutions**:
```dart
// Ensure ConsumerWidget is used:
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(faydaProvider); // ✅ Correct
    // ... rest of code
  }
}

// NOT StatefulWidget with Consumer:
class MyWidget extends StatefulWidget { // ❌ Wrong approach
  // This won't react to state changes properly
}
```

### 6. JavaScript Disabled

**Problem**: WebView not executing JavaScript properly

**Solution**:
```dart
// Ensure JavaScript is enabled:
_webViewController = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted) // ✅ Important
```

## Debugging Tips

### 1. Enable Debug Logging

Add this to see all state changes:
```dart
class FaydaNotifier extends StateNotifier<NationalIdState> {
  @override
  set state(NationalIdState newState) {
    print('State change: ${state.runtimeType} -> ${newState.runtimeType}');
    print('Loading: ${newState.isLoading}');
    print('Connected: ${newState.isConnected}');
    print('Error: ${newState.error}');
    super.state = newState;
  }
}
```

### 2. Test Individual Steps

Test each step independently:
```dart
// Test WebSocket only
final service = FaydaService();
await service.connectAndRegister();

// Test API only
final url = await service.getAuthUrl(baseUrl);
print('Auth URL: $url');

// Test callback processing
await service.processCallback(baseUrl, 'test_code', 'test_state');
```

### 3. Mock Services for Testing

Create mock service for testing:
```dart
class MockFaydaService extends FaydaService {
  @override
  Future<void> connectAndRegister() async {
    await Future.delayed(Duration(seconds: 1));
    // Simulate success
  }
  
  @override
  Future<String> getAuthUrl(String baseUrl) async {
    return 'https://test-auth-url.com';
  }
}
```

## Performance Tips

### 1. WebView Optimization

```dart
// Pre-initialize WebView for faster loading
@override
void initState() {
  super.initState();
  _initializeWebView();
  // Pre-warm WebView
  _webViewController?.loadRequest(Uri.parse('about:blank'));
}
```

### 2. Memory Management

```dart
@override
void dispose() {
  _webViewController = null; // Clean up controller
  super.dispose();
}
```

## Network Issues

### 1. Proxy/Firewall

If behind corporate firewall:
```dart
// Add proxy settings if needed
// This depends on your network configuration
```

### 2. SSL Certificate Issues

For development with self-signed certificates:
```dart
// Android: Add network security config
// iOS: Add exception in Info.plist
```

## Platform-Specific Issues

### Android
- Ensure `minSdkVersion` is at least 21 in `android/app/build.gradle`
- Add required permissions in AndroidManifest.xml

### iOS
- Update iOS deployment target to 12.0 or higher
- Add required permissions in Info.plist

## Contact & Support

If issues persist:
1. Check the console for detailed error messages
2. Test on different devices/simulators
3. Verify network connectivity
4. Test individual components separately

## Quick Health Check

Run this diagnostic function:
```dart
Future<void> diagnosticCheck() async {
  print('=== Fayda Auth Diagnostic ===');
  
  // 1. Test WebSocket
  try {
    final ws = WebSocketChannel.connect(Uri.parse('ws://10.8.100.111:9062/ws/fayda'));
    print('✅ WebSocket: Connection OK');
    ws.sink.close();
  } catch (e) {
    print('❌ WebSocket: $e');
  }
  
  // 2. Test API
  try {
    final response = await http.get(Uri.parse('http://10.8.100.111:9062/api/v1/fayda/authenticate-url-ws?clientId=12344'));
    print('✅ API: Status ${response.statusCode}');
  } catch (e) {
    print('❌ API: $e');
  }
  
  // 3. Test Provider
  try {
    final container = ProviderContainer();
    final provider = container.read(faydaProvider);
    print('✅ Provider: Initialized');
  } catch (e) {
    print('❌ Provider: $e');
  }
  
  print('=== End Diagnostic ===');
} 