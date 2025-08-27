import 'dart:convert';
import 'dart:async';

import 'package:coopengageplus/constants/config/config.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:http/http.dart' as http;
import 'package:coopengageplus/constants/kconstant.dart';

import '../providers/stepper_provider.dart';
import '../providers/national_id_provider.dart';

class NationalIdAuthWidget extends ConsumerStatefulWidget {
  const NationalIdAuthWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<NationalIdAuthWidget> createState() =>
      _NationalIdAuthWidgetState();
}

class _NationalIdAuthWidgetState extends ConsumerState<NationalIdAuthWidget> {
  WebViewController? _webViewController;
  bool _disposed = false;
  bool _showingDialog = false;
  bool _isWebViewLoading = true;
  String? _expectedFinalUrl;
  int? _selectedMemberIndex; // <-- Add this line

  // WebSocket auth state
  static const String _wsUrl = AppConstants.webSocketUrl;

  //"ws://10.12.53.33:9062/ws/fayda";
  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  String? _clientId;
  String? _authUrl; // URL to load in WebView once received
  String? _errorMessage;
  bool _wsConnecting = false;
  bool _dialogShown = false; // Flag to prevent showing dialog multiple times

  @override
  void initState() {
    super.initState();
    _isWebViewLoading = false;
    _webViewController = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _webViewController?.clearCache();
    _webViewController?.clearLocalStorage();
    _closeWebSocket();
    super.dispose();
  }

  void _resetWebView() {
    if (_disposed) return;

    try {
      _authUrl = null;
      _errorMessage = null;
      _dialogShown = false;
      _wsConnecting = false;
      _clientId = null; // Reset client ID for fresh connection
      _closeWebSocket();
      if (_selectedMemberIndex != null) {
        // Restart WS auth for current member with fresh connection
        _startWsAuth();
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return const SizedBox.shrink();

    // Watch the national ID provider state for changes
    final nationalIdState = ref.watch(nationalIdProvider);

    return SingleChildScrollView(
      child: Container(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_disposed) return const SizedBox.shrink();

    // Show member list first if no member is selected
    if (_selectedMemberIndex == null) {
      final stepperState = ref.watch(stepperProvider);
      final members = stepperState.members;
      if (members.isEmpty) {
        return const Center(child: Text('No members found.'));
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return ListTile(
            leading: Icon(
              member.isVerified ? Icons.verified : Icons.person,
              color: member.isVerified ? cyanblueColor : null,
            ),
            title: Text('Authorize Member ${index + 1}'),
            trailing: member.isVerified
                ? ElevatedButton.icon(
                    onPressed: () {
                      _showMemberDetailsDialog(context, member);
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text(
                      'Details',
                      style: TextStyle(color: whiteColor),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cyanblueColor,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      // Completely reset and start fresh
                      print('=== STARTING FRESH AUTHORIZATION FOR MEMBER ${index + 1} ===');
                      
                      // Force close any existing WebSocket immediately
                      await _forceCloseEverything();
                      
                      // Reset all state variables
                      setState(() {
                        _selectedMemberIndex = index;
                        _errorMessage = null;
                        _authUrl = null;
                        _dialogShown = false;
                        _clientId = null;
                        _wsConnecting = false;
                        _isWebViewLoading = false;
                        _showingDialog = false;
                      });
                      
                      // Clear WebView completely
                      _webViewController?.clearCache();
                      _webViewController?.clearLocalStorage();
                      _webViewController = null;
                      
                      // Wait a bit longer to ensure everything is cleaned up
                      await Future.delayed(const Duration(milliseconds: 500));
                      
                      print('=== STARTING WEBSOCKET CONNECTION ===');
                      // Start fresh WebSocket auth
                      _startWsAuth();
                    },
                    child: const Text('Authorize'),
                  ),
          );
        },
      );
    }

    // Show error if any
    if (_errorMessage != null) {
      return _buildWsError(_errorMessage!);
    }

    // Show loading while connecting
    if (_wsConnecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(cyanblueColor),
            ),
            SizedBox(height: 16),
            Text(
              'Connecting to server...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Show auth URL in dialog if available
    if (_authUrl != null && _authUrl!.isNotEmpty && !_dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed && !_dialogShown) {
          _dialogShown = true;
          _showWebViewDialog(_authUrl!);
        }
      });
    }

    // Return to member list
    return const Center(
      child: Text(
        'Ready to authenticate',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildWsError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading authentication',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (!_disposed) {
                      print('=== RETRY BUTTON CLICKED ===');
                      await _forceCloseEverything();
                      await Future.delayed(const Duration(milliseconds: 300));
                      _startWsAuth();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cyanblueColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!_disposed) {
                      _resetWebView();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reset All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          const Text(
            'Success!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'National ID Authentication Complete',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'You can now proceed to the next step',
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

  void _showWebViewDialog(String url) {
    if (_disposed) return;

    _expectedFinalUrl = url;
    print('NationalIdAuthWidget: Showing WebView dialog with URL: $url');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cyanblueColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.security,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'National ID Authentication',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          print('=== WEBVIEW DIALOG CLOSE BUTTON CLICKED ===');
                          Navigator.of(context).pop();
                          await _forceCloseEverything();
                          setState(() {
                            _selectedMemberIndex = null;
                            _authUrl = null;
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // WebView Container
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: WebViewWidget(
                          controller: _createWebViewController(url),
                        ),
                      ),
                      // Loading overlay
                      if (_isWebViewLoading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withOpacity(0.9),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      cyanblueColor),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Loading Authentication Page...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  WebViewController _createWebViewController(String url) {
    print('NationalIdAuthWidget: Creating WebView controller for URL: $url');

    if (_disposed) {
      print(
          'NationalIdAuthWidget: Widget disposed, returning dummy controller');
      return WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse('about:blank'));
    }

    if (_webViewController != null) {
      print('NationalIdAuthWidget: Reusing existing WebView controller');
      return _webViewController!;
    }

    print('NationalIdAuthWidget: Creating new WebView controller');

    _expectedFinalUrl = url;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (_disposed) return NavigationDecision.prevent;

            print('Navigating to: ${request.url}');

            final isCallback = request.url.contains('callback') ||
                request.url.contains('code=') ||
                request.url.contains('state=');

            if (isCallback) {
              print('Callback detected: ${request.url}');
              print(
                  'Callback parameters received - keeping WebSocket alive for result');
              // Don't close WebSocket here - wait for the server to send the result
              // The WebSocket should receive the authentication_result message
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            if (_disposed) return;
            print('Page started loading: $url');
            setState(() {
              _isWebViewLoading = true;
            });
          },
          onPageFinished: (String url) {
            if (_disposed) return;
            print('Page finished loading: $url');

            // Only hide loader if final URL is reached
            if (_expectedFinalUrl != null &&
                Uri.parse(url).host == Uri.parse(_expectedFinalUrl!).host) {
              print('Final auth page loaded — hiding loader');
              setState(() {
                _isWebViewLoading = false;
              });
            } else {
              print('Intermediate redirect — keep showing loader');
            }

            // Inject useful CSS/JS
            _webViewController?.runJavaScript('''
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);

            // Prevent double-tap zoom
            document.addEventListener('touchstart', function(event) {
              if (event.touches.length > 1) {
                event.preventDefault();
              }
            }, { passive: false });

            // Prevent pinch zoom
            document.addEventListener('gesturestart', function(event) {
              event.preventDefault();
            }, { passive: false });

            // Improve input field experience
            var inputs = document.querySelectorAll('input, textarea, select');
            inputs.forEach(function(input) {
              input.style.fontSize = '16px';
              input.addEventListener('focus', function() {
                setTimeout(function() {
                  input.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }, 300);
              });
            });

            // Optimize page performance
            document.addEventListener('DOMContentLoaded', function() {
              var elements = document.querySelectorAll('*');
              elements.forEach(function(el) {
                if (el.style.animation) {
                  el.style.animation = 'none';
                }
                if (el.style.transition) {
                  el.style.transition = 'none';
                }
              });
            });
          ''');
          },
          onWebResourceError: (WebResourceError error) {
            if (_disposed) return;
            print('Web resource error: ${error.description}');
            setState(() {
              _errorMessage = 'WebView error: ${error.description}';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    print('NationalIdAuthWidget: WebView controller created successfully');
    return _webViewController!;
  }

  void _handleCallback(String callbackUrl) {
    if (_disposed) return;

    print(
        'NationalIdAuthWidget: _handleCallback called with URL: $callbackUrl');

    try {
      final uri = Uri.parse(callbackUrl);
      final queryParameters = uri.queryParameters;

      final hasCode = queryParameters.containsKey('code');
      final hasState = queryParameters.containsKey('state');

      print('NationalIdAuthWidget: Has code: $hasCode');
      print('NationalIdAuthWidget: Has state: $hasState');

      if (hasCode && hasState) {
        // WebSocket flow handles verification; ignore this callback
        print('Callback parameters received (ignored in WS flow)');
      }
    } catch (e) {
      _showErrorDialog('Error parsing callback URL: $e');
    }
  }

  // Note: WebSocket-based flow handles verification; the old HTTP code is removed.

  void _showVerificationSuccessDialog(Map<String, dynamic>? responseData) {
    if (_disposed || _showingDialog) return;

    print('NationalIdAuthWidget: Showing verification success dialog');
    print('Response data: $responseData');

    _showingDialog = true;

    // Add a small delay to ensure the dialog is properly displayed
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_disposed) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          print('NationalIdAuthWidget: Dialog builder called');
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'National ID Authentication Complete',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your authentication data has been saved successfully.',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showingDialog = false;
                  if (!_disposed) {
                    // Clear the WebView
                    _webViewController?.clearCache();
                    _webViewController?.clearLocalStorage();
                    _webViewController = null;

                    // Clear any state to force showing completion state
                    setState(() {
                      _authUrl = null;
                    });

                    // Force rebuild to show completion state
                    setState(() {
                      _isWebViewLoading = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyanblueColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );
    });
  }

  void _showErrorDialog(String errorMessage) {
    if (_disposed || _showingDialog) return;

    _showingDialog = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showingDialog = false;
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _testApiEndpoint() async {
    if (_disposed) return;

    try {
      print('Testing API endpoint...');
      // final String baseUrl = 'http://10.8.100.111:9061';
      final String baseUrl = AppConstants.baseUrl;
      final apiUrl = '$baseUrl/api/v1/fayda/authenticate-url-ws?clientId=test';

      print('Testing URL: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 400));

      print('Test response status: ${response.statusCode}');
      print('Test response body: ${response.body}');

      if (response.statusCode == 200) {
        _showErrorDialog(
            'API Test Successful!\nStatus: ${response.statusCode}\nResponse: ${response.body}');
      } else {
        _showErrorDialog(
            'API Test Failed!\nStatus: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      print('API test error: $e');
      _showErrorDialog('API Test Error: $e');
    }
  }

  void _showVerificationErrorDialog(String errorMessage) {
    if (_disposed || _showingDialog) return;

    _showingDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Verification Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                print(
                    'NationalIdAuthWidget: User clicked Retry in error dialog');
                Navigator.of(context).pop();
                _showingDialog = false;
                if (!_disposed) {
                  print('NationalIdAuthWidget: Retrying verification');
                  // Reset the state and try again via WebSocket
                  _resetWebView();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
            ElevatedButton(
              onPressed: () {
                print(
                    'NationalIdAuthWidget: User clicked Cancel in error dialog');
                Navigator.of(context).pop();
                _showingDialog = false;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showMembersDialog() {
    final stepperState = ref.read(stepperProvider);
    final members = stepperState.members;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Authorize Members'),
          content: SizedBox(
            width: double.maxFinite,
            child: members.isEmpty
                ? const Text('No members found.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text('Authorize Member ${index + 1}'),
                        subtitle: Text(member.fullName ?? 'No Name'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _authorizeMember(index, member);
                          },
                          child: const Text('Authorize'),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _authorizeMember(int index, dynamic member) async {
    // Simulate fetch/authorize logic for the selected member
    print(
        'Authorizing Member ${index + 1}: ${member.fullName ?? 'No Name'} (ID: ${member.nationalId ?? 'N/A'})');
    // TODO: Replace with your real API call or logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Authorized Member ${index + 1} (simulated)')),
    );
  }

  Future<void> _fetchDataForAllMembers() async {
    final stepperState = ref.read(stepperProvider);
    final members = stepperState.members;
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No members to fetch data for.')),
      );
      return;
    }
    for (final member in members) {
      // Simulate fetching data for each member (replace with real API call as needed)
      print(
          'Fetching data for member: ${member.fullName ?? 'No Name'} (ID: ${member.nationalId ?? 'N/A'})');
      // await fetchMemberData(member.nationalId); // Implement this if you have an API
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Fetched data for all members! (simulated)')),
    );
  }

  void _onMemberVerified(int memberIndex, Map<String, dynamic> data) {
    final stepperNotifier = ref.read(stepperProvider.notifier);
    final stepperState = ref.read(stepperProvider);
    // Map verified fields into the member's main fields for consistency
    final updatedMember = stepperState.members[memberIndex].copyWith(
      isVerified: true,
      verifiedData: data,
      fullName: data['fullName'] ?? stepperState.members[memberIndex].fullName,
      motherName:
          data['motherName'] ?? stepperState.members[memberIndex].motherName,
      title: data['title'] ?? stepperState.members[memberIndex].title,
      sex: data['sex'] ?? stepperState.members[memberIndex].sex,
      dateOfBirth:
          data['dateOfBirth'] ?? stepperState.members[memberIndex].dateOfBirth,
      maritalStatus: data['maritalStatus'] ??
          stepperState.members[memberIndex].maritalStatus,
      // Add more fields as needed
    );
    stepperNotifier.updateMember(memberIndex, updatedMember);
  }

  void _showMemberDetailsDialog(BuildContext context, dynamic member) {
    final data = member.verifiedData as Map<String, dynamic>?;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(member.fullName ?? 'Member Details'),
          content: SizedBox(
            width: double.maxFinite,
            child: data == null
                ? const Text('No details available.')
                : SingleChildScrollView(
                    child: _buildKeyValueWidgets(_filterPreferredFields(data)),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> _filterPreferredFields(Map<String, dynamic> original) {
    // Define conflicts: prefer the first key in each group
    final preferenceGroups = [
      ['full_name', 'name'],
      ['phone_number', 'phone'],
      ['gender', 'sex'],
    ];

    final filtered = <String, dynamic>{};
    final lowerKeys = original.map((k, v) => MapEntry(k.toLowerCase(), k));

    // Handle preferred fields
    for (var group in preferenceGroups) {
      for (var key in group) {
        final match = lowerKeys[key];
        if (match != null) {
          filtered[group[0]] =
              original[match]; // always assign under preferred key
          break; // stop at the first found in the preference order
        }
      }
    }

    // Add all other keys that are NOT part of any preference group
    final allExcludedKeys = preferenceGroups.expand((g) => g).toSet();

    for (var entry in original.entries) {
      final keyLower = entry.key.toLowerCase();
      final alreadyAdded = filtered.containsValue(entry.value);

      if (!allExcludedKeys.contains(keyLower) && !alreadyAdded) {
        filtered[entry.key] = entry.value;
      }
    }

    return filtered;
  }

//  Map<String, dynamic> _filterPreferredFields(Map<String, dynamic> original) {
//   final filtered = <String, dynamic>{};

//   // Set mandatory preferred fields with fallback logic
//   filtered['email'] = original['email'];
//   filtered['sub'] = original['sub'];
//   filtered['sex'] = original['sex'] ?? original['gender'];
//   filtered['dateOfBirth'] = original['dateOfBirth'] ?? original['dob'];
//   // filtered['picture'] = base64Picture;

//   // Optional: add any other fields not already included
//   final excludedKeys = {'email', 'sub', 'sex', 'gender', 'dateOfBirth', 'dob', 'picture'};

//   for (var entry in original.entries) {
//     final keyLower = entry.key.toLowerCase();
//     if (!excludedKeys.contains(keyLower) && !filtered.containsKey(entry.key)) {
//       filtered[entry.key] = entry.value;
//     }
//   }

//   return filtered;
// }

  Widget _buildKeyValueWidgets(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map<Widget>((entry) {
        final key = entry.key;
        final value = entry.value;

        if (value is String && value.startsWith('data:image')) {
          try {
            final base64String = value.split(',').last;
            final imageBytes = base64Decode(base64String);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${key.replaceAll('_', ' ').toUpperCase()}:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      imageBytes,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            );
          } catch (e) {
            return Text(
              '${key.toUpperCase()}: [Invalid image]',
              style: const TextStyle(color: Colors.red),
            );
          }
        }

        if (value is Map<String, dynamic>) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${key.replaceAll('_', ' ').toUpperCase()}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: value.entries.map<Widget>((subEntry) {
                      return Text('${subEntry.key}: ${subEntry.value}');
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${key.replaceAll('_', ' ').toUpperCase()}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(child: Text(value.toString())),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===== WebSocket-based flow =====
  void _startWsAuth() async {
    if (_disposed) return;
    
    print('NationalIdAuthWidget: === STARTING WS AUTH ===');
    print('NationalIdAuthWidget: Selected member index: $_selectedMemberIndex');
    
    // Ensure everything is closed first
    _closeWebSocket();
    
    setState(() {
      _wsConnecting = true;
      _errorMessage = null;
      _authUrl = null;
      _clientId = null; // Will generate fresh client ID
      _dialogShown = false;
      _showingDialog = false;
      _isWebViewLoading = false;
    });
    
    // Wait longer to ensure WebSocket is properly closed and state is reset
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (_disposed) return;
    
    print('NationalIdAuthWidget: Starting WebSocket connection...');
    await _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    try {
      print('NationalIdAuthWidget: Connecting to WebSocket at $_wsUrl');
      print('NationalIdAuthWidget: Current clientId before connection: $_clientId');
      _closeWebSocket();
      
      // Add timeout for WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      
      // Set up timeout for the connection
      Timer? connectionTimeout = Timer(const Duration(seconds: 30), () {
        if (_wsConnecting && !_disposed) {
          print('NationalIdAuthWidget: WebSocket connection timeout');
          setState(() {
            _errorMessage = 'Connection timeout. Please try again.';
            _wsConnecting = false;
          });
          _closeWebSocket();
        }
      });
      
      _wsSub = _channel!.stream.listen(
        (event) {
          connectionTimeout?.cancel(); // Cancel timeout on first message
          _handleWsMessage(event);
        },
        onError: (err) {
          connectionTimeout?.cancel();
          print('NationalIdAuthWidget: WebSocket error: $err');
          if (_disposed) return;
          setState(() {
            _errorMessage = 'WebSocket error: $err';
            _wsConnecting = false;
          });
        },
        onDone: () {
          connectionTimeout?.cancel();
          print('NationalIdAuthWidget: WebSocket connection done');
          if (_disposed) return;
          // Only mark disconnected if not in normal completion
          if (_authUrl == null && _selectedMemberIndex != null) {
            setState(() {
              _errorMessage ??= 'WebSocket disconnected unexpectedly';
              _wsConnecting = false;
            });
          }
        },
      );

      // Register client once connection is open
      print('NationalIdAuthWidget: WebSocket connected, registering client...');
      _registerClient();
    } catch (e) {
      print('NationalIdAuthWidget: Failed to connect to WebSocket: $e');
      if (_disposed) return;
      setState(() {
        _errorMessage = 'Failed to connect to WebSocket: $e';
        _wsConnecting = false;
      });
    }
  }

  void _registerClient() {
    print("NationalIdAuthWidget: Starting client registration");
    // Generate a fresh client id; server may confirm/override in response
    _clientId = _generateClientId();
    print('NationalIdAuthWidget: Generated new clientId: $_clientId');
    final payload = {
      'type': 'register_client',
      'clientId': _clientId,
    };
    print('NationalIdAuthWidget: Registering client with payload: $payload');
    _channel?.sink.add(jsonEncode(payload));
    print('NationalIdAuthWidget: Client registration message sent');
  }

  Future<void> _fetchAuthUrl() async {
    try {
      print(
          'NationalIdAuthWidget: Fetching auth URL with clientId: $_clientId');

      // Use the provider to fetch the auth URL with the correct clientId
      await ref.read(nationalIdProvider.notifier).callEsignetApi(_clientId);

      if (!mounted) return;

      // Get the state from the provider
      final nationalIdState = ref.read(nationalIdProvider);

      if (nationalIdState.isError) {
        setState(() {
          _errorMessage =
              nationalIdState.errorMessage ?? 'Failed to get auth URL';
          _wsConnecting = false;
        });
        return;
      }

      if (nationalIdState.authUrl != null &&
          nationalIdState.authUrl!.isNotEmpty) {
        print(
            'NationalIdAuthWidget: Received auth URL: ${nationalIdState.authUrl}');
        setState(() {
          _authUrl = nationalIdState.authUrl;
          _wsConnecting = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Empty auth URL received from provider';
          _wsConnecting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      print('NationalIdAuthWidget: Error in _fetchAuthUrl: $e');
      setState(() {
        _errorMessage = 'Error fetching auth URL: $e';
        _wsConnecting = false;
      });
    }
  }

  void _handleWsMessage(dynamic event) {
    if (_disposed) return;
    try {
      print('NationalIdAuthWidget: Received WebSocket message: $event');
      final data = event is String ? jsonDecode(event) : event;
      if (data is! Map) {
        print('NationalIdAuthWidget: Message is not a Map: $data');
        return;
      }
      final type = data['type'];
      print('NationalIdAuthWidget: Message type: $type');

      switch (type) {
        case 'registration_success':
          // Server confirms/assigns clientId
          final serverClientId = data['clientId'];
          print(
              'NationalIdAuthWidget: Registration success, server clientId: $serverClientId');
          if (serverClientId is String && serverClientId.isNotEmpty) {
            _clientId = serverClientId;
            print('NationalIdAuthWidget: Updated clientId to: $_clientId');
          }
          // Now fetch the auth URL
          print('NationalIdAuthWidget: Fetching auth URL...');
          _fetchAuthUrl();
          break;
        case 'authentication_result':
          print('NationalIdAuthWidget: Authentication result received');
          print('NationalIdAuthWidget: Result data: ${data['data']}');
          // Parse and persist result, then close everything
          _handleAuthenticationResult(data);
          break;
        case 'authentication_complete':
          print(
              'NationalIdAuthWidget: Authentication complete message received');
          // This might be a different message type from the server
          _handleAuthenticationResult(data);
          break;
        case 'error':
          print('NationalIdAuthWidget: Server error: ${data['message']}');
          setState(() {
            _errorMessage = data['message']?.toString() ?? 'Server error';
          });
          break;
        default:
          print('NationalIdAuthWidget: Unknown message type: $type');
          print('NationalIdAuthWidget: Full message data: $data');
          // Check if this might be an authentication result with different structure
          if (data.containsKey('clientId') &&
              (data.containsKey('data') || data.containsKey('result'))) {
            print(
                'NationalIdAuthWidget: Treating as authentication result with different structure');
            _handleAuthenticationResult(data);
          }
          break;
      }
    } catch (e) {
      print('NationalIdAuthWidget: Error handling WebSocket message: $e');
      setState(() {
        _errorMessage = 'Invalid message from server: $e';
      });
    }
  }

  void _closeWebSocket() {
    try {
      print('NationalIdAuthWidget: Closing WebSocket connection');
      print('NationalIdAuthWidget: Current clientId being closed: $_clientId');
      _wsSub?.cancel();
      _wsSub = null;
      _channel?.sink.close(ws_status.normalClosure);
      _channel = null;
      print('NationalIdAuthWidget: WebSocket closed successfully');
    } catch (e) {
      print('NationalIdAuthWidget: Error closing WebSocket: $e');
    }
  }

  Future<void> _forceCloseEverything() async {
    try {
      print('NationalIdAuthWidget: === FORCE CLOSING EVERYTHING ===');
      
      // Close WebSocket
      _closeWebSocket();
      
      // Close any open dialogs
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      // Clear WebView
      _webViewController?.clearCache();
      _webViewController?.clearLocalStorage();
      _webViewController = null;
      
      // Reset all state
      _authUrl = null;
      _errorMessage = null;
      _wsConnecting = false;
      _dialogShown = false;
      _showingDialog = false;
      _isWebViewLoading = false;
      _selectedMemberIndex = null;
      _clientId = null;
      
      print('NationalIdAuthWidget: === FORCE CLOSE COMPLETE ===');
    } catch (e) {
      print('NationalIdAuthWidget: Error in force close: $e');
    }
  }

  String _generateClientId() {
    // Simple unique id without external dependency
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  Future<void> _handleAuthenticationResult(Map result) async {
    print('NationalIdAuthWidget: Processing authentication result');
    try {
      final clientId = result['clientId'];
      print('NationalIdAuthWidget: Client ID from result: $clientId');

      // Handle different possible data structures
      dynamic payload;
      if (result.containsKey('data')) {
        payload = result['data'];
      } else if (result.containsKey('result')) {
        payload = result['result'];
      } else {
        payload = result; // Use the entire result if no specific data field
      }

      print('NationalIdAuthWidget: Payload to process: $payload');

      if (payload is Map<String, dynamic>) {
        final mapped = _mapAuthenticationData(payload);
        print('NationalIdAuthWidget: Mapped data: $mapped');

        if (_selectedMemberIndex != null) {
          _onMemberVerified(_selectedMemberIndex!, mapped);
          print('NationalIdAuthWidget: Member verified successfully');
        }
      } else {
        print('NationalIdAuthWidget: Payload is not a Map: $payload');
      }
    } catch (e) {
      print('NationalIdAuthWidget: Error processing authentication result: $e');
    } finally {
      // Close WebSocket first
      _closeWebSocket();

      if (!_disposed) {
        // Close any open dialogs first
        Navigator.of(context).popUntil((route) => route.isFirst);

        // Show success message
        _showAuthenticationSuccessDialog();

        // Close WebView and return to member list
        setState(() {
          _authUrl = null;
          _dialogShown = false;
          _webViewController?.clearCache();
          _webViewController?.clearLocalStorage();
          _webViewController = null;
          _selectedMemberIndex = null;
          _isWebViewLoading = false;
          // Reset WebSocket state completely
          _clientId = null;
          _wsConnecting = false;
          _errorMessage = null;
        });
      }
    }
  }

  Map<String, dynamic> _mapAuthenticationData(Map<String, dynamic> data) {
    // Extract base64 image if provided under 'picture'
    String? base64Picture;
    final picture = data['picture'];
    if (picture is String && picture.isNotEmpty) {
      base64Picture = picture; // expected to be base64 data URL or raw b64
    }

    // Handle address data properly
    String? country;
    String? state;
    String? city;
    
    final address = data['address'];
    if (address is Map<String, dynamic>) {
      country = address['country']?.toString();
      state = address['state']?.toString() ?? address['region']?.toString();
      city = address['city']?.toString() ?? address['locality']?.toString();
    } else if (address is String) {
      country = address;
    }

    // Map common fields
    final mapped = <String, dynamic>{
      'fullName': data['name'] ?? data['full_name'] ?? data['fullName'],
      'email': data['email'],
      'sub': data['sub'],
      'sex': data['sex'] ?? data['gender'],
      'dateOfBirth': data['dateOfBirth'] ?? data['dob'],
      'picture': base64Picture,
      'country': country,
      'state': state,
      'city': city,
      // Preserve original as well
      // 'raw': data,
    };
    return mapped;
  }

  void _showAuthenticationSuccessDialog() {
    if (_disposed || _showingDialog) return;

    _showingDialog = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Authentication Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'National ID verification was successful.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showingDialog = false;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}
