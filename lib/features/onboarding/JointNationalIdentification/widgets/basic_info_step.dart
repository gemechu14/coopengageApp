import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/features/onboarding/JointNationalIdentification/providers/stepper_provider.dart';

class BasicInfoStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepperState = ref.watch(stepperProvider);
    final notifier = ref.read(stepperProvider.notifier);

    // Ensure default members list is initialized if not already, but not during build
    if (stepperState.numberOfMembers == 2 && stepperState.members.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.updateNumberOfMembers(2);
      });
    }
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text('Basic Information',
          //     style: Theme.of(context).textTheme.titleLarge),
          // const SizedBox(height: 16),
          Text(
            'Product Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ReusableDropdown(
            selectedValue: stepperState.selectedProductType,
            items: ListContants.productType,
            hintText: 'Select Product Type',
            onChanged: (newStatus) {
              if (newStatus != null) {
                notifier.updateProductType(newStatus);
              }
            },
            prefixIcon: Icons.business,
            errorMessage: 'Please select a product type',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Text(
            'Account Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ReusableDropdown(
            selectedValue: stepperState.jointAccountType,
            items: ListContants.AccountTypeSelection,
            hintText: 'Select Account Type',
            onChanged: (newStatus) {
              if (newStatus != null) {
                notifier.updateJointAccountType(newStatus);
              }
            },
            prefixIcon: Icons.merge,
            errorMessage: 'Please select an account type',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Text('Number of Members',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ReusableDropdown(
            selectedValue: stepperState.numberOfMembers.toString(),
            items: ['2', '3'],
            hintText: 'Select Number of Members',
            onChanged: (newStatus) {
              print('Dropdown changed: newStatus = '
                  ' [32m$newStatus [0m, type = '
                  ' [34m${newStatus.runtimeType} [0m');
              if (newStatus != null) {
                final parsed = int.tryParse(newStatus);
                print('Parsed int: $parsed');
                if (parsed != null) {
                  notifier.updateNumberOfMembers(parsed);
                  print('Called notifier.updateNumberOfMembers($parsed)');
                } else {
                  print('Failed to parse newStatus to int');
                }
              }
            },
            prefixIcon: Icons.group,
            errorMessage: 'Please select number of members',
            isRequired: true,
          ),
        ],
      ),
    );
  }
}
