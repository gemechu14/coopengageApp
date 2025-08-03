import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/fayda_provider.dart';
import '../providers/stepper_provider.dart';
import '../model/national_id_models.dart';

class NationalIdAuthWidget extends ConsumerStatefulWidget {
  const NationalIdAuthWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<NationalIdAuthWidget> createState() =>
      _NationalIdAuthWidgetState();
}

class _NationalIdAuthWidgetState extends ConsumerState<NationalIdAuthWidget> {
  bool _authStarted = false;
  bool _showWebView = false;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Check if this is a callback URL and handle immediately
            if (_isCallbackUrl(request.url)) {
              _handleCallbackImmediately(request.url);
              return NavigationDecision.prevent; // Stop navigation immediately
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            // Double-check on page start
            if (_isCallbackUrl(url)) {
              _handleCallbackImmediately(url);
            }
          },
          onUrlChange: (UrlChange change) {
            // Triple-check on URL change
            if (change.url != null && _isCallbackUrl(change.url!)) {
              _handleCallbackImmediately(change.url!);
            }
          },
        ),
      );
  }

  bool _isCallbackUrl(String url) {
    return url.contains('/callback') || 
           url.contains('code=') || 
           url.contains('state=');
  }

  void _handleCallbackImmediately(String url) {
    if (!mounted) return;
    
    print('🎯 [Widget] CALLBACK DETECTED IMMEDIATELY!');
    print('🎯 [Widget] URL: $url');
    print('🎯 [Widget] Widget mounted: $mounted');
    print('🎯 [Widget] WebView showing: $_showWebView');
    print('🎯 [Widget] Provider WebSocket connected: ${ref.read(faydaProvider.notifier).isWebSocketConnected}');
    
    // Extract code and state from callback URL
    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];
    
    print('🎯 [Widget] Extracted code: $code');
    print('🎯 [Widget] Extracted state: $state');
    
    if (code != null && state != null) {
      print('✅ [Widget] Code and state found - processing callback');
      print('🎯 [Widget] WebSocket status before callback: ${ref.read(faydaProvider.notifier).isWebSocketConnected}');
      
      // IMMEDIATELY hide WebView and prevent further navigation
      setState(() => _showWebView = false);
      print('🎯 [Widget] WebView hidden immediately');
      
      // Process the callback API call
      const baseUrl = 'http://10.8.100.111:9062/';
      print('🎯 [Widget] Calling processCallback with baseUrl: $baseUrl');
      print('🎯 [Widget] WebSocket status before processCallback: ${ref.read(faydaProvider.notifier).isWebSocketConnected}');
      
      ref.read(faydaProvider.notifier).processCallback(baseUrl, code, state);
      print('🎯 [Widget] processCallback called');
      
      // Show loading indicator while processing
      setState(() => _authStarted = true);
      print('🎯 [Widget] Auth started state set to true');
    } else {
      print('❌ [Widget] Code or state missing - callback not processed');
      print('❌ [Widget] Code: $code, State: $state');
    }
  }

  void _handleCallback(String url) {
    // This method is kept for backwards compatibility but main handling is in _handleCallbackImmediately
    _handleCallbackImmediately(url);
  }

  @override
  Widget build(BuildContext context) {
    final faydaState = ref.watch(faydaProvider);
    final faydaNotifier = ref.read(faydaProvider.notifier);

    // Auto-advance stepper when authentication is completed
    if (faydaState.isCompleted && faydaState.userData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Show brief success message before advancing
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication successful! Welcome ${faydaState.userData!.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Advance to next step
          ref.read(stepperProvider.notifier).nextStep();
        }
      });
    }

    // Hide WebView immediately if authentication is completed or if there's an error
    if ((faydaState.isCompleted || faydaState.error != null) && _showWebView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _showWebView = false);
        }
      });
    }

    // Auto-show WebView when auth URL is available (only if not completed and no error)
    if (faydaState.authUrl != null && 
        !faydaState.isCompleted && 
        faydaState.error == null &&
        !_showWebView && 
        _authStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _showWebView = true);
          _webViewController?.loadRequest(Uri.parse(faydaState.authUrl!));
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'National ID Authentication',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Status display
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatusRow('Connected', faydaState.isConnected),
                  _buildStatusRow('Registered', faydaState.isRegistered),
                  _buildStatusRow('WebSocket Open', ref.read(faydaProvider.notifier).isWebSocketConnected),
                  _buildStatusRow('Callback Processed', faydaState.authUrl != null && !faydaState.isLoading),
                  _buildStatusRow('Completed', faydaState.isCompleted),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Main content area
          Expanded(
            child: _showWebView && faydaState.authUrl != null && !faydaState.isCompleted
                ? _buildWebView()
                : _buildAuthContent(faydaState, faydaNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return Card(
      child: Column(
        children: [
          // WebView header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: Colors.blue),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Complete your National ID authentication',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() => _showWebView = false);
                    ref.read(faydaProvider.notifier).reset();
                    setState(() => _authStarted = false);
                  },
                ),
              ],
            ),
          ),
          
          // WebView content
          Expanded(
            child: _webViewController != null
                ? WebViewWidget(controller: _webViewController!)
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthContent(NationalIdState faydaState, FaydaNotifier faydaNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main action buttons
        if (!_authStarted) ...[
          ElevatedButton(
            onPressed: faydaState.isLoading
                ? null
                : () => _startAuthentication(faydaNotifier),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: faydaState.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Start National ID Authentication',
                    style: TextStyle(fontSize: 16)),
          ),
        ],
        

        
        // Processing indicator after callback is detected
        if (_authStarted && 
            faydaState.authUrl != null && 
            !_showWebView && 
            !faydaState.isCompleted && 
            faydaState.isLoading) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Processing authentication...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait while we verify your National ID information.',
                  style: TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ),
        ],
        
        // Show ready message only if not loading and WebView is not shown
        if (_authStarted && 
            faydaState.authUrl != null && 
            !_showWebView && 
            !faydaState.isCompleted && 
            !faydaState.isLoading) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.info, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ready to authenticate!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(() => _showWebView = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Complete Authentication'),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Error display with smart retry options
        if (faydaState.error != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Error occurred',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  faydaState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Show retry callback button if WebSocket is still open and it's a callback error
                    if (ref.read(faydaProvider.notifier).isWebSocketConnected &&
                        faydaState.error!.contains('Callback API failed')) ...[
                      ElevatedButton(
                        onPressed: () => _retryCallback(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry Callback'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Always show restart option
                    ElevatedButton(
                      onPressed: () => _retryAuthentication(faydaNotifier),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Restart Authentication'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        
        // Success display
        if (faydaState.userData != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Authentication Successful!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildUserInfoRow('Name', faydaState.userData!.name),
                _buildUserInfoRow('Email', faydaState.userData!.email),
                if (faydaState.userData!.phoneNumber != null)
                  _buildUserInfoRow(
                      'Phone', faydaState.userData!.phoneNumber!),
                if (faydaState.userData!.birthdate != null)
                  _buildUserInfoRow(
                      'Birth Date', faydaState.userData!.birthdate!),
                if (faydaState.userData!.gender != null)
                  _buildUserInfoRow('Gender', faydaState.userData!.gender!),
              ],
            ),
          ),
        ],
        
        const Spacer(),
        
        // Reset button
        if (_authStarted) ...[
          ElevatedButton(
            onPressed: () => _retryAuthentication(faydaNotifier),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('Start Over'),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusRow(String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isActive ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _startAuthentication(FaydaNotifier notifier) {
    print('🚀 [Widget] Starting authentication...');
    print('🚀 [Widget] Setting authStarted to true');
    setState(() => _authStarted = true);
    
    const baseUrl = 'http://10.8.100.111:9062/';
    print('🚀 [Widget] Base URL: $baseUrl');
    print('🚀 [Widget] Calling notifier.startAuthentication');
    
    notifier.startAuthentication(baseUrl);
    print('🚀 [Widget] startAuthentication called');
  }

  void _retryCallback() {
    // Extract code and state from the last callback URL
    // For simplicity, we'll prompt the user to re-complete authentication
    // In a real app, you might store the code and state to retry
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please complete the authentication again to retry the callback.'),
        backgroundColor: Colors.orange,
      ),
    );
    
    // Show WebView again for user to re-authenticate
    setState(() => _showWebView = true);
  }

  void _retryAuthentication(FaydaNotifier notifier) {
    setState(() {
      _authStarted = false;
      _showWebView = false;
    });
    notifier.reset();
  }
}
