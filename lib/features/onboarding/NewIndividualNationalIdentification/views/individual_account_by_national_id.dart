// ignore_for_file: use_build_context_synchronously

import 'package:coopengageplus/common_widgets/AlertDialog/DialogHelper%20.dart';
// import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/model/registration_data.dart';
// import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/providers/national_id_provider.dart';
// import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/providers/stepper_provider.dart';
// import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/services/registration_service.dart';
// import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/widgets/Signature.dart';
// import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/widgets/account_type_step.dart';
// import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/widgets/additional_information.dart';
// import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/widgets/national_id_auth_widget.dart';
import 'package:coopengageplus/features/onboarding/NewIndividualNationalIdentification/model/registration_data.dart';
import 'package:coopengageplus/features/onboarding/NewIndividualNationalIdentification/providers/national_id_provider.dart';
import 'package:coopengageplus/features/onboarding/NewIndividualNationalIdentification/providers/stepper_provider.dart';
import 'package:coopengageplus/features/onboarding/NewIndividualNationalIdentification/services/registration_service.dart';
import 'package:coopengageplus/features/onboarding/NewIndividualNationalIdentification/widgets/Signature.dart';
import 'package:coopengageplus/features/onboarding/NewIndividualNationalIdentification/widgets/account_type_step.dart';
import 'package:coopengageplus/features/onboarding/NewIndividualNationalIdentification/widgets/additional_information.dart';
import 'package:coopengageplus/features/onboarding/NewIndividualNationalIdentification/widgets/national_id_auth_widget.dart';
import 'package:coopengageplus/features/onboarding/NewIndividualNationalIdentification/widgets/registration_summary_page.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:coopengageplus/constants/kconstant.dart';

// 1. Add StepConfig class at the top
class StepConfig {
  final String title;
  final Icon icon;
  final Widget Function(BuildContext, WidgetRef) builder;
  StepConfig({required this.title, required this.icon, required this.builder});
}

class NationalIdentificationWebSocket extends ConsumerStatefulWidget {
  const NationalIdentificationWebSocket({Key? key}) : super(key: key);

  @override
  ConsumerState<NationalIdentificationWebSocket> createState() =>
      _IndividualAccountByNationalIdState();
}

class _IndividualAccountByNationalIdState
    extends ConsumerState<NationalIdentificationWebSocket> {
  List<GlobalKey<FormState>> formKeys = [];
  bool _disposed = false;

  // 2. Replace the static steps list with a dynamic one using StepConfig
  late final List<StepConfig> stepConfigs;

  @override
  void initState() {
    super.initState();
    formKeys = List.generate(4, (index) => GlobalKey<FormState>());
    stepConfigs = [
      StepConfig(
        title: 'National ID Auth',
        icon: Icon(Icons.fingerprint),
        builder: (context, ref) => const NationalIdAuthWidget(),
      ),
      StepConfig(
        title: 'Additional Information',
        icon: Icon(Icons.info_outline),
        builder: (context, ref) => const PhoneFanWidget(),
      ),
      StepConfig(
        title: 'Signature',
        icon: Icon(Icons.edit),
        builder: (context, ref) => const SignatureStep(),
      ),
      StepConfig(
        title: 'Account Type',
        icon: Icon(Icons.account_balance),
        builder: (context, ref) => AccountTypeStep(
          selectedAccountType: ref.watch(stepperProvider).selectedAccountType,
          onAccountTypeChanged: (value) {
            ref.read(stepperProvider.notifier).updateAccountType(value);
          },
          onAccountTypeSelected: (accountType) {},
          formKey: formKeys[3],
          customerAge: ref.watch(stepperProvider).customerAge,
          customerGender: ref.watch(stepperProvider).customerGender,
          initialDeposit: ref.watch(stepperProvider).initialDeposit,
          bankingType: ref.watch(stepperProvider).bankingType,
        ),
      ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        ref.read(stepperProvider.notifier).reset();
        ref.read(nationalIdProvider.notifier).reset();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // 3. Refactor the steps and stepper to use stepConfigs
  List<EasyStep> steps = [];

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
      steps = stepConfigs
          .map((config) => EasyStep(title: config.title, icon: config.icon))
          .toList();
      return Scaffold(
        key: ValueKey('stepper_scaffold_ ${stepperState.activeStep}'),
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: cyanblueColor),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainPage()
                  //JointAccountStepperPage(),
                  ),
              (route) => false,
            ),
          ),
          title: const Text(
            'Individual Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: cyanblueColor,
            ),
          ),
          // centerTitle: true,
          // actions: [
          //   if (stepperState.activeStep == 0 && nationalIdState.authUrl != null)
          //     IconButton(
          //       icon: const Icon(Icons.refresh, color: cyanblueColor),
          //       onPressed: () =>
          //           ref.read(nationalIdProvider.notifier).callEsignetApi(),
          //     ),
          // ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Stepper Header - Reduced Height
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  stepRadius: 15,
                  finishedStepTextColor: Colors.white,
                  finishedStepBackgroundColor: cyanblueColor,
                  activeStepTextColor: cyanblueColor,
                  activeStepBackgroundColor: Colors.white,
                  showLoadingAnimation: true,
                  steps: List.generate(
                    steps.length,
                    (index) => EasyStep(
                      icon: steps[index].icon,
                      title: index == stepperState.activeStep
                          ? steps[index].title
                          : '',
                    ),
                  ),
                  onStepReached: null,
                ),
              ),

              // Content Area
              Expanded(
                child: Container(
                  key: ValueKey('content_area_ ${stepperState.activeStep}'),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      ? () {
                          ref.read(stepperProvider.notifier).previousStep();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: stepperState.activeStep > 1
                        ? Colors.grey.shade700
                        : Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(
                          color: stepperState.activeStep > 1
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
                      if (nationalIdState.isAuthCompleted) {
                        if (nationalIdState.authResult != null) {
                          ref
                              .read(stepperProvider.notifier)
                              .saveAuthenticationData(
                                  nationalIdState.authResult!);

                          final updatedState = ref.read(stepperProvider);
                        } else {}
                        ref.read(stepperProvider.notifier).nextStep();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please complete National ID authentication first'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else if (stepperState.activeStep == 1) {
                      final stepperState = ref.read(stepperProvider);
                      if (stepperState.initialDeposit == null ||
                          // stepperState.selectedMaritalStatus == null ||
                          stepperState.motherName == null ||
                          stepperState.motherName!.isEmpty ||
                          stepperState.selectedProductType == null ||
                          stepperState.selectedProductType!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Please fill in all required fields: Initial Deposit, Mother Name, and Product Type'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (stepperState.selectedProductType != null &&
                          stepperState.selectedBranch != null) {
                        ref.read(stepperProvider.notifier).nextStep();
                        final newStep = ref.read(stepperProvider).activeStep;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all required fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else if (stepperState.activeStep == 2) {
                      print("step 2");
                      ref.read(stepperProvider.notifier).nextStep();
                    } else if (stepperState.activeStep == 3) {
                      final currentFormKey = formKeys[3];
                      if (currentFormKey.currentState?.validate() ?? false) {
                        // Build RegistrationData from stepperState
                        final registrationData = RegistrationData(
                            fullName: stepperState.fullName,
                            email: stepperState.email,
                            phone: stepperState.authPhone,
                            accountType: stepperState.selectedAccountType,
                            branch: stepperState.selectedBranch,
                            motherName: stepperState.motherName,
                            initialDeposit:
                                stepperState.initialDeposit?.toString(),
                            dateOfBirth: stepperState.dateOfBirth,
                            productType: stepperState.selectedProductType,
                            documentName: 'NATIONALID',
                            signature: stepperState.signature,
                            sex: stepperState.sex,
                            country: stepperState.country,
                            state: stepperState.state,
                            legalId: stepperState.legalId,
                            bankShare: stepperState.bankShare,
                            customerShare: stepperState.customerShare,
                            title: stepperState.selectedTitle,
                            maritalStatus: stepperState.selectedMaritalStatus);

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrationSummaryScreen(
                              registrationData: registrationData,
                              onConfirm: () async {
                                await _submitRegistration();
                              },
                            ),
                          ),
                        );
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 18),
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
                          final buttonText =
                              stepperState.activeStep == 3 ? 'Submit' : 'Next';
                          print(
                              'Button text for step ${stepperState.activeStep}: $buttonText');
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
                        stepperState.activeStep == 3
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

  Widget _buildContentArea(
      StepperState stepperState, NationalIdState nationalIdState) {
    if (_disposed) return const SizedBox.shrink();

    try {
      print(
          '_buildContentArea - Step: ${stepperState.activeStep}, Auth completed: ${nationalIdState.isAuthCompleted}');

      if (stepperState.activeStep == 0) {
        return const NationalIdAuthWidget();
      } else {
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
      return const Center(
        child: Text(
          'Something went wrong. Please try again.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }

  // 4. Refactor _buildStepContent to use stepConfigs
  Widget _buildStepContent(int step) {
    if (step < 0 || step >= stepConfigs.length) {
      return const Center(child: Text('Step not found'));
    }
    return stepConfigs[step].builder(context, ref);
  }

  // 5. (Optional) Add a helper to add new steps easily
  void addStep(StepConfig config) {
    setState(() {
      stepConfigs.add(config);
      formKeys.add(GlobalKey<FormState>());
    });
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
      var authId = stepperState.authId?.toString();

      if (authId == null) {
        print(
            'AuthId is null in stepper state, trying National ID state as fallback');
        final nationalIdState = ref.read(nationalIdProvider);
        if (nationalIdState.authResult != null &&
            nationalIdState.authResult!['id'] != null) {
          print(
              'Found authId in National ID state: ${nationalIdState.authResult!['id']}');
          authId = nationalIdState.authResult!['id'].toString();

          ref
              .read(stepperProvider.notifier)
              .saveAuthenticationData(nationalIdState.authResult!);
        }
      }

      if (authId == null) {
        print('ERROR: Authentication ID is null!');
        print(
            'This means the authentication data was not properly saved to stepper state.');
        throw Exception(
            'Authentication ID not found. Please complete National ID authentication first.');
      }

      // Prepare registration data
      final registrationData = {
        'authId': authId,
        'accountType': stepperState.selectedAccountType ?? '1',
        // 'bankShare': stepperState.bankShare ?? ,
        // 'customerShare':
        //     stepperState.customerShare, // Default to "1" if not selected
        'initialDeposit': (stepperState.initialDeposit ?? 1000.0).toString(),
        'branch': stepperState.selectedBranch ?? 'FINIFINNE', // Default branch
        'motherName': stepperState.motherName ?? 'N/A',
        'state':
            stepperState.state ?? 'Addis abeba', // Use saved state from step 1
        'documentName': 'NATIONALID',
        // 'customerInfoInitialDeposit': '100', // Default value
        'signature': stepperState.signature,
      };

      print('Registration Data: $registrationData');

      // Call the registration service
      final result = await registrationService.submitRegistration(
        authId: authId,
        accountType: stepperState.selectedAccountType ?? '1',
        initialDeposit: (stepperState.initialDeposit ?? 1000.0).toString(),
        branch: stepperState.selectedBranch ?? 'FINFINNE',
        motherName: stepperState.motherName ?? 'N/A',
        state: stepperState.state ?? 'Addis abeba',
        documentName: 'NATIONALID',
        customerInfoInitialDeposit: '100',
        signature: stepperState.signature,
        title: stepperState.selectedTitle,
      );

      // Close loading dialog
      if (!_disposed && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!_disposed) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: cyanblueColor), // cyan blue
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Confirm Registration',
                  style: TextStyle(
                    fontSize: 15,
                    color: cyanblueColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Are you sure you want to submit your registration?',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Once submitted, your information will be sent for review.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            actions: [
              TextButton(
                onPressed: () {
                  if (!_disposed) {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()
                          //JointAccountStepperPage(),
                          ),
                      (route) => false,
                    );
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: cyanblueColor, // cyan blue
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!_disposed && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!_disposed) {
        DialogHelper.showErrorDialog(
            context, "Registration Failed, please try later");
      }
    }
  }
}
