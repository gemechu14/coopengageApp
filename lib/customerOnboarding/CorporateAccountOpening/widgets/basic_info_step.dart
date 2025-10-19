// import 'package:coopengageplus/features/onboarding/corporate/corporateAccount.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/common_widgets/textField/PhoneNumberWidget.dart';
import 'package:coopengageplus/common_widgets/textField/emailWidget.dart';
import 'package:coopengageplus/common_widgets/dropDown/DatePickerField.dart';
import 'package:coopengageplus/customerOnboarding/CorporateAccountOpening/providers/stepper_provider.dart';
import 'package:coopengageplus/customerOnboarding/CorporateAccountOpening/services/tin_verification_service.dart';

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
            // Product Type
            Text('Product Type', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 8),

            Text('TIN', style: TextStyle(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
              child: TextFormField(
                controller: tinNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (value) {
                  notifier.updateCompanyTinNumber(value);
                  setState(() {}); // Update button state
                },
                decoration: InputDecoration(
                  hintText: 'TIN Number',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 10.0),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  prefixIcon: const Icon(Icons.badge),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(
                        right: 4.0, top: 4.0, bottom: 4.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: (_isVerifyingTin || !_isTinValid)
                              ? null
                              : _verifyTinNumber,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: stepperState.isTinVerified
                                  ? LinearGradient(
                                      colors: [cyanblueColor, cyanblueColor],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : _isTinValid
                                      ? LinearGradient(
                                          colors: [
                                            Colors.blue.shade500,
                                            Colors.blue.shade700
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                              color: (!_isTinValid && !stepperState.isTinVerified)
                                  ? Colors.grey.shade300
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: (_isTinValid || stepperState.isTinVerified) &&
                                      !_isVerifyingTin
                                  ? [
                                      BoxShadow(
                                        color: stepperState.isTinVerified
                                            ? cyanblueColor
                                            : Colors.blue.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ✅ Keep icon always present
                                Icon(
                                  stepperState.isTinVerified
                                      ? Icons.check_circle_rounded
                                      : Icons.verified_rounded,
                                  size: 18,
                                  color: (_isTinValid || stepperState.isTinVerified)
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                ),
                                const SizedBox(width: 6),

                                // ✅ Reserve space for both loader and text
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Loader
                                    Visibility(
                                      visible: _isVerifyingTin,
                                      child: const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                    ),
                                    // Text
                                    Visibility(
                                      visible: !_isVerifyingTin,
                                      child: Text(
                                        stepperState.isTinVerified ? 'Verified' : 'Verify',
                                        style: TextStyle(
                                          color: (_isTinValid || stepperState.isTinVerified)
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                validator: (value) {
                  // Optional validation can be added here
                  return null;
                },
              ),
            ),

            const SizedBox(height: 8),
            // Company Name
            Text('Company Name', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 8),
            // Phone Number
            Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold)),
            PhoneNumberWidget(
              phoneNumberController: phoneNumberController,
              isRequired: true,
              onChanged: (value) {
                notifier.updateCompanyPhoneNumber(value);
              },
            ),
            const SizedBox(height: 8),
            // Email
            Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            EmailWidget(
              emailController: emailController,
              onChanged: (value) {
                notifier.updateCompanyEmail(value);
              },
            ),
            const SizedBox(height: 8),
            // Date of Establishment
            Text('Date of Establishment',
                style: TextStyle(fontWeight: FontWeight.bold)),
            DatePickerField(
              controller: dateOfEstabilishmentController,
              hintText: 'Date of Establishment',
              prefixIcon: Icons.date_range,
              initialDate: DateTime.now().add(const Duration(days: -10000)),
              firstDate: DateTime(1940),
              lastDate: DateTime.now(),
              isRequired: false,
              isGreyBorder: true,
              errorMessage: 'Please select a date of Establishment',
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
