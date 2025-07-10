import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/registration_providers.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/constants/listConstants.dart';

class SignatureStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationProvider);
    final notifier = ref.read(registrationProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Branch"),
        // TODO: Replace with your branchSelectorWidget1() or equivalent
        Text("State"),
        ReusableDropdown(
          selectedValue: state.selectedState,
          items: ListContants.ethiopianStates,
          hintText: 'Select State',
          onChanged: (val) => notifier.setSelectedState(val),
          errorMessage: 'Please select a state',
          prefixIcon: Icons.map,
          isRequired: false,
        ),
        Text("Zone Subcity"),
        ReusableTextFormField(
          hintText: "Zone Subcity",
          controller: state.cityController,
          errorMessage: "Zone Subcity cannot be empty",
          leadingIcon: Icons.location_city,
          isRequired: false,
        ),
        Text("Woreda"),
        ReusableTextFormField(
          hintText: "Woreda",
          controller: state.woredaController,
          errorMessage: "Woreda cannot be empty",
          leadingIcon: Icons.location_city,
          isRequired: false,
        ),
        Text("Resident"),
        ReusableTextFormField(
          hintText: "Resident ",
          controller: state.residenceControllers,
          keyboardType: TextInputType.text,
          errorMessage: "Resident cannot be empty",
          leadingIcon: Icons.location_city,
          isRequired: true,
        ),
        Text("Select Number of Authorized Signers"),
        ReusableDropdown(
          selectedValue: state.numberOfMembers,
          items: ListContants.NumberOfMembersForOrganization,
          hintText: 'Select Number of Authorized Signers',
          onChanged: (val) => notifier.setNumberOfMembers(val),
          prefixIcon: Icons.person_add,
          errorMessage: 'Please select the number of authorized signers',
          isRequired: true,
        ),
      ],
    );
  }
} 