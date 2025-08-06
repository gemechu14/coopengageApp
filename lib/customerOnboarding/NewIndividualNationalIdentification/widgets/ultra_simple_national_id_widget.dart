import 'dart:async';
import 'dart:io';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/customerOnboarding/NewIndividualNationalIdentification/providers/fayda_provider.dart';
import 'package:coopengageplus/customerOnboarding/NewIndividualNationalIdentification/providers/stepper_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/simple_national_id_provider.dart';
import '../model/national_id_models.dart';

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
  Timer? _checkTimer;
  bool _showUserData = false;
  bool _callbackDetected = false;
  @override
  void initState() {
    super.initState();
    _initializeWebView();

    // Check if this is a fresh page visit vs step navigation
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (mounted) {
    //       final currentState = ref.read(simpleNationalIdProvider);

    //       // Fresh visit: No user data exists (new session)
    //       bool isFreshVisit = currentState.userData == null &&
    //                          !currentState.isCompleted &&
    //                          !currentState.isConnected;

    //       if (isFreshVisit) {
    //         print('🔄 [Widget] Fresh page visit detected - starting fresh authentication');
    //         _startAuthentication();
    //       } else if (currentState.isCompleted && currentState.userData != null) {
    //         print('✅ [Widget] Step navigation detected - keeping existing data');
    //         // Keep existing data (user navigated back from next step)
    //         // No need to start authentication
    //       } else {
    //         print('🚀 [Widget] Partial state detected - resetting and starting fresh');
    //         ref.read(simpleNationalIdProvider.notifier).reset();
    //         _startAuthentication();
    //       }
    //     }
    //   });
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stepperState = ref.read(stepperProvider);
      final currentState = ref.read(simpleNationalIdProvider);

      // Check if we have completed data from previous session
      bool hasCompletedData = currentState.isCompleted && currentState.userData != null;
      
      // Check if we have stepper data (user has completed authentication before)
      bool hasStepperData = stepperState.authId != null || 
                           stepperState.fullName != null || 
                           stepperState.email != null;
      
      // Check if this is a fresh visit (no stepper data and no completed authentication)
      bool isFreshVisit = !hasStepperData && !hasCompletedData;

      // Debug logging
      print('🔍 [Widget] Debug - Stepper data: authId=${stepperState.authId}, fullName=${stepperState.fullName}, email=${stepperState.email}');
      print('🔍 [Widget] Debug - Current state: isCompleted=${currentState.isCompleted}, hasUserData=${currentState.userData != null}');
      print('🔍 [Widget] Debug - Flags: hasStepperData=$hasStepperData, hasCompletedData=$hasCompletedData, isFreshVisit=$isFreshVisit');

      if (isFreshVisit) {
        print('🔄 [Widget] Fresh page visit detected - starting fresh authentication');
        ref.read(simpleNationalIdProvider.notifier).reset();
        setState(() {
          _callbackDetected = false;
        });
        // Small delay to ensure reset is complete, then auto-start
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _startAuthentication();
          }
        });
      } else if (hasCompletedData) {
        print('✅ [Widget] Step navigation with completed data - keeping existing data');
        // Keep existing data (user navigated back from next step)
        setState(() {
          _callbackDetected = true; // Mark as completed to prevent WebView restart
        });
      } else if (hasStepperData && !hasCompletedData) {
        print('🔄 [Widget] Returning with stepper data but no current data - restoring from stepper');
        // User has stepper data but no current authentication data, restore from stepper
        _restoreFromStepper(stepperState);
        setState(() {
          _callbackDetected = true; // Mark as completed to prevent WebView restart
        });
      } else {
        print('🚀 [Widget] Partial state detected - resetting and starting fresh');
        // In step flow but no completed data, start fresh
        ref.read(simpleNationalIdProvider.notifier).reset();
        setState(() {
          _callbackDetected = false;
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
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  void _startAuthentication() {
    // Start authentication
    ref.read(simpleNationalIdProvider.notifier).startAuthentication();

    // Start checking WebSocket status every 2 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkWebSocketStatus();
    });
  }

    void _checkWebSocketStatus() {
    final state = ref.read(simpleNationalIdProvider);
    
    // If WebSocket is not connected, close WebView
    if (!state.isConnected && _showWebView) {
      print('🔌 WebSocket closed - closing WebView');
      setState(() => _showWebView = false);
      _checkTimer?.cancel();
    }
    
    // If authentication completed, close WebView and save to stepper
    if (state.isCompleted && state.userData != null && _showWebView) {
      print('✅ Authentication completed - closing WebView');
      setState(() => _showWebView = false);
      _checkTimer?.cancel();
      
      // Save authentication data to stepper provider
      _saveToStepper(state.userData!);
    }
    
    // If error occurred, close WebView
    if (state.error != null && _showWebView) {
      print('❌ Error occurred - closing WebView');
      setState(() => _showWebView = false);
      _checkTimer?.cancel();
    }
  }

  void _saveToStepper(FaydaUserData userData) {
    print('💾 [Widget] Saving authentication data to stepper provider');
    final stepperNotifier = ref.read(stepperProvider.notifier);
    
    // Convert sub to int if possible, otherwise use null
    int? authId;
    try {
      authId = int.tryParse(userData.sub);
    } catch (e) {
      print('⚠️ [Widget] Could not parse auth ID: ${userData.sub}');
    }
    
    stepperNotifier.updateAuthId(authId);
    stepperNotifier.updateFullName(userData.name);
    stepperNotifier.updateEmail(userData.email);
    
    print('💾 [Widget] Authentication data saved to stepper');
    print('💾 [Widget] Auth ID: $authId, Name: ${userData.name}, Email: ${userData.email}');
  }

  void _restoreFromStepper(StepperState stepperState) {
    print('🔄 [Widget] Restoring authentication data from stepper provider');
    
    // Create a mock user data from stepper state
    final userData = FaydaUserData(
      sub: stepperState.authId?.toString() ?? '',
      name: stepperState.fullName ?? '',
      email: stepperState.email ?? '',
      phoneNumber: stepperState.authPhone,
      birthdate: stepperState.dateOfBirth,
      gender: stepperState.sex,
      address: null, // Address not stored in stepper
      picture: null, // Picture not stored in stepper
    );
    
    // Update the simple national ID provider with the restored data
    ref.read(simpleNationalIdProvider.notifier).restoreUserData(userData);
    
    print('🔄 [Widget] Authentication data restored from stepper');
    print('🔄 [Widget] Auth ID: ${stepperState.authId}, Name: ${stepperState.fullName}, Email: ${stepperState.email}');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(simpleNationalIdProvider);

    // Show WebView only if WebSocket is connected and we have auth URL
    if (state.authUrl != null &&
        state.isConnected &&
        !state.isCompleted &&
        state.error == null &&
        !_showWebView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _showWebView = true);
        _webViewController?.loadRequest(Uri.parse(state.authUrl!));
      });
    }

    return
        // appBar: AppBar(title: const Text('National ID Authentication')),
        Padding(
      padding: const EdgeInsets.all(0),
      child: _showWebView ? _buildWebView() : _buildMainContent(state),
    );
  }

  Widget _buildWebView() {
    return Card(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Text(
              'Complete your National ID authentication',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          // WebView
          Expanded(
            child: _webViewController != null
                ? WebViewWidget(controller: _webViewController!)
                : const Center(child: CircularProgressIndicator()),
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
          // Loading state (only show if not completed and no error)
          if (faydaState.isLoading ||
              (!faydaState.isCompleted && faydaState.error == null && !faydaState.isConnected)) ...[
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

          if (userData.picture != null && userData.picture!.isNotEmpty) ...[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(userData.picture!),
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

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
              if (userData.address!.woreda != null)
                _buildDataRow('Woreda', userData.address!.woreda!),
              if (userData.address!.zone != null)
                _buildDataRow('Zone', userData.address!.zone!),
            ]),
          ],

          const SizedBox(height: 24),
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

  Widget _buildUserDataCard(FaydaUserData userData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${userData.name}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (userData.phoneNumber != null)
              Text('Phone: ${userData.phoneNumber}'),
            if (userData.birthdate != null)
              Text('Birthdate: ${userData.birthdate}'),
            if (userData.gender != null) Text('Gender: ${userData.gender}'),
            if (userData.address != null) ...[
              Text(
                  'Address: ${userData.address!.country}, ${userData.address!.region}'),
            ],
          ],
        ),
      ),
    );
  }

  String _getLoadingMessage(NationalIdState state) {
    // Don't show loading message if we have completed data
    if (state.isCompleted && state.userData != null) {
      return '';
    }

    // Don't show loading message if we're connected and have auth URL
    if (state.isConnected && state.authUrl != null) {
      return '';
    }

    if (state.isRegistered) return 'Getting authentication URL...';
    if (state.isConnected) return 'Registering client...';
    return 'Connecting to authentication service...';
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}
