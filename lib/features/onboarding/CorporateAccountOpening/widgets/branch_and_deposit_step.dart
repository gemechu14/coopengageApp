// ignore_for_file: use_key_in_widget_constructors

import 'package:coopengageplus/features/onboarding/CorporateAccountOpening/providers/stepper_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:coopengageplus/features/onboarding/JointNationalIdentification/providers/stepper_provider.dart';
import 'package:coopengageplus/common_widgets/dropDown/branch_selector.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';

import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';

class BranchAndDepositStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<BranchAndDepositStep> createState() =>
      _BranchAndDepositStepState();
}

class _BranchAndDepositStepState extends ConsumerState<BranchAndDepositStep> {
  late TextEditingController initialDepositController;
  final TextEditingController cityController = TextEditingController();
  final TextEditingController woredaController = TextEditingController();
  final TextEditingController residenceController = TextEditingController();
  String? selectedState;
  String? selectedNumberOfMembers;

  @override
  void initState() {
    super.initState();
    final stepperState = ref.read(stepperProvider);
    initialDepositController = TextEditingController(
      text: stepperState.initialDeposit != null &&
              stepperState.initialDeposit! > 0
          ? stepperState.initialDeposit!.toInt().toString()
          : '',
    );
    selectedState = stepperState.state;
    selectedNumberOfMembers = stepperState.numberOfMembers.toString();
  }

  @override
  void didUpdateWidget(covariant BranchAndDepositStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stepperState = ref.read(stepperProvider);
    final newText =
        stepperState.initialDeposit != null && stepperState.initialDeposit! > 0
            ? stepperState.initialDeposit!.toInt().toString()
            : '';
    if (initialDepositController.text != newText) {
      initialDepositController.text = newText;
    }
    selectedState = stepperState.state;
    selectedNumberOfMembers = stepperState.numberOfMembers.toString();
  }

  @override
  void dispose() {
    initialDepositController.dispose();
    cityController.dispose();
    woredaController.dispose();
    residenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepperState = ref.watch(stepperProvider);
    final notifier = ref.read(stepperProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Branch', style: TextStyle(fontWeight: FontWeight.bold)),
          BranchSelector(
            initialValue: stepperState.selectedBranch,
            onChanged: (value) {
              notifier.updateBranch(value);
            },
          ),
          SizedBox(height: 10),
          Text('Number of Authorized Signers',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ReusableDropdown(
            selectedValue: selectedNumberOfMembers,
            items: ListContants.NumberOfMembersForOrganization,
            hintText: 'Select Number of Authorized Signers',
            onChanged: (newValue) {
              setState(() {
                selectedNumberOfMembers = newValue;
              });
              final parsed = int.tryParse(newValue ?? '');
              if (parsed != null) {
                notifier.updateNumberOfMembers(parsed);
              }
            },
            errorMessage: 'Please select number of authorized signers',
            prefixIcon: Icons.group,
            isRequired: false,
          ),
          const SizedBox(height: 16),
          Text('State', style: TextStyle(fontWeight: FontWeight.bold)),
          ReusableDropdown(
            selectedValue: selectedState,
            items: ListContants.ethiopianStates,
            hintText: 'Select State',
            onChanged: (newState) {
              setState(() {
                selectedState = newState;
              });
              notifier.updateState(newState);
            },
            errorMessage: 'Please select a state',
            prefixIcon: Icons.map,
            isRequired: false,
          ),
          Text('Zone Subcity', style: TextStyle(fontWeight: FontWeight.bold)),
          ReusableTextFormField(
            hintText: "Zone Subcity",
            controller: cityController,
            errorMessage: "Zone Subcity cannot be empty",
            leadingIcon: Icons.location_city,
            isRequired: false,
            onChanged: (value) {
              // If you have an updateZoneSubCity method, use it here
              // notifier.updateZoneSubCity(value);
            },
          ),
          Text('Woreda', style: TextStyle(fontWeight: FontWeight.bold)),
          ReusableTextFormField(
            hintText: "Woreda",
            controller: woredaController,
            errorMessage: "Woreda cannot be empty",
            leadingIcon: Icons.location_city,
            isRequired: false,
            onChanged: (value) {
              // If you have an updateWoreda method, use it here
              // notifier.updateWoreda(value);
            },
          ),
          Text('Resident', style: TextStyle(fontWeight: FontWeight.bold)),
          ReusableTextFormField(
            hintText: "Resident ",
            controller: residenceController,
            keyboardType: TextInputType.text,
            errorMessage: "Resident cannot be empty",
            leadingIcon: Icons.location_city,
            isRequired: true,
            onChanged: (value) {
              // If you have an updateResident method, use it here
              // notifier.updateResident(value);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
