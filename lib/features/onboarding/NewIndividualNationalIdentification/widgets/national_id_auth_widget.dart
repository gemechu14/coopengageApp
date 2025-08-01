import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Core imports
import '../providers/national_id_provider.dart';
import '../providers/stepper_provider.dart';

// Component imports
import 'components/auth_states.dart';

// Service imports
import '../services/webview_service.dart';
import '../services/dialog_service.dart';
import '../services/api_service.dart';
import '../services/user_info_service.dart';
import '../services/websocket_service.dart';

// Widget imports
import 'user_info_display_widget.dart';

/// Improved National ID Authentication Widget
///
/// This widget handles the National ID authentication flow with:
/// - Clean separation of concerns
/// - Reusable components
/// - Proper error handling
/// - Better state management
class NationalIdAuthWidget extends ConsumerStatefulWidget {
  const NationalIdAuthWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<NationalIdAuthWidget> createState() =>
      _NationalIdAuthWidgetState();
}

class _NationalIdAuthWidgetState extends ConsumerState<NationalIdAuthWidget>
    with AutomaticKeepAliveClientMixin {
  // Private fields
  WebViewController? _webViewController;
  bool _isWebViewLoading = false;
  bool _dialogInProgress = false;

  // Constants
  static const double _containerHeight = 0.65;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAuthentication();
  }

  @override
  void dispose() {
    _cleanupWebView();
    super.dispose();
  }

  /// Initialize the authentication process with smart refresh logic
  void _initializeAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final nationalIdState = ref.read(nationalIdProvider);
      final stepperState = ref.read(stepperProvider);

      // Check if we already have completed authentication data
      final hasCompletedAuth = nationalIdState.isAuthCompleted ||
          (stepperState.authId != null && stepperState.fullName != null);

      if (hasCompletedAuth) {
        // If we have data, just mark as completed without refreshing
        debugPrint('Authentication already completed, skipping refresh');
        if (!nationalIdState.isAuthCompleted) {
          ref.read(nationalIdProvider.notifier).markAuthCompleted();
        }
      } else {
        // Only reset and call API if we don't have completed data
        debugPrint('No authentication data found, initializing fresh');
        ref.read(nationalIdProvider.notifier).reset();
        ref.read(nationalIdProvider.notifier).callEsignetApi();
      }
    });
  }

  /// Start WebSocket-based authentication
  Future<void> _startWebSocketAuth() async {
    if (!mounted) return;

    try {
      debugPrint('Starting WebSocket authentication...');
      
      // Show loading state
      ref.read(nationalIdProvider.notifier).setWebSocketMode(true);
      
      // Start WebSocket authentication
      final result = await WebSocketService.authenticate();
      
      if (!mounted) return;

      if (result != null) {
        // Save authentication data to stepper state
        ref.read(stepperProvider.notifier).saveAuthenticationData(result);
        
        // Mark authentication as completed
        ref.read(nationalIdProvider.notifier).markAuthCompleted();
        
        debugPrint('WebSocket authentication completed successfully');
      } else {
        throw Exception('WebSocket authentication returned null result');
      }
    } catch (e) {
      debugPrint('WebSocket authentication failed: $e');
      
      if (mounted) {
        _showVerificationErrorDialog(e.toString());
      }
    }
  }

  /// Clean up WebView resources
  Future<void> _cleanupWebView() async {
    if (_webViewController != null) {
      await WebViewService.clearWebViewData(_webViewController);
      _webViewController = null;
    }
  }

  /// Reset the WebView and restart authentication
  Future<void> _resetWebView() async {
    if (!mounted) return;

    try {
      await _cleanupWebView();
      ref.read(nationalIdProvider.notifier).reset();

      // Small delay to ensure cleanup is complete
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        ref.read(nationalIdProvider.notifier).callEsignetApi();
      }
    } catch (e) {
      debugPrint('Error resetting WebView: $e');
    }
  }

  /// Force refresh authentication (clears existing data)
  Future<void> _forceRefresh() async {
    if (!mounted) return;

    debugPrint('Force refreshing authentication...');

    try {
      // Clear all existing data
      await _cleanupWebView();
      ref.read(nationalIdProvider.notifier).reset();

      // Small delay to ensure cleanup is complete
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        ref.read(nationalIdProvider.notifier).callEsignetApi();
      }
    } catch (e) {
      debugPrint('Error force refreshing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!mounted) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, child) {
        final nationalIdState = ref.watch(nationalIdProvider);

        return SizedBox(
          height: MediaQuery.of(context).size.height * _containerHeight,
          child: _buildContent(nationalIdState),
        );
      },
    );
  }

  /// Build the main content based on current state
  Widget _buildContent(NationalIdState state) {
    final stepperState = ref.read(stepperProvider);

    // Check if we have completed authentication data (from either source)
    final hasCompletedAuth = state.isAuthCompleted ||
        (stepperState.authId != null && stepperState.fullName != null);

    // Show success state if completed
    if (hasCompletedAuth) {
      return _buildSuccessStateWithInfo();
    }

    // Show error state
    if (state.isError) {
      return _buildEnhancedErrorState(state);
    }

    // Show WebSocket authentication in progress
    if (state.useWebSocket && state.isLoading) {
      return _buildWebSocketLoadingState(state);
    }

    // Show WebView if auth URL is available (traditional mode)
    if (state.authUrl != null && state.authUrl!.isNotEmpty) {
      return _buildWebViewContainer(state.authUrl!);
    }

    // Show clean loading state only when actually loading
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 16),
            Text(
              'Connecting to National ID service...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Show authentication mode selection or fallback
    return _buildAuthenticationModeSelection(state);
  }

  /// Build WebView container with loading overlay
  Widget _buildWebViewContainer(String url) {
    return Stack(
      children: [
        _buildWebView(url),
        if (_isWebViewLoading) const WebViewLoadingOverlay(),
      ],
    );
  }

  /// Build the WebView widget
  Widget _buildWebView(String url) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: WebViewWidget(
          controller: _createWebViewController(url),
        ),
      ),
    );
  }

  /// Create and configure the WebView controller
  WebViewController _createWebViewController(String url) {
    if (_webViewController != null) {
      return _webViewController!;
    }

    _webViewController = WebViewService.createController(
      url: url,
      onNavigationRequest: _handleNavigationRequest,
      onPageStarted: () => _setWebViewLoading(true),
      onPageFinished: () => _setWebViewLoading(false),
      onWebResourceError: _handleWebResourceError,
    );

    return _webViewController!;
  }

  /// Handle navigation requests and detect callbacks
  void _handleNavigationRequest(String url) {
    debugPrint('Navigation request: $url');

    final callbackParams = WebViewService.extractCallbackParams(url);
    if (callbackParams != null) {
      _handleAuthCallback(
        callbackParams['code']!,
        callbackParams['state']!,
      );
    }
  }

  /// Handle authentication callback
  Future<void> _handleAuthCallback(String code, String state) async {
    if (!mounted || _dialogInProgress) return;

    debugPrint('Processing auth callback - Code: $code, State: $state');

    try {
      final responseData = await ref
          .read(nationalIdProvider.notifier)
          .verifyAccount(code, state);

      if (!mounted) return;

      if (responseData != null) {
        // Save authentication data to stepper state
        ref.read(stepperProvider.notifier).saveAuthenticationData(responseData);

        // Mark authentication as completed
        ref.read(nationalIdProvider.notifier).markAuthCompleted();

        _setWebViewLoading(false);

        debugPrint('Authentication completed successfully');
      }
    } catch (e) {
      debugPrint('Authentication failed: $e');

      if (mounted && !_dialogInProgress) {
        _showVerificationErrorDialog(e.toString());
      }
    }
  }

  /// Set WebView loading state
  void _setWebViewLoading(bool loading) {
    if (mounted && _isWebViewLoading != loading) {
      setState(() {
        _isWebViewLoading = loading;
      });
    }
  }

  /// Handle WebView resource errors
  void _handleWebResourceError(String errorDescription) {
    debugPrint('WebView resource error: $errorDescription');
  }

  /// Test API endpoint connectivity
  Future<void> _testApiEndpoint() async {
    if (!mounted) return;

    try {
      final result = await ApiService.testApiEndpoint();

      if (mounted) {
        await DialogService.showApiTestResultDialog(
          context: context,
          isSuccess: result.isSuccess,
          statusCode: result.statusCode,
          responseBody: result.responseBody,
        );
      }
    } catch (e) {
      if (mounted) {
        await DialogService.showErrorDialog(
          context: context,
          title: 'API Test Error',
          message: e.toString(),
        );
      }
    }
  }

  /// Build WebSocket loading state
  Widget _buildWebSocketLoadingState(NationalIdState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 16),
          const Text(
            'Establishing WebSocket connection...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (state.clientId != null)
            Text(
              'Client ID: ${state.clientId}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'Please wait while we connect to the authentication service...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build authentication mode selection
  Widget _buildAuthenticationModeSelection(NationalIdState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fingerprint,
            size: 64,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          const Text(
            'National ID Authentication',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
                     Text(
             'Current Method: ${state.useWebSocket ? "Primary" : "Alternative"}',
             style: const TextStyle(
               fontSize: 14,
               color: Colors.grey,
             ),
           ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                             ElevatedButton.icon(
                 onPressed: () {
                   ref.read(nationalIdProvider.notifier).setWebSocketMode(true);
                   ref.read(nationalIdProvider.notifier).callEsignetApi();
                 },
                 icon: const Icon(Icons.wifi),
                 label: const Text('Primary'),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: state.useWebSocket ? Colors.blue : Colors.grey,
                   foregroundColor: Colors.white,
                 ),
               ),
               ElevatedButton.icon(
                 onPressed: () {
                   ref.read(nationalIdProvider.notifier).setWebSocketMode(false);
                   ref.read(nationalIdProvider.notifier).callEsignetApi();
                 },
                 icon: const Icon(Icons.web),
                 label: const Text('Alternative'),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: state.useWebSocket ? Colors.grey : Colors.blue,
                   foregroundColor: Colors.white,
                 ),
               ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _testApiEndpoint,
            icon: const Icon(Icons.bug_report),
            label: const Text('Test API'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
                       ElevatedButton.icon(
               onPressed: () async {
                 final result = await ApiService.testWebSocketConnection();
                 if (mounted) {
                   await DialogService.showWebSocketTestResultDialog(
                     context: context,
                     result: result,
                   );
                 }
               },
               icon: const Icon(Icons.wifi_find),
               label: const Text('Test Connection'),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.purple,
                 foregroundColor: Colors.white,
               ),
             ),
        ],
      ),
    );
  }

  /// Show verification error dialog
  Future<void> _showVerificationErrorDialog(String errorMessage) async {
    if (!mounted || _dialogInProgress) return;

    _dialogInProgress = true;

    try {
      await DialogService.showVerificationErrorDialog(
        context: context,
        errorMessage: errorMessage,
        onRetry: () {
          ref.read(nationalIdProvider.notifier).reset();
          ref.read(nationalIdProvider.notifier).callEsignetApi();
        },
        onCancel: () {
          // Handle cancellation if needed
        },
      );
    } finally {
      _dialogInProgress = false;
    }
  }

  /// Build success state with user information viewing option
  Widget _buildSuccessStateWithInfo() {
    return Consumer(
      builder: (context, ref, child) {
        final stepperState = ref.watch(stepperProvider);
        final userInfo = UserInfoService.extractUserInfo(stepperState);
        final hasInfo = UserInfoService.hasMinimumInfo(userInfo);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified, color: Colors.blue, size: 80),
              const SizedBox(height: 2),
              const Text(
                'National ID Verified!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You have successfully completed National ID authentication.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (hasInfo) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton.icon(
                    onPressed: () => _showUserInformation(userInfo),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View My Information'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to see the information we received from your National ID',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                //  const SizedBox(height: 20),
                //  // Small refresh option
                //  TextButton.icon(
                //    onPressed: _forceRefresh,
                //    icon: const Icon(Icons.refresh, size: 16),
                //    label: const Text('Re-verify'),
                //    style: TextButton.styleFrom(
                //      foregroundColor: Colors.grey[600],
                //      textStyle: const TextStyle(fontSize: 12),
                //    ),
                //  ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Show user information in a bottom sheet
  Future<void> _showUserInformation(userInfo) async {
    if (!mounted) return;

    try {
      await UserInfoDisplayWidget.showUserInfo(context, userInfo);
    } catch (e) {
      debugPrint('Error showing user information: $e');
    }
  }

  /// Build enhanced error state with fallback options
  Widget _buildEnhancedErrorState(NationalIdState state) {
    final isWebSocketError = state.errorMessage?.contains('WebSocket') ?? false;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isWebSocketError ? Icons.wifi_off : Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
                         Text(
               isWebSocketError ? 'Connection Failed' : 'Authentication Error',
               style: const TextStyle(
                 fontSize: 18,
                 fontWeight: FontWeight.bold,
                 color: Colors.red,
               ),
             ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
                         if (isWebSocketError) ...[
               const Text(
                 'Connection failed. Please try again:',
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontSize: 14,
                   fontWeight: FontWeight.w500,
                 ),
               ),
               const SizedBox(height: 16),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                   ElevatedButton.icon(
                     onPressed: () {
                       ref.read(nationalIdProvider.notifier).setWebSocketMode(false);
                       ref.read(nationalIdProvider.notifier).callEsignetApi();
                     },
                     icon: const Icon(Icons.web),
                     label: const Text('Use Alternative'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.green,
                       foregroundColor: Colors.white,
                     ),
                   ),
                   ElevatedButton.icon(
                     onPressed: () {
                       ref.read(nationalIdProvider.notifier).callEsignetApi();
                     },
                     icon: const Icon(Icons.refresh),
                     label: const Text('Retry'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.blue,
                       foregroundColor: Colors.white,
                     ),
                   ),
                 ],
               ),
             ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ref.read(nationalIdProvider.notifier).callEsignetApi();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                  ElevatedButton(
                    onPressed: _forceRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reset All'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
                         TextButton.icon(
               onPressed: () {
                 ref.read(nationalIdProvider.notifier).toggleWebSocketMode();
                 setState(() {});
               },
               icon: const Icon(Icons.swap_horiz),
               label: Text(
                 'Switch to ${state.useWebSocket ? 'Alternative' : 'Primary'} Method',
               ),
             ),
          ],
        ),
      ),
    );
  }
}
