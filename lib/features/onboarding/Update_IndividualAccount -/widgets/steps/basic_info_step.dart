import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/features/onboarding/_IndividualAccount/widgets/common/reusable_dropdown.dart';
import 'package:coopengageplus/features/onboarding/corporate/corporateAccount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/common_widgets/textField/PhoneNumberWidget.dart';
import 'package:coopengageplus/common_widgets/textField/emailWidget.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import '../../providers/registration_providers.dart';
import '../../screens/registration_screen.dart';

class BasicInfoStep extends ConsumerStatefulWidget {
  const BasicInfoStep({Key? key}) : super(key: key);

  @override
  ConsumerState<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends ConsumerState<BasicInfoStep> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    print("datatatrtrt");
    print(phoneControllerProvider);
    super.initState();
    _initializeControllers();

    // Set CONVENTIONAL as default product type if not already set
    final registrationData = ref.read(registrationDataProvider);
    // if (registrationData.productType == null) {
    //   Future.microtask(() {
    //     ref.read(registrationDataProvider.notifier).updateBasicInfo(
    //           productType: 'CONVENTIONAL',
    //         );
    //   });
    // }
  }

  @override
  void dispose() {
    // Don't dispose controllers as they're managed by providers
    super.dispose();
  }

  void _initializeControllers() {
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    // Initialize with existing data if available
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.phone != null) {
      _phoneController.text = registrationData.phone!;
    }
    if (registrationData.email != null) {
      _emailController.text = registrationData.email!;
    }

    _phoneController.addListener(() {
      final formatted = formatPhoneNumber(_phoneController.text);
      if (formatted != _phoneController.text) {
        _phoneController.value = _phoneController.value.copyWith(
          text: formatted ?? '',
          selection: TextSelection.collapsed(offset: (formatted ?? '').length),
        );
      }
      ref.read(registrationDataProvider.notifier).updateBasicInfo(
        phone: formatted,
      );
      if ((formatted ?? '').isNotEmpty) {
        ref.read(formValidationProvider.notifier).clearError('phone');
      }
    });

    _emailController.addListener(() {
      ref.read(registrationDataProvider.notifier).updateBasicInfo(
            email: _emailController.text,
          );
      // Clear validation error when user types
      if (_emailController.text.isNotEmpty) {
        ref.read(formValidationProvider.notifier).clearError('email');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("object1111111111111111111111111111111111");
    final registrationData = ref.watch(registrationDataProvider);
    final validationErrors = ref.watch(formValidationProvider);
    print(registrationData);
    // Always sync controller text with provider
    if (registrationData.phone != null &&
        formatPhoneNumber(registrationData.phone) != _phoneController.text) {
      _phoneController.text = formatPhoneNumber(registrationData.phone)!;
    }
    if (registrationData.email != null &&
        registrationData.email != _emailController.text) {
      _emailController.text = registrationData.email!;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: graybackgroundColor,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Basic Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide your basic contact information to get started.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

              

                // Phone Number
                _buildLabel("Phone Number *"),
                PhoneNumberWidget(
                  phoneNumberController: _phoneController,
                  onChanged: (value) {
                    // Clear validation error when user types
                    if (value.isNotEmpty) {
                      ref
                          .read(formValidationProvider.notifier)
                          .clearError('phone');
                    }
                  },
                ),
                if (validationErrors['phone'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      validationErrors['phone']!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Email
                _buildLabel("Email (Optional)"),
                EmailWidget(
                  emailController: _emailController,
                  onChanged: (value) {
                    // Clear validation error when user types
                    if (value.isNotEmpty) {
                      ref
                          .read(formValidationProvider.notifier)
                          .clearError('email');
                    }
                  },
                ),
                if (validationErrors['email'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      validationErrors['email']!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  String? formatPhoneNumber(String? phone) {
    if (phone == null) return null;
    if (phone.startsWith('0')) {
      return phone.substring(1);
    } else if (phone.startsWith('+251')) {
      return phone.substring(4);
    }
    return phone;
  }
}
