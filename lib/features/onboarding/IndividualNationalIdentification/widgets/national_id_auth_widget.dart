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
      return AuthErrorState(
        state: state,
        onRetry: () => ref.read(nationalIdProvider.notifier).callEsignetApi(),
        onReset: _forceRefresh,
      );
    }

    // Show WebView if auth URL is available
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

    // Minimal fallback with retry options (only show if no loading and no URL)
    return AuthLoadingState(
      onRetry: _forceRefresh,
      onTestApi: _testApiEndpoint,
    );
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
              const SizedBox(height: 24),
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
}
