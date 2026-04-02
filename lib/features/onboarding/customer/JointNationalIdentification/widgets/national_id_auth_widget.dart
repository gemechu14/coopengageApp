import 'dart:convert';
import 'dart:async';

import 'package:coopengageplus/core/config/config.dart';
import 'package:coopengageplus/core/common_widgets/full_screen_auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:http/http.dart' as http;
import 'package:coopengageplus/core/constants/kconstant.dart';

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
  int? _selectedMemberIndex;
  ValueNotifier<bool>? _pageLoadingNotifier;
  bool _authWebViewInitialLoadDone = false;

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
    _pageLoadingNotifier?.dispose();
    _pageLoadingNotifier = null;
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cyanblueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.group, color: cyanblueColor, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Authorize Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: cyanblueColor,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: member.isVerified
                        ? cyanblueColor.withOpacity(0.3)
                        : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: member.isVerified
                              ? cyanblueColor.withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          member.isVerified
                              ? Icons.verified
                              : Icons.person_outline,
                          color: member.isVerified
                              ? cyanblueColor
                              : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Member ${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              member.isVerified
                                  ? 'Verified'
                                  : 'Pending verification',
                              style: TextStyle(
                                fontSize: 13,
                                color: member.isVerified
                                    ? cyanblueColor
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      member.isVerified
                          ? ElevatedButton.icon(
                              onPressed: () {
                                _showMemberDetailsDialog(context, member);
                              },
                              icon:
                                  const Icon(Icons.info_outline, size: 18),
                              label: const Text('Details'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cyanblueColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () async {
                                print(
                                    '=== STARTING FRESH AUTHORIZATION FOR MEMBER ${index + 1} ===');
                                await _forceCloseEverything();
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
                                _webViewController?.clearCache();
                                _webViewController?.clearLocalStorage();
                                _webViewController = null;
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                                print(
                                    '=== STARTING WEBSOCKET CONNECTION ===');
                                _startWsAuth();
                              },
                              icon:
                                  const Icon(Icons.fingerprint, size: 18),
                              label: const Text('Authorize'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cyanblueColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
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

    _pageLoadingNotifier?.dispose();
    _pageLoadingNotifier = ValueNotifier<bool>(true);
    _authWebViewInitialLoadDone = false;

    FullScreenAuthDialog.show(
      context: context,
      webViewController: _createWebViewController(url),
      title: 'National ID Authentication',
      pageLoading: _pageLoadingNotifier,
      onClose: () async {
        print('=== WEBVIEW DIALOG CLOSE BUTTON CLICKED ===');
        await _forceCloseEverything();
        setState(() {
          _selectedMemberIndex = null;
          _authUrl = null;
        });
        _pageLoadingNotifier?.dispose();
        _pageLoadingNotifier = null;
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
            if (!_authWebViewInitialLoadDone) {
              _pageLoadingNotifier?.value = true;
            }
            setState(() {
              _isWebViewLoading = true;
            });
          },
          onPageFinished: (String url) {
            if (_disposed) return;
            print('Page finished loading: $url');

            if (_expectedFinalUrl != null &&
                Uri.parse(url).host == Uri.parse(_expectedFinalUrl!).host) {
              print('Final auth page loaded — hiding loader');
              _authWebViewInitialLoadDone = true;
              _pageLoadingNotifier?.value = false;
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
            _authWebViewInitialLoadDone = true;
            _pageLoadingNotifier?.value = false;
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

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Member Details',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim, secondAnim) {
        return _MemberDetailsSheet(
          memberName: member.fullName ?? 'Member',
          data: data,
        );
      },
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
      print(
          'NationalIdAuthWidget: Current clientId before connection: $_clientId');
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
    final payload = {
      'type': 'register_client',
      'clientId': _clientId,
    };
    _channel?.sink.add(jsonEncode(payload));
  }

  Future<void> _fetchAuthUrl() async {
    try {
      // Use the provider to fetch the auth URL with the correct clientId
      await ref.read(nationalIdProvider.notifier).callEsignetApi(_clientId);

      if (!mounted) return;
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
 
      _wsSub?.cancel();
      _wsSub = null;
      _channel?.sink.close(ws_status.normalClosure);
      _channel = null;
    } catch (e) {
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
    print('NationalIdAuthWidget: Raw authentication data: $data');

    // Extract base64 image if provided under 'picture'
    String? base64Picture;
    final picture = data['picture'];
    if (picture is String && picture.isNotEmpty) {
      base64Picture = picture; // expected to be base64 data URL or raw b64
      print(
          'NationalIdAuthWidget: Picture data found: ${picture.length} chars');
    }

    // Handle address data properly
    String? country;
    String? state;
    String? city;
    String? zone;
    String? woreda;
    String? region;

    final address = data['address'];
    if (address is Map<String, dynamic>) {
      print('NationalIdAuthWidget: Processing address data: $address');
      country = address['country']?.toString()?.trim();
      zone = address['zone']?.toString()?.trim();
      woreda = address['woreda']?.toString()?.trim();
      region = address['region']?.toString()?.trim();

      // Set state to region if available, otherwise use zone
      state = region ?? zone;
      city = woreda; // Use woreda as city for Ethiopian addressing

      print(
          'NationalIdAuthWidget: Extracted address - Country: $country, State: $state, City: $city, Zone: $zone, Woreda: $woreda');
    } else if (address is String) {
      country = address;
      print('NationalIdAuthWidget: Address is string: $country');
    }

    // Handle name variations
    String? fullName = data['name'] ?? data['full_name'] ?? data['fullName'];
    print('NationalIdAuthWidget: Full name: $fullName');

    // Handle gender variations
    String? gender = data['gender'] ?? data['sex'];
    print('NationalIdAuthWidget: Gender: $gender');

    // Handle birthdate variations
    String? dateOfBirth =
        data['birthdate'] ?? data['dateOfBirth'] ?? data['dob'];
    print('NationalIdAuthWidget: Date of birth: $dateOfBirth');

    // Handle email and sub
    String? email = data['email']?.toString();
    String? sub = data['sub']?.toString();
    print('NationalIdAuthWidget: Email: $email, Sub: $sub');

    // Map common fields
    final mapped = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'sub': sub,
      'sex': gender,
      'gender': gender, // Keep both for compatibility
      'dateOfBirth': dateOfBirth,
      'birthdate': dateOfBirth, // Keep both for compatibility
      'picture': base64Picture,
      'country': country,
      'state': state,
      'region': region,
      'city': city,
      'zone': zone,
      'woreda': woreda,
      'zoneSubCity': zone, // Map zone to zoneSubCity for compatibility
      'streetAddress': woreda, // Map woreda to streetAddress for compatibility
      // Preserve original address structure as well
      'address': address,
      // Preserve original as well
      // 'raw': data,
    };

    print('NationalIdAuthWidget: Mapped authentication data: $mapped');
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'National ID verification was successful.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.left,
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
                backgroundColor: Colors.blue,
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

/// Beautiful full-screen member details sheet.
class _MemberDetailsSheet extends StatelessWidget {
  final String memberName;
  final Map<String, dynamic>? data;

  const _MemberDetailsSheet({required this.memberName, this.data});

  static const _hiddenKeys = {
    'raw',
    'address',
    'picture',
    'photo',
    'signature',
  };

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m[1]} ${m[2]}',
        )
        .split(' ')
        .map((w) =>
            w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final personalFields = <String, String>{};
    final addressFields = <String, String>{};
    String? pictureData;

    if (data != null) {
      final addressMap = data!['address'];

      for (final entry in data!.entries) {
        final k = entry.key.toLowerCase();
        final v = entry.value;

        if (_hiddenKeys.contains(k)) continue;
        if (v == null || (v is String && v.trim().isEmpty)) continue;
        if (v is Map || v is List) continue;

        if (v is String && v.startsWith('data:image')) {
          pictureData = v;
          continue;
        }

        final isAddress = k.contains('country') ||
            k.contains('state') ||
            k.contains('region') ||
            k.contains('zone') ||
            k.contains('woreda') ||
            k.contains('city') ||
            k.contains('street') ||
            k.contains('subcity');

        if (isAddress) {
          addressFields[entry.key] = v.toString();
        } else {
          personalFields[entry.key] = v.toString();
        }
      }

      if (addressMap is Map<String, dynamic>) {
        for (final entry in addressMap.entries) {
          final v = entry.value;
          if (v == null || (v is String && v.trim().isEmpty)) continue;
          if (!addressFields.containsKey(entry.key)) {
            addressFields[entry.key] = v.toString();
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: cyanblueColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          memberName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: cyanblueColor,
          ),
        ),
      ),
      body: data == null
          ? const Center(child: Text('No details available.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cyanblueColor,
                          cyanblueColor.withOpacity(0.85)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildAvatar(pictureData),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.verified,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Identity Verified',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                memberName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (personalFields.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildSection('Personal Information', personalFields),
                  ],

                  if (addressFields.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildSection('Address Information', addressFields),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatar(String? pictureBase64) {
    Widget child;
    if (pictureBase64 != null) {
      try {
        final bytes = base64Decode(pictureBase64.split(',').last);
        child = ClipOval(
          child: Image.memory(bytes, fit: BoxFit.cover, width: 62, height: 62),
        );
      } catch (_) {
        child = const Icon(Icons.person, color: cyanblueColor, size: 30);
      }
    } else {
      child = const Icon(Icons.person, color: cyanblueColor, size: 30);
    }

    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: child,
    );
  }

  Widget _buildSection(String title, Map<String, String> fields) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: blueColor,
            ),
          ),
          const SizedBox(height: 10),
          ...fields.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      _formatKey(e.key),
                      style: const TextStyle(
                        fontSize: 13,
                        color: textInfoColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
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
}
