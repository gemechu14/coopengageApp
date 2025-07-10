import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/registration_providers.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/common_widgets/textField/PhoneNumberWidget.dart';
import 'package:coopengageplus/common_widgets/textField/emailWidget.dart';
import 'package:coopengageplus/common_widgets/dropDown/DatePickerField.dart';
import 'package:coopengageplus/constants/listConstants.dart';

class BasicInfoStep extends ConsumerWidget {

 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationProvider);
    final notifier = ref.read(registrationProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Product Type"),
        ReusableDropdown(
          selectedValue: state.selectedProductType,
          items: ListContants.productType,
          hintText: 'Select Product Type',
          onChanged: (val) => notifier.setSelectedProductType(val),
          prefixIcon: Icons.business,
          errorMessage: 'Please select a product type',
          isRequired: true,
        ),
        Text("Company Name"),
        ReusableTextFormField(
          hintText: "Company Name",
          controller: state.companyNameController,
          keyboardType: TextInputType.text,
          errorMessage: "Company Name cannot be empty",
          leadingIcon: Icons.business,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+ 0'))],
          isRequired: false,
        ),
        Text("PhoneNumber"),
        PhoneNumberWidget(phoneNumberController: state.phoneNumberController),
        Text("Email"),
        EmailWidget(emailController: state.emailController),
        Text("TIN"),
        ReusableTextFormField(
          hintText: "TIN ",
          controller: state.tinNumberController,
          keyboardType: TextInputType.number,
          errorMessage: "TIN cannot be empty",
          leadingIcon: Icons.badge,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          isRequired: false,
        ),
        Text("Date of Establishment"),
        DatePickerField(
          controller: state.dateOfEstabilishmentController,
          hintText: 'Date of Establishment',
          prefixIcon: Icons.date_range,
          initialDate: DateTime.now().add(const Duration(days: -10000)),
          firstDate: DateTime(1940),
          lastDate: DateTime.now(),
          isRequired: false,
          isGreyBorder: true,
          errorMessage: 'Please select a date of Establishment',
        ),
      ],
    );
  }
} 