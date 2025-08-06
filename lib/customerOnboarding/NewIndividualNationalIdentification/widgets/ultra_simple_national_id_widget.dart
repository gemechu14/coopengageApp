import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/simple_national_id_provider.dart';
import '../model/national_id_models.dart';

class UltraSimpleNationalIdWidget extends ConsumerStatefulWidget {
  const UltraSimpleNationalIdWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<UltraSimpleNationalIdWidget> createState() => _UltraSimpleNationalIdWidgetState();
}

class _UltraSimpleNationalIdWidgetState extends ConsumerState<UltraSimpleNationalIdWidget> {
  bool _showWebView = false;
  WebViewController? _webViewController;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _startAuthentication();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  void _startAuthentication() {
    // Start authentication
    ref.read(simpleNationalIdProvider.notifier).startAuthentication();
    
    // Start checking WebSocket status every 2 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkWebSocketStatus();
    });
  }

  void _checkWebSocketStatus() {
    final state = ref.read(simpleNationalIdProvider);
    
    // If WebSocket is not connected, close WebView
    if (!state.isConnected && _showWebView) {
      print('🔌 WebSocket closed - closing WebView');
      setState(() => _showWebView = false);
      _checkTimer?.cancel();
    }
    
    // If authentication completed, close WebView
    if (state.isCompleted && _showWebView) {
      print('✅ Authentication completed - closing WebView');
      setState(() => _showWebView = false);
      _checkTimer?.cancel();
    }
    
    // If error occurred, close WebView
    if (state.error != null && _showWebView) {
      print('❌ Error occurred - closing WebView');
      setState(() => _showWebView = false);
      _checkTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(simpleNationalIdProvider);

    // Show WebView only if WebSocket is connected and we have auth URL
    if (state.authUrl != null && 
        state.isConnected && 
        !state.isCompleted && 
        state.error == null && 
        !_showWebView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _showWebView = true);
        _webViewController?.loadRequest(Uri.parse(state.authUrl!));
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('National ID Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showWebView ? _buildWebView() : _buildMainContent(state),
      ),
    );
  }

  Widget _buildWebView() {
    return Card(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Text(
              'Complete your National ID authentication',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          // WebView
          Expanded(
            child: _webViewController != null
                ? WebViewWidget(controller: _webViewController!)
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(NationalIdState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading state
          if (state.isLoading) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_getLoadingMessage(state)),
          ],

          // Success state
          if (state.isCompleted && state.userData != null) ...[
            const Icon(Icons.verified_user, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'VERIFIED',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text('Welcome, ${state.userData!.name}!'),
            const SizedBox(height: 16),
            _buildUserDataCard(state.userData!),
          ],

          // Error state
          if (state.error != null) ...[
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Authentication Failed', style: TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(simpleNationalIdProvider.notifier).reset();
                _startAuthentication();
              },
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserDataCard(FaydaUserData userData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${userData.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (userData.phoneNumber != null) Text('Phone: ${userData.phoneNumber}'),
            if (userData.birthdate != null) Text('Birthdate: ${userData.birthdate}'),
            if (userData.gender != null) Text('Gender: ${userData.gender}'),
            if (userData.address != null) ...[
              Text('Address: ${userData.address!.country}, ${userData.address!.region}'),
            ],
          ],
        ),
      ),
    );
  }

  String _getLoadingMessage(NationalIdState state) {
    if (state.isRegistered) return 'Getting authentication URL...';
    if (state.isConnected) return 'Registering client...';
    return 'Connecting to authentication service...';
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
} 