import 'dart:convert';
import 'dart:async';

import 'package:coopengageplus/constants/config/config.dart';
import 'package:flutter/material.dart';
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
  int? _selectedMemberIndex;

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

  @override
  Widget build(BuildContext context) {
    if (_disposed) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: _buildContent(),
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
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: ListTile(
              leading: Icon(
                member.isVerified ? Icons.verified : Icons.person,
                color: member.isVerified ? cyanblueColor : Colors.grey,
                size: 32,
              ),
              title: Text(
                'Member ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: member.isVerified
                  ? Text(
                      member.fullName ?? 'Verified',
                      style: const TextStyle(color: Colors.green),
                    )
                  : const Text('Not authenticated'),
              trailing: member.isVerified
                  ? ElevatedButton.icon(
                      onPressed: () {
                        _showMemberDetailsDialog(context, member);
                      },
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cyanblueColor,
                        foregroundColor: whiteColor,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        print('=== STARTING FRESH AUTHORIZATION FOR MEMBER ${index + 1} ===');
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
                        await Future.delayed(const Duration(milliseconds: 500));
                        print('=== STARTING WEBSOCKET CONNECTION ===');
                        _startWsAuth();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cyanblueColor,
                        foregroundColor: whiteColor,
                      ),
                      child: const Text('Authorize'),
                    ),
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
                      const Icon(Icons.security, color: Colors.white, size: 24),
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
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
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
                      if (_isWebViewLoading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withOpacity(0.9),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(cyanblueColor),
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
            print('Page started loading: $url');
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
              setState(() {
                _isWebViewLoading = false;
              });
            } else {
              print('Intermediate redirect — keep showing loader');
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
    final preferenceGroups = [
      ['full_name', 'name'],
      ['phone_number', 'phone'],
      ['gender', 'sex'],
    ];

    final filtered = <String, dynamic>{};
    final lowerKeys = original.map((k, v) => MapEntry(k.toLowerCase(), k));

    for (var group in preferenceGroups) {
      for (var key in group) {
        final match = lowerKeys[key];
        if (match != null) {
          filtered[group[0]] = original[match];
          break;
        }
      }
    }

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
          final filteredMap = _filterPreferredFields(value);
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
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

}
