import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/model/account_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import '../providers/account_type_provider.dart';
import '../providers/stepper_provider.dart';

class AccountTypeStep extends ConsumerStatefulWidget {
  final String? selectedAccountType;
  final Function(String?) onAccountTypeChanged;
  final Function(AccountType?) onAccountTypeSelected;
  final GlobalKey<FormState> formKey;
  final int customerAge;
  final String customerGender;
  final double? initialDeposit;
  final String bankingType;
  final DateTime? dateOfBirth;
  final String? productType;

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
    this.dateOfBirth,
    this.productType,
  }) : super(key: key);

  @override
  ConsumerState<AccountTypeStep> createState() => _AccountTypeStepState();
}

class _AccountTypeStepState extends ConsumerState<AccountTypeStep> {
  bool _disposed = false;
  List<AccountType> filteredAccountTypes = [];
  final TextEditingController _bankShareController = TextEditingController();
  final TextEditingController _customerShareController =
      TextEditingController();
  String? _shareError;

  @override
  void initState() {
    print("gememkdhdihfd");
    super.initState();
    // Schedule after build so provider is guaranteed to be alive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeStep();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AccountTypeStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    _filterAccountTypes();
  }

  @override
  void dispose() {
    _disposed = true;
    _bankShareController.dispose();
    _customerShareController.dispose();
    super.dispose();
  }

  Future<void> _initializeStep() async {
    print("dkfkdfkdkjfdkfkdfkdkjf");
    if (_disposed) return;
    await ref.read(accountTypeStepProvider.notifier).initializeStep(
          customerAge: widget.customerAge,
          customerGender: widget.customerGender,
          initialDeposit: widget.initialDeposit,
          bankingType: widget.bankingType,
        );
    _filterAccountTypes();
  }

  void _filterAccountTypes() {
    final accountTypeStepState = ref.read(accountTypeStepProvider);
    final account_types = accountTypeStepState.availableAccountTypes;
    final stepper_state = ref.read(stepperProvider);

    final String? product_type = stepper_state.selectedProductType;
    final double? initial_deposit = widget.initialDeposit;

    // Filter: Only category == 'CURRENT', matches productType (bankingType), and minAmount <= initialDeposit
    List<AccountType> filtered = account_types
        .where((account_type) =>
            account_type.category.toUpperCase() == 'CURRENT' &&
            (product_type == null ||
                product_type.trim().isEmpty ||
                account_type.bankingType.trim().toLowerCase() ==
                    product_type.trim().toLowerCase()) &&
            (initial_deposit == null ||
                account_type.minAmount <= initial_deposit))
        .toList();

    setState(() {
      filteredAccountTypes = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return const SizedBox.shrink();
    final accountTypeStepState = ref.watch(accountTypeStepProvider);
    if (accountTypeStepState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    void _onAccountTypeTap(AccountType account_type) {
      widget.onAccountTypeChanged(account_type.id.toString());
      widget.onAccountTypeSelected(account_type);
      _bankShareController.text = '';
      _customerShareController.text = '';
      setState(() {
        _shareError = null;
      });
    }

    final allAccountTypes = filteredAccountTypes.isNotEmpty
        ? filteredAccountTypes
        : accountTypeStepState.availableAccountTypes;

    AccountType? selectedType;
    try {
      selectedType = allAccountTypes.firstWhere(
        (type) => widget.selectedAccountType == type.id.toString(),
      );
    } catch (_) {
      selectedType = null;
    }
    final showShares = selectedType != null &&
        selectedType.category == 'MUDARABAH' &&
        selectedType.bankingType == 'ALHUDA';

    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Account Type"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: allAccountTypes.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...allAccountTypes.map<Widget>((account_type) {
                        final bool isSelected = widget.selectedAccountType ==
                            account_type.id.toString();
                        return InkWell(
                          onTap: () => _onAccountTypeTap(account_type),
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1976D2)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1976D2)
                                    : Colors.grey.shade300,
                                width: isSelected ? 2.2 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? const Color(0xFF1976D2)
                                          .withOpacity(0.18)
                                      : Colors.grey.withOpacity(0.10),
                                  blurRadius: isSelected ? 16 : 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.account_balance,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.blueGrey,
                                  size: 28,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account_type.name,
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        account_type.bankingType,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white70
                                              : Colors.blueGrey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Text(
                                      //   ': ${account_type.}  |  Max Age: ${account_type.maxAge}',
                                      //   style: TextStyle(
                                      //     color: isSelected
                                      //         ? Colors.white70
                                      //         : Colors.grey[600],
                                      //     fontSize: 13,
                                      //   ),
                                      // ),
                                      Text(
                                        'Min Deposit: ${account_type.minAmount}',
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white70
                                              : Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      if (showShares) ...[
                        const SizedBox(height: 24),
                        Text('Bank Share (%)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextFormField(
                          controller: _bankShareController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Enter bank share',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bank share is required';
                            }
                            final bank = int.tryParse(value);
                            final customer =
                                int.tryParse(_customerShareController.text);
                            if (bank == null || bank < 0 || bank > 100) {
                              return 'Enter a valid percent (0-100)';
                            }
                            if (customer == null) {
                              return 'Customer share is required';
                            }
                            if (bank + customer != 100) {
                              return 'Sum must be 100';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            final bank = int.tryParse(value);
                            if (bank != null && bank >= 0 && bank <= 100) {
                              final customer = 100 - bank;
                              _customerShareController.text =
                                  customer.toString();
                              setState(() {
                                _shareError = null;
                              });
                              ref
                                  .read(stepperProvider.notifier)
                                  .updateBankShare(bank);
                              ref
                                  .read(stepperProvider.notifier)
                                  .updateCustomerShare(customer);
                            } else {
                              setState(() {
                                _shareError = 'Enter a valid percent (0-100)';
                              });
                              ref
                                  .read(stepperProvider.notifier)
                                  .updateBankShare(null);
                              ref
                                  .read(stepperProvider.notifier)
                                  .updateCustomerShare(null);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Text('Customer Share (%)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextFormField(
                          controller: _customerShareController,
                          keyboardType: TextInputType.number,
                          readOnly: true,
                          decoration: const InputDecoration(
                            hintText: 'Auto-calculated',
                          ),
                        ),
                        if (_shareError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(_shareError!,
                                style: const TextStyle(color: Colors.red)),
                          ),
                      ],
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Sorry, no account types match your selection.",
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
