import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/features/onboarding/JointNationalIdentification/providers/stepper_provider.dart';
import 'package:coopengageplus/common_widgets/dropDown/branch_selector.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:flutter/services.dart';

class BranchAndDepositStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<BranchAndDepositStep> createState() => _BranchAndDepositStepState();
}

class _BranchAndDepositStepState extends ConsumerState<BranchAndDepositStep> {
  late TextEditingController initialDepositController;

  @override
  void initState() {
    super.initState();
    final stepperState = ref.read(stepperProvider);
    initialDepositController = TextEditingController(
      text: stepperState.initialDeposit != null && stepperState.initialDeposit! > 0
          ? stepperState.initialDeposit!.toInt().toString()
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant BranchAndDepositStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stepperState = ref.read(stepperProvider);
    final newText = stepperState.initialDeposit != null && stepperState.initialDeposit! > 0
        ? stepperState.initialDeposit!.toInt().toString()
        : '';
    if (initialDepositController.text != newText) {
      initialDepositController.text = newText;
    }
  }

  @override
  void dispose() {
    initialDepositController.dispose();
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
          const SizedBox(height: 16),
          Text('Branch'),
          BranchSelector(
            initialValue: stepperState.selectedBranch,
            onChanged: (value) {
              notifier.updateBranch(value);
            },
          ),
          const SizedBox(height: 16),
          Text('Initial Deposit'),
          ReusableTextFormField(
            hintText: 'Initial Deposit',
            controller: initialDepositController,
            keyboardType: TextInputType.number,
            errorMessage: 'Initial Deposit cannot be empty',
            leadingIcon: Icons.account_balance_wallet,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            isRequired: true,
            onChanged: (value) {
              // Only allow integer values
              final intValue = int.tryParse(value);
              notifier.updateInitialDeposit(intValue?.toDouble());
            },
          ),
        ],
      ),
    );
  }
}
