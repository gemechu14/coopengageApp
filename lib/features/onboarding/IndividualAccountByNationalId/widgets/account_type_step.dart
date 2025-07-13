import 'package:coopengageplus/features/onboarding/IndividualAccountByNationalId/model/account_type.dart';
import 'package:coopengageplus/features/onboarding/IndividualAccountByNationalId/services/account_type_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import '../providers/account_type_provider.dart';

class AccountTypeStep extends ConsumerStatefulWidget {
  final String? selectedAccountType;
  final Function(String?) onAccountTypeChanged;
  final Function(AccountType?) onAccountTypeSelected;
  final GlobalKey<FormState> formKey;
  final int customerAge;
  final String customerGender;
  final double? initialDeposit;
  final String bankingType;

  const AccountTypeStep({
    Key? key,
    required this.selectedAccountType,
    required this.onAccountTypeChanged,
    required this.onAccountTypeSelected,
    required this.formKey,
    required this.customerAge,
    required this.customerGender,
    required this.initialDeposit,
    required this.bankingType,
  }) : super(key: key);

  @override
  ConsumerState<AccountTypeStep> createState() => _AccountTypeStepState();
}

class _AccountTypeStepState extends ConsumerState<AccountTypeStep> {
  bool _disposed = false;

  @override
  void initState() {
    print("gememkdhdihfd");
    super.initState();
    _initializeStep();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _initializeStep() async {
    if (_disposed) return;

    // Initialize the step with customer data
    await ref.read(accountTypeStepProvider.notifier).initializeStep(
          customerAge: widget.customerAge,
          customerGender: widget.customerGender,
          initialDeposit: widget.initialDeposit,
          bankingType: widget.bankingType,
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return const SizedBox.shrink();

    // Watch the account type step state
    final accountTypeState = ref.watch(accountTypeStepProvider);
    List<Map<String, dynamic>> filteredAccountTypes = [];
    String? selectedAccountTypeId;
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Account Type"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: filteredAccountTypes.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: filteredAccountTypes.map<Widget>((accountType) {
                      final bool isSelected =
                          selectedAccountTypeId == accountType['name'];
                      // final bool isExpanded =
                      //     expandedAccountTypeId == accountType['name'];

                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedAccountTypeId = accountType['name'];
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue[600]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                accountType['name'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Description
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                crossFadeState: CrossFadeState.showFirst,
                                // : CrossFadeState.showSecond,
                                firstChild: Text(
                                  accountType['description'] ?? '',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                secondChild: Text(
                                  accountType['description'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Show more/less
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      // expandedAccountTypeId = isExpanded
                                      //     ? null
                                      //     : accountType['name'];
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: isSelected
                                        ? Colors.white
                                        : Colors.blueGrey,
                                    padding: EdgeInsets.zero,
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 18,
                                  ),
                                  label: Text(
                                    "Show More",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Sorry, no accounts were found for selection.\nPlease ensure the initial deposit and date of birth are correct.",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          )

          // _buildAccountTypeContent(accountTypeState),
          // _buildAccountTypeDetails(accountTypeState),
        ],
      ),
    );
  }

  Widget _buildAccountTypeContent(AccountTypeStepState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Text(
          state.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (state.availableAccountTypes.isEmpty) {
      return const Center(
        child: Text(
          'No account types available for your profile',
          style: TextStyle(color: Colors.orange),
        ),
      );
    }

    return ReusableDropdown(
      hintText: "Select Account Type",
      selectedValue: widget.selectedAccountType,
      items: state.availableAccountTypes.map((type) => type.name).toList(),
      onChanged: (value) {
        if (!_disposed) {
          // Update both the local state and the provider state
          widget.onAccountTypeChanged(value);
          ref
              .read(accountTypeStepProvider.notifier)
              .updateSelectedAccountType(value);

          if (value != null) {
            final selectedType = ref
                .read(accountTypeStepProvider.notifier)
                .getSelectedAccountType();
            widget.onAccountTypeSelected(selectedType);
          }
        }
      },
      errorMessage: "Please select an account type",
      isRequired: true,
    );
  }

  Widget _buildAccountTypeDetails(AccountTypeStepState state) {
    // Only show details if we have account types and one is selected
    if (state.availableAccountTypes.isEmpty ||
        widget.selectedAccountType == null) {
      return const SizedBox.shrink();
    }

    final selectedType =
        ref.read(accountTypeStepProvider.notifier).getSelectedAccountType();

    if (selectedType == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Type Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Type', selectedType.type),
              _buildDetailRow('Minimum Age', '${selectedType.minAge} years'),
              _buildDetailRow('Maximum Age', '${selectedType.maxAge} years'),
              _buildDetailRow(
                  'Minimum Amount', '${selectedType.minAmount} ETB'),
              _buildDetailRow('Gender', selectedType.sex),
              _buildDetailRow('Banking Type', selectedType.bankingType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
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
