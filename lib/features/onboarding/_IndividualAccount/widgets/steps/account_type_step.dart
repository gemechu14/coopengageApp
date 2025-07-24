import 'package:flutter/material.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import '../../constants/list_constants.dart';
import '../../models/account_type.dart';
import '../../services/account_type_service.dart';

class AccountTypeStep extends StatefulWidget {
  final String? selectedAccountType;
  final Function(String?) onAccountTypeChanged;
  final Function(AccountType?) onAccountTypeSelected;
  final GlobalKey<FormState> formKey;
  final int customerAge;
  final String customerGender;
  final double initialDeposit;
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
  State<AccountTypeStep> createState() => _AccountTypeStepState();
}

class _AccountTypeStepState extends State<AccountTypeStep> {
  final AccountTypeService _accountTypeService = AccountTypeService();
  List<AccountType> _availableAccountTypes = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Controllers for share calculation
  final TextEditingController _bankShareController = TextEditingController();
  final TextEditingController _customerShareController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAccountTypes();
    // Initialize customer share controller to be auto-calculated
    _customerShareController.text = '';
  }

  @override
  void dispose() {
    _bankShareController.dispose();
    _customerShareController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountTypes() async {
    try {
      final accountTypes = await _accountTypeService.fetchAccountTypes();
      final filteredTypes = _accountTypeService.filterAccountTypes(
        allTypes: accountTypes,
        age: widget.customerAge,
        gender: widget.customerGender,
        initialDeposit: widget.initialDeposit,
        bankingType: widget.bankingType,
      );
      setState(() {
        _availableAccountTypes = filteredTypes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load account types: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _handleBankShareChange(String value) {
    if (value.isNotEmpty) {
      final bankShare = double.tryParse(value) ?? 0.0;
      if (bankShare >= 0 && bankShare <= 100) {
        final customerShare = 100 - bankShare;
        setState(() {
          _customerShareController.text = customerShare.toStringAsFixed(1);
        });
      } else {
        setState(() {
          _customerShareController.text = '';
        });
      }
    } else {
      setState(() {
        _customerShareController.text = '';
      });
    }
  }

  bool _isMudarabahAccount() {
    if (widget.selectedAccountType == null) return false;
    
    final selectedType = _accountTypeService.findAccountTypeByName(
      _availableAccountTypes,
      widget.selectedAccountType!,
    );
    
    return selectedType?.type.toUpperCase() == 'MUDARABAH';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Account Type"),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (_availableAccountTypes.isEmpty)
            const Center(
              child: Text(
                'No account types available for your profile',
                style: TextStyle(color: Colors.orange),
              ),
            )
          else
            ReusableDropdown(
              hintText: "Select Account Type",
              selectedValue: widget.selectedAccountType,
              items: _availableAccountTypes.map((type) => type.name).toList(),
              onChanged: (value) {
                widget.onAccountTypeChanged(value);
                if (value != null) {
                  final selectedType =
                      _accountTypeService.findAccountTypeByName(
                    _availableAccountTypes,
                    value,
                  );
                  widget.onAccountTypeSelected(selectedType);
                  
                  // Clear share fields when account type changes
                  _bankShareController.clear();
                  _customerShareController.clear();
                }
              },
              errorMessage: "Please select an account type",
              isRequired: true,
            ),
          
          // Show share fields for MUDARABAH accounts
          if (_isMudarabahAccount()) ...[
            const SizedBox(height: 20),
            _buildShareSection(),
          ],
          
          if (_availableAccountTypes.isNotEmpty &&
              widget.selectedAccountType != null)
            _buildAccountTypeDetails(),
        ],
      ),
    );
  }

  Widget _buildShareSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Profit Sharing Configuration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Configure the profit sharing ratio for this Mudarabah account',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          _buildShareField(
            label: 'Bank Share (%)',
            controller: _bankShareController,
            onChanged: _handleBankShareChange,
          ),
          const SizedBox(height: 12),
          _buildShareField(
            label: 'Customer Share (%)',
            controller: _customerShareController,
            readOnly: true,
            hint: 'Auto-calculated',
          ),
        ],
      ),
    );
  }

  Widget _buildShareField({
    required String label,
    required TextEditingController controller,
    Function(String)? onChanged,
    bool readOnly = false,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onChanged: onChanged,
          keyboardType: readOnly ? TextInputType.none : TextInputType.number,
          decoration: InputDecoration(
            hintText: hint ?? 'Enter percentage (0-100)',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            suffixIcon: const Icon(
              Icons.percent,
              size: 18,
              color: Colors.grey,
            ),
          ),
          validator: readOnly ? null : (value) {
            if (!readOnly && (value == null || value.isEmpty)) {
              return 'Please enter bank share percentage';
            }
            if (!readOnly) {
              final percentage = double.tryParse(value!);
              if (percentage == null || percentage < 0 || percentage > 100) {
                return 'Please enter a valid percentage (0-100)';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAccountTypeDetails() {
    final selectedType = _accountTypeService.findAccountTypeByName(
      _availableAccountTypes,
      widget.selectedAccountType!,
    );

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

// class StepOneForm extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   const StepOneForm({required this.formKey, super.key});
//   // ...
// }

class RegistrationStepper extends StatefulWidget {
  @override
  State<RegistrationStepper> createState() => _RegistrationStepperState();
}

class _RegistrationStepperState extends State<RegistrationStepper> {
  final List<GlobalKey<FormState>> _formKeys =
      List.generate(8, (_) => GlobalKey<FormState>());
  int _activeStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _activeStepIndex,
      onStepContinue: () {
        if (_formKeys[_activeStepIndex].currentState?.validate() ?? false) {
          setState(() {
            _activeStepIndex++;
          });
        }
      },
      onStepCancel: () {
        if (_activeStepIndex > 0) {
          setState(() {
            _activeStepIndex--;
          });
        }
      },
      steps: List.generate(
          8,
          (index) => Step(
                title: Text('Step ${index + 1}'),
                content: Form(
                  key: _formKeys[index],
                  child: Text('Form for step ${index + 1}'),
                ),
              )),
    );
  }
}
