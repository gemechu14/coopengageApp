import 'dart:async';
import 'dart:io';
import 'package:coopengageplus/customerOnboarding/NewIndividualNationalIdentification/providers/stepper_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/simple_national_id_provider.dart';
import '../model/national_id_models.dart';

/// A widget that handles ultra-simple national ID authentication
/// using WebView and WebSocket connections.
class UltraSimpleNationalIdWidget extends ConsumerStatefulWidget {
  const UltraSimpleNationalIdWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<UltraSimpleNationalIdWidget> createState() =>
      _UltraSimpleNationalIdWidgetState();
}

class _UltraSimpleNationalIdWidgetState
    extends ConsumerState<UltraSimpleNationalIdWidget> {
  
  // Constants
  static const Duration _checkInterval = Duration(seconds: 2);
  static const Duration _webViewTimeout = Duration(minutes: 3);
  static const Duration _webSocketTimeout = Duration(minutes: 10);
  static const Duration _initializationDelay = Duration(milliseconds: 500);

  // State variables
  bool _showWebView = false;
  bool _showUserData = false;
  bool _callbackDetected = false;
  bool _isWebViewLoading = true;
  String? _webViewError;
  DateTime? _webViewStartTime;
  
  // Controllers and timers
  WebViewController? _webViewController;
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    _initializeWidget();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  // ========== INITIALIZATION METHODS ==========

  /// Initializes the widget and determines the appropriate flow
  void _initializeWidget() {
    _initializeWebViewController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _determineInitialFlow());
  }

  /// Initializes the WebView controller with proper delegates
  void _initializeWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(_createNavigationDelegate());
  }

  /// Creates navigation delegate for WebView
  NavigationDelegate _createNavigationDelegate() {
    return NavigationDelegate(
      onPageStarted: _handleWebViewPageStarted,
      onPageFinished: _handleWebViewPageFinished,
      onWebResourceError: _handleWebViewError,
    );
  }

  /// Determines the initial flow based on current state
  void _determineInitialFlow() {
    final stepperState = ref.read(stepperProvider);
    final currentState = ref.read(simpleNationalIdProvider);

    final bool hasCompletedData = currentState.isCompleted && currentState.userData != null;
    final bool isFreshVisit = _isFreshVisit(stepperState);
    final bool hasStepperData = _hasStepperData(stepperState);

    _logInitialState(stepperState, currentState, hasCompletedData, isFreshVisit, hasStepperData);

    if (isFreshVisit) {
      _handleFreshVisit();
    } else if (hasCompletedData) {
      _handleCompletedDataVisit();
    } else if (hasStepperData && !hasCompletedData) {
      _handleStepperDataRestore(stepperState);
    } else {
      _handlePartialStateReset();
    }
  }

  /// Checks if this is a fresh visit
  bool _isFreshVisit(StepperState stepperState) {
    return stepperState.authId == null &&
           stepperState.fullName == null &&
           stepperState.email == null;
  }

  /// Checks if stepper has data
  bool _hasStepperData(StepperState stepperState) {
    return stepperState.authId != null ||
           stepperState.fullName != null ||
           stepperState.email != null;
  }

  /// Logs the initial state for debugging
  void _logInitialState(
    StepperState stepperState,
    NationalIdState currentState,
    bool hasCompletedData,
    bool isFreshVisit,
    bool hasStepperData,
  ) {
    debugPrint('🔍 [Widget] Initial State Analysis:');
    debugPrint('   - Stepper: authId=${stepperState.authId}, fullName=${stepperState.fullName}, email=${stepperState.email}');
    debugPrint('   - Current: isCompleted=${currentState.isCompleted}, hasUserData=${currentState.userData != null}');
    debugPrint('   - Flags: hasStepperData=$hasStepperData, hasCompletedData=$hasCompletedData, isFreshVisit=$isFreshVisit');
  }

  // ========== FLOW HANDLERS ==========

  /// Handles fresh visit scenario
  void _handleFreshVisit() {
    debugPrint('🔄 [Widget] Fresh visit detected - starting fresh authentication');
    _resetAuthenticationState();
    _scheduleAuthenticationStart();
  }

  /// Handles visit with completed data
  void _handleCompletedDataVisit() {
    debugPrint('✅ [Widget] Completed data detected - preserving existing state');
    setState(() => _callbackDetected = true);
  }

  /// Handles stepper data restoration
  void _handleStepperDataRestore(StepperState stepperState) {
    debugPrint('🔄 [Widget] Restoring from stepper data');
    _restoreAuthenticationFromStepper(stepperState);
    setState(() => _callbackDetected = true);
  }

  /// Handles partial state reset
  void _handlePartialStateReset() {
    debugPrint('🚀 [Widget] Partial state detected - resetting and starting fresh');
    _resetAuthenticationState();
    _scheduleAuthenticationStart();
  }

  /// Resets authentication state
  void _resetAuthenticationState() {
    ref.read(simpleNationalIdProvider.notifier).reset();
    setState(() => _callbackDetected = false);
  }

  /// Schedules authentication start with delay
  void _scheduleAuthenticationStart() {
    Future.delayed(_initializationDelay, () {
      if (mounted) _startAuthentication();
    });
  }

  // ========== AUTHENTICATION METHODS ==========

  /// Starts the authentication process
  void _startAuthentication() {
    debugPrint('🚀 [Widget] Starting authentication process');
    ref.read(simpleNationalIdProvider.notifier).startAuthentication();
    _startStatusMonitoring();
  }

  /// Starts periodic status monitoring
  void _startStatusMonitoring() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(_checkInterval, (_) => _checkAuthenticationStatus());
  }

  /// Stops status monitoring
  void _stopStatusMonitoring() {
    _statusCheckTimer?.cancel();
    debugPrint('🛑 [Widget] Status monitoring stopped');
  }

  /// Restarts the authentication process
  void _restartAuthentication() {
    debugPrint('🔄 [Widget] Restarting authentication process');
    _stopStatusMonitoring();
    _resetAuthenticationState();
    Future.delayed(_initializationDelay, () {
      if (mounted) _startAuthentication();
    });
  }

  // ========== STATUS MONITORING ==========

  /// Checks the current authentication status
  void _checkAuthenticationStatus() {
    final state = ref.read(simpleNationalIdProvider);
    _logCurrentStatus(state);

    // Handle WebView timeout
    if (_shouldCloseWebViewDueToTimeout()) {
      _handleWebViewTimeout();
      return;
    }

    // Handle WebSocket disconnection
    if (_shouldCloseWebViewDueToDisconnection(state)) {
      _handleWebSocketDisconnection();
      return;
    }

    // Handle successful completion
    if (_shouldHandleCompletion(state)) {
      _handleAuthenticationCompletion(state);
      return;
    }

    // Handle errors
    if (_shouldHandleError(state)) {
      _handleAuthenticationError(state);
      return;
    }

    // Continue monitoring if authentication is in progress
    if (!state.isCompleted && state.error == null) {
      // Keep monitoring
      return;
    }

    // Stop monitoring if authentication is finished
    _stopStatusMonitoring();
  }

  /// Logs current status for debugging
  void _logCurrentStatus(NationalIdState state) {
    debugPrint('🔍 [Status Check] Current state:');
    debugPrint('   - Connected: ${state.isConnected}');
    debugPrint('   - Registered: ${state.isRegistered}');
    debugPrint('   - Loading: ${state.isLoading}');
    debugPrint('   - Completed: ${state.isCompleted}');
    debugPrint('   - Has Auth URL: ${state.authUrl != null}');
    debugPrint('   - Has Error: ${state.error != null}');
    debugPrint('   - WebView Showing: $_showWebView');
    
    if (_webViewStartTime != null && _showWebView) {
      final elapsed = DateTime.now().difference(_webViewStartTime!);
      debugPrint('   - WebView Duration: ${elapsed.inSeconds}s');
    }
  }

  // ========== STATUS CHECK CONDITIONS ==========

  /// Checks if WebView should be closed due to timeout
  bool _shouldCloseWebViewDueToTimeout() {
    return _webViewStartTime != null &&
           _showWebView &&
           DateTime.now().difference(_webViewStartTime!) >= _webViewTimeout;
  }

  /// Checks if WebView should be closed due to WebSocket disconnection
  bool _shouldCloseWebViewDueToDisconnection(NationalIdState state) {
    return !state.isConnected && _showWebView;
  }

  /// Checks if authentication completion should be handled
  bool _shouldHandleCompletion(NationalIdState state) {
    return state.isCompleted && state.userData != null;
  }

  /// Checks if error should be handled
  bool _shouldHandleError(NationalIdState state) {
    return state.error != null && !_isRecoverableError(state.error!);
  }

  /// Checks if an error is recoverable
  bool _isRecoverableError(String error) {
    return error.contains('WebSocket connection closed') ||
           error.contains('connection') ||
           error.contains('network');
  }

  // ========== EVENT HANDLERS ==========

  /// Handles WebView timeout
  void _handleWebViewTimeout() {
    debugPrint('⏰ [Widget] WebView timeout reached - closing WebView, keeping WebSocket alive');
    setState(() => _showWebView = false);
    _showTimeoutMessage();
  }

  /// Handles WebSocket disconnection
  void _handleWebSocketDisconnection() {
    debugPrint('🔌 [Widget] WebSocket disconnected - closing WebView');
    setState(() => _showWebView = false);
    _stopStatusMonitoring();
  }

  /// Handles authentication completion
  void _handleAuthenticationCompletion(NationalIdState state) {
    debugPrint('✅ [Widget] Authentication completed successfully');
    
    if (_showWebView) {
      setState(() => _showWebView = false);
    }
    
    _stopStatusMonitoring();
    _saveAuthenticationDataToStepper(state.userData!);
    _closeWebSocketConnection();
  }

  /// Handles authentication error
  void _handleAuthenticationError(NationalIdState state) {
    debugPrint('❌ [Widget] Authentication error: ${state.error}');
    
    if (_showWebView) {
      setState(() => _showWebView = false);
    }
    
    _stopStatusMonitoring();
    _closeWebSocketConnection();
  }

  // ========== WEBVIEW HANDLERS ==========

  /// Handles WebView page start
  void _handleWebViewPageStarted(String url) {
    debugPrint('🌐 [WebView] Page loading started: $url');
    setState(() {
      _isWebViewLoading = true;
      _webViewError = null;
    });
  }

  /// Handles WebView page finish
  void _handleWebViewPageFinished(String url) {
    debugPrint('✅ [WebView] Page loading finished: $url');
    setState(() => _isWebViewLoading = false);
  }

  /// Handles WebView error
  void _handleWebViewError(WebResourceError error) {
    debugPrint('❌ [WebView] Error loading page: ${error.description}');
    setState(() {
      _isWebViewLoading = false;
      _webViewError = 'Unable to load authentication page. Please check your internet connection and try again.';
    });
  }

  /// Shows WebView if conditions are met
  void _showWebViewIfReady(NationalIdState state) {
    if (_shouldShowWebView(state)) {
      _logWebViewShowConditions(state);
      WidgetsBinding.instance.addPostFrameCallback((_) => _displayWebView(state));
    }
  }

  /// Checks if WebView should be shown
  bool _shouldShowWebView(NationalIdState state) {
    return state.authUrl != null &&
           state.isConnected &&
           !state.isCompleted &&
           state.error == null &&
           !_showWebView;
  }

  /// Logs WebView show conditions
  void _logWebViewShowConditions(NationalIdState state) {
    debugPrint('🌐 [Widget] Showing WebView - conditions met:');
    debugPrint('   - Has Auth URL: ${state.authUrl != null}');
    debugPrint('   - Is Connected: ${state.isConnected}');
    debugPrint('   - Not Completed: ${!state.isCompleted}');
    debugPrint('   - No Error: ${state.error == null}');
    debugPrint('   - WebView Hidden: ${!_showWebView}');
  }

  /// Displays the WebView
  void _displayWebView(NationalIdState state) {
    setState(() {
      _showWebView = true;
      _isWebViewLoading = true;
      _webViewError = null;
      _webViewStartTime = DateTime.now();
    });
    
    debugPrint('🌐 [Widget] Loading WebView with URL: ${state.authUrl}');
    _webViewController?.loadRequest(Uri.parse(state.authUrl!));
  }

  // ========== DATA MANAGEMENT ==========

  /// Saves authentication data to stepper provider
  void _saveAuthenticationDataToStepper(FaydaUserData userData) {
    debugPrint('💾 [Widget] Saving authentication data to stepper');
    
    final stepperNotifier = ref.read(stepperProvider.notifier);
    final authId = _parseAuthId(userData.sub);
    
    stepperNotifier.updateAuthId(authId);
    stepperNotifier.updateFullName(userData.name);
    stepperNotifier.updateEmail(userData.email);
    
    debugPrint('💾 [Widget] Data saved - Auth ID: $authId, Name: ${userData.name}, Email: ${userData.email}');
  }

  /// Parses auth ID from string
  int? _parseAuthId(String sub) {
    try {
      return int.tryParse(sub);
    } catch (e) {
      debugPrint('⚠️ [Widget] Could not parse auth ID: $sub');
      return null;
    }
  }

  /// Restores authentication data from stepper
  void _restoreAuthenticationFromStepper(StepperState stepperState) {
    debugPrint('🔄 [Widget] Restoring authentication data from stepper');
    
    final userData = _createUserDataFromStepper(stepperState);
    ref.read(simpleNationalIdProvider.notifier).restoreUserData(userData);
    
    debugPrint('🔄 [Widget] Data restored - Auth ID: ${stepperState.authId}, Name: ${stepperState.fullName}, Email: ${stepperState.email}');
  }

  /// Creates user data from stepper state
  FaydaUserData _createUserDataFromStepper(StepperState stepperState) {
    return FaydaUserData(
      sub: stepperState.authId?.toString() ?? '',
      name: stepperState.fullName ?? '',
      email: stepperState.email ?? '',
      phoneNumber: stepperState.authPhone,
      birthdate: stepperState.dateOfBirth,
      gender: stepperState.sex,
      address: null,
      picture: null,
    );
  }

  // ========== UTILITY METHODS ==========

  /// Shows timeout message to user
  void _showTimeoutMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication page closed. Please wait for the result...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Closes WebSocket connection
  void _closeWebSocketConnection() {
    ref.read(simpleNationalIdProvider.notifier).closeWebSocket();
  }

  /// Cleans up resources
  void _cleanup() {
    _statusCheckTimer?.cancel();
  }

  /// Gets appropriate loading message
  String _getLoadingMessage(NationalIdState state) {
    if (state.isCompleted && state.userData != null) return '';
    if (state.isConnected && state.authUrl != null) return '';
    if (state.isRegistered) return 'Getting authentication URL...';
    if (state.isConnected) return 'Registering client...';
    return 'Connecting to authentication service...';
  }

  // ========== BUILD METHODS ==========

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(simpleNationalIdProvider);
    
    // Listen for authentication completion and close WebView
    ref.listen(simpleNationalIdProvider, (previous, next) {
      // Close WebView immediately when authentication completes
      if (next.isCompleted && next.userData != null) {
        debugPrint('🎉 [Widget] Authentication completed - FORCE closing WebView');
        debugPrint('   - isCompleted: ${next.isCompleted}');
        debugPrint('   - hasUserData: ${next.userData != null}');
        debugPrint('   - showWebView: $_showWebView');
        
        if (_showWebView) {
          setState(() {
            _showWebView = false;
            debugPrint('✅ [Widget] WebView closed successfully');
          });
        }
        _stopStatusMonitoring();
      }
    });
    
    // ADDITIONAL: Force close WebView if authentication is completed
    if (state.isCompleted && state.userData != null && _showWebView) {
      debugPrint('🔄 [Widget] Force closing WebView in build method');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _showWebView) {
          setState(() {
            _showWebView = false;
            debugPrint('✅ [Widget] WebView force closed in post frame callback');
          });
        }
      });
    }
    
    // DEBUG: Print state changes
    debugPrint('🔍 [Widget] Build - isCompleted: ${state.isCompleted}, hasData: ${state.userData != null}, showWebView: $_showWebView');
    
    _showWebViewIfReady(state);
    
    return Padding(
      padding: const EdgeInsets.all(0),
      child: _showWebView ? _buildWebViewContainer() : _buildMainContent(state),
    );
  }

  /// Builds the WebView container
  Widget _buildWebViewContainer() {
    return Card(
      child: Column(
        children: [
          _buildWebViewHeader(),
          Expanded(child: _buildWebViewContent()),
        ],
      ),
    );
  }

  /// Builds WebView header
  Widget _buildWebViewHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Complete your National ID authentication',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          _buildCloseButton(),
          const SizedBox(width: 8),
          _buildRetryButton(),
        ],
      ),
    );
  }

  /// Builds close button
  Widget _buildCloseButton() {
    return IconButton(
      onPressed: () {
        debugPrint('❌ [Widget] Manual close requested');
        setState(() {
          _showWebView = false;
        });
        _stopStatusMonitoring();
      },
      icon: const Icon(Icons.close, color: Colors.red),
      tooltip: 'Close Authentication',
    );
  }

  /// Builds retry button
  Widget _buildRetryButton() {
    return IconButton(
      onPressed: () {
        debugPrint('🔄 [Widget] Manual retry requested');
        setState(() {
          _showWebView = false;
          _webViewError = null;
          _isWebViewLoading = true;
        });
        _restartAuthentication();
      },
      icon: const Icon(Icons.refresh, color: Colors.blue),
      tooltip: 'Retry Authentication',
    );
  }

  /// Builds WebView content with overlays
  Widget _buildWebViewContent() {
    return Stack(
      children: [
        // WebView
        _webViewController != null
            ? WebViewWidget(controller: _webViewController!)
            : const Center(child: CircularProgressIndicator()),
        
        // Loading overlay
        if (_isWebViewLoading) _buildLoadingOverlay(),
        
        // Error overlay
        if (_webViewError != null) _buildErrorOverlay(),
      ],
    );
  }

  /// Builds loading overlay
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue, strokeWidth: 4),
            SizedBox(height: 16),
            Text(
              'Loading authentication page...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds error overlay
  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade600),
              const SizedBox(height: 16),
              const Text(
                'Connection Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                _webViewError!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _webViewError = null;
                    _isWebViewLoading = true;
                  });
                  _webViewController?.reload();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds main content when WebView is not shown
  Widget _buildMainContent(NationalIdState state) {
    if (_showUserData && state.userData != null) {
      return _buildUserDataView(state.userData!);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Loading state
          if (_shouldShowLoadingState(state)) ..._buildLoadingState(state),
          
          // WebSocket waiting state
          if (_shouldShowWaitingState(state)) ..._buildWaitingState(),
          
          // Success state
          if (_shouldShowSuccessState(state)) ..._buildSuccessState(state),
          
          // Error state
          if (_shouldShowErrorState(state)) ..._buildErrorState(state),
        ],
      ),
    );
  }

  /// Checks if loading state should be shown
  bool _shouldShowLoadingState(NationalIdState state) {
    return state.isLoading ||
           (!state.isCompleted && state.error == null && !state.isConnected);
  }

  /// Checks if waiting state should be shown
  bool _shouldShowWaitingState(NationalIdState state) {
    return !_showWebView &&
           state.isConnected &&
           !state.isCompleted &&
           state.error == null &&
           state.authUrl != null;
  }

  /// Checks if success state should be shown
  bool _shouldShowSuccessState(NationalIdState state) {
    return state.isCompleted && state.userData != null;
  }

  /// Checks if error state should be shown
  bool _shouldShowErrorState(NationalIdState state) {
    return state.error != null;
  }

  /// Builds loading state widgets
  List<Widget> _buildLoadingState(NationalIdState state) {
    return [
      const CircularProgressIndicator(color: Colors.blue, strokeWidth: 4),
      const SizedBox(height: 24),
      Text(
        _getLoadingMessage(state),
        style: const TextStyle(fontSize: 16, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    ];
  }

  /// Builds waiting state widgets
  List<Widget> _buildWaitingState() {
    return [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200, width: 2),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(color: Colors.blue, strokeWidth: 4),
            const SizedBox(height: 16),
            const Text(
              'Waiting for Authentication Result',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text(
              'The authentication page has been closed, but we are still waiting for the result from the server. Please wait...',
              style: TextStyle(color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _restartAuthentication,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Restart Authentication'),
            ),
          ],
        ),
      ),
    ];
  }

  /// Builds success state widgets
  List<Widget> _buildSuccessState(NationalIdState state) {
    return [
      Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'VERIFIED',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text(
              'National ID authentication successful',
              style: TextStyle(fontSize: 16, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() => _showUserData = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              icon: const Icon(Icons.person),
              label: const Text('View Data'),
            ),
          ],
        ),
      ),
    ];
  }

  /// Builds error state widgets
  List<Widget> _buildErrorState(NationalIdState state) {
    return [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200, width: 2),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade600),
            const SizedBox(height: 16),
            const Text(
              'Authentication Failed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ];
  }

  /// Builds user data view
  Widget _buildUserDataView(FaydaUserData userData) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserDataHeader(),
          const SizedBox(height: 16),
          if (userData.picture != null && userData.picture!.isNotEmpty) 
            _buildUserPicture(userData.picture!),
          _buildPersonalInformationCard(userData),
          if (userData.address != null) _buildAddressInformationCard(userData.address!),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Builds user data header
  Widget _buildUserDataHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() => _showUserData = false),
          icon: const Icon(Icons.arrow_back),
        ),
        const Text(
          'Authentication Data',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Builds user picture
  Widget _buildUserPicture(String picturePath) {
    return Column(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(picturePath),
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Builds personal information card
  Widget _buildPersonalInformationCard(FaydaUserData userData) {
    return _buildDataCard('Personal Information', [
      _buildDataRow('Full Name', userData.name),
      _buildDataRow('Email', userData.email),
      if (userData.phoneNumber != null) _buildDataRow('Phone Number', userData.phoneNumber!),
      if (userData.birthdate != null) _buildDataRow('Birth Date', userData.birthdate!),
      if (userData.gender != null) _buildDataRow('Gender', userData.gender!),
    ]);
  }

  /// Builds address information card
  Widget _buildAddressInformationCard(FaydaAddress address) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildDataCard('Address Information', [
          if (address.country != null) _buildDataRow('Country', address.country!),
          if (address.region != null) _buildDataRow('Region', address.region!),
          if (address.woreda != null) _buildDataRow('Woreda', address.woreda!),
          if (address.zone != null) _buildDataRow('Zone', address.zone!),
        ]),
      ],
    );
  }

  /// Builds a data card with title and children
  Widget _buildDataCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Builds a data row with label and value
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
