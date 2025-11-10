import 'package:flutter/material.dart';
import 'package:coopengageplus/shared/widgets/ReusableTextFormField.dart';
import 'package:coopengageplus/shared/widgets/dropDown/ReusableDropdown.dart';
import '../../constants/list_constants.dart';
import 'package:intl/intl.dart';

class PersonalInfoStep extends StatefulWidget {
  final TextEditingController fullNameController;
  final TextEditingController dateOfBirthController;
  final TextEditingController occupationController;
  final TextEditingController initialDepositController;
  final String? selectedTitle;
  final String? selectedGender;
  final String? selectedMaritalStatus;
  final String? selectedBankingType;
  final Function(String?) onTitleChanged;
  final Function(String?) onGenderChanged;
  final Function(String?) onMaritalStatusChanged;
  final Function(String?) onBankingTypeChanged;
  final Function(String) onDateOfBirthChanged;
  final GlobalKey<FormState> formKey;

  const PersonalInfoStep({
    Key? key,
    required this.fullNameController,
    required this.dateOfBirthController,
    required this.occupationController,
    required this.initialDepositController,
    required this.selectedTitle,
    required this.selectedGender,
    required this.selectedMaritalStatus,
    required this.selectedBankingType,
    required this.onTitleChanged,
    required this.onGenderChanged,
    required this.onMaritalStatusChanged,
    required this.onBankingTypeChanged,
    required this.onDateOfBirthChanged,
    required this.formKey,
  }) : super(key: key);

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Title"),
          ReusableDropdown(
            hintText: "Select Title",
            selectedValue: widget.selectedTitle,
            items: listConstants.titles,
            onChanged: widget.onTitleChanged,
            errorMessage: "Please select a title",
            isRequired: true,
          ),
          _buildLabel("Full Name"),
          ReusableTextFormField(
            hintText: "Full Name",
            controller: widget.fullNameController,
            keyboardType: TextInputType.text,
            errorMessage: "Full Name cannot be empty",
            leadingIcon: Icons.person,
            isRequired: true,
          ),
          _buildLabel("Gender"),
          ReusableDropdown(
            hintText: "Select Gender",
            selectedValue: widget.selectedGender,
            items: listConstants.genders,
            onChanged: widget.onGenderChanged,
            errorMessage: "Please select a gender",
            isRequired: true,
          ),
          _buildLabel("Date of Birth"),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: ReusableTextFormField(
                hintText: "Date of Birth",
                controller: widget.dateOfBirthController,
                keyboardType: TextInputType.none,
                errorMessage: "Date of Birth cannot be empty",
                leadingIcon: Icons.calendar_today,
                isRequired: true,
              ),
            ),
          ),
          _buildLabel("Marital Status"),
          ReusableDropdown(
            hintText: "Select Marital Status",
            selectedValue: widget.selectedMaritalStatus,
            items: listConstants.maritalStatuses,
            onChanged: widget.onMaritalStatusChanged,
            errorMessage: "Please select a marital status",
            isRequired: true,
          ),
          _buildLabel("Occupation"),
          ReusableTextFormField(
            hintText: "Occupation",
            controller: widget.occupationController,
            keyboardType: TextInputType.text,
            errorMessage: "Occupation cannot be empty",
            leadingIcon: Icons.work,
            isRequired: true,
          ),
          _buildLabel("Banking Type"),
          ReusableDropdown(
            hintText: "Select Banking Type",
            selectedValue: widget.selectedBankingType,
            items: listConstants.bankingTypes,
            onChanged: widget.onBankingTypeChanged,
            errorMessage: "Please select a banking type",
            isRequired: true,
          ),
          _buildLabel("Initial Deposit"),
          ReusableTextFormField(
            hintText: "Initial Deposit",
            controller: widget.initialDepositController,
            keyboardType: TextInputType.number,
            errorMessage: "Initial Deposit must be at least 100",
            leadingIcon: Icons.attach_money,
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      widget.dateOfBirthController.text = formattedDate;
      widget.onDateOfBirthChanged(formattedDate);
    }
  }

  Widget _buildLabel(String text) {
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
