import 'dart:async';
import 'dart:io';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/stepper_provider.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
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
  bool _hasConsented = false;
  bool _showInfoScreen = true;
  final ValueNotifier<bool> _isWebViewLoading = ValueNotifier<bool>(false);
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    // Don't auto-start auth flow, wait for user to click continue
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkExistingData());
  }

  /// Initialize WebView controller
  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          print('🌐 WebView loading: $url');
          _isWebViewLoading.value = true;
        },
        onPageFinished: (url) {
          print('✅ WebView loaded: $url');
          _isWebViewLoading.value = false;
        },
        onWebResourceError: (error) {
          print('❌ WebView error: ${error.description}');
          _isWebViewLoading.value = false;
        },
      ));
  }

  @override
  void dispose() {
    _isWebViewLoading.dispose();
    super.dispose();
  }

  /// Check existing data without starting auth flow
  void _checkExistingData() {
    final stepperState = ref.read(stepperProvider);
    final currentState = ref.read(simpleNationalIdProvider);

    // Check if stepper has authentication data (means user came back from another step)
    final hasStepperData = stepperState.authId != null ||
        stepperState.fullName != null ||
        stepperState.email != null;

    // If stepper has data, user came back from step 2 - preserve data
    if (hasStepperData) {
      // If provider already has completed data, show it
      if (currentState.isCompleted && currentState.userData != null) {
        print('✅ User came back from step 2 - showing existing data');
        setState(() {
          _showInfoScreen = false;
        });
        return;
      }
      
      // If provider doesn't have data but stepper does, restore from stepper
      print('🔄 User came back from step 2 - restoring data from stepper');
      setState(() {
        _showInfoScreen = false;
      });
      _restoreFromStepper(stepperState);
      return;
    }

    // First time visit - no stepper data exists, clear everything and start fresh
    print('🆕 First time visit - clearing data and showing info screen');
    ref.read(simpleNationalIdProvider.notifier).reset();
    setState(() {
      _showInfoScreen = true;
    });
  }

  /// Start authentication flow (called when user clicks continue)
  void _startAuthFlow() {
    // Data is already cleared in _checkExistingData if it's first time
    // Just start authentication
    print('🚀 Starting authentication');
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
      // Show WebView dialog when auth URL is ready
      if (next.authUrl != null &&
          !next.isCompleted &&
          next.error == null &&
          !_showWebView) {
        print('🌐 Auth URL ready - showing WebView dialog');
        setState(() => _showWebView = true);
        _showWebViewDialog(next.authUrl!);
      }

      // Close WebView when authentication completes
      if (next.isCompleted && next.userData != null && _showWebView) {
        print('✅ Authentication completed - closing WebView dialog and showing data');
        // Add small delay to ensure state is properly set
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            Navigator.of(context).pop(); // Close dialog
            setState(() => _showWebView = false);
            _saveToStepper(next.userData!);
          }
        });
      }

      // Close WebView when WebSocket disconnects (backup)
      if (previous?.isConnected == true &&
          next.isConnected == false &&
          _showWebView) {
        print('🔌 WebSocket closed - closing WebView dialog');
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        setState(() => _showWebView = false);
      }
    });

    // Show informational screen first (if not consented yet and no existing data)
    if (_showInfoScreen && !state.isCompleted) {
      return _buildInfoScreen();
    }

    // Show success screen with beautiful data display
    if (state.isCompleted && state.userData != null) {
      return _buildSuccessScreen(state.userData!);
    }

    // Show error
    if (state.error != null) {
      return _buildErrorScreen(state.error!);
    }

    // Show loading
    return _buildLoadingScreen();
  }

  /// Show WebView in dialog (similar to JointNationalIdentification)
  void _showWebViewDialog(String url) {
    print('🌐 Showing WebView dialog with URL: $url');
    
    _isWebViewLoading.value = true;

    // Load URL before showing dialog
    _webViewController?.loadRequest(Uri.parse(url));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
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
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Reset provider and show info screen again
                          ref.read(simpleNationalIdProvider.notifier).reset();
                          setState(() {
                            _showWebView = false;
                            _showInfoScreen = true;
                            _hasConsented = false;
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
                          controller: _webViewController!,
                        ),
                      ),
                      // Loading overlay - listens to ValueNotifier
                      ValueListenableBuilder<bool>(
                        valueListenable: _isWebViewLoading,
                        builder: (context, isLoading, child) {
                          if (!isLoading) return const SizedBox.shrink();
                          return Positioned.fill(
                            child: Container(
                              color: Colors.white.withOpacity(0.9),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        cyanblueColor),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
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
                          );
                        },
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

  /// Build informational screen
  Widget _buildInfoScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Info Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cyanblueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Icon
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: cyanblueColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'National ID Verification Required',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: cyanblueColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verify customer identity using National ID (Fayda) to pre-fill account information.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Benefits Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Benefits:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                _buildBenefitItem('Instant identity verification'),
                const SizedBox(height: 8),
                _buildBenefitItem('Pre-filled personal information'),
                const SizedBox(height: 8),
                _buildBenefitItem('Faster account activation'),
                const SizedBox(height: 8),
                _buildBenefitItem('Enhanced security'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Consent Checkbox - simplified
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _hasConsented,
                onChanged: (value) {
                  setState(() {
                    _hasConsented = value ?? false;
                  });
                },
                activeColor: cyanblueColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Customer consents to access National ID (Fayda) data for account opening.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Continue Button
          FilledButton(
            onPressed: _hasConsented
                ? () {
                    setState(() {
                      _showInfoScreen = false;
                    });
                    _startAuthFlow();
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: cyanblueColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: const Text(
              'Continue with National ID',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Build benefit item
  Widget _buildBenefitItem(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: cyanblueColor, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
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
                    fontSize: 17,
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
            padding: EdgeInsets.all(7),
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
