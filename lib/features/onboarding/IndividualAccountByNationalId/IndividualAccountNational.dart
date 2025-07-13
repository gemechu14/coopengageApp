import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/constants/config/config.dart';

class IndividualAccountNational extends StatefulWidget {
  const IndividualAccountNational({Key? key}) : super(key: key);

  @override
  State<IndividualAccountNational> createState() =>
      _IndividualAccountNationalState();
}

class _IndividualAccountNationalState extends State<IndividualAccountNational> {
  bool _isLoading = true;
  bool _isError = false;
  String? _authUrl;
  String? _errorMessage;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _callEsignetApi();
  }

  Future<void> _callEsignetApi() async {
    try {
      setState(() {
        _isLoading = true;
        _isError = false;
        _errorMessage = null;
      });

      // Construct the API URL
      // final String baseUrl = 'http://10.8.100.210:7272';

      final String baseUrl = AppConstants.baseURL;
      // final String redirectUri = 'http://10.8.100.210:80/api/v1/callback';
      // final String apiUrl =
      //     '$baseUrl/api/v1/esignet/get-auth-url?redirect_uri=$redirectUri';

      final apiUrl = '$baseUrl/api/v1/fayda/authenticate-url';

      print('Calling API: $apiUrl');

      // Make the API call
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('url')) {
          setState(() {
            _authUrl = responseData['url'];
            _isLoading = false;
          });
          print('Auth URL received: $_authUrl');
        } else {
          throw Exception('No URL found in response');
        }
      } else {
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error calling API: $e');
      setState(() {
        _isError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: cyanblueColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'National ID Authentication',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: cyanblueColor,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_authUrl != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: cyanblueColor),
              onPressed: _callEsignetApi,
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(cyanblueColor),
            ),
            SizedBox(height: 16),
            Text(
              'Loading authentication...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_isError) {
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
                _errorMessage ?? 'Unknown error occurred',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _callEsignetApi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyanblueColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_authUrl != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setNavigationDelegate(
                NavigationDelegate(
                  onNavigationRequest: (NavigationRequest request) {
                    print('Navigating to: ${request.url}');

                    // Handle callback URL
                    if (request.url.contains('/api/v1/callback')) {
                      print('Callback detected: ${request.url}');
                      // You can handle the callback here
                      // For example, extract parameters from the URL
                      _handleCallback(request.url);
                      return NavigationDecision.prevent;
                    }

                    return NavigationDecision.navigate;
                  },
                  onPageStarted: (String url) {
                    print('Page started loading: $url');
                  },
                  onPageFinished: (String url) {
                    print('Page finished loading: $url');
                  },
                  onWebResourceError: (WebResourceError error) {
                    print('Web resource error: ${error.description}');
                  },
                ),
              )
              ..loadRequest(Uri.parse(_authUrl!)),
          ),
        ),
      );
    }

    return const Center(
      child: Text(
        'No authentication URL available',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _handleCallback(String callbackUrl) {
    // Parse the callback URL and extract parameters
    try {
      final uri = Uri.parse(callbackUrl);
      final queryParameters = uri.queryParameters;

      print('Callback parameters: $queryParameters');

      // If we have code and state, verify the account
      if (queryParameters.containsKey('code') &&
          queryParameters.containsKey('state')) {
        _verifyAccount(queryParameters['code']!, queryParameters['state']!);
      } else {
        // Show dialog with callback response
        _showCallbackDialog(callbackUrl, queryParameters);
      }
    } catch (e) {
      print('Error parsing callback URL: $e');
      _showErrorDialog('Error parsing callback URL: $e');
    }
  }

  Future<void> _verifyAccount(String code, String state) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Construct the verification URL
      final String baseUrl = AppConstants.baseURL;
      final String verifyUrl =
          '$baseUrl/api/v1/fayda/verify-account?code=$code&state=$state';

      print('Calling verification API: $verifyUrl');

      // Make the verification API call
      final response = await http.post(
        Uri.parse(verifyUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('Verification response status: ${response.statusCode}');
      print('Verification response body: ${response.body}');

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _showVerificationSuccessDialog(responseData);
      } else {
        throw Exception(
            'Verification failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error verifying account: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error verifying account: $e');
    }
  }

  void _showCallbackDialog(
      String callbackUrl, Map<String, String> queryParameters) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                queryParameters.containsKey('code')
                    ? Icons.check_circle
                    : Icons.error,
                color: queryParameters.containsKey('code')
                    ? Colors.green
                    : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                queryParameters.containsKey('code')
                    ? 'Authentication Success'
                    : 'Authentication Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: queryParameters.containsKey('code')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Callback URL:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    callbackUrl,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Parameters:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: queryParameters.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (queryParameters.containsKey('code')) ...[
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
                        Icon(Icons.check_circle,
                            color: Colors.green[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Authorization successful! You can now proceed with the registration.',
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
                if (queryParameters.containsKey('error')) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Authentication failed: ${queryParameters['error']}',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            if (queryParameters.containsKey('code'))
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to next step or close this page
                  Navigator.pop(context);
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
  }

  void _showVerificationSuccessDialog(Map<String, dynamic> responseData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: cyanblueColor, size: 21),
              // const SizedBox(width: 8),
              const Text(
                'Registered Successfully',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: cyanblueColor,
                ),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your National ID has been successfully verified.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              // Container(
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     color: Colors.green[50],
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: Colors.green[200]!),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'Response Data:',
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 14,
              //           color: Colors.grey[700],
              //         ),
              //       ),
              //       const SizedBox(height: 8),
              //       Text(
              //         json.encode(responseData),
              //         style: const TextStyle(
              //           fontSize: 12,
              //           fontFamily: 'monospace',
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to next step or close this page
                Navigator.pop(context);
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
  }

  void _showErrorDialog(String errorMessage) {
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
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
