// import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/fayda_provider.dart';
import '../providers/stepper_provider.dart';
import '../model/national_id_models.dart';
import 'dart:async'; // Added for Timer

class NationalIdAuthWidget extends ConsumerStatefulWidget {
  const NationalIdAuthWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<NationalIdAuthWidget> createState() =>
      _NationalIdAuthWidgetState();
}

class _NationalIdAuthWidgetState extends ConsumerState<NationalIdAuthWidget> {
  bool _showWebView = false;
  bool _showUserData = false;
  bool _isWebViewLoading = false; // Track WebView loading state
  bool _callbackDetected = false; // Track if callback was already detected
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();

    // Check if this is a fresh page visit vs step navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stepperState = ref.read(stepperProvider);
      final currentFaydaState = ref.read(faydaProvider);

      // Fresh visit: No stepper auth data exists (new session)
      bool isFreshVisit = (stepperState.authId == null &&
          stepperState.fullName == null &&
          stepperState.email == null);

      if (isFreshVisit) {
        print(
            '🔄 [Widget] Fresh page visit detected - clearing data and starting fresh');
        ref.read(faydaProvider.notifier).reset();
        setState(() {
          _callbackDetected = false; // Reset callback flag for fresh start
        });
        // Small delay to ensure reset is complete, then auto-start
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _startAuthentication();
          }
        });
      } else if (currentFaydaState.isCompleted &&
          currentFaydaState.userData != null) {
        print(
            '✅ [Widget] Step navigation detected - keeping existing Fayda data');
        // Keep existing data (user navigated back from next step)
        setState(() {
          _callbackDetected = true; // Mark as completed to prevent WebView restart
        });
      } else {
        print(
            '🚀 [Widget] Step navigation but no Fayda data - starting authentication');
        // In step flow but no Fayda data, start authentication
        ref.read(faydaProvider.notifier).reset();
        setState(() {
          _callbackDetected = false; // Reset callback flag
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _startAuthentication();
          }
        });
      }
    });
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (_isCallbackUrl(request.url)) {
              _handleCallbackImmediately(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            setState(() => _isWebViewLoading = true);
            if (_isCallbackUrl(url)) {
              _handleCallbackImmediately(url);
            }
          },
          onPageFinished: (String url) {
            setState(() => _isWebViewLoading = false);
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null && _isCallbackUrl(change.url!)) {
              _handleCallbackImmediately(change.url!);
            }
          },
        ),
      );
  }

  bool _isCallbackUrl(String url) {
    // Simple callback detection - just look for callback URLs with code and state
    return (url.contains('callback') && url.contains('code=') && url.contains('state=')) ||
           (url.contains('code=') && url.contains('state='));
  }

  void _handleCallbackImmediately(String url) {
    if (!mounted) return;

    print('🎯 [Widget] CALLBACK DETECTED IMMEDIATELY!');
    print('🎯 [Widget] URL: $url');

    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];

    if (code != null && state != null) {
      print('✅ [Widget] Code and state found - closing WebView and waiting for WebSocket');
      print('🔍 [Widget] Extracted code: $code');
      print('🔍 [Widget] Extracted state: $state');

      // Check WebSocket connection status
      final faydaState = ref.read(faydaProvider);
      print('🔍 [Widget] Current Fayda provider state: isConnected=${faydaState.isConnected}, isCompleted=${faydaState.isCompleted}');
      print('🔍 [Widget] WebSocket connection status: ${ref.read(faydaProvider.notifier).isWebSocketConnected}');

      // IMMEDIATELY hide WebView and mark callback as detected
      setState(() {
        _showWebView = false;
        _callbackDetected = true; // Prevent WebView from restarting
      });

      print('⏳ [Widget] WebView closed, waiting for WebSocket authentication result...');
      print('🚫 [Widget] WebView restart prevented - callback detected');
      print('⏳ [Widget] Now waiting for server to process callback and send authentication_result via WebSocket...');
      
      // Log a periodic check to see if we're still waiting
      _startWaitingTimer();
    }
  }
  
  Timer? _waitingTimer;
  
  void _startWaitingTimer() {
    _waitingTimer?.cancel();
    int waitingSeconds = 0;
    
    _waitingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      waitingSeconds += 5;
      final faydaState = ref.read(faydaProvider);
      
      print('⏰ [Widget] Still waiting for WebSocket result... ${waitingSeconds}s elapsed');
      print('🔍 [Widget] Current state: isCompleted=${faydaState.isCompleted}, error=${faydaState.error}');
      print('🔍 [Widget] WebSocket connected: ${ref.read(faydaProvider.notifier).isWebSocketConnected}');
      
      if (faydaState.isCompleted || faydaState.error != null) {
        print('✅ [Widget] Authentication completed or error occurred, stopping timer');
        timer.cancel();
      } else if (waitingSeconds >= 60) {
        print('⚠️ [Widget] Waited 60 seconds for WebSocket result - this seems too long');
        print('⚠️ [Widget] Consider checking server-side callback processing');
        timer.cancel();
      }
    });
  }
  
  @override
  void dispose() {
    _waitingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faydaState = ref.watch(faydaProvider);

    // Removed auto-advance - user can manually proceed when ready

    // Hide WebView if authentication is completed or error
    if ((faydaState.isCompleted || faydaState.error != null) && _showWebView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _showWebView = false);
        }
      });
    }

    // Auto-show WebView when auth URL is available
    if (faydaState.authUrl != null &&
        !faydaState.isCompleted &&
        faydaState.error == null &&
        !_showWebView &&
        !_callbackDetected) { // Only show if not already shown and no callback detected
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showWebView = true;
            _isWebViewLoading = true; // Start with loading state
          });
          _webViewController?.loadRequest(Uri.parse(faydaState.authUrl!));
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _showWebView &&
                    faydaState.authUrl != null &&
                    !faydaState.isCompleted
                ? _buildWebView()
                : _buildMainContent(faydaState),
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
            child: const Row(
              children: [
                Icon(Icons.security, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Complete your National ID authentication',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // WebView content
          Expanded(
            child: _webViewController != null
                ? Stack(
                    children: [
                      WebViewWidget(controller: _webViewController!),
                      // Loading overlay
                      if (_isWebViewLoading)
                        Container(
                          color: Colors.white,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Colors.blue,
                                  strokeWidth: 4,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Loading authentication page...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.blue,
                          strokeWidth: 4,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Initializing WebView...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(NationalIdState faydaState) {
    // Show user data if requested
    if (_showUserData && faydaState.userData != null) {
      return _buildUserDataView(faydaState.userData!);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Loading state (auto-started)
          if (faydaState.isLoading ||
              (!faydaState.isCompleted && faydaState.error == null)) ...[
            const CircularProgressIndicator(
              color: Colors.blue,
              strokeWidth: 4,
            ),
            const SizedBox(height: 24),
            Text(
              _getLoadingMessage(faydaState),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Success state - Verified
          if (faydaState.isCompleted && faydaState.userData != null) ...[
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white, // White background
                borderRadius: BorderRadius.circular(16), // Rounded corners
                // No border
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user,
                    size: 80,
                    color: Colors.blue, // Icon in blue
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'VERIFIED',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // Text in blue
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'National ID authentication successful',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue, // Text in blue
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // View Data button
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showUserData = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button blue
                      foregroundColor: Colors.white, // Icon and text white
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.person),
                    label: const Text('View Data'),
                  ),
                ],
              ),
            )
          ],

          // Error state
          if (faydaState.error != null) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.shade600,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Authentication Failed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    faydaState.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _retryAuthentication(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry Authentication'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserDataView(FaydaUserData userData) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Row(
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
          ),

          const SizedBox(height: 16),

          // User data cards
          _buildDataCard('Personal Information', [
            _buildDataRow('Full Name', userData.name),
            _buildDataRow('Email', userData.email),
            if (userData.phoneNumber != null)
              _buildDataRow('Phone Number', userData.phoneNumber!),
            if (userData.birthdate != null)
              _buildDataRow('Birth Date', userData.birthdate!),
            if (userData.gender != null)
              _buildDataRow('Gender', userData.gender!),
          ]),

          if (userData.address != null) ...[
            const SizedBox(height: 16),
            _buildDataCard('Address Information', [
              if (userData.address!.country != null)
                _buildDataRow('Country', userData.address!.country!),
              if (userData.address!.region != null)
                _buildDataRow('Region', userData.address!.region!),
            ]),
          ],

          const SizedBox(height: 24),

          // Continue button
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: () => setState(() => _showUserData = false),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.blue,
          //       foregroundColor: Colors.white,
          //       padding: const EdgeInsets.symmetric(vertical: 16),
          //     ),
          //     child: const Text('Continue', style: TextStyle(fontSize: 16)),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
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

  String _getLoadingMessage(NationalIdState state) {
    if (state.isLoading && state.authUrl != null) {
      return 'Processing authentication...';
    } else if (state.isRegistered) {
      return 'Preparing authentication...';
    } else if (state.isConnected) {
      return 'Registering client...';
    } else {
      return 'Connecting to authentication service...';
    }
  }

  void _startAuthentication() {
    print('🚀 [Widget] Auto-starting authentication...');
    // const baseUrl = 'http://10.8.100.111:9062/';
    const baseUrl = AppConstants.baseURL;
    ref.read(faydaProvider.notifier).startAuthentication(baseUrl);
  }

  void _retryAuthentication() {
    setState(() {
      _showUserData = false;
      _callbackDetected = false; // Reset callback detection flag
    });
    ref.read(faydaProvider.notifier).reset();
    // Auto-start again after reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAuthentication();
    });
  }
}
