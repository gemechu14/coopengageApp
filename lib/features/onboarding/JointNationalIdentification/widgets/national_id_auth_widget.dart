import 'package:coopengageplus/constants/config/config.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:coopengageplus/constants/kconstant.dart';
import '../providers/national_id_provider.dart';
import '../providers/stepper_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _isWebViewLoading = false;

    _webViewController = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        ref.read(nationalIdProvider.notifier).reset();

        ref.read(nationalIdProvider.notifier).callEsignetApi();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _webViewController?.clearCache();
    _webViewController?.clearLocalStorage();
    super.dispose();
  }

  void _resetWebView() {
    if (_disposed) return;

    try {
      _webViewController?.clearCache();
      _webViewController?.clearLocalStorage();
      _webViewController = null;

      ref.read(nationalIdProvider.notifier).reset();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!_disposed) {
          ref.read(nationalIdProvider.notifier).callEsignetApi();
        }
      });

      print('WebView reset successfully');
    } catch (e) {
      print('Error resetting WebView: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return const SizedBox.shrink();

    try {
      final nationalIdState = ref.watch(nationalIdProvider);

      return SingleChildScrollView(
        child: Container(
          // height: MediaQuery.of(context).size.height * 0.65,
          child: _buildContent(nationalIdState),
        ),
      );
    } catch (e) {
      return const Center(
        child: Text(
          'Error loading authentication widget',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }

  Widget _buildContent(NationalIdState nationalIdState) {
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
            // subtitle: Text(member.fullName ?? 'No Name'),
            trailing: member.isVerified
                ? ElevatedButton.icon(
                    onPressed: () {
                      _showMemberDetailsDialog(member);
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
                    onPressed: () {
                      setState(() {
                        _selectedMemberIndex = index;
                        _webViewController = null; // Reset WebView
                        _isWebViewLoading =
                            true; // Show loading spinner if needed
                      });
                      // Reset the provider state and get a new auth URL
                      ref.read(nationalIdProvider.notifier).reset();
                      ref.read(nationalIdProvider.notifier).callEsignetApi();
                    },
                    child: const Text('Authorize'),
                  ),
          );
        },
      );
    }

    if (nationalIdState.isError) {
      return _buildErrorState(nationalIdState);
    }

    if (nationalIdState.authUrl != null &&
        nationalIdState.authUrl!.isNotEmpty) {
      return _buildWebView(nationalIdState.authUrl!);
    }

    if (nationalIdState.isLoading) {
      print('NationalIdAuthWidget: Showing simple loading state');
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(cyanblueColor),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(cyanblueColor),
          ),
          const SizedBox(height: 16),
          const Text(
            'Initializing National ID Authentication...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (!_disposed) {
                print('Manual API call triggered');
                ref.read(nationalIdProvider.notifier).callEsignetApi();
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
            child: const Text('Retry API Call'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (!_disposed) {
                print('Testing API endpoint');
                _testApiEndpoint();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Test API'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (!_disposed) {}
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Test Verification'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _showMembersDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Show Members'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _fetchDataForAllMembers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Fetch Data for All Members'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(NationalIdState nationalIdState) {
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
              nationalIdState.errorMessage ?? 'Unknown error occurred',
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
                  onPressed: () {
                    if (!_disposed) {
                      ref.read(nationalIdProvider.notifier).callEsignetApi();
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

  Widget _buildWebView(String url) {
    if (_disposed) return const SizedBox.shrink();

    _expectedFinalUrl = url;

    print('NationalIdAuthWidget: Building WebView with URL: $url');

    try {
      return Stack(
        children: [
          Container(
            height:
                MediaQuery.of(context).size.height * 0.85, // Increase height
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
          ),

          // Loading overlay with text and spinner
          if (_isWebViewLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.75),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(cyanblueColor),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading National ID Authentication Page...',
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
      );
    } catch (e) {
      print('Error building WebView: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading WebView: $e',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (!_disposed) {
                  setState(() {});
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
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
              _handleCallback(request.url);
              return NavigationDecision.prevent;
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
        final code = queryParameters['code']!;
        final state = queryParameters['state']!;

        // Call the verification API
        _verifyAccount(code, state);
      } else {}
    } catch (e) {
      _showErrorDialog('Error parsing callback URL: $e');
    }
  }

  Future<void> _verifyAccount(String code, String state) async {
    if (_disposed) return;

    print('NationalIdAuthWidget: Starting account verification');
    print('Code: $code, State: $state');

    try {
      final responseData = await ref
          .read(nationalIdProvider.notifier)
          .verifyAccount(code, state);

      if (!_disposed) {
        if (responseData != null) {
          // Save authentication data to stepper state immediately
          _onMemberVerified(_selectedMemberIndex!, responseData);
          setState(() {
            _selectedMemberIndex = null; // Return to member list
          });
        }
        // No longer mark as completed or show success screen
        setState(() {
          _isWebViewLoading = false;
        });
      }
    } catch (e) {
      print('NationalIdAuthWidget: Verification failed: $e');
      if (!_disposed) {
        print('NationalIdAuthWidget: Showing verification error dialog');
        _showVerificationErrorDialog('Verification failed: $e');
      }
    }
  }

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

                    // Clear the auth URL to force showing completion state
                    ref.read(nationalIdProvider.notifier).clearAuthUrl();

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
      final apiUrl = '$baseUrl/api/v1/fayda/authenticate-url';

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
                  // Reset the state and try again
                  ref.read(nationalIdProvider.notifier).reset();
                  ref.read(nationalIdProvider.notifier).callEsignetApi();
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

  void _showMemberDetailsDialog(dynamic member) {
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.entries.map((entry) {
                        final key = entry.key;
                        final value = entry.value;

                        if (value is Map) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${key.replaceAll('_', ' ').toUpperCase()}:',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: (value as Map<String, dynamic>)
                                        .entries
                                        .map((subEntry) {
                                      return Text(
                                          '${subEntry.key}: ${subEntry.value}');
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Text(value.toString())),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
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
}
