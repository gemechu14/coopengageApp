import 'package:flutter/material.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import '../../constants/list_constants.dart';

class AddressStep extends StatelessWidget {
  final TextEditingController regionController;
  final TextEditingController cityController;
  final TextEditingController subCityController;
  final TextEditingController woredaController;
  final TextEditingController kebeleController;
  final TextEditingController houseNumberController;
  final TextEditingController phoneNumberController;
  final String? selectedRegion;
  final Function(String?) onRegionChanged;
  final GlobalKey<FormState> formKey;

  const AddressStep({
    Key? key,
    required this.regionController,
    required this.cityController,
    required this.subCityController,
    required this.woredaController,
    required this.kebeleController,
    required this.houseNumberController,
    required this.phoneNumberController,
    required this.selectedRegion,
    required this.onRegionChanged,
    required this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Region"),
          ReusableDropdown(
            hintText: "Select Region",
            selectedValue: selectedRegion,
            items: listConstants.regions,
            onChanged: onRegionChanged,
            errorMessage: "Please select a region",
            isRequired: true,
          ),
          _buildLabel("City"),
          ReusableTextFormField(
            hintText: "City",
            controller: cityController,
            keyboardType: TextInputType.text,
            errorMessage: "City cannot be empty",
            leadingIcon: Icons.location_city,
            isRequired: true,
          ),
          _buildLabel("Sub City"),
          ReusableTextFormField(
            hintText: "Sub City",
            controller: subCityController,
            keyboardType: TextInputType.text,
            errorMessage: "Sub City cannot be empty",
            leadingIcon: Icons.location_city_outlined,
            isRequired: true,
          ),
          _buildLabel("Woreda"),
          ReusableTextFormField(
            hintText: "Woreda",
            controller: woredaController,
            keyboardType: TextInputType.text,
            errorMessage: "Woreda cannot be empty",
            leadingIcon: Icons.location_on,
            isRequired: true,
          ),
          _buildLabel("Kebele"),
          ReusableTextFormField(
            hintText: "Kebele",
            controller: kebeleController,
            keyboardType: TextInputType.text,
            errorMessage: "Kebele cannot be empty",
            leadingIcon: Icons.location_on_outlined,
            isRequired: true,
          ),
          _buildLabel("House Number"),
          ReusableTextFormField(
            hintText: "House Number",
            controller: houseNumberController,
            keyboardType: TextInputType.text,
            errorMessage: "House Number cannot be empty",
            leadingIcon: Icons.home,
            isRequired: true,
          ),
          _buildLabel("Phone Number"),
          ReusableTextFormField(
            hintText: "Phone Number",
            controller: phoneNumberController,
            keyboardType: TextInputType.phone,
            errorMessage: "Phone Number cannot be empty",
            leadingIcon: Icons.phone,
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
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
