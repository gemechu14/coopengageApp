import 'package:coopengageplus/common_widgets/dropDown/DatePickerField.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/features/onboarding/_corporate/providers/registration_providers.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../_corporate/models/corporate_registration_form.dart';

class CompanyInfoForm extends ConsumerStatefulWidget {
  final GlobalKey<FormState>? formKey;
  const CompanyInfoForm({Key? key, this.formKey}) : super(key: key);

  @override
  ConsumerState<CompanyInfoForm> createState() => _CompanyInfoFormState();
}

class _CompanyInfoFormState extends ConsumerState<CompanyInfoForm> {
  late final TextEditingController companyNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController dateOfEstablishmentController;
  late final TextEditingController tinController;

  @override
  void initState() {
    super.initState();
    final form = ref.read(corporateRegistrationProvider);
    companyNameController = TextEditingController(text: form.companyName ?? '');
    emailController = TextEditingController(text: form.email ?? '');
    phoneController = TextEditingController(text: form.phoneNumber ?? '');
    dateOfEstablishmentController = TextEditingController(text: form.dateOfEstablishment ?? '');
    tinController = TextEditingController(text: form.tin ?? '');
  }

  @override
  void dispose() {
    companyNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dateOfEstablishmentController.dispose();
    tinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(corporateRegistrationProvider);
    final notifier = ref.read(corporateRegistrationProvider.notifier);

    // Set default value for product type
    String? productTypeValue = form.accountType;
    if (productTypeValue == null) {
      Future.microtask(() {
        String? defaultValue;
        if (ListContants.productType.contains('CONVENTIONAL')) {
          defaultValue = 'CONVENTIONAL';
        } else if (ListContants.productType.isNotEmpty) {
          defaultValue = ListContants.productType.first;
        }
        if (defaultValue != null) {
          notifier.updateField('accountType', defaultValue);
        }
      });
    }

    // Add a listener to update Riverpod state when the date changes
    dateOfEstablishmentController.addListener(() {
      if (form.dateOfEstablishment != dateOfEstablishmentController.text) {
        notifier.updateField(
            'dateOfEstablishment', dateOfEstablishmentController.text);
      }
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
        child: Form(
          key: widget.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              TextLabel("Product Type"),
              ReusableDropdown(
                selectedValue: form.accountType,
                items: ListContants.productType,
                hintText: 'Select Product Type',
                onChanged: (newStatus) =>
                    notifier.updateField('accountType', newStatus),
                prefixIcon: Icons.business,
                errorMessage: 'Please select a product type',
                isRequired: true,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  "Company Name",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ReusableTextFormField(
                hintText: "Company Name",
                controller: companyNameController,
                keyboardType: TextInputType.text,
                errorMessage: "Company Name cannot be empty",
                leadingIcon: Icons.business,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$')),
                ],
                isRequired: true,
                onChanged: (value) => notifier.updateField('companyName', value),
              ),
              const SizedBox(height: 12),
              TextLabel("Phonenumber"),
              const SizedBox(height: 4),
              ReusableTextFormField(
                hintText: "Phone Number",
                controller: phoneController,
                keyboardType: TextInputType.phone,
                errorMessage: "Phone number cannot be empty",
                leadingIcon: Icons.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                isRequired: true,
                onChanged: (value) => notifier.updateField('phoneNumber', value),
              ),
              const SizedBox(height: 12),
              TextLabel("Email  (optional)"),
              const SizedBox(height: 4),
              ReusableTextFormField(
                hintText: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                errorMessage: "Email cannot be empty",
                leadingIcon: Icons.email,
                isRequired: true,
                onChanged: (value) => notifier.updateField('email', value),
              ),
              const SizedBox(height: 12),
              TextLabel("TIN"),
              ReusableTextFormField(
                hintText: "TIN",
                controller: tinController,
                keyboardType: TextInputType.number,
                errorMessage: "TIN cannot be empty",
                leadingIcon: Icons.badge,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                isRequired: true,
                onChanged: (value) => notifier.updateField('tin', value),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Padding TextLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 10, right: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
