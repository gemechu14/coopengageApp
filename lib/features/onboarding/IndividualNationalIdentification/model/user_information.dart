/// Model representing user information fetched from National ID authentication
class UserInformation {
  final int? authId;
  final String? fullName;
  final String? email;
  final bool? emailVerified;
  final String? phone;
  final String? state;
  final String? country;
  final String? sex;
  final String? status;
  final String? dateOfBirth;
  final String? customerType;
  final String? legalId;
  final double? percentageComplete;
  final String? createdAt;
  final String? updatedAt;
  final int? accountId;

  const UserInformation({
    this.authId,
    this.fullName,
    this.email,
    this.emailVerified,
    this.phone,
    this.state,
    this.country,
    this.sex,
    this.status,
    this.dateOfBirth,
    this.customerType,
    this.legalId,
    this.percentageComplete,
    this.createdAt,
    this.updatedAt,
    this.accountId,
  });

  /// Create UserInformation from JSON
  factory UserInformation.fromJson(Map<String, dynamic> json) {
    return UserInformation(
      authId: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      fullName: json['fullName']?.toString(),
      email: json['email']?.toString(),
      emailVerified: json['emailVerified'] as bool?,
      phone: json['phone']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      sex: json['sex']?.toString(),
      status: json['status']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      customerType: json['customerType']?.toString(),
      legalId: json['legalId']?.toString(),
      percentageComplete: json['percentageComplete'] != null
          ? double.tryParse(json['percentageComplete'].toString())
          : null,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      accountId: json['accountId'] != null
          ? int.tryParse(json['accountId'].toString())
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': authId,
      'fullName': fullName,
      'email': email,
      'emailVerified': emailVerified,
      'phone': phone,
      'state': state,
      'country': country,
      'sex': sex,
      'status': status,
      'dateOfBirth': dateOfBirth,
      'customerType': customerType,
      'legalId': legalId,
      'percentageComplete': percentageComplete,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'accountId': accountId,
    };
  }

  /// Create a copy with updated values
  UserInformation copyWith({
    int? authId,
    String? fullName,
    String? email,
    bool? emailVerified,
    String? phone,
    String? state,
    String? country,
    String? sex,
    String? status,
    String? dateOfBirth,
    String? customerType,
    String? legalId,
    double? percentageComplete,
    String? createdAt,
    String? updatedAt,
    int? accountId,
  }) {
    return UserInformation(
      authId: authId ?? this.authId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      phone: phone ?? this.phone,
      state: state ?? this.state,
      country: country ?? this.country,
      sex: sex ?? this.sex,
      status: status ?? this.status,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      customerType: customerType ?? this.customerType,
      legalId: legalId ?? this.legalId,
      percentageComplete: percentageComplete ?? this.percentageComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accountId: accountId ?? this.accountId,
    );
  }

  @override
  String toString() {
    return 'UserInformation(authId: $authId, fullName: $fullName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInformation &&
        other.authId == authId &&
        other.fullName == fullName &&
        other.email == email;
  }

  @override
  int get hashCode {
    return authId.hashCode ^ fullName.hashCode ^ email.hashCode;
  }
} 