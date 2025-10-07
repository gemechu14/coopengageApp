import 'package:coopengageplus/customerOnboarding/CorporateAccountOpening/providers/national_id_provider.dart';
import 'package:coopengageplus/customerOnboarding/NewIndividualNationalIdentification/providers/fayda_provider.dart';
import 'package:coopengageplus/customerOnboarding/NewIndividualNationalIdentification/providers/simple_national_id_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/stepper_provider.dart';
import '../../../widget/ReusableTextFormField.dart';

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
      final faydaState = ref.read(simpleNationalIdProvider); //
      // final stepperState = ref.read(stepperProvider);
      // legalIdController.text = stepperState.legalId ?? '';
      // legalIdController.text =    ;
      legalIdController.text = faydaState.userData!.sub.toString();
      ref.read(stepperProvider.notifier).updateLegalId(legalIdController.text);
      issueAuthorityController.text = stepperState.issueAuthority ?? 'ET';
      issueDateController.text = stepperState.issueDate ?? '';
      expireDateController.text = stepperState.expireDate ?? '';
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now()
          .subtract(const Duration(days: 365)), // Default to 1 year ago
      firstDate: DateTime(1900), // Allow dates from 1900
      lastDate: DateTime.now(), // Last date is today
    );
    if (picked != null) {
      setState(() {
        issueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      // Update stepper provider
      ref
          .read(stepperProvider.notifier)
          .updateIssueDate(issueDateController.text);
      // Clear validation error
      _clearError('issueDate');
    }
  }

  Future<void> _selectExpireDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now()
          .add(const Duration(days: 365 * 5)), // Default to 5 years from now
      firstDate: DateTime.now(), // First date is today
      lastDate: DateTime.now()
          .add(const Duration(days: 365 * 12)), // 12 years from today
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
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
          const SizedBox(height: 24),

          // Legal ID
          _buildLabel("Legal ID *"),
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

          // Issue Authority
          _buildLabel("Issue Authority"),
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

          // Issue Date
          _buildLabel("Issue Date"),
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

          // Expire Date
          _buildLabel("Expire Date"),
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
