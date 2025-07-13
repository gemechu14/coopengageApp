class AccountType {
  final int id;
  final String name;
  final String type;
  final int minAge;
  final int maxAge;
  final double minAmount;
  final String sex;
  final String bankingType;

  AccountType({
    required this.id,
    required this.name,
    required this.type,
    required this.minAge,
    required this.maxAge,
    required this.minAmount,
    required this.sex,
    required this.bankingType,
  });

  factory AccountType.fromMap(Map<String, dynamic> map) {
    return AccountType(
      id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      name: map['name']?.toString() ?? 'Unknown Account Type',
      type: map['type']?.toString() ?? 'Unknown',
      minAge: int.tryParse(map['minAge']?.toString() ?? '0') ?? 0,
      maxAge: int.tryParse(map['maxAge']?.toString() ?? '300') ?? 300,
      minAmount: double.tryParse(map['minAmount']?.toString() ?? '0') ?? 0,
      sex: (map['sex'] ?? 'BOTH').toString().toUpperCase(),
      bankingType: (map['bankingType'] ?? '').toString().toUpperCase(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'minAge': minAge,
      'maxAge': maxAge,
      'minAmount': minAmount,
      'sex': sex,
      'bankingType': bankingType,
    };
  }

  bool isValidForCustomer({
    required int age,
    required String gender,
    required double initialDeposit,
    required String bankingType,
  }) {
    // Banking type must match
    if (this.bankingType != bankingType.toUpperCase()) {
      return false;
    }

    // Age must be within range
    if (age < minAge || age > maxAge) {
      return false;
    }

    // Initial deposit must meet minimum
    if (initialDeposit < minAmount) {
      return false;
    }

    // Gender must match if not BOTH
    if (sex != 'BOTH' && sex != gender.toUpperCase()) {
      return false;
    }

    return true;
  }
}
