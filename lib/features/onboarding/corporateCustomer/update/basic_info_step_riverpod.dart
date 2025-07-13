import 'package:coopengageplus/common_widgets/dropDown/DatePickerField.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/common_widgets/textField/PhoneNumberWidget.dart';
import 'package:coopengageplus/common_widgets/textField/emailWidget.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'basic_info_providers.dart';

final companyNameErrorProvider = StateProvider<String?>((ref) => null);
final phoneNumberErrorProvider = StateProvider<String?>((ref) => null);

class BasicInfoStepRiverpod extends ConsumerWidget {
  const BasicInfoStepRiverpod({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProductType = ref.watch(selectedProductTypeProvider);
    final companyNameController = ref.watch(companyNameControllerProvider);
    final phoneNumberController = ref.watch(phoneNumberControllerProvider);
    final emailController = ref.watch(emailControllerProvider);
    final tinNumberController = ref.watch(tinNumberControllerProvider);
    final dateOfEstablishmentController =
        ref.watch(dateOfEstablishmentControllerProvider);
    final companyNameError = ref.watch(companyNameErrorProvider);
    final phoneNumberError = ref.watch(phoneNumberErrorProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextLabel("Product Type"),
        ReusableDropdown(
          selectedValue: selectedProductType,
          items: ListContants.productType,
          hintText: 'Select Product Type',
          onChanged: (newStatus) {
            ref.read(selectedProductTypeProvider.notifier).state = newStatus;
          },
          prefixIcon: Icons.business,
          errorMessage: 'Please select a product type',
          isRequired: true,
        ),
        TextLabel("Company Name"),
        ReusableTextFormField(
          hintText: "Company Name",
          controller: companyNameController,
          keyboardType: TextInputType.text,
          errorMessage: companyNameError ?? "Company Name cannot be empty",
          leadingIcon: Icons.business,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\\s]+')),
          ],
          isRequired: true,
        ),
        TextLabel("PhoneNumber"),
        PhoneNumberWidget(phoneNumberController: phoneNumberController),
        if (phoneNumberError != null)
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 2),
            child: Text(
              phoneNumberError,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        TextLabel("Email"),
        EmailWidget(emailController: emailController),
        TextLabel("TIN"),
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
        ),
        TextLabel("Date of Establishment"),
        DatePickerField(
          controller: dateOfEstablishmentController,
          hintText: 'Date of Establishment',
          prefixIcon: Icons.date_range,
          initialDate: DateTime.now().add(const Duration(days: -10000)),
          firstDate: DateTime(1940),
          lastDate: DateTime.now(),
          isRequired: false,
          isGreyBorder: true,
          errorMessage: 'Please select a date of Establishment',
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Padding TextLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
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
