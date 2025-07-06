import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/features/onboarding/_IndividualAccount/widgets/common/reusable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/common_widgets/textField/PhoneNumberWidget.dart';
import 'package:coopengageplus/common_widgets/textField/emailWidget.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import '../../providers/registration_providers.dart';

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
    super.initState();
    _phoneController = ref.read(phoneControllerProvider);
    _emailController = ref.read(emailControllerProvider);

    // Initialize with existing data if available
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.phone != null) {
      _phoneController.text = registrationData.phone!;
    }
    if (registrationData.email != null) {
      _emailController.text = registrationData.email!;
    }
    
    // Set CONVENTIONAL as default product type if not already set
    // Use Future.microtask to avoid modifying provider during build
    if (registrationData.productType == null) {
      Future.microtask(() {
        ref.read(registrationDataProvider.notifier).updateBasicInfo(
          productType: 'CONVENTIONAL',
        );
      });
    }
  }

  @override
  void dispose() {
    // Don't dispose controllers as they're managed by providers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationData = ref.watch(registrationDataProvider);
    final validationErrors = ref.watch(formValidationProvider);

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

                // Product Type
                // _buildLabel("Product Type *"),
                ReusableDropdown(
                  selectedValue: registrationData.productType,
                  items: ListContants.productType,
                  hintText: 'Select Product Type',
                  onChanged: (value) {
                    ref.read(registrationDataProvider.notifier).updateBasicInfo(
                          productType: value,
                        );
                    // Clear validation error when user makes a selection
                    if (value != null) {
                      ref
                          .read(formValidationProvider.notifier)
                          .clearError('productType');
                    }
                  },
                  prefixIcon: Icons.business,
                  errorMessage: validationErrors['productType'] ?? '',
                  isRequired: true,
                ),

                const SizedBox(height: 20),

                // Phone Number
                // _buildLabel("Phone Number *"),
                PhoneNumberWidget(
                  phoneNumberController: _phoneController,
                  onChanged: (value) {
                    // Clear validation error when user types
                    if (value.isNotEmpty) {
                      ref.read(formValidationProvider.notifier).clearError('phone');
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
                // _buildLabel("Email Address"),
                EmailWidget(
                  emailController: _emailController,
                  onChanged: (value) {
                    // Clear validation error when user types
                    if (value.isNotEmpty) {
                      ref.read(formValidationProvider.notifier).clearError('email');
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

                // Progress indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Step Progress',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '1 of 8',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.125,
                        backgroundColor: Colors.grey.shade300,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '12.5% Complete',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
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
}
