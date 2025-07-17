import 'package:flutter/material.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/common_widgets/textField/PhoneNumberWidget.dart';
import 'package:coopengageplus/common_widgets/textField/emailWidget.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/constants/listConstants.dart';

class PersonalInfoSection extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final String? selectedGender;
  final String? selectedTitle;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onTitleChanged;

  const PersonalInfoSection({
    Key? key,
    required this.fullNameController,
    required this.phoneController,
    required this.emailController,
    required this.selectedGender,
    required this.selectedTitle,
    required this.onGenderChanged,
    required this.onTitleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Full Name'),
        ReusableTextFormField(
          hintText: "Full Name",
          controller: fullNameController,
          keyboardType: TextInputType.text,
          errorMessage: "Full Name cannot be empty",
          leadingIcon: Icons.person,
          isRequired: true,
        ),
        Text('Phone Number'),
        PhoneNumberWidget(phoneNumberController: phoneController),
        Text('Email'),
        EmailWidget(emailController: emailController),
        Text('Gender'),
        ReusableDropdown(
          selectedValue: selectedGender,
          items: ListContants.gender,
          hintText: 'Select Gender',
          onChanged: onGenderChanged,
          prefixIcon: Icons.person,
          errorMessage: 'Please select Gender',
          isRequired: false,
        ),
        Text('Title'),
        ReusableDropdown(
          selectedValue: selectedTitle,
          items: ListContants.title,
          hintText: 'Select Title',
          onChanged: onTitleChanged,
          prefixIcon: Icons.category,
          errorMessage: 'Please select a Title',
          isRequired: true,
        ),
      ],
    );
  }
} 