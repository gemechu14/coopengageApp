import 'dart:async';
import 'dart:io';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/stepper_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/simple_national_id_provider.dart';
import '../model/national_id_models.dart';
import 'dart:convert';
/// Clean and simple National ID authentication widget
/// WebSocket stays open until authentication data is received
class UltraSimpleNationalIdWidget extends ConsumerStatefulWidget {
  const UltraSimpleNationalIdWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<UltraSimpleNationalIdWidget> createState() =>
      _UltraSimpleNationalIdWidgetState();
}

class _UltraSimpleNationalIdWidgetState
    extends ConsumerState<UltraSimpleNationalIdWidget> {
  bool _showWebView = false;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAuthFlow());
  }

  /// Initialize WebView controller
  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          print('🌐 WebView loading: $url');
        },
        onPageFinished: (url) {
          print('✅ WebView loaded: $url');
        },
        onWebResourceError: (error) {
          print('❌ WebView error: ${error.description}');
        },
      ));
  }

  /// Start authentication flow
  void _startAuthFlow() {
    final stepperState = ref.read(stepperProvider);
    final currentState = ref.read(simpleNationalIdProvider);

    // Check if this is first time (no data in stepper)
    final isFirstTime = stepperState.authId == null &&
        stepperState.fullName == null &&
        stepperState.email == null;

    if (isFirstTime) {
      // First time: Clean everything and start fresh
      print('🆕 First time visit - cleaning all data and starting fresh');
      ref.read(simpleNationalIdProvider.notifier).reset();
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          ref.read(simpleNationalIdProvider.notifier).startAuthentication();
        }
      });
      return;
    }

    // If already completed, restore data
    if (currentState.isCompleted && currentState.userData != null) {
      print('✅ Data already completed - showing existing data');
      return;
    }

    // If stepper has data, restore it
    if (stepperState.authId != null) {
      print('🔄 Restoring data from stepper');
      _restoreFromStepper(stepperState);
      return;
    }

    // Fallback: Start fresh
    print('🚀 Starting fresh authentication');
    ref.read(simpleNationalIdProvider.notifier).reset();
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(simpleNationalIdProvider.notifier).startAuthentication();
      }
    });
  }

  /// Restore data from stepper
  void _restoreFromStepper(StepperState stepperState) {
    final userData = FaydaUserData(
      sub: stepperState.authId?.toString() ?? '',
      name: stepperState.fullName ?? '',
      email: stepperState.email ?? '',
      phoneNumber: stepperState.authPhone,
      birthdate: stepperState.dateOfBirth,
      gender: stepperState.sex,
      address: null,
      picture: null,
    );
    ref.read(simpleNationalIdProvider.notifier).restoreUserData(userData);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(simpleNationalIdProvider);

    // Listen for state changes
    ref.listen(simpleNationalIdProvider, (previous, next) {
      // Show WebView when auth URL is ready
      if (next.authUrl != null &&
          !next.isCompleted &&
          next.error == null &&
          !_showWebView) {
        print('🌐 Loading WebView with auth URL');
        setState(() => _showWebView = true);
        _webViewController?.loadRequest(Uri.parse(next.authUrl!));
      }

      // Close WebView when authentication completes
      if (next.isCompleted && next.userData != null && _showWebView) {
        print('✅ Authentication completed - closing WebView and showing data');
        // Add small delay to ensure state is properly set
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() => _showWebView = false);
            _saveToStepper(next.userData!);
          }
        });
      }

      // Close WebView when WebSocket disconnects (backup)
      if (previous?.isConnected == true &&
          next.isConnected == false &&
          _showWebView) {
        print('🔌 WebSocket closed - closing WebView');
        setState(() => _showWebView = false);
      }
    });

    // FORCE close WebView if authentication is completed
    if (state.isCompleted && state.userData != null && _showWebView) {
      print('🔄 Force closing WebView in build method');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _showWebView) {
          setState(() => _showWebView = false);
        }
      });
    }

    // Show success screen with beautiful data display
    if (state.isCompleted && state.userData != null) {
      return _buildSuccessScreen(state.userData!);
    }

    // Show WebView during authentication
    if (_showWebView) {
      return _buildWebView();
    }

    // Show error
    if (state.error != null) {
      return _buildErrorScreen(state.error!);
    }

    // Show loading
    return _buildLoadingScreen();
  }

  /// Build WebView
  Widget _buildWebView() {
    return Card(
      elevation: 2,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: _webViewController != null
            ? WebViewWidget(controller: _webViewController!)
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// Build beautiful success screen (like the image you showed)
  Widget _buildSuccessScreen(FaydaUserData userData) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fayda Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Blue card with profile picture and name
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Verified badge
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_user,
                      // color: Color(0xFF1565C0),
                      // size: 24,
                    ),
                  ),
                ),

                // SizedBox(height: 16),

                // Profile picture
                if (userData.picture != null && userData.picture!.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: FileImage(File(userData.picture!)),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 60, color: Color(0xFF1565C0)),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 5),

          // Details card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Info.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                  ),
                ),
                Divider(height: 32),
                // SizedBox(height: 20),

                // Full Name
                _buildDetailRow('Full Name', userData.name),

                // Phone Number
                if (userData.phoneNumber != null)
                  _buildDetailRow('Phone Number', userData.phoneNumber!),

                if (userData.gender != null)
                  _buildDetailRow('Gender', userData.gender!),

                if (userData.birthdate != null)
                  _buildDetailRow('Date of Birth', userData.birthdate!),
              ],
            ),
          ),

          SizedBox(height: 5),

          // Details card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Address Information.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                  ),
                ),
                Divider(height: 32),
                // SizedBox(height: 20),

                // Full Name
                if (userData.address?.country != null)
                  _buildDetailRow('Country', userData?.address?.country ?? ''),

                // Phone Number
                if (userData?.address?.region != null)
                  _buildDetailRow('Region', userData?.address?.region ?? ''),

                if (userData?.address?.zone != null)
                  _buildDetailRow(
                      'Zone/ Subcity', userData?.address?.zone ?? ''),

                if (userData?.address?.woreda != null)
                  _buildDetailRow('Woreda', userData?.address?.woreda ?? ''),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Continue button

          SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            // color: Colors.grey.shade400,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            // fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  /// Build loading screen
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF1565C0)),
          SizedBox(height: 16),
          Text(
            'Connecting to authentication service...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Build error screen
  Widget _buildErrorScreen(String error) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(24),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Authentication Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(simpleNationalIdProvider.notifier).reset();
                Future.delayed(Duration(milliseconds: 500), () {
                  if (mounted) {
                    ref
                        .read(simpleNationalIdProvider.notifier)
                        .startAuthentication();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Save data to stepper provider
  void _saveToStepper(FaydaUserData userData) {
    final stepperNotifier = ref.read(stepperProvider.notifier);
    stepperNotifier.updateAuthId(int.tryParse(userData.sub));
    stepperNotifier.updateFullName(userData.name);
    stepperNotifier.updateEmail(userData.email);
    print('💾 Data saved to stepper: ${userData.name}');
    // print('ALL Data": $userData');
    // print('ALL Data: ${userData.}');

  }
}
