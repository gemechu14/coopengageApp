import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/model/account_type.dart';
import 'package:coopengageplus/features/onboarding/IndividualNationalIdentification/services/account_type_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// State for AccountTypeStep
class AccountTypeStepState {
  final List<AccountType> availableAccountTypes;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedAccountType;
  final bool isInitialized;

  const AccountTypeStepState({
    this.availableAccountTypes = const [],
    this.isLoading = true,
    this.errorMessage,
    this.selectedAccountType,
    this.isInitialized = false,
  });

  AccountTypeStepState copyWith({
    List<AccountType>? availableAccountTypes,
    bool? isLoading,
    String? errorMessage,
    String? selectedAccountType,
    bool? isInitialized,
  }) {
    return AccountTypeStepState(
      availableAccountTypes:
          availableAccountTypes ?? this.availableAccountTypes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedAccountType: selectedAccountType ?? this.selectedAccountType,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// Notifier for AccountTypeStep
class AccountTypeStepNotifier extends StateNotifier<AccountTypeStepState> {
  final AccountTypeService _accountTypeService = AccountTypeService();
  bool _isDisposed = false;

  AccountTypeStepNotifier() : super(const AccountTypeStepState());

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Initialize the step with customer data
  Future<void> initializeStep({
    required int customerAge,
    required String customerGender,
    required double? initialDeposit,
    required String bankingType,
  }) async {
    if (_isDisposed) return;

    // Only initialize once
    if (state.isInitialized) return;

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
    } catch (e) {
      // If notifier is disposed, ignore
      if (e is StateError) return;
      rethrow;
    }

    try {
      final accountTypes = await _accountTypeService.fetchAccountTypes();
      if (_isDisposed) return;

      if (accountTypes.isEmpty) {
        try {
          if (!_isDisposed) {
            state = state.copyWith(
              availableAccountTypes: [],
              isLoading: false,
              errorMessage: 'No account types available',
              isInitialized: true,
            );
          }
        } catch (e) {
          if (e is StateError) return;
          rethrow;
        }
        return;
      }

      // Show all account types instead of filtering
      try {
        if (!_isDisposed) {
          state = state.copyWith(
            availableAccountTypes: accountTypes, // Use all account types
            isLoading: false,
            errorMessage: null,
            isInitialized: true,
          );
        }
      } catch (e) {
        if (e is StateError) return;
        rethrow;
      }
    } catch (e) {
      try {
        if (!_isDisposed) {
          state = state.copyWith(
            availableAccountTypes: [],
            errorMessage: 'Failed to load account types:  [31m${e.toString()} [0m',
            isLoading: false,
            isInitialized: true,
          );
        }
      } catch (err) {
        if (err is StateError) return;
        rethrow;
      }
    }
  }

  // Update selected account type
  void updateSelectedAccountType(String? accountType) {
    if (_isDisposed) return;
    state = state.copyWith(selectedAccountType: accountType);
  }

  // Reset the step
  void reset() {
    if (_isDisposed) return;
    state = const AccountTypeStepState();
  }

  // Get selected account type details
  AccountType? getSelectedAccountType() {
    if (state.selectedAccountType == null) return null;

    return _accountTypeService.findAccountTypeByName(
      state.availableAccountTypes,
      state.selectedAccountType!,
    );
  }
}

// Provider
final accountTypeStepProvider =
    StateNotifierProvider<AccountTypeStepNotifier, AccountTypeStepState>((ref) {
  return AccountTypeStepNotifier();
});
