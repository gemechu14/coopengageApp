import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'providers/national_id_provider.dart';
import 'providers/stepper_provider.dart';
import 'widgets/national_id_auth_widget.dart';
import 'widgets/phone_fan_widget.dart';
import 'widgets/account_type_step.dart';
import 'services/registration_service.dart';

class IndividualAccountByNationalId extends ConsumerStatefulWidget {
  const IndividualAccountByNationalId({Key? key}) : super(key: key);

  @override
  ConsumerState<IndividualAccountByNationalId> createState() =>
      _IndividualAccountByNationalIdState();
}

class _IndividualAccountByNationalIdState
    extends ConsumerState<IndividualAccountByNationalId> {
  List<GlobalKey<FormState>> formKeys = [];
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    formKeys = List.generate(3, (index) => GlobalKey<FormState>());
    
    // Reset all state when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        // Reset stepper state
        ref.read(stepperProvider.notifier).reset();
        // Reset National ID state
        ref.read(nationalIdProvider.notifier).reset();
        print('All state reset successfully');
      }
    });
  }



  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  List<EasyStep> steps = [
    EasyStep(
      title: 'National ID Auth',
      icon: Icon(Icons.fingerprint),
    ),
    EasyStep(
      title: 'Phone & FAN',
      icon: Icon(Icons.phone),
    ),
    EasyStep(
      title: 'Account Type',
      icon: Icon(Icons.account_balance),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_disposed) {
      return const Scaffold(
        body: Center(
          child: Text('Widget disposed'),
        ),
      );
    }
    
    try {
      final stepperState = ref.watch(stepperProvider);
      final nationalIdState = ref.watch(nationalIdProvider);

      print('Main build - Current step: ${stepperState.activeStep}');

      return Scaffold(
        key: ValueKey('stepper_scaffold_${stepperState.activeStep}'),
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: cyanblueColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'National ID Registration',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: cyanblueColor,
            ),
          ),
          centerTitle: true,
          actions: [
            if (stepperState.activeStep == 0 && nationalIdState.authUrl != null)
              IconButton(
                icon: const Icon(Icons.refresh, color: cyanblueColor),
                onPressed: () => ref.read(nationalIdProvider.notifier).callEsignetApi(),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Stepper Header - Reduced Height
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: EasyStepper(
                  activeStep: stepperState.activeStep,
                  lineStyle: LineStyle(
                    lineLength: 30,
                    lineSpace: 0,
                    lineType: LineType.normal,
                    defaultLineColor: Colors.grey.shade300,
                    finishedLineColor: cyanblueColor,
                    lineThickness: 2,
                  ),
                  stepShape: StepShape.circle,
                  stepBorderRadius: 15,
                  borderThickness: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  stepRadius: 15,
                  finishedStepTextColor: Colors.white,
                  finishedStepBackgroundColor: cyanblueColor,
                  activeStepTextColor: cyanblueColor,
                  activeStepBackgroundColor: Colors.white,
                  showLoadingAnimation: true,
                  steps: steps,
                  onStepReached: (index) => ref.read(stepperProvider.notifier).goToStep(index),
                ),
              ),

              // Content Area
              Expanded(
                child: Container(
                  key: ValueKey('content_area_${stepperState.activeStep}'),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: _disposed 
                      ? const SizedBox.shrink()
                      : _buildContentArea(stepperState, nationalIdState),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: stepperState.activeStep > 0
                      ? () => ref.read(stepperProvider.notifier).previousStep()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: stepperState.activeStep > 0
                        ? Colors.grey.shade700
                        : Colors.grey.shade400,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(
                          color: stepperState.activeStep > 0
                              ? Colors.grey.shade300
                              : Colors.grey.shade200),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 20),
                      SizedBox(width: 8),
                      Text('Previous',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

              // Next/Submit Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [cyanblueColor, cyanblueColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cyanblueColor.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_disposed) return;
                    
                    print('Current step: ${stepperState.activeStep}');
                    
                    if (stepperState.activeStep == 0) {
                      // For National ID Auth step, check if auth is completed
                      print('Checking National ID auth completion: ${nationalIdState.isAuthCompleted}');
                      print('National ID auth result: ${nationalIdState.authResult}');
                      
                      if (nationalIdState.isAuthCompleted) {
                        // Save authentication data to stepper state
                        if (nationalIdState.authResult != null) {
                          print('Saving authentication data to stepper state');
                          ref.read(stepperProvider.notifier).saveAuthenticationData(nationalIdState.authResult!);
                          
                          // Verify the data was saved
                          final updatedState = ref.read(stepperProvider);
                          print('Updated stepper state - Auth ID: ${updatedState.authId}');
                          print('Updated stepper state - Full Name: ${updatedState.fullName}');
                          print('Updated stepper state - Email: ${updatedState.email}');
                        } else {
                          print('Warning: National ID auth completed but authResult is null');
                        }
                        ref.read(stepperProvider.notifier).nextStep();
                        print('Moving to next step after National ID auth');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please complete National ID authentication first'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else if (stepperState.activeStep == 1) {
                      // For Phone & FAN step, validate required fields
                      final stepperState = ref.read(stepperProvider);
                      print('Validating step 1 - Product Type: ${stepperState.selectedProductType}, Branch: ${stepperState.selectedBranch}');
                      if (stepperState.selectedProductType != null && 
                          stepperState.selectedBranch != null) {
                        print('Step 1 validation successful, moving to step 2');
                        ref.read(stepperProvider.notifier).nextStep();
                        print('Moving to next step after step 1 validation');
                        // Check the new step immediately
                        final newStep = ref.read(stepperProvider).activeStep;
                        print('After transition, current step is: $newStep');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all required fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else if (stepperState.activeStep == 2) {
                      // For Account Type step, validate form
                      print('Validating step 2 - Account Type form');
                      final currentFormKey = formKeys[stepperState.activeStep];
                      print('Form key exists: ${currentFormKey.currentState != null}');
                      if (currentFormKey.currentState?.validate() ?? false) {
                        // Submit registration
                        print('Step 2 validation successful, submitting registration');
                        await _submitRegistration();
                      } else {
                        print('Step 2 validation failed');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select an account type'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(
                        builder: (context) {
                          final buttonText = stepperState.activeStep == 2 ? 'Submit' : 'Next';
                          print('Button text for step ${stepperState.activeStep}: $buttonText');
                          return Text(
                            buttonText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        stepperState.activeStep == 2
                            ? Icons.check
                            : Icons.arrow_forward,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error in build method: $e');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: $e',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Force rebuild
                  setState(() {});
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildContentArea(StepperState stepperState, NationalIdState nationalIdState) {
    if (_disposed) return const SizedBox.shrink();
    
    try {
      print('_buildContentArea - Step: ${stepperState.activeStep}, Auth completed: ${nationalIdState.isAuthCompleted}');
      
      // Show National ID Auth widget if we're on step 0
      if (stepperState.activeStep == 0) {
        print('Showing National ID Auth widget');
        return const NationalIdAuthWidget();
      } else {
        print('Showing step content for step: ${stepperState.activeStep}');
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildStepContent(stepperState.activeStep),
                const SizedBox(height: 80), // Reduced space for keyboard
              ],
            ),
          ),
        );
      }
    } catch (e) {
      print('Error in _buildContentArea: $e');
      return const Center(
        child: Text(
          'Something went wrong. Please try again.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }

  Widget _buildStep0LoadingState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(cyanblueColor),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Preparing National ID Authentication',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Please wait while we initialize the authentication service...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 24,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This step will authenticate your National ID using the official government service.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    final stepperState = ref.watch(stepperProvider);

    switch (step) {
      case 0:
        return const SizedBox.shrink(); // National ID Auth is handled separately
      case 1:
        return const PhoneFanWidget();
      case 2:
        return AccountTypeStep(
          selectedAccountType: stepperState.selectedAccountType,
          onAccountTypeChanged: (value) {
            ref.read(stepperProvider.notifier).updateAccountType(value);
          },
          onAccountTypeSelected: (accountType) {
            // Handle account type selection if needed
          },
          formKey: formKeys[2], // Use fixed index
          customerAge: stepperState.customerAge,
          customerGender: stepperState.customerGender,
          initialDeposit: stepperState.initialDeposit,
          bankingType: stepperState.bankingType,
        );
      default:
        return const Center(child: Text('Step not found'));
    }
  }

  // Submit registration
  Future<void> _submitRegistration() async {
    if (_disposed) return;
    
    final stepperState = ref.read(stepperProvider);
    final nationalIdState = ref.read(nationalIdProvider);
    final registrationService = RegistrationService();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _disposed 
          ? const SizedBox.shrink()
          : const Center(
              child: CircularProgressIndicator(
                color: cyanblueColor,
              ),
            ),
    );

    try {
      // Get the authentication ID from stepper state (saved from step 1)
      print('=== REGISTRATION DEBUG ===');
      print('Stepper state authId: ${stepperState.authId}');
      print('Stepper state fullName: ${stepperState.fullName}');
      print('Stepper state email: ${stepperState.email}');
      print('Stepper state selectedAccountType: ${stepperState.selectedAccountType}');
      print('Stepper state selectedBranch: ${stepperState.selectedBranch}');
      print('Stepper state motherName: ${stepperState.motherName}');
      print('Stepper state initialDeposit: ${stepperState.initialDeposit}');
      
      // Try to get authId from stepper state first
      var authId = stepperState.authId?.toString();
      
      // If authId is null, try to get it from National ID state as fallback
      if (authId == null) {
        print('AuthId is null in stepper state, trying National ID state as fallback');
        final nationalIdState = ref.read(nationalIdProvider);
        if (nationalIdState.authResult != null && nationalIdState.authResult!['id'] != null) {
          print('Found authId in National ID state: ${nationalIdState.authResult!['id']}');
          authId = nationalIdState.authResult!['id'].toString();
          
          // Save it to stepper state
          ref.read(stepperProvider.notifier).saveAuthenticationData(nationalIdState.authResult!);
        }
      }
      
      if (authId == null) {
        print('ERROR: Authentication ID is null!');
        print('This means the authentication data was not properly saved to stepper state.');
        throw Exception('Authentication ID not found. Please complete National ID authentication first.');
      }

      // Prepare registration data
      final registrationData = {
        'authId': authId,
        'accountType': stepperState.selectedAccountType ?? '1', // Default to "1" if not selected
        'initialDeposit': (stepperState.initialDeposit ?? 1000.0).toString(),
        'branch': stepperState.selectedBranch ?? 'FINIFINNE', // Default branch
        'motherName': stepperState.motherName ?? 'N/A',
        'state': stepperState.state ?? 'Addus abeba', // Use saved state from step 1
        'documentName': 'NATIONALID',
        'customerInfoInitialDeposit': '100', // Default value
        'signature': stepperState.signature,
      };

      print('Registration Data: $registrationData');

      // Call the registration service
      final result = await registrationService.submitRegistration(
        authId: authId,
        accountType: stepperState.selectedAccountType ?? '1',
        initialDeposit: (stepperState.initialDeposit ?? 1000.0).toString(),
        branch: stepperState.selectedBranch ?? 'FINIFINNE',
        motherName: stepperState.motherName ?? 'N/A',
        state: stepperState.state ?? 'Addus abeba',
        documentName: 'NATIONALID',
        customerInfoInitialDeposit: '100',
        signature: stepperState.signature,
      );

      // Close loading dialog
      if (!_disposed && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show success dialog with saved authentication data
      if (!_disposed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your account registration has been submitted successfully.'),
                const SizedBox(height: 10),
                Text('Authentication ID: $authId'),
                const SizedBox(height: 5),
                Text('Full Name: ${stepperState.fullName ?? 'N/A'}'),
                const SizedBox(height: 5),
                Text('Email: ${stepperState.email ?? 'N/A'}'),
                const SizedBox(height: 5),
                Text('Phone: ${stepperState.authPhone ?? 'N/A'}'),
                const SizedBox(height: 5),
                Text('Account Type: ${stepperState.selectedAccountType ?? 'Default'}'),
                const SizedBox(height: 5),
                Text('Branch: ${stepperState.selectedBranch ?? 'FINIFINNE'}'),
                const SizedBox(height: 5),
                Text('Mother Name: ${stepperState.motherName ?? 'N/A'}'),
                const SizedBox(height: 5),
                Text('Initial Deposit: ${stepperState.initialDeposit ?? 1000.0} ETB'),
                const SizedBox(height: 10),
                const Text('We will review your application and contact you soon.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (!_disposed) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (!_disposed && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Show error dialog
      if (!_disposed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Failed'),
            content: Text('An error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  if (!_disposed) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
