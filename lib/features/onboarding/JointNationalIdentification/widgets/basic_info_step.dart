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
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Information',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Product Type'),
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
          Text('Account Type'),
          ReusableDropdown(
            selectedValue: stepperState.selectedAccountType,
            items: ListContants.AccountTypeSelection,
            hintText: 'Select Account Type',
            onChanged: (newStatus) {
              if (newStatus != null) {
                notifier.updateAccountType(newStatus);
              }
            },
            prefixIcon: Icons.merge,
            errorMessage: 'Please select an account type',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Text('Number of Members'),
          ReusableDropdown(
            selectedValue: stepperState.numberOfMembers.toString(),
            items: ['2', '3'],
            hintText: 'Select Number of Members',
            onChanged: (newStatus) {
              if (newStatus != null) {
                notifier.updateNumberOfMembers(int.parse(newStatus));
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
