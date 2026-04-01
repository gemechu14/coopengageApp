import 'dart:io';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/stepper_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/simple_national_id_provider.dart';
import '../model/national_id_models.dart';
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
  bool _startedAuth = false;
  bool _showWebView = false;
  bool _isAuthDialogOpen = false;
  BuildContext? _authDialogContext;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
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

  void _onContinuePressed() {
    if (_startedAuth) return;
    setState(() => _startedAuth = true);
    _startAuthFlow();
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
      // Open authentication WebView in a popup dialog when URL is ready.
      if (next.authUrl != null &&
          !next.isCompleted &&
          next.error == null &&
          !_isAuthDialogOpen) {
        print('🌐 Opening auth dialog with URL');
        if (mounted) {
          setState(() => _showWebView = true);
        }
        _webViewController?.loadRequest(Uri.parse(next.authUrl!));
        _showAuthDialog();
      }

      // Close popup dialog when authentication completes
      if (next.isCompleted && next.userData != null && _isAuthDialogOpen) {
        print('✅ Authentication completed - closing popup and showing data');
        // Add small delay to ensure state is properly set
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            _closeAuthDialog();
            setState(() => _showWebView = false);
            _saveToStepper(next.userData!);
          }
        });
      }

      // Close popup when WebSocket disconnects (backup)
      if (previous?.isConnected == true &&
          next.isConnected == false &&
          _isAuthDialogOpen) {
        print('🔌 WebSocket closed - closing auth popup');
        _closeAuthDialog();
        if (mounted) {
          setState(() => _showWebView = false);
        }
      }
    });

    // FORCE close auth popup if authentication is completed
    if (state.isCompleted && state.userData != null && _isAuthDialogOpen) {
      print('🔄 Force closing auth popup in build method');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isAuthDialogOpen) {
          _closeAuthDialog();
          setState(() => _showWebView = false);
        }
      });
    }

    // Show success screen with beautiful data display
    if (state.isCompleted && state.userData != null) {
      return _buildSuccessScreen(state.userData!);
    }

    // Keep background stable while popup auth flow is active.
    if (_isAuthDialogOpen || (_startedAuth && _showWebView)) {
      return _buildIntroScreen(
        isLocked: true,
        subtitle:
            'Verification window is open. Please complete the process in the popup.',
      );
    }

    // Show intro screen before starting authentication.
    if (!_startedAuth) {
      return _buildIntroScreen();
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

  void _showAuthDialog() {
    if (!mounted || _isAuthDialogOpen || _webViewController == null) return;

    _isAuthDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        _authDialogContext = dialogContext;
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(dialogContext).size.height * 0.88,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: cyanblueColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: Colors.white),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'National ID Authentication',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _closeAuthDialog();
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: WebViewWidget(controller: _webViewController!),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _isAuthDialogOpen = false;
      _authDialogContext = null;
    });
  }

  void _closeAuthDialog() {
    if (!_isAuthDialogOpen) return;
    final dialogContext = _authDialogContext;
    if (dialogContext != null) {
      Navigator.of(dialogContext).pop();
    }
    _isAuthDialogOpen = false;
    _authDialogContext = null;
  }

  Widget _buildIntroScreen({
    bool isLocked = false,
    String subtitle =
        'Verify customer identity securely before moving to the next account opening steps.',
  }) {
    Widget benefitRow(IconData icon, String text) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: cyanblueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 14, color: cyanblueColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF4F9FF), Color(0xFFEAF5FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cyanblueColor.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: cyanblueColor.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/fayda.webp',
                height: 96,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'National ID Verification',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: blueColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: textInfoColor,
              ),
            ),
            const SizedBox(height: 10),
            benefitRow(Icons.verified_user_outlined, 'Instant identity verification'),
            benefitRow(Icons.badge_outlined, 'Pre-filled personal information'),
            benefitRow(Icons.speed_outlined, 'Faster account activation'),
            benefitRow(Icons.lock_outline, 'Enhanced security and compliance'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLocked ? null : _onContinuePressed,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(
                  isLocked
                      ? 'Verification In Progress'
                      : 'Start National ID Verification',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyanblueColor,
                  foregroundColor: whiteColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build beautiful success screen (like the image you showed)
  Widget _buildSuccessScreen(FaydaUserData userData) {
    Widget compactRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 112,
              child: Text(
                label,
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
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget sectionCard(String title, List<Widget> children) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
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
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cyanblueColor, cyanblueColor.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: userData.picture != null &&
                              userData.picture!.isNotEmpty
                          ? Image.file(
                              File(userData.picture!),
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.person, color: cyanblueColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified, color: Colors.white, size: 18),
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
                          userData.name,
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
            sectionCard('Personal Information', [
              compactRow('Full Name', userData.name),
              if (userData.phoneNumber != null)
                compactRow('Phone Number', userData.phoneNumber!),
              if (userData.gender != null) compactRow('Gender', userData.gender!),
              if (userData.birthdate != null)
                compactRow('Date of Birth', userData.birthdate!),
            ]),
            if (userData.address != null)
              sectionCard('Address Information', [
                if (userData.address?.country != null)
                  compactRow('Country', userData.address?.country ?? ''),
                if (userData.address?.region != null)
                  compactRow('Region', userData.address?.region ?? ''),
                if (userData.address?.zone != null)
                  compactRow('Zone/Subcity', userData.address?.zone ?? ''),
                if (userData.address?.woreda != null)
                  compactRow('Woreda', userData.address?.woreda ?? ''),
              ]),
          ],
        ),
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
                setState(() => _startedAuth = false);
                ref.read(simpleNationalIdProvider.notifier).reset();
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
