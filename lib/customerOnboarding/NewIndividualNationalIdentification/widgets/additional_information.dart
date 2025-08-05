import 'dart:typed_data';

import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/common_widgets/dropDown/branch_selector.dart';
import 'package:coopengageplus/constants/listConstants.dart';
// import 'package:coopengageplus/features/onboarding/_IndividualAccount/widgets/common/signature_pad.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import '../providers/stepper_provider.dart';

class PhoneFanWidget extends ConsumerStatefulWidget {
  const PhoneFanWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<PhoneFanWidget> createState() => _PhoneFanWidgetState();
}

class _PhoneFanWidgetState extends ConsumerState<PhoneFanWidget> {
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController initialdepositController =
      TextEditingController();
  late SignatureController _signatureController1;
  late SignatureController _signatureController2;
  late SignatureController _signatureController3;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _signatureData;

  @override
  void initState() {
    super.initState();
    _signatureController1 = SignatureController(
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.white,
    );
    _signatureController2 = SignatureController(
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.white,
    );
    _signatureController3 = SignatureController(
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.white,
    );

    // Initialize with existing values from state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stepperState = ref.read(stepperProvider);
      if (stepperState.motherName != null &&
          stepperState.motherName!.isNotEmpty) {
        motherNameController.text = stepperState.motherName!;
      }
      if (stepperState.initialDeposit != null &&
          initialdepositController.text !=
              stepperState.initialDeposit.toString()) {
        initialdepositController.text = stepperState.initialDeposit.toString();
      }
    });
  }

  @override
  void dispose() {
    motherNameController.dispose();
    _signatureController1.dispose();
    _signatureController2.dispose();
    _signatureController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepperState = ref.watch(stepperProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textLabel("Mother Name"),
        ReusableTextFormField(
          hintText: "Mother Name",
          controller: motherNameController,
          keyboardType: TextInputType.text,
          errorMessage: "Mother Name cannot be empty",
          leadingIcon: Icons.person,
          isRequired: false,
          onChanged: (value) {
            // Save to stepper state
            ref.read(stepperProvider.notifier).updateMotherName(value);
          },
        ),
        textLabel("Branch"),
        BranchSelector(
          initialValue: stepperState.selectedBranch,
          onChanged: (value) {
            ref.read(stepperProvider.notifier).updateBranch(value);
          },
        ),
        textLabel("Initial Amount"),
        ReusableTextFormField(
          hintText: "Initial Amount",
          controller: initialdepositController,
          keyboardType: TextInputType.number,
          errorMessage: "Initial amount cannot be empty",
          leadingIcon: Icons.balance,
          isRequired: true,
          onChanged: (value) {
            // Save to stepper state
            ref
                .read(stepperProvider.notifier)
                .updateInitialDeposit(double.tryParse(value));
          },
        ),
        textLabel("Product Type"),
        ReusableDropdown(
          selectedValue: stepperState.selectedProductType,
          items: ListContants.productType,
          hintText: 'Select Product Type',
          onChanged: (newStatus) {
            if (newStatus != null) {
              ref.read(stepperProvider.notifier).updateProductType(newStatus);
            }
          },
          prefixIcon: Icons.business,
          errorMessage: 'Please select a product type',
          isRequired: true,
        ),
        textLabel("Title"),
        ReusableDropdown(
          selectedValue: stepperState.selectedTitle,
          items: ListContants.title,
          hintText: 'Select Title',
          onChanged: (newStatus) {
            if (newStatus != null) {
              ref.read(stepperProvider.notifier).updateTitle(newStatus);
            }
          },
          prefixIcon: Icons.person,
          errorMessage: 'Please select a title',
          isRequired: true,
        ),
        textLabel("Marital Status"),
        ReusableDropdown(
          selectedValue: stepperState.selectedMaritalStatus,
          items: ListContants.maritalStatuses,
          hintText: 'Select Marital status',
          onChanged: (newStatus) {
            if (newStatus != null) {
              ref.read(stepperProvider.notifier).updateMaritalStatus(newStatus);
            }
          },
          prefixIcon: Icons.family_restroom,
          errorMessage: 'Please select a marital status',
          isRequired: true,
        ),
      ],
    );
  }

  Padding textLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
