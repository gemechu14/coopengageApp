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
  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  String? _clientId;
  String? _authUrl;
  String? _errorMessage;
  bool _wsConnecting = false;
  bool _dialogShown = false;

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
      _clientId = null;
      _closeWebSocket();
      if (_selectedMemberIndex != null) {
        _startWsAuth();
      }
    } catch (e) {}
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_disposed) return const SizedBox.shrink();

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
                  child:
                      const Icon(Icons.group, color: cyanblueColor, size: 20),
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
              final hasValidEmail =
                  member.email != null && _isValidEmail(member.email!);

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                  member.fullName ?? 'Member ${index + 1}',
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
                          if (member.isVerified)
                            ElevatedButton.icon(
                              onPressed: () {
                                _showMemberDetailsDialog(context, member);
                              },
                              icon: const Icon(Icons.info_outline, size: 18),
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
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: member.email ?? '',
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                            fontSize: 14, color: Colors.blueGrey.shade900),
                        decoration: InputDecoration(
                          labelText: 'Email Address *',
                          hintText: 'Enter email address',
                          prefixIcon: Icon(Icons.email_outlined,
                              size: 20,
                              color: cyanblueColor.withOpacity(0.7)),
                          suffixIcon: hasValidEmail
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20)
                              : null,
                          errorText: member.email != null &&
                                  member.email!.isNotEmpty &&
                                  !_isValidEmail(member.email!)
                              ? 'Invalid email format'
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: cyanblueColor.withOpacity(0.30)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: cyanblueColor.withOpacity(0.30)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: cyanblueColor, width: 1.5),
                          ),
                        ),
                        onChanged: (value) {
                          ref
                              .read(stepperProvider.notifier)
                              .updateMemberEmail(index, value);
                        },
                      ),
                      if (hasValidEmail) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
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
                              _startWsAuth();
                            },
                            icon: Icon(
                              member.isVerified
                                  ? Icons.refresh_rounded
                                  : Icons.fingerprint,
                              size: 18,
                            ),
                            label: Text(
                              member.isVerified
                                  ? 'Re-verify National ID'
                                  : 'Verify with National ID',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: member.isVerified
                                  ? Colors.white
                                  : cyanblueColor,
                              foregroundColor: member.isVerified
                                  ? cyanblueColor
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: member.isVerified
                                    ? const BorderSide(color: cyanblueColor)
                                    : BorderSide.none,
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
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
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
        style: TextStyle(fontSize: 16, color: Colors.grey),
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  void _showWebViewDialog(String url) {
    if (_disposed) return;

    _expectedFinalUrl = url;

    _pageLoadingNotifier?.dispose();
    _pageLoadingNotifier = ValueNotifier<bool>(true);
    _authWebViewInitialLoadDone = false;

    FullScreenAuthDialog.show(
      context: context,
      webViewController: _createWebViewController(url),
      title: 'National ID Authentication',
      pageLoading: _pageLoadingNotifier,
      onClose: () async {
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
      print('NationalIdAuthWidget: Widget disposed, returning dummy controller');
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
              print('Callback parameters received - keeping WebSocket alive for result');
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            if (_disposed) return;
            if (!_authWebViewInitialLoadDone) {
              _pageLoadingNotifier?.value = true;
            }
            setState(() {
              _isWebViewLoading = true;
            });
          },
          onPageFinished: (String url) {
            if (_disposed) return;
            if (_expectedFinalUrl != null &&
                Uri.parse(url).host == Uri.parse(_expectedFinalUrl!).host) {
              _authWebViewInitialLoadDone = true;
              _pageLoadingNotifier?.value = false;
              setState(() {
                _isWebViewLoading = false;
              });
            }
            _webViewController?.runJavaScript('''
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);
            document.addEventListener('touchstart', function(event) {
              if (event.touches.length > 1) {
                event.preventDefault();
              }
            }, { passive: false });
            document.addEventListener('gesturestart', function(event) {
              event.preventDefault();
            }, { passive: false });
            var inputs = document.querySelectorAll('input, textarea, select');
            inputs.forEach(function(input) {
              input.style.fontSize = '16px';
              input.addEventListener('focus', function() {
                setTimeout(function() {
                  input.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }, 300);
              });
            });
          ''');
          },
          onWebResourceError: (WebResourceError error) {
            if (_disposed) return;
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

  // ===== WebSocket-based flow =====
  void _startWsAuth() async {
    if (_disposed) return;

    print('NationalIdAuthWidget: === STARTING WS AUTH ===');
    print('NationalIdAuthWidget: Selected member index: $_selectedMemberIndex');

    _closeWebSocket();

    setState(() {
      _wsConnecting = true;
      _errorMessage = null;
      _authUrl = null;
      _clientId = null;
      _dialogShown = false;
      _showingDialog = false;
      _isWebViewLoading = false;
    });

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

      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

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
          connectionTimeout?.cancel();
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
          if (_authUrl == null && _selectedMemberIndex != null) {
            setState(() {
              _errorMessage ??= 'WebSocket disconnected unexpectedly';
              _wsConnecting = false;
            });
          }
        },
      );

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
    _clientId = _generateClientId();
    final payload = {
      'type': 'register_client',
      'clientId': _clientId,
    };
    _channel?.sink.add(jsonEncode(payload));
  }

  Future<void> _fetchAuthUrl() async {
    try {
      await ref.read(nationalIdProvider.notifier).callEsignetApi(_clientId);

      if (!mounted) return;
      final nationalIdState = ref.read(nationalIdProvider);

      if (nationalIdState.isError) {
        setState(() {
          _errorMessage = nationalIdState.errorMessage ?? 'Failed to get auth URL';
          _wsConnecting = false;
        });
        return;
      }

      if (nationalIdState.authUrl != null && nationalIdState.authUrl!.isNotEmpty) {
        print('NationalIdAuthWidget: Received auth URL: ${nationalIdState.authUrl}');
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
          final serverClientId = data['clientId'];
          print('NationalIdAuthWidget: Registration success, server clientId: $serverClientId');
          if (serverClientId is String && serverClientId.isNotEmpty) {
            _clientId = serverClientId;
            print('NationalIdAuthWidget: Updated clientId to: $_clientId');
          }
          print('NationalIdAuthWidget: Fetching auth URL...');
          _fetchAuthUrl();
          break;
        case 'authentication_result':
          print('NationalIdAuthWidget: Authentication result received');
          print('NationalIdAuthWidget: Result data: ${data['data']}');
          _handleAuthenticationResult(data);
          break;
        case 'authentication_complete':
          print('NationalIdAuthWidget: Authentication complete message received');
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
          if (data.containsKey('clientId') &&
              (data.containsKey('data') || data.containsKey('result'))) {
            print('NationalIdAuthWidget: Treating as authentication result with different structure');
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
    } catch (e) {}
  }

  Future<void> _forceCloseEverything() async {
    try {
      print('NationalIdAuthWidget: === FORCE CLOSING EVERYTHING ===');

      _closeWebSocket();
      Navigator.of(context).popUntil((route) => route.isFirst);

      _webViewController?.clearCache();
      _webViewController?.clearLocalStorage();
      _webViewController = null;

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
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  Future<void> _handleAuthenticationResult(Map result) async {
    print('NationalIdAuthWidget: Processing authentication result');
    try {
      final clientId = result['clientId'];
      print('NationalIdAuthWidget: Client ID from result: $clientId');

      dynamic payload;
      if (result.containsKey('data')) {
        payload = result['data'];
      } else if (result.containsKey('result')) {
        payload = result['result'];
      } else {
        payload = result;
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
      _closeWebSocket();

      if (!_disposed) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        _showAuthenticationSuccessDialog();

        setState(() {
          _authUrl = null;
          _dialogShown = false;
          _webViewController?.clearCache();
          _webViewController?.clearLocalStorage();
          _webViewController = null;
          _selectedMemberIndex = null;
          _isWebViewLoading = false;
          _clientId = null;
          _wsConnecting = false;
          _errorMessage = null;
        });
      }
    }
  }

  Map<String, dynamic> _mapAuthenticationData(Map<String, dynamic> data) {
    print('NationalIdAuthWidget: Raw authentication data: $data');

    String? base64Picture;
    final picture = data['picture'];
    if (picture is String && picture.isNotEmpty) {
      base64Picture = picture;
      print('NationalIdAuthWidget: Picture data found: ${picture.length} chars');
    }

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

      state = region ?? zone;
      city = woreda;

      print('NationalIdAuthWidget: Extracted address - Country: $country, State: $state, City: $city, Zone: $zone, Woreda: $woreda');
    } else if (address is String) {
      country = address;
      print('NationalIdAuthWidget: Address is string: $country');
    }

    String? fullName = data['name'] ?? data['full_name'] ?? data['fullName'];
    print('NationalIdAuthWidget: Full name: $fullName');

    String? gender = data['gender'] ?? data['sex'];
    print('NationalIdAuthWidget: Gender: $gender');

    String? dateOfBirth = data['birthdate'] ?? data['dateOfBirth'] ?? data['dob'];
    print('NationalIdAuthWidget: Date of birth: $dateOfBirth');

    String? email = data['email']?.toString();
    String? sub = data['sub']?.toString();
    String? phone = data['phone']?.toString() ?? data['phone_number']?.toString();
    print('NationalIdAuthWidget: Email: $email, Sub: $sub, Phone: $phone');

    final mapped = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'sub': sub,
      'phone': phone,
      'phone_number': phone,
      'sex': gender,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'birthdate': dateOfBirth,
      'picture': base64Picture,
      'country': country,
      'state': state,
      'region': region,
      'city': city,
      'zone': zone,
      'woreda': woreda,
      'zoneSubCity': zone,
      'streetAddress': woreda,
      'address': address,
    };

    print('NationalIdAuthWidget: Mapped authentication data: $mapped');
    return mapped;
  }

  void _onMemberVerified(int memberIndex, Map<String, dynamic> data) {
    final stepperNotifier = ref.read(stepperProvider.notifier);
    final stepperState = ref.read(stepperProvider);
    
    // Extract phone from verifiedData (phone_number or phone)
    String? phone = data['phone'] ?? data['phone_number'];
    
    // Extract email from verifiedData
    String? email = data['email'];
    
    // Extract state and zoneSubCity from verifiedData
    String? state = data['state'] ?? data['region'];
    String? zoneSubCity = data['zoneSubCity'] ?? data['zone'];
    
    final updatedMember = stepperState.members[memberIndex].copyWith(
      isVerified: true,
      verifiedData: data,
      fullName: data['fullName'] ?? stepperState.members[memberIndex].fullName,
      phone: phone ?? stepperState.members[memberIndex].phone,
      email: email ?? stepperState.members[memberIndex].email,
      motherName: data['motherName'] ?? stepperState.members[memberIndex].motherName,
      title: data['title'] ?? stepperState.members[memberIndex].title,
      sex: data['sex'] ?? stepperState.members[memberIndex].sex,
      dateOfBirth: data['dateOfBirth'] ?? stepperState.members[memberIndex].dateOfBirth,
      maritalStatus: data['maritalStatus'] ?? stepperState.members[memberIndex].maritalStatus,
      legalId: data['sub'] ?? data['legalId'] ?? stepperState.members[memberIndex].legalId,
      state: state ?? stepperState.members[memberIndex].state,
      zoneSubCity: zoneSubCity ?? stepperState.members[memberIndex].zoneSubCity,
      documentType: stepperState.members[memberIndex].documentType ?? 'NATIONALID',
      issueAuthority: stepperState.members[memberIndex].issueAuthority ?? 'ET',
    );
    stepperNotifier.updateMember(memberIndex, updatedMember);
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
}

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
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
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
