import 'package:coopengageplus/NetworkHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import '../../providers/registration_providers.dart';
import '../../services/registration_service.dart';

class StepAccountType extends ConsumerStatefulWidget {
  const StepAccountType({super.key});

  @override
  ConsumerState<StepAccountType> createState() => _StepAccountTypeState();
}

class _StepAccountTypeState extends ConsumerState<StepAccountType> {
  List<Map<String, dynamic>> allAccountTypes = [];
  List<Map<String, dynamic>> filteredAccountTypes = [];
  String? selectedAccountTypeId;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _loadAccountTypes();
  }

  void _loadExistingData() {
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.accountType != null &&
        registrationData.accountType!.isNotEmpty) {
      setState(() {
        selectedAccountTypeId = registrationData.accountType;
      });
    }
  }

  void _loadExistingDataAfterLoad() {
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.accountType != null &&
        registrationData.accountType!.isNotEmpty) {
      // Check if the stored value is a name (not a numeric ID)
      final storedValue = registrationData.accountType!;
      if (int.tryParse(storedValue) == null) {
        // It's a name, find the corresponding ID
        final accountTypeDetails = getAccountTypeDetails(storedValue);
        if (accountTypeDetails != null) {
          setState(() {
            selectedAccountTypeId = accountTypeDetails['id'].toString();
          });
          // Update the registration data with the ID
          ref.read(registrationDataProvider.notifier).updateAccountType(accountTypeDetails['id'].toString());
        }
      } else {
        // It's already an ID
        setState(() {
          selectedAccountTypeId = storedValue;
        });
      }
    }
  }

  Future<void> _loadAccountTypes() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final networkHandler = NetworkHandler();
      final accountTypes = await networkHandler.fetchAccountTypesFromDatabase();
      print("Account types loaded: ${accountTypes.length}");

      if (accountTypes.isNotEmpty) {
        setState(() {
          allAccountTypes = accountTypes;
          filteredAccountTypes = allAccountTypes;
          isLoading = false;
        });
        _filterAccountTypes();
        _loadExistingDataAfterLoad();
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'No account types found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'An error occurred while loading account types: $e';
        isLoading = false;
      });
    }
  }

  void _filterAccountTypes() {
    final registrationData = ref.read(registrationDataProvider);
    final dateOfBirth = registrationData.dateOfBirth;
    final initialDeposit = registrationData.initialDeposit;
    final sex = registrationData.sex;
    final productType = registrationData.productType;

    if (dateOfBirth == null || initialDeposit == null || productType == null) {
      setState(() {
        filteredAccountTypes = [];
      });
      return;
    }

    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final age = DateTime.now().year - birthDate.year;
      final deposit = double.tryParse(initialDeposit.toString()) ?? 0.0;

      setState(() {
        filteredAccountTypes = allAccountTypes.where((accountType) {
          final minAge =
              int.tryParse(accountType['minAge']?.toString() ?? '0') ?? 0;
          final maxAge =
              int.tryParse(accountType['maxAge']?.toString() ?? '999') ?? 999;
          final minAmount =
              double.tryParse(accountType['minAmount']?.toString() ?? '0') ??
                  0.0;
          final accountSex = accountType['sex']?.toString() ?? '';
          final accountBankingType =
              accountType['bankingType']?.toString() ?? '';

          // Check age requirements
          final meetsAgeRequirement =
              age >= minAge && (maxAge > 100 || age <= maxAge);

          // Check deposit requirements
          final meetsDepositRequirement = deposit >= minAmount;

          // Check gender requirements (if specified)
          final meetsGenderRequirement =
              accountSex.isEmpty || accountSex == sex || accountSex == 'BOTH';

          // Check product type requirements (Conventional vs Alhuda)
          final meetsProductTypeRequirement =
              accountBankingType.toUpperCase() == productType.toUpperCase();

          return meetsAgeRequirement &&
              meetsDepositRequirement &&
              meetsGenderRequirement &&
              meetsProductTypeRequirement;
        }).toList();
      });
    } catch (e) {
      setState(() {
        filteredAccountTypes = [];
      });
    }
  }

  Map<String, dynamic>? getAccountTypeDetails(String selectedAccountType) {
    if (selectedAccountType.isNotEmpty && filteredAccountTypes.isNotEmpty) {
      try {
        var selectedAccountTypeDetails = filteredAccountTypes.firstWhere(
          (accountType) => accountType['name'] == selectedAccountType,
        );

        return {
          "id": selectedAccountTypeDetails['id'],
          "name": selectedAccountTypeDetails['name'],
          "type": selectedAccountTypeDetails['type'],
          "minAge": selectedAccountTypeDetails["minAge"] ?? "",
          "maxAge": selectedAccountTypeDetails["maxAge"] ?? "",
          "minAmount": selectedAccountTypeDetails["minAmount"] ?? "",
          "sex": selectedAccountTypeDetails["sex"] ?? "",
          "bankingType": selectedAccountTypeDetails["bankingType"]
        };
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard(
      Map<String, dynamic> accountType, bool isSelected) {
    final name = accountType['name'] as String? ?? 'Unknown';
    final minAge = int.tryParse(accountType['minAge']?.toString() ?? '0') ?? 0;
    final maxAge = int.tryParse(accountType['maxAge']?.toString() ?? '0') ?? 0;
    final minAmount = accountType['minAmount']?.toString() ?? '0';
    final bankingType = accountType['bankingType']?.toString() ?? '';

    final ageText =
        maxAge > 100 ? 'Minimum Age: $minAge' : 'Age Range: $minAge - $maxAge';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: isSelected ? 8 : 2,
        shadowColor: isSelected
            ? cyanblueColor.withOpacity(0.3)
            : Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? cyanblueColor : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedAccountTypeId = accountType['id'].toString();
            });
            // Update registration data with ID
            ref.read(registrationDataProvider.notifier).updateAccountType(accountType['id'].toString());
            // Clear validation errors
            ref.read(formValidationProvider.notifier).clearError('accountType');
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cyanblueColor,
                        cyanblueColor.withOpacity(0.8),
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ageText,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Min Amount: $minAmount',
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (bankingType.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_outlined,
                        size: 16,
                        color: isSelected ? Colors.white70 : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Type: $bankingType',
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validationErrors = ref.watch(formValidationProvider);

    // Listen to registration data changes
    ref.listen(registrationDataProvider, (previous, next) {
      if (previous?.accountType != next.accountType &&
          next.accountType != null &&
          next.accountType!.isNotEmpty) {
        setState(() {
          selectedAccountTypeId = next.accountType;
        });
      }
    });

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cyanblueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cyanblueColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_outlined,
                        color: cyanblueColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Select Account Type',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the account type that best suits your needs based on your age, initial deposit, and product type.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Loading State
            if (isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(cyanblueColor),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading account types...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

            // Error State
            if (hasError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error Loading Account Types',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadAccountTypes,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

            // Account Types List
            if (!isLoading && !hasError) ...[
              if (filteredAccountTypes.isNotEmpty) ...[
                Text(
                  'Available Account Types (${filteredAccountTypes.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ...filteredAccountTypes
                    .map((accountType) => _buildAccountTypeCard(accountType,
                        selectedAccountTypeId == accountType['id'].toString()))
                    .toList(),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade600,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Account Types Available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sorry, no accounts were found for selection. Please ensure that the initial deposit, date of birth, and product type are correctly entered.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            // Validation Error
            if (validationErrors['accountType'] != null &&
                validationErrors['accountType']!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        validationErrors['accountType']!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Method to validate and save data (called from parent)

  // Method to handle registration (similar to your previous code)
  // Future<bool> handleRegistration() async {
  //   try {
  //     print("dfjdnfdjfjdjddfnjdjjfd");
  //     final registrationData = ref.read(registrationDataProvider);
  //     final isOnline = ref.read(connectivityProvider);
  //     final userId = ref.read(userIdProvider);

  //     print(selectedAccountTypeId);
  //     print("daaaaa");

  //     var id;
  //     var selectedAccountTypeName;

  //     if (selectedAccountTypeId != null) {
  //       var accountTypeDetails = getAccountTypeDetails(selectedAccountTypeId!);

  //       id = accountTypeDetails != null ? accountTypeDetails['id'] : null;
  //       selectedAccountTypeName = accountTypeDetails?['name'];
  //     }

  //     if (id == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Please select account type'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       return false; // Stop execution if invalid
  //     }
  //     print("kfdkfnjjfdndjfjdfjdfjdjfjdjfj");
  //     print(id);
  //     // Use the registration service to submit account type
  //     final registrationService = ref.read(registrationServiceProvider);
  //     final result = await registrationService.submitAccountType(
  //       accountType: id.toString(),
  //       isOnline: isOnline,
  //       userId: userId,
  //     );

  //     if (result.isSuccess) {
  //       // Update local registration data (save the ID, not the name)
  //       ref
  //           .read(registrationDataProvider.notifier)
  //           .updateAccountType(id.toString());
  //       ref.read(registrationDataProvider.notifier).updateProgress(87.5);

  //       return true;
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content:
  //               Text(result.errorMessage ?? 'Failed to update account type'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error in handleRegistration: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('An error occurred: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return false;
  //   }
  // }
}
