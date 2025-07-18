import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/common_widgets/textField/PhoneNumberWidget.dart';
import 'package:coopengageplus/common_widgets/textField/emailWidget.dart';
import 'package:coopengageplus/common_widgets/dropDown/DatePickerField.dart';
import 'package:coopengageplus/features/onboarding/CorporateAccountOpening/providers/stepper_provider.dart';

class BasicInfoStep extends ConsumerStatefulWidget {
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
          // Company Name
          Text('Company Name', style: TextStyle(fontWeight: FontWeight.bold)),
          ReusableTextFormField(
            hintText: "Company Name",
            controller: companyNameController,
            keyboardType: TextInputType.text,
            errorMessage:
                companyNameTouched && companyNameController.text.trim().isEmpty
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
          // TIN
          Text('TIN', style: TextStyle(fontWeight: FontWeight.bold)),
          ReusableTextFormField(
            hintText: "TIN ",
            controller: tinNumberController,
            keyboardType: TextInputType.number,
            errorMessage: "TIN cannot be empty",
            leadingIcon: Icons.badge,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            isRequired: false,
            onChanged: (value) {
              notifier.updateCompanyTinNumber(value);
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
    );
  }
}
