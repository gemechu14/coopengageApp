import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/features/onboarding/IndividualAccountByNationalId/model/account_type.dart';


class AccountTypeService {
  final NetworkHandler _networkHandler = NetworkHandler();

  Future<List<AccountType>> fetchAccountTypes() async {
    print("ddjfhdhfjdjfdjjfdjdjf");
    try {
      final accountTypes = await _networkHandler.fetchAccountTypesFromDatabase();
      return accountTypes.map((type) => AccountType.fromMap(type)).toList();
    } catch (e) {
      print('Error fetching account types: $e');
      return [];
    }
  }

  List<AccountType> filterAccountTypes({
    required List<AccountType> allTypes,
    required int age,
    required String gender,
    required double? initialDeposit,
    required String bankingType,
  }) {
    final deposit = initialDeposit ?? 1000.0; // Default value if null
    return allTypes.where((type) => type.isValidForCustomer(
      age: age,
      gender: gender,
      initialDeposit: deposit,
      bankingType: bankingType,
    )).toList();
  }

  AccountType? findAccountTypeByName(List<AccountType> types, String name) {
    try {
      return types.firstWhere((type) => type.name == name);
    } catch (e) {
      print('Account type not found: $name');
      return null;
    }
  }

  getAccountTypes() {}
} 