// ignore_for_file: use_build_context_synchronously

import 'package:coopengageplus/features/screens/LoginScreen.dart';
import 'package:coopengageplus/shared/widgets/AlertDialog/DialogHelper%20.dart';
import 'package:coopengageplus/shared/widgets/simple_page_loading.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/model/registration_data.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/fayda_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/national_id_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/simple_national_id_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/stepper_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/services/registration_service.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/Signature.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/account_type_step.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/additional_information.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/registration_summary_page.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/ultra_simple_national_id_widget.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/id_information_step.dart';
import 'package:coopengageplus/features/home/main_page.dart';
import 'package:coopengageplus/core/utils/checkToken.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  bool _existingAccountChecked = false;
  String? _lastCheckedPhone;
  final RegistrationService _registrationService = RegistrationService();

  // 2. Replace the static steps list with a dynamic one using StepConfig
  late final List<StepConfig> stepConfigs;

  @override
  void initState() {
    super.initState();
    formKeys = List.generate(5, (index) => GlobalKey<FormState>());
    stepConfigs = [
      StepConfig(
          title: 'National ID Authetication',
          icon: Icon(Icons.fingerprint),
          builder: (context, ref) =>
              // const FaydaAuthWidget()
              const UltraSimpleNationalIdWidget()
          // const NationalIdAuthWidget(),
          ),
      StepConfig(
        title: 'Additional Information',
        icon: Icon(Icons.info_outline),
        builder: (context, ref) => const PhoneFanWidget(),
      ),
      StepConfig(
        title: 'ID Information',
        icon: Icon(Icons.credit_card),
        builder: (context, ref) => const IdInformationStep(),
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
          formKey: formKeys[4],
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
        ref.read(simpleNationalIdProvider.notifier).reset();
        _existingAccountChecked = false;
        _lastCheckedPhone = null;
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// This flow is often opened with [pushAndRemoveUntil] clearing the stack, so
  /// the system back button would otherwise close the app. Match sensible back:
  /// pop if a route exists, else previous stepper step, else same as AppBar → MainPage.
  void _handleSystemBack() {
    if (_disposed || !mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    final step = ref.read(stepperProvider).activeStep;
    if (step > 0) {
      ref.read(stepperProvider.notifier).previousStep();
      return;
    }
    _navigateToMainPage();
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
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) return;
          _handleSystemBack();
        },
        child: Scaffold(
        key: ValueKey('stepper_scaffold_ ${stepperState.activeStep}'),
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          scrolledUnderElevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
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
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Stepper header (package default title under active step — matches original UX).
              Container(
                padding: const EdgeInsets.fromLTRB(1, 1, 1, 0),
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
                   disableScroll :true,
                  stepBorderRadius: 15,
                  borderThickness: 2,
                  // padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
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
                          ? (steps[index].title ?? '')
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
        bottomNavigationBar: Builder(builder: (context) {
          final faydaState = ref.watch(simpleNationalIdProvider);
          final bool step0Authenticated = nationalIdState.isAuthCompleted ||
              (faydaState.isCompleted && faydaState.userData != null);

          // Step 0: hide Previous/Next until correct authentication data is received.
          if (stepperState.activeStep == 0 && !step0Authenticated) {
            return const SizedBox.shrink();
          }

          return Container(
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
          // Base inset with content card; extra margin on Previous (left) / Next (right); room below buttons
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Previous — same outer shell (14 + 1.5 ring + inner 12.5) for disabled & enabled; ring grey vs cyan
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: stepperState.activeStep > 0
                        ? null
                        : Colors.grey.shade300,
                    gradient: stepperState.activeStep > 0
                        ? LinearGradient(
                            colors: [
                              cyanblueColor,
                              cyanblueColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    boxShadow: stepperState.activeStep > 0
                        ? [
                            BoxShadow(
                              color: cyanblueColor.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.5),
                    ),
                    child: ElevatedButton(
                      onPressed: stepperState.activeStep > 0
                          ? () {
                              ref
                                  .read(stepperProvider.notifier)
                                  .previousStep();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white,
                        foregroundColor: Colors.transparent,
                        disabledForegroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        minimumSize: const Size(118, 42),
                        maximumSize: const Size(double.infinity, 42),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.5),
                        ),
                        elevation: 0,
                        splashFactory: InkRipple.splashFactory,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _gradientIconOrMuted(
                            stepperState.activeStep > 0,
                            Icons.arrow_back_ios_new_rounded,
                            14,
                          ),
                          const SizedBox(width: 6),
                          _gradientLabelOrMuted(
                            stepperState.activeStep > 0,
                            'Previous',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Next / Submit — extra margin from screen / bar right
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [
                        cyanblueColor,
                        cyanblueColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cyanblueColor.withOpacity(0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                  onPressed: () async {
                    if (_disposed) return;

                    // print('Current step: ${stepperState.activeStep}');

                    if (stepperState.activeStep == 0) {
                      // Check both old National ID system and new Fayda system

                      final faydaState = ref.read(simpleNationalIdProvider);
                      // final faydaState = ref.read(faydaProvider);
                      bool isAuthenticated = false;

                      // Check old National ID system first
                      if (nationalIdState.isAuthCompleted) {
                        if (nationalIdState.authResult != null) {
                          ref
                              .read(stepperProvider.notifier)
                              .saveAuthenticationData(
                                  nationalIdState.authResult!);
                        }
                        isAuthenticated = true;
                      }
                      // Check new Fayda system as fallback
                      else if (faydaState.isCompleted &&
                          faydaState.userData != null) {
                        print(
                            '🎯 [Stepper] Fayda authentication detected, proceeding...');

                        // Convert Fayda data to expected format
                        final faydaAuthData = {
                          'id': faydaState.userData!.sub,
                          'name': faydaState.userData!.name,
                          'email': faydaState.userData!.email,
                          'phone_number': faydaState.userData!.phoneNumber,
                          'gender': faydaState.userData!.gender,
                          'birthdate': faydaState.userData!.birthdate,
                          'address': {
                            'country': faydaState.userData!.address?.country ??
                                'Unknown',
                            'region': faydaState.userData!.address?.region ??
                                'Unknown',
                          },
                        };

                        ref
                            .read(stepperProvider.notifier)
                            .saveAuthenticationData(faydaAuthData);
                        isAuthenticated = true;
                      }

                      if (isAuthenticated) {
                        final phoneNumber =
                            faydaState.userData?.phoneNumber ??
                                stepperState.authPhone ??
                                '';
                        final sanitizedPhone = phoneNumber.trim();

                        if (sanitizedPhone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Phone number is missing. Unable to check existing accounts.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final shouldCheckExistingAccount =
                            !_existingAccountChecked ||
                                _lastCheckedPhone != sanitizedPhone;

                        if (shouldCheckExistingAccount) {
                          final accountResponse =
                              await _fetchExistingAccountData(sanitizedPhone);
                          if (accountResponse == null) {
                            return;
                          }

                          final userInfo = accountResponse['userInfo'];
                          final accounts = userInfo is Map<String, dynamic>
                              ? userInfo['accounts']
                              : null;
                          final hasAccount =
                              accounts is List && accounts.isNotEmpty;

                          // if (hasAccount) {
                          //   await _showExistingAccountDialog(
                          //       sanitizedPhone, accountResponse);
                          //   return;
                          // }

                          _existingAccountChecked = true;
                          _lastCheckedPhone = sanitizedPhone;
                        }

                        ref.read(stepperProvider.notifier).nextStep();
                      } else {
                        //  print(faydaAuthData);
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
                      // ID Information step validation
                      final stepperState = ref.read(stepperProvider);
                      if (stepperState.legalId == null ||
                          stepperState.legalId!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in the Legal ID field'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      ref.read(stepperProvider.notifier).nextStep();
                    } else if (stepperState.activeStep == 3) {
                      print("step 3 - signature");
                      print(stepperState.activeStep);
                      ref.read(stepperProvider.notifier).nextStep();
                    } else if (stepperState.activeStep == 4) {
                      final currentFormKey = formKeys[4];
                      if (currentFormKey.currentState?.validate() ?? false) {
                        // Get National ID data from SimpleFaydaService
                        final faydaState = ref.read(simpleNationalIdProvider);

                        final registrationData = RegistrationData(
                            fullName: faydaState.userData?.name ??
                                stepperState.fullName ??
                                '',
                            email: faydaState.userData?.email ??
                                stepperState.email ??
                                '',
                            phone: faydaState.userData?.phoneNumber ??
                                stepperState.authPhone ??
                                '',
                            accountType: stepperState.selectedAccountType,
                            branch: stepperState.selectedBranch,
                            motherName: stepperState.motherName,
                            initialDeposit:
                                stepperState.initialDeposit?.toString(),
                            dateOfBirth: faydaState.userData?.birthdate ??
                                stepperState.dateOfBirth,
                            productType: stepperState.selectedProductType,
                            documentName: 'NATIONALID',
                            signature: stepperState.signature,
                            sex:
                                faydaState.userData?.gender ?? stepperState.sex,
                            // country: faydaState.userData?.address?.country ??
                            //     stepperState.country ?? "ETHIOPIA",


                              

                            // state: faydaState.userData?.address?.region ??
                            //     stepperState.state  ?? "Addis Ababa",
                            // zoneSubCity: faydaState
                            //     .userData?.address?.zone ?? "Addis Ababa", // Add zone data
                            // streetAddress: faydaState
                            //     .userData?.address?.woreda ?? "Addis Ababa", // Add woreda data

                            country: getValue(faydaState.userData?.address?.country, stepperState.country, "ETHIOPIA"),
                              state: getValue(faydaState.userData?.address?.region, stepperState.state, "Addis Ababa"),
                              zoneSubCity: getValue(faydaState.userData?.address?.zone, null, "Addis Ababa"),
                              streetAddress: getValue(faydaState.userData?.address?.woreda, null, "Addis Ababa"),

                            // legalId: stepperState.legalId,
                            bankShare: stepperState.bankShare,
                            customerShare: stepperState.customerShare,
                            title: stepperState.selectedTitle,
                            photo: faydaState.userData?.picture,
                            // Use the saved picture path
                            maritalStatus: stepperState.selectedMaritalStatus,
                            // legalId: faydaState.userData?.sub ?? '',
                            legalId: stepperState.legalId ?? '',
                            issueAuthority: stepperState.issueAuthority ?? '',
                            expirayDate: stepperState.expireDate ?? '',
                            issueDate: stepperState.issueDate ?? '');

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
                        horizontal: 20, vertical: 12),
                    minimumSize: const Size(118, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(
                        builder: (context) {
                          final buttonText =
                              stepperState.activeStep == 4 ? 'Submit' : 'Next';
                          print(
                              'Button text for step ${stepperState.activeStep}: $buttonText');
                          return Text(
                            buttonText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        stepperState.activeStep == 4
                            ? Icons.check
                            : Icons.arrow_forward_ios_rounded,
                        size: 14,
                      ),
                    ],
                  ),
                ),
                ),
              ),
            ],
          ),
        );
        }),
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

String getValue(String? primary, String? fallback, String defaultValue) {
  if (primary != null && primary.isNotEmpty) return primary;
  if (fallback != null && fallback.isNotEmpty) return fallback;
  return defaultValue;
}
  Widget _buildContentArea(
      StepperState stepperState, NationalIdState nationalIdState) {
    if (_disposed) return const SizedBox.shrink();

    try {
      print(
          '_buildContentArea - Step: ${stepperState.activeStep}, Auth completed: ${nationalIdState.isAuthCompleted}');

      if (stepperState.activeStep == 0) {
        return const UltraSimpleNationalIdWidget();
        // const NationalIdAuthWidget();
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

  Future<Map<String, dynamic>?> _fetchExistingAccountData(
      String phoneNumber) async {
    if (_disposed) return null;

    bool loaderVisible = false;

    if (mounted) {
      loaderVisible = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Dialog(
          insetPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: SimplePageLoading(
            title: 'Checking Existing Account',
            subtitle:
                'Please wait while we verify whether this phone number already has an account.',
          ),
        ),
      );
    }

    try {
      final result =
          await _registrationService.checkAccountExist(phoneNumber);
      return result;
    } catch (e) {
      if (!_disposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Unable to verify existing account. ${e.toString().replaceFirst('Exception: ', '')}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      if (loaderVisible && !_disposed && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  Future<void> _showExistingAccountDialog(
      String phoneNumber, Map<String, dynamic> response) async {
    if (_disposed) return;

    final userInfo =
        (response['userInfo'] as Map<String, dynamic>?) ?? const {};
    final accounts = userInfo['accounts'];
    final firstAccount = accounts is List && accounts.isNotEmpty
        ? (accounts.first as Map<String, dynamic>?)
        : null;

    final accountTitle = firstAccount?['accountTitle']?.toString() ?? 'N/A';
    final accountNumber = firstAccount?['accountNumber']?.toString() ?? 'N/A';
    final branchName = firstAccount?['branchName']?.toString() ?? 'N/A';

    Widget infoRow(String label, String value, {IconData? icon}) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? Icons.info_outline, size: 16, color: cyanblueColor),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                  children: [
                    TextSpan(
                      text: '$label: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textInfoColor,
                      ),
                    ),
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: blueColor,
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

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async {
          _navigateToMainPage();
          return false;
        },
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: SizedBox(
            width: MediaQuery.of(dialogContext).size.width,
            height: MediaQuery.of(dialogContext).size.height,
            child: Scaffold(
              backgroundColor: const Color(0xFFF4F8FF),
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cyanblueColor,
                            cyanblueColor.withOpacity(0.88),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cyanblueColor.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              color: Colors.white, size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Existing Account Found',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Text(
                                'A customer account already exists with this phone number. Please review the details below.',
                                style: TextStyle(
                                  color: textInfoColor,
                                  fontSize: 13.5,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            infoRow('Phone', phoneNumber,
                                icon: Icons.phone_outlined),
                            infoRow('Account Title', accountTitle,
                                icon: Icons.person_outline),
                            infoRow('Account Number', accountNumber,
                                icon: Icons.credit_card_outlined),
                            infoRow('Branch', branchName,
                                icon: Icons.location_on_outlined),
                            const SizedBox(height: 10),
                            // Container(
                            //   padding: const EdgeInsets.all(12),
                            //   decoration: BoxDecoration(
                            //     color: Colors.orange.withOpacity(0.1),
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   child: const Row(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Icon(Icons.info_outline,
                            //           color: Colors.orange, size: 18),
                            //       SizedBox(width: 8),
                            //       Expanded(
                            //         child: Text(
                            //           'Please visit the main page to manage the existing account.',
                            //           style: TextStyle(
                            //             fontSize: 13,
                            //             color: textInfoColor,
                            //             height: 1.35,
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          
                          
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _navigateToMainPage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cyanblueColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Go to Main Page',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Matches Next button fill gradient (border + text on Previous).
  LinearGradient get _stepperCyanGradient => LinearGradient(
        colors: [
          cyanblueColor,
          cyanblueColor.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  Widget _gradientLabelOrMuted(bool enabled, String text) {
    if (!enabled) {
      return Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: cyanblueColor.withOpacity(0.38),
        ),
      );
    }
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => _stepperCyanGradient.createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _gradientIconOrMuted(bool enabled, IconData icon, double size) {
    if (!enabled) {
      return Icon(
        icon,
        size: size,
        color: cyanblueColor.withOpacity(0.38),
      );
    }
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => _stepperCyanGradient.createShader(bounds),
      child: Icon(icon, size: size, color: Colors.white),
    );
  }

  void _navigateToMainPage() {
    if (_disposed) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
      (route) => false,
    );
  }

  // Submit registration
  Future<void> _submitRegistration() async {
    if (_disposed) return;

///////

    final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
    );

    final token = await storage.read(key: 'token');

    if (token == null || isTokenExpired(token)) {
      if (context.mounted) {
        DialogHelper.showErrorDialog(
          context,
          "Session expired. Please login again.",
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Loginscreen()),
          (route) => false,
        );
      }
      return; // Stop further execution
    }

    ///

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

      // If still null, try Fayda authentication data as fallback
      if (authId == null) {
        print(
            'AuthId still null, trying Fayda authentication state as fallback');
        final faydaState = ref.read(faydaProvider);
        if (faydaState.isCompleted &&
            faydaState.userData != null &&
            faydaState.userData!.sub.isNotEmpty) {
          print('Found authId in Fayda state: ${faydaState.userData!.sub}');
          authId = faydaState.userData!.sub;

          // Convert Fayda data to expected format for stepper
          final faydaAuthData = {
            'id': faydaState.userData!.sub,
            'name': faydaState.userData!.name,
            'email': faydaState.userData!.email,
            'phone_number': faydaState.userData!.phoneNumber,
            'gender': faydaState.userData!.gender,
            'birthdate': faydaState.userData!.birthdate,
            'address': {
              'country': faydaState.userData!.address?.country ?? 'Unknown',
              'region': faydaState.userData!.address?.region ?? 'Unknown',
            },
          };

          ref
              .read(stepperProvider.notifier)
              .saveAuthenticationData(faydaAuthData);
        }
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

      // Get National ID data for registration
      final faydaState = ref.read(simpleNationalIdProvider);

      // Call the registration service
      final result = await registrationService.submitRegistration(
          accountType: stepperState.selectedAccountType ?? '1',
          initialDeposit: (stepperState.initialDeposit ?? 1000.0).toString(),
          branch: stepperState.selectedBranch ?? 'FINFINNE',
          motherName: stepperState.motherName ?? 'N/A',
          state: faydaState.userData?.address?.region ??
              stepperState.state ??
              'Addis abeba',
          documentName: 'NATIONALID',
          customerInfoInitialDeposit: '100',
          signature: stepperState.signature,
          title: stepperState.selectedTitle,
          fullName: faydaState.userData?.name ?? stepperState.fullName ?? '',
          Sex: faydaState.userData?.gender ?? stepperState.sex ?? '',
          phone: faydaState.userData?.phoneNumber ??
              stepperState.phoneNumber ??
              '',
          email: faydaState.userData?.email ?? stepperState.email ?? '',
          dateOfBirth:
              faydaState.userData?.birthdate ?? stepperState.dateOfBirth ?? '',
          // country: faydaState.userData?.address?.country ??
          //     stepperState.country ??
          //     '',
          // zoneSubCity: faydaState.userData?.address?.zone ?? '',
          // streetAddress: faydaState.userData?.address?.woreda ?? '',

          country: getValue(faydaState.userData?.address?.country, stepperState.country, "ETHIOPIA"),
      // state: getValue(faydaState.userData?.address?.region, stepperState.state, "Addis Ababa"),
           zoneSubCity: getValue(faydaState.userData?.address?.zone, null, ""),
       streetAddress: getValue(faydaState.userData?.address?.woreda, null, ""),
          photo: faydaState.userData?.picture ?? '',
          // legalId: faydaState.userData?.sub ?? '',
        
          currency:"ETB",
          surname: getSurname(faydaState.userData?.name ?? stepperState.fullName ?? ''),
          
          legalId: stepperState.legalId ?? '',
          issueAuthority: stepperState.issueAuthority ?? 'ET',
          expirayDate: stepperState.expireDate ?? '',
          issueDate: stepperState.issueDate ?? '');

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
                    'Thank you. Your registration has been successfully submitted.',
                    style: TextStyle(fontSize: 16),
                  ),

                  // Text(
                  //   'Thank you for s submitted your registration.',
                  //   style: TextStyle(fontSize: 16),
                  // ),
                  SizedBox(height: 10),
                ]),
        
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

      String errorMessage = "Registration failed, please try again later.";

      // If e is a FormatException, it's probably HTML or invalid JSON
      if (e is FormatException) {
        print("⚠️ FormatException caught: ${e.message}");
        errorMessage =
            "Server returned an unexpected response. Please try again later.";
      }
      // If using Dio or HTTP client, handle HTTP errors
      else if (e is DioError) {
        final responseData = e.response?.data?.toString() ?? '';
        if (responseData.startsWith('<html>')) {
          errorMessage =
              "Server rejected the request. Please check your input or try again later.";
        } else if (responseData.isNotEmpty) {
          errorMessage = responseData;
        }
      }
      // fallback for other exceptions
      else {
        final msg = e.toString().replaceFirst('Exception: ', '');
        if (msg.isNotEmpty) errorMessage = msg;
      }

      print("⚠️ Registration Error: $errorMessage");

      if (!_disposed) {
        DialogHelper.showErrorDialog(context, errorMessage);
      }
    }


  }
  


String getSurname(String fullName) {
  List<String> parts = fullName.trim().split(' ');
  return parts.length > 1 ? parts[1] : ''; // second word is the father’s name
}
}
