import 'package:coopengageplus/features/onboarding/customer/CorporateAccountOpening/providers/national_id_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/fayda_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/simple_national_id_provider.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/shared/widgets/app_label.dart';
import 'package:coopengageplus/shared/widgets/ReusableTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/stepper_provider.dart';

class IdInformationStep extends ConsumerStatefulWidget {
  const IdInformationStep({Key? key}) : super(key: key);

  @override
  ConsumerState<IdInformationStep> createState() => _IdInformationStepState();
}

class _IdInformationStepState extends ConsumerState<IdInformationStep> {
  late TextEditingController legalIdController;
  late TextEditingController issueAuthorityController;
  late TextEditingController issueDateController;
  late TextEditingController expireDateController;
  late TextEditingController fanController;

  Map<String, String> validationErrors = {};
  // final faydaState = ref.read(simpleNationalIdProvider);
  @override
  void initState() {
    super.initState();
    legalIdController = TextEditingController();
    issueAuthorityController = TextEditingController();
    issueDateController = TextEditingController();
    expireDateController = TextEditingController();
    fanController = TextEditingController();

    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stepperState = ref.read(stepperProvider);
      final faydaState = ref.read(simpleNationalIdProvider);
      legalIdController.text = faydaState.userData!.sub.toString();
      ref.read(stepperProvider.notifier).updateLegalId(legalIdController.text);
      issueAuthorityController.text = stepperState.issueAuthority ?? 'ET';

      final now = DateTime.now();
      final defaultIssueDate = DateTime(now.year - 1, now.month, now.day);
      final defaultExpireDate = DateTime(defaultIssueDate.year + 7, defaultIssueDate.month, defaultIssueDate.day);
      final dateFormat = DateFormat('yyyy-MM-dd');

      if (stepperState.issueDate == null || stepperState.issueDate!.isEmpty) {
        issueDateController.text = dateFormat.format(defaultIssueDate);
        ref.read(stepperProvider.notifier).updateIssueDate(issueDateController.text);
      } else {
        issueDateController.text = stepperState.issueDate!;
      }

      if (stepperState.expireDate == null || stepperState.expireDate!.isEmpty) {
        expireDateController.text = dateFormat.format(defaultExpireDate);
        ref.read(stepperProvider.notifier).updateExpireDate(expireDateController.text);
      } else {
        expireDateController.text = stepperState.expireDate!;
      }

      fanController.text = stepperState.fanNumber;
    });
  }

  @override
  void dispose() {
    legalIdController.dispose();
    issueAuthorityController.dispose();
    issueDateController.dispose();
    expireDateController.dispose();
    fanController.dispose();
    super.dispose();
  }

  Future<void> _selectIssueDate(BuildContext context) async {
    final DateTime? picked = await _showStyledDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final expireDate = DateTime(picked.year + 7, picked.month, picked.day);
      setState(() {
        issueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        expireDateController.text = DateFormat('yyyy-MM-dd').format(expireDate);
      });
      ref
          .read(stepperProvider.notifier)
          .updateIssueDate(issueDateController.text);
      ref
          .read(stepperProvider.notifier)
          .updateExpireDate(expireDateController.text);
      _clearError('issueDate');
      _clearError('expireDate');
    }
  }

  Future<void> _selectExpireDate(BuildContext context) async {
    final DateTime? picked = await _showStyledDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365 * 5)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 12)),
    );
    if (picked != null) {
      setState(() {
        expireDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      // Update stepper provider
      ref
          .read(stepperProvider.notifier)
          .updateExpireDate(expireDateController.text);
      // Clear validation error
      _clearError('expireDate');
    }
  }

  void _clearError(String field) {
    setState(() {
      validationErrors.remove(field);
    });
  }

  Future<DateTime?> _showStyledDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (ctx, child) {
        final baseTheme = Theme.of(ctx);
        return Theme(
          data: baseTheme.copyWith(
            colorScheme: baseTheme.colorScheme.copyWith(
              primary: cyanblueColor,
              onPrimary: Colors.white,
              secondary: cyanblueColor,
            ),
            dialogTheme: baseTheme.dialogTheme.copyWith(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }


  Widget _buildErrorDisplay(String field) {
    if (validationErrors[field] != null &&
        validationErrors[field]!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0, left: 12.0),
        child: Text(
          validationErrors[field]!,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  bool validateForm() {
    setState(() {
      validationErrors.clear();
    });

    bool isValid = true;

    // Validate Legal ID (required)
    if (legalIdController.text.trim().isEmpty) {
      validationErrors['legalId'] = 'Legal ID is required';
      isValid = false;
    }

    // Validate FAN (get from stepper provider - should be filled from authentication or manual entry)
    final stepperState = ref.read(stepperProvider);
    if (stepperState.fanNumber.isEmpty) {
      validationErrors['fan'] = 'FAN number is required';
      isValid = false;
    } else if (stepperState.fanNumber.length != 16) {
      validationErrors['fan'] = 'FAN number must be exactly 16 digits';
      isValid = false;
    } else if (!RegExp(r'^\d{16}$').hasMatch(stepperState.fanNumber)) {
      validationErrors['fan'] = 'FAN number must contain only digits';
      isValid = false;
    }

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final stepperState = ref.watch(stepperProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          // const Text(
          //   'ID Information',
          //   style: TextStyle(
          //     fontSize: 24,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.blue,
          //   ),
          // ),
          // const SizedBox(height: 8),
          // const Text(
          //   'Please provide your identification details',
          //   style: TextStyle(
          //     fontSize: 16,
          //     color: Colors.grey,
          //   ),
          // ),
          // const SizedBox(height: 24),

          const AppLabel("Legal ID", isRequired: true),
          ReusableTextFormField(
            hintText: "Legal ID",
            controller: legalIdController,
            keyboardType: TextInputType.text,
            errorMessage: validationErrors['legalId'] ?? '',
            leadingIcon: Icons.badge,
            isRequired: true,
            onChanged: (value) {
              // Update stepper provider
              ref.read(stepperProvider.notifier).updateLegalId(value);
              // Clear validation errors when user makes changes
              if (value.isNotEmpty) {
                _clearError('legalId');
              }
            },
          ),
          _buildErrorDisplay('legalId'),
          const SizedBox(height: 16),

          const AppLabel("Issue Authority"),
          ReusableTextFormField(
            hintText: "Issue Authority",
            controller: issueAuthorityController,
            keyboardType: TextInputType.text,
            errorMessage: validationErrors['issueAuthority'] ?? '',
            leadingIcon: Icons.verified,
            isRequired: false,
            onChanged: (value) {
              // Update stepper provider
              ref.read(stepperProvider.notifier).updateIssueAuthority(value);
              // Clear validation errors when user makes changes
              if (value.isNotEmpty) {
                _clearError('issueAuthority');
              }
            },
          ),
          _buildErrorDisplay('issueAuthority'),
          const SizedBox(height: 16),

          const AppLabel("Issue Date"),
          GestureDetector(
            onTap: () => _selectIssueDate(context),
            child: AbsorbPointer(
              child: ReusableTextFormField(
                hintText: "Issue Date",
                controller: issueDateController,
                keyboardType: TextInputType.none,
                errorMessage: validationErrors['issueDate'] ?? '',
                leadingIcon: Icons.calendar_today,
                isRequired: false,
              ),
            ),
          ),
          _buildErrorDisplay('issueDate'),
          const SizedBox(height: 16),

          const AppLabel("Expire Date"),
          GestureDetector(
            onTap: () => _selectExpireDate(context),
            child: AbsorbPointer(
              child: ReusableTextFormField(
                hintText: "Expire Date",
                controller: expireDateController,
                keyboardType: TextInputType.none,
                errorMessage: validationErrors['expireDate'] ?? '',
                leadingIcon: Icons.event_busy,
                isRequired: false,
              ),
            ),
          ),
          _buildErrorDisplay('expireDate'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Method to validate this step (can be called from parent)
  bool validate() {
    return validateForm();
  }
}
