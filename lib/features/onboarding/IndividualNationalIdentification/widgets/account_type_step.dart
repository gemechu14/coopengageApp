import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/account_type.dart';
import '../providers/account_type_provider.dart';
import '../providers/stepper_provider.dart';

/// Account Type Selection Step Widget
///
/// Features:
/// - Smart filtering based on age, gender, and product type
/// - Beautiful card-based selection UI
/// - Share calculation for MUDARABAH accounts
/// - Comprehensive validation and error handling
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
  // Controllers for share calculation
  final TextEditingController _bankShareController = TextEditingController();
  final TextEditingController _customerShareController =
      TextEditingController();

  // State management
  bool _disposed = false;
  List<AccountType> _filteredAccountTypes = [];
  String? _shareError;
  int _calculatedAge = 0;

  @override
  void initState() {
    super.initState();
    _calculateAge();
    _scheduleInitialization();
  }

  @override
  void didUpdateWidget(covariant AccountTypeStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    _filterAccountTypes();
  }

  @override
  void dispose() {
    _disposed = true;
    _cleanupControllers();
    super.dispose();
  }

  /// Clean up controllers
  void _cleanupControllers() {
    _bankShareController.dispose();
    _customerShareController.dispose();
  }

  /// Calculate user's age from date of birth
  void _calculateAge() {
    if (widget.dateOfBirth != null) {
      final DateTime dob = widget.dateOfBirth!;
      final DateTime now = DateTime.now();

      _calculatedAge = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        _calculatedAge--;
      }
    } else {
      _calculatedAge = widget.customerAge;
    }
  }

  /// Schedule initialization after build
  void _scheduleInitialization() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeStep();
      }
    });
  }

  /// Initialize the step
  Future<void> _initializeStep() async {
    if (_disposed) return;

    try {
      await ref.read(accountTypeStepProvider.notifier).initializeStep(
            customerAge: _calculatedAge,
            customerGender: widget.customerGender,
            initialDeposit: widget.initialDeposit,
            bankingType: widget.bankingType,
          );
      _filterAccountTypes();
    } catch (e) {
      debugPrint('Error initializing account type step: $e');
    }
  }

  /// Filter account types based on user criteria
  void _filterAccountTypes() {
    if (_disposed) return;

    final accountTypeStepState = ref.read(accountTypeStepProvider);
    final stepperState = ref.read(stepperProvider);

    List<AccountType> filtered =
        List.from(accountTypeStepState.availableAccountTypes);

    // Apply filters
    filtered = _applyAgeFilter(filtered);
    filtered =
        _applyProductTypeFilter(filtered, stepperState.selectedProductType);
    filtered = _applyGenderFilter(filtered, stepperState.sex);

    if (mounted) {
      setState(() {
        _filteredAccountTypes = filtered;
      });
    }
  }

  /// Apply age-based filtering
  List<AccountType> _applyAgeFilter(List<AccountType> accountTypes) {
    if (_calculatedAge <= 0) return accountTypes;

    return accountTypes
        .where((type) =>
            _calculatedAge >= type.minAge && _calculatedAge <= type.maxAge)
        .toList();
  }

  /// Apply product type filtering
  List<AccountType> _applyProductTypeFilter(
    List<AccountType> accountTypes,
    String? productType,
  ) {
    if (productType?.trim().isEmpty != false) return accountTypes;

    final normalizedProductType = productType!.trim().toLowerCase();
    return accountTypes
        .where((type) =>
            type.bankingType.trim().toLowerCase() == normalizedProductType)
        .toList();
  }

  /// Apply gender-based filtering
  List<AccountType> _applyGenderFilter(
    List<AccountType> accountTypes,
    String? userSex,
  ) {
    if (userSex?.trim().isEmpty != false) return accountTypes;

    final normalizedUserSex = userSex!.trim().toUpperCase();
    return accountTypes
        .where((type) => type.sex == 'BOTH' || type.sex == normalizedUserSex)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return const SizedBox.shrink();

    final accountTypeStepState = ref.watch(accountTypeStepProvider);

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildContent(accountTypeStepState),
        ],
      ),
    );
  }

  /// Build header section
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.account_balance, color: Colors.blue, size: 24),
          ),
          // const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Type Selection',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                // Text(
                //   'Choose an account type that matches your profile (Age: $_calculatedAge)',
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: Colors.grey[600],
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build main content
  Widget _buildContent(AccountTypeStepState state) {
    if (state.isLoading) {
      return _buildLoadingState();
    }

    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!);
    }

    if (_filteredAccountTypes.isEmpty) {
      return _buildNoAccountTypesState();
    }

    return Column(
      children: [
        _buildAccountTypesList(),
        _buildSharesSection(),
      ],
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading account types...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading account types',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeStep,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build no account types state
  Widget _buildNoAccountTypesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.orange[600]),
            const SizedBox(height: 16),
            const Text(
              'No Matching Account Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No account types match your current profile. Please check your information and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// Build account types list
  Widget _buildAccountTypesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _filteredAccountTypes.map((accountType) {
          final bool isSelected =
              widget.selectedAccountType == accountType.id.toString();
          return _buildAccountTypeCard(accountType, isSelected);
        }).toList(),
      ),
    );
  }

  /// Build individual account type card
  Widget _buildAccountTypeCard(AccountType accountType, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleAccountTypeSelection(accountType),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                blurRadius: isSelected ? 12 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _buildCardIcon(accountType, isSelected),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCardContent(accountType, isSelected),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build card icon
  Widget _buildCardIcon(AccountType accountType, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withOpacity(0.2)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getAccountTypeIcon(accountType.type),
        color: isSelected ? Colors.white : Colors.blue,
        size: 24,
      ),
    );
  }

  /// Build card content
  Widget _buildCardContent(AccountType accountType, bool isSelected) {
    final textColor = isSelected ? Colors.white : Colors.black87;
    final subtitleColor = isSelected ? Colors.white70 : Colors.grey[600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          accountType.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${accountType.bankingType} • ${accountType.type}',
          style: TextStyle(
            fontSize: 12,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildAccountDetails(accountType, subtitleColor),
      ],
    );
  }

  /// Build account details
  Widget _buildAccountDetails(AccountType accountType, Color? textColor) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _buildDetailChip(
            'Age: ${accountType.minAge}-${accountType.maxAge}', textColor),
        _buildDetailChip('Min: ${accountType.minAmount} ETB', textColor),
        if (accountType.sex != 'BOTH')
          _buildDetailChip(accountType.sex, textColor),
      ],
    );
  }

  /// Build detail chip
  Widget _buildDetailChip(String text, Color? textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: textColor?.withOpacity(0.1) ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Build shares section for MUDARABAH accounts
  Widget _buildSharesSection() {
    final selectedType = _getSelectedAccountType();
    final showShares = selectedType?.category == 'MUDARABAH' &&
        selectedType?.bankingType == 'ALHUDA';

    if (!showShares) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Profit Sharing Configuration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
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
          if (_shareError != null) ...[
            const SizedBox(height: 8),
            Text(
              _shareError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  /// Build share input field
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
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          readOnly: readOnly,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint ?? 'Enter percentage (0-100)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          validator: readOnly ? null : _validateBankShare,
        ),
      ],
    );
  }

  /// Get account type icon
  IconData _getAccountTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'SAVING':
        return Icons.savings;
      case 'CURRENT':
        return Icons.account_balance_wallet;
      case 'FIXED':
        return Icons.lock;
      default:
        return Icons.account_balance;
    }
  }

  /// Handle account type selection
  void _handleAccountTypeSelection(AccountType accountType) {
    widget.onAccountTypeChanged(accountType.id.toString());
    widget.onAccountTypeSelected(accountType);
    _resetShareFields();
  }

  /// Reset share fields
  void _resetShareFields() {
    _bankShareController.clear();
    _customerShareController.clear();
    setState(() => _shareError = null);
  }

  /// Handle bank share change
  void _handleBankShareChange(String value) {
    final bankShare = int.tryParse(value);

    if (bankShare != null && bankShare >= 0 && bankShare <= 100) {
      final customerShare = 100 - bankShare;
      _customerShareController.text = customerShare.toString();

      setState(() => _shareError = null);

      // Update stepper state
      ref.read(stepperProvider.notifier).updateBankShare(bankShare);
      ref.read(stepperProvider.notifier).updateCustomerShare(customerShare);
    } else {
      setState(() => _shareError = 'Enter a valid percentage (0-100)');

      // Clear stepper state
      ref.read(stepperProvider.notifier).updateBankShare(null);
      ref.read(stepperProvider.notifier).updateCustomerShare(null);
    }
  }

  /// Validate bank share
  String? _validateBankShare(String? value) {
    if (value?.trim().isEmpty == true) {
      return 'Bank share is required';
    }

    final bankShare = int.tryParse(value!);
    if (bankShare == null || bankShare < 0 || bankShare > 100) {
      return 'Enter a valid percentage (0-100)';
    }

    final customerShare = int.tryParse(_customerShareController.text);
    if (customerShare == null) {
      return 'Customer share calculation failed';
    }

    if (bankShare + customerShare != 100) {
      return 'Total shares must equal 100%';
    }

    return null;
  }

  /// Get selected account type
  AccountType? _getSelectedAccountType() {
    if (widget.selectedAccountType == null) return null;

    try {
      return _filteredAccountTypes.firstWhere(
        (type) => type.id.toString() == widget.selectedAccountType,
      );
    } catch (_) {
      return null;
    }
  }
}
