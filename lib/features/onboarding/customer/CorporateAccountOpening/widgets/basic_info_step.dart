// import 'package:coopengageplus/features/onboarding/corporate/corporateAccount.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/shared/widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/core/constants/listConstants.dart';
import 'package:coopengageplus/shared/widgets/ReusableTextFormField.dart';
import 'package:coopengageplus/features/onboarding/customer/CorporateAccountOpening/providers/stepper_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/CorporateAccountOpening/services/tin_verification_service.dart';

class BasicInfoStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState>? formkey;

  const BasicInfoStep({Key? key, this.formkey}) : super(key: key);

  @override
  ConsumerState<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends ConsumerState<BasicInfoStep> {
  String? selectedProductType;
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController tinNumberController = TextEditingController();
  final TextEditingController dateOfEstabilishmentController =
      TextEditingController();
  bool companyNameTouched = false;

  // TIN verification state
  final TinVerificationService _tinService = TinVerificationService();
  bool _isVerifyingTin = false;

  // Method to validate the form - can be called from parent
  bool validateForm() {
    final stepperState = ref.read(stepperProvider);

    // Check if form is valid
    final isFormValid = widget.formkey?.currentState?.validate() ?? false;

    // Check required fields from provider state
    final hasProductType = stepperState.selectedProductType != null;
    final hasCompanyName = (stepperState.companyName ?? '').trim().isNotEmpty;
    final hasPhoneNumber =
        (stepperState.companyPhoneNumber ?? '').trim().isNotEmpty;

    return isFormValid && hasProductType && hasCompanyName && hasPhoneNumber;
  }

  // Method to get validation errors
  List<String> getValidationErrors() {
    final stepperState = ref.read(stepperProvider);
    List<String> errors = [];

    if (stepperState.selectedProductType == null) {
      errors.add('Please select a product type');
    }
    if ((stepperState.companyName ?? '').trim().isEmpty) {
      errors.add('Please enter company name');
    }
    if ((stepperState.companyPhoneNumber ?? '').trim().isEmpty) {
      errors.add('Please enter phone number');
    }

    return errors;
  }

  // Method to trigger validation and show errors
  void triggerValidation() {
    setState(() {
      companyNameTouched = true;
    });

    // Trigger form validation
    widget.formkey?.currentState?.validate();
  }

  // Method to force validation UI updates - call this from parent
  void forceValidationUI() {
    setState(() {
      companyNameTouched = true;
    });
  }

  @override
  void dispose() {
    companyNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    tinNumberController.dispose();
    dateOfEstabilishmentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    dateOfEstabilishmentController.addListener(() {
      final notifier = ref.read(stepperProvider.notifier);
      notifier.updateCompanyDateOfEstablishment(
          dateOfEstabilishmentController.text);
    });

    // Reset verification when TIN changes
    tinNumberController.addListener(() {
      final stepperState = ref.read(stepperProvider);
      if (stepperState.isTinVerified) {
        ref.read(stepperProvider.notifier).resetTinVerification();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stepperState = ref.read(stepperProvider);
      if (stepperState.selectedProductType == null) {
        ref
            .read(stepperProvider.notifier)
            .updateProductType(ListContants.productType.first);
      }
    });
  }

  /// Verify TIN Number
  Future<void> _verifyTinNumber() async {
    final tinNumber = tinNumberController.text.trim();

    // Validate TIN format
    if (tinNumber.isEmpty) {
      _showSnackBar('Please enter TIN number', isError: true);
      return;
    }

    if (tinNumber.length != 10) {
      _showSnackBar('TIN number must be 10 digits', isError: true);
      return;
    }

    setState(() {
      _isVerifyingTin = true;
    });
    ref.read(stepperProvider.notifier).setTinVerificationError(null);

    try {
      print('Starting TIN verification for: $tinNumber');

      final response = await _tinService.verifyTinNumber(tinNumber);

      print('TIN Verification successful!');
      print('Business Name: ${response.businessName}');
      print('Registration Date: ${response.regDate}');

      // Format date to yyyy-mm-dd
      String formattedDate = _formatDate(response.regDate);
      print('Formatted Date: $formattedDate');

      // Update controllers with verified data
      companyNameController.text = response.businessName;
      dateOfEstabilishmentController.text = formattedDate;

      // Update provider state
      final notifier = ref.read(stepperProvider.notifier);
      notifier.updateCompanyName(response.businessName);
      notifier.updateCompanyDateOfEstablishment(formattedDate);

      setState(() {
        _isVerifyingTin = false;
      });
      ref.read(stepperProvider.notifier).setTinVerified(true);

      _showSnackBar('TIN verified successfully!', isError: false);
    } catch (e) {
      print('TIN Verification failed: $e');

      String errorMessage = e.toString().replaceAll('Exception: ', '');

      setState(() {
        _isVerifyingTin = false;
      });
      ref.read(stepperProvider.notifier).setTinVerificationError(errorMessage);

      _showSnackBar(errorMessage, isError: true);
    }
  }

  /// Format date from "3/15/2019" to "2019-03-15"
  String _formatDate(String dateString) {
    try {
      // Parse date in format "M/d/yyyy" or "M/dd/yyyy"
      final parts = dateString.split('/');
      if (parts.length != 3) return dateString;

      final month = parts[0].padLeft(2, '0');
      final day = parts[1].padLeft(2, '0');
      final year = parts[2];

      return '$year-$month-$day';
    } catch (e) {
      print('Date formatting error: $e');
      return dateString; // Return original if formatting fails
    }
  }

  /// Check if TIN is valid for verification
  bool get _isTinValid {
    final tin = tinNumberController.text.trim();
    return tin.length == 10 && RegExp(r'^\d{10}$').hasMatch(tin);
  }

  /// Show snackbar message
  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : cyanblueColor,
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stepperState = ref.watch(stepperProvider);
    final notifier = ref.read(stepperProvider.notifier);

    // Sync controller values with provider state
    if (companyNameController.text != (stepperState.companyName ?? '')) {
      companyNameController.text = stepperState.companyName ?? '';
    }
    if (phoneNumberController.text != (stepperState.companyPhoneNumber ?? '')) {
      phoneNumberController.text = stepperState.companyPhoneNumber ?? '';
    }
    if (emailController.text != (stepperState.companyEmail ?? '')) {
      emailController.text = stepperState.companyEmail ?? '';
    }
    if (tinNumberController.text != (stepperState.companyTinNumber ?? '')) {
      tinNumberController.text = stepperState.companyTinNumber ?? '';
    }
    if (dateOfEstabilishmentController.text !=
        (stepperState.companyDateOfEstablishment ?? '')) {
      dateOfEstabilishmentController.text =
          stepperState.companyDateOfEstablishment ?? '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Form(
        key: widget.formkey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Product Type'),
            ReusableDropdown(
              selectedValue: stepperState.selectedProductType,
              items: ListContants.productType,
              hintText: 'Select Product Type',
              onChanged: (newStatus) {
                notifier.updateProductType(newStatus);
              },
              prefixIcon: Icons.business,
              errorMessage: 'Please select a product type',
              isRequired: true,
            ),
            const SizedBox(height: 10),

            _buildLabel('TIN Number'),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 3, right: 3),
              child: TextFormField(
                controller: tinNumberController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade900),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (value) {
                  notifier.updateCompanyTinNumber(value);
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Enter 10-digit TIN number',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.blueGrey.shade400.withOpacity(0.7),
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  prefixIcon: Icon(Icons.badge_outlined,
                      size: 20,
                      color: cyanblueColor.withOpacity(0.7)),
                  suffixIcon: _isVerifyingTin
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: cyanblueColor,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: (_isTinValid && !stepperState.isTinVerified)
                              ? _verifyTinNumber
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: stepperState.isTinVerified
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      key: ValueKey('verified'),
                                      size: 24,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      _isTinValid
                                          ? Icons.arrow_circle_right_outlined
                                          : Icons.circle_outlined,
                                      key: const ValueKey('unverified'),
                                      size: 24,
                                      color: _isTinValid
                                          ? cyanblueColor
                                          : Colors.blueGrey.shade300,
                                    ),
                            ),
                          ),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: cyanblueColor.withOpacity(0.30)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: cyanblueColor.withOpacity(0.30)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: cyanblueColor, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.redAccent, width: 1.3),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                ),
                validator: (value) => null,
              ),
            ),

            const SizedBox(height: 10),
            _buildLabel('Company Name'),
            ReusableTextFormField(
              hintText: "Company Name",
              controller: companyNameController,
              keyboardType: TextInputType.text,
              errorMessage: companyNameTouched &&
                      companyNameController.text.trim().isEmpty
                  ? "Please enter company name"
                  : null,
              leadingIcon: Icons.business,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+')),
              ],
              isRequired: true,
              onChanged: (value) {
                notifier.updateCompanyName(value);
                if (!companyNameTouched) {
                  setState(() {
                    companyNameTouched = true;
                  });
                } else {
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 10),
            _buildLabel('Phone Number'),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 3, right: 3),
              child: TextFormField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade900),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                onChanged: (value) {
                  notifier.updateCompanyPhoneNumber(value);
                },
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.blueGrey.shade400.withOpacity(0.7),
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 20,
                            color: cyanblueColor.withOpacity(0.7)),
                        const SizedBox(width: 6),
                        Text(
                          '+251',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                        Container(
                          height: 20,
                          width: 1,
                          margin: const EdgeInsets.only(left: 8),
                          color: cyanblueColor.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: cyanblueColor.withOpacity(0.30)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: cyanblueColor.withOpacity(0.30)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: cyanblueColor, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.redAccent, width: 1.3),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  if (value.length != 9) {
                    return 'Phone number must be 9 digits';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10),
            _buildLabel('Email'),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 3, right: 3),
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade900),
                onChanged: (value) {
                  notifier.updateCompanyEmail(value);
                },
                decoration: InputDecoration(
                  hintText: 'Enter email address',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.blueGrey.shade400.withOpacity(0.7),
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  prefixIcon: Icon(Icons.email_outlined,
                      size: 20,
                      color: cyanblueColor.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: cyanblueColor.withOpacity(0.30)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: cyanblueColor.withOpacity(0.30)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: cyanblueColor, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.redAccent, width: 1.3),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10),
            _buildLabel('Date of Establishment'),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 3, right: 3),
              child: TextFormField(
                controller: dateOfEstabilishmentController,
                readOnly: true,
                style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade900),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: cyanblueColor,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black87,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    dateOfEstabilishmentController.text =
                        picked.toLocal().toString().split(' ')[0];
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Select date of establishment',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.blueGrey.shade400.withOpacity(0.7),
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  prefixIcon: Icon(Icons.calendar_today_rounded,
                      size: 20,
                      color: cyanblueColor.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: cyanblueColor.withOpacity(0.30)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: cyanblueColor.withOpacity(0.30)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: cyanblueColor, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
