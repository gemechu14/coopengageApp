// ignore_for_file: use_build_context_synchronously

import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/home/main_page.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/controllers/registration_controller.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/national_id_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/simple_national_id_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/stepper_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/Signature.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/account_type_step.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/additional_information.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/id_information_step.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/registration_summary_page.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/stepper_nav_bar.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/widgets/ultra_simple_national_id_widget.dart';
import 'package:coopengageplus/features/screens/LoginScreen.dart';
import 'package:coopengageplus/shared/widgets/AlertDialog/DialogHelper%20.dart';
import 'package:coopengageplus/shared/widgets/simple_page_loading.dart';
import 'package:dio/dio.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NationalIdentificationWebSocket extends ConsumerStatefulWidget {
  const NationalIdentificationWebSocket({super.key});

  @override
  ConsumerState<NationalIdentificationWebSocket> createState() =>
      _NationalIdRegistrationState();
}

class _NationalIdRegistrationState
    extends ConsumerState<NationalIdentificationWebSocket> {
  final _accountTypeFormKey = GlobalKey<FormState>();

  static const _stepTitles = [
    'National ID Authentication',
    'Additional Information',
    'ID Information',
    'Signature',
    'Account Type',
  ];

  static const _stepIcons = [
    Icons.fingerprint,
    Icons.info_outline,
    Icons.credit_card,
    Icons.edit,
    Icons.account_balance,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(stepperProvider.notifier).reset();
      ref.read(nationalIdProvider.notifier).reset();
      ref.read(simpleNationalIdProvider.notifier).reset();
      ref.read(registrationControllerProvider.notifier).reset();
    });
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _goToMainPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainPage()),
      (route) => false,
    );
  }

  void _handleBack(int activeStep) {
    if (activeStep > 0) {
      ref.read(stepperProvider.notifier).previousStep();
    } else {
      _goToMainPage();
    }
  }

  // ── Step action handlers ────────────────────────────────────────────────

  Future<void> _onNextPressed(int step) async {
    final controller = ref.read(registrationControllerProvider.notifier);

    switch (step) {
      case 0:
        await _handleAuthStepNext(controller);
        break;
      case 1:
        _advanceIfValid(controller.validateAdditionalInfoStep());
        break;
      case 2:
        _advanceIfValid(controller.validateIdInfoStep());
        break;
      case 3:
        ref.read(stepperProvider.notifier).nextStep();
        break;
      case 4:
        await _handleSubmitStep(controller);
        break;
    }
  }

  Future<void> _handleAuthStepNext(
      RegistrationControllerNotifier controller) async {
    final error = controller.validateAuthStep();
    if (error != null) {
      _showError(error);
      return;
    }

    // Existing account check on step 0 is disabled; uncomment the block below to restore.
    /*
    final phone = controller.getPhoneNumber()!;
    if (controller.shouldCheckExistingAccount(phone)) {
      _showFullScreenLoader(
        'Checking Existing Account',
        'Please wait while we verify whether this phone number already has an account.',
      );
      try {
        final accountResponse = await controller.checkExistingAccount(phone);
        final hasExistingAccount = _hasExistingAccount(accountResponse);

        // if (hasExistingAccount && accountResponse != null) {
        //   _dismissDialog();
        //   await _showExistingAccountDialog(phone, accountResponse);
        //   // ref.read(stepperProvider.notifier).nextStep();
        //   return;
        // }
      } catch (e) {
        _dismissDialog();
        _showError(
            'Unable to verify existing account. ${e.toString().replaceFirst("Exception: ", "")}');
        return;
      }
      _dismissDialog();
    }
    */

    ref.read(stepperProvider.notifier).nextStep();
  }

  Future<void> _handleSubmitStep(
      RegistrationControllerNotifier controller) async {
    if (!(_accountTypeFormKey.currentState?.validate() ?? false)) {
      _showError('Please select an account type');
      return;
    }

    final data = controller.buildRegistrationData();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrationSummaryScreen(
          registrationData: data,
          onConfirm: _submitRegistration,
        ),
      ),
    );
  }

  void _advanceIfValid(String? error) {
    if (error != null) {
      _showError(error);
      return;
    }
    ref.read(stepperProvider.notifier).nextStep();
  }

  // ── Registration submission ────────────────────────────────────────────

  Future<void> _submitRegistration() async {
    final controller = ref.read(registrationControllerProvider.notifier);

    final token = await controller.getValidToken();
    if (token == null && context.mounted) {
      DialogHelper.showErrorDialog(
          context, 'Session expired. Please login again.');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Loginscreen()),
        (route) => false,
      );
      return;
    }

    _showLoadingIndicator();
    try {
      await controller.submitRegistration();
      _dismissDialog();
      _showSuccessDialog();
    } on FormatException {
      _dismissDialog();
      DialogHelper.showErrorDialog(context,
          'Server returned an unexpected response. Please try again later.');
    } on DioError catch (e) {
      _dismissDialog();
      final body = e.response?.data?.toString() ?? '';
      final msg = body.startsWith('<html>')
          ? 'Server rejected the request. Please check your input or try again later.'
          : body.isNotEmpty
              ? body
              : 'Registration failed, please try again later.';
      DialogHelper.showErrorDialog(context, msg);
    } catch (e) {
      _dismissDialog();
      DialogHelper.showErrorDialog(
          context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Dialog helpers ──────────────────────────────────────────────────────

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showFullScreenLoader(String title, String subtitle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: SimplePageLoading(title: title, subtitle: subtitle),
      ),
    );
  }

  void _showLoadingIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: cyanblueColor),
      ),
    );
  }

  void _dismissDialog() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: cyanblueColor),
            SizedBox(width: 5),
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
        content: const Text(
          'Thank you. Your registration has been successfully submitted.',
          style: TextStyle(fontSize: 16),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _goToMainPage();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: cyanblueColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _hasExistingAccount(Map<String, dynamic>? response) {
    final resp = response ?? const {};
    final userInfo = resp['userInfo'];
    final accounts =
        userInfo is Map<String, dynamic> ? userInfo['accounts'] : null;
    return accounts is List && accounts.isNotEmpty;
  }

  Future<void> _showExistingAccountDialog(
    String phoneNumber,
    Map<String, dynamic> response,
  ) async {
    final userInfo = (response['userInfo'] as Map<String, dynamic>?) ?? const {};
    final accounts = userInfo['accounts'];
    final firstAccount = accounts is List && accounts.isNotEmpty
        ? accounts.first as Map<String, dynamic>?
        : null;

    final accountTitle =
        firstAccount?['accountTitle']?.toString() ?? 'N/A';
    final accountNumber =
        firstAccount?['accountNumber']?.toString() ?? 'N/A';
    final branchName =
        firstAccount?['branchName']?.toString() ?? 'N/A';

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
          _goToMainPage();
          return false;
        },
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
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
                                border:
                                    Border.all(color: Colors.grey.shade200),
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
                          _goToMainPage();
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

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final stepper = ref.watch(stepperProvider);
    final nationalId = ref.watch(nationalIdProvider);
    final fayda = ref.watch(simpleNationalIdProvider);

    final isAuthenticated = nationalId.isAuthCompleted ||
        (fayda.isCompleted && fayda.userData != null);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(stepper.activeStep);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              _buildStepperHeader(stepper.activeStep),
              _buildContent(stepper.activeStep),
            ],
          ),
        ),
        bottomNavigationBar: StepperNavBar(
          activeStep: stepper.activeStep,
          totalSteps: _stepTitles.length,
          isVisible: stepper.activeStep != 0 || isAuthenticated,
          onPrevious: () => ref.read(stepperProvider.notifier).previousStep(),
          onNext: () => _onNextPressed(stepper.activeStep),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
        onPressed: _goToMainPage,
      ),
      title: const Text(
        'Individual Account',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: cyanblueColor,
        ),
      ),
    );
  }

  Widget _buildStepperHeader(int activeStep) {
    return Container(
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
        activeStep: activeStep,
        lineStyle: LineStyle(
          lineLength: 30,
          lineSpace: 0,
          lineType: LineType.normal,
          defaultLineColor: Colors.grey.shade300,
          finishedLineColor: cyanblueColor,
          lineThickness: 2,
        ),
        stepShape: StepShape.circle,
        disableScroll: true,
        stepBorderRadius: 15,
        borderThickness: 2,
        stepRadius: 15,
        finishedStepTextColor: Colors.white,
        finishedStepBackgroundColor: cyanblueColor,
        activeStepTextColor: cyanblueColor,
        activeStepBackgroundColor: Colors.white,
        showLoadingAnimation: true,
        steps: List.generate(
          _stepTitles.length,
          (i) => EasyStep(
            icon: Icon(_stepIcons[i]),
            title: i == activeStep ? _stepTitles[i] : '',
          ),
        ),
        onStepReached: null,
      ),
    );
  }

  Widget _buildContent(int activeStep) {
    return Expanded(
      child: Container(
        key: ValueKey('content_$activeStep'),
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
        child: activeStep == 0
            ? const UltraSimpleNationalIdWidget()
            : _buildScrollableStep(activeStep),
      ),
    );
  }

  Widget _buildScrollableStep(int step) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildStepWidget(step),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStepWidget(int step) {
    final stepper = ref.watch(stepperProvider);
    switch (step) {
      case 1:
        return const PhoneFanWidget();
      case 2:
        return const IdInformationStep();
      case 3:
        return const SignatureStep();
      case 4:
        return AccountTypeStep(
          selectedAccountType: stepper.selectedAccountType,
          onAccountTypeChanged: (v) =>
              ref.read(stepperProvider.notifier).updateAccountType(v),
          onAccountTypeSelected: (_) {},
          formKey: _accountTypeFormKey,
          customerAge: stepper.customerAge,
          customerGender: stepper.customerGender,
          initialDeposit: stepper.initialDeposit,
          bankingType: stepper.bankingType,
        );
      default:
        return const Center(child: Text('Step not found'));
    }
  }
}
