class JointMemberInfo {
  final String? nationalId;
  final String? fullName;
  final String? motherName;
  final String? title;
  final String? sex;
  final String? dateOfBirth;
  final String? maritalStatus;
  final dynamic signature;

  JointMemberInfo({
    this.nationalId,
    this.fullName,
    this.motherName,
    this.title,
    this.sex,
    this.dateOfBirth,
    this.maritalStatus,
    this.signature,
  });

  JointMemberInfo copyWith({
    String? nationalId,
    String? fullName,
    String? motherName,
    String? title,
    String? sex,
    String? dateOfBirth,
    String? maritalStatus,
    dynamic signature,
  }) {
    return JointMemberInfo(
      nationalId: nationalId ?? this.nationalId,
      fullName: fullName ?? this.fullName,
      motherName: motherName ?? this.motherName,
      title: title ?? this.title,
      sex: sex ?? this.sex,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      signature: signature ?? this.signature,
    );
  }

  factory JointMemberInfo.fromMap(Map<String, dynamic> map) {
    return JointMemberInfo(
      nationalId: map['nationalId'],
      fullName: map['fullName'],
      motherName: map['motherName'],
      title: map['title'],
      sex: map['sex'],
      dateOfBirth: map['dateOfBirth'],
      maritalStatus: map['maritalStatus'],
      signature: map['signature'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nationalId': nationalId,
      'fullName': fullName,
      'motherName': motherName,
      'title': title,
      'sex': sex,
      'dateOfBirth': dateOfBirth,
      'maritalStatus': maritalStatus,
      'signature': signature,
    };
  }
}

class RegistrationData {
  final String? phone;
  final String? email;
  final String? productType;
  final String? fullName;
  final String? surname;
  final String? motherName;
  final String? title;
  final String? sex;
  final String? dateOfBirth;
  final String? maritalStatus;
  final String? branch;
  final String? documentName;
  final dynamic residenceCard; // Can be String, File, or Uint8List depending on usage
  final dynamic residenceCardBack;
  final String? occupation;
  final String? monthlyIncome;
  final String? initialDeposit;
  final String? sector;
  final String? country;
  final String? state;
  final String? zoneSubCity;
  final String? streetAddress;
  final String? legalId;
  final String? issueAuthority;
  final String? issueDate;
  final String? expirayDate;
  final String? accountType;
  final String? currency;
  final dynamic signature;
  final dynamic photo;
  final bool? termsAccepted;
  final double percentageCompleted;
  final String? status;
  final int? bankShare;
  final int? customerShare;
  final List<JointMemberInfo>? members;

  RegistrationData({
    this.phone,
    this.email,
    this.productType,
    this.fullName,
    this.surname,
    this.motherName,
    this.title,
    this.sex,
    this.dateOfBirth,
    this.maritalStatus,
    this.branch,
    this.documentName,
    this.residenceCard,
    this.residenceCardBack,
    this.occupation,
    this.monthlyIncome,
    this.initialDeposit,
    this.sector,
    this.country,
    this.state,
    this.zoneSubCity,
    this.streetAddress,
    this.legalId,
    this.issueAuthority,
    this.issueDate,
    this.expirayDate,
    this.accountType,
    this.currency,
    this.signature,
    this.photo,
    this.termsAccepted,
    this.percentageCompleted = 0.0,
    this.status,
    this.bankShare,
    this.customerShare,
    this.members,
  });

  factory RegistrationData.fromMap(Map<String, dynamic> map) {
    return RegistrationData(
      phone: map['phone'],
      email: map['email'],
      productType: map['productType'],
      fullName: map['fullName'],
      surname: map['surname'],
      motherName: map['motherName'],
      title: map['title'],
      sex: map['sex'],
      dateOfBirth: map['dateOfBirth'],
      maritalStatus: map['maritalStatus'],
      branch: map['branch'],
      documentName: map['documentName'],
      residenceCard: map['residenceCard'],
      residenceCardBack: map['residenceCardBack'],
      occupation: map['occupation'],
      monthlyIncome: map['monthlyIncome'],
      initialDeposit: map['initialDeposit'],
      sector: map['sector'],
      country: map['country'],
      state: map['state'],
      zoneSubCity: map['zoneSubCity'],
      streetAddress: map['streetAddress'],
      legalId: map['legalId'],
      issueAuthority: map['issueAuthority'],
      issueDate: map['issueDate'],
      expirayDate: map['expirayDate'],
      accountType: map['accountType'],
      currency: map['currency'],
      signature: map['signature'],
      photo: map['photo'],
      termsAccepted: map['termsAccepted'],
      percentageCompleted: map['percentageCompleted'] != null ? double.tryParse(map['percentageCompleted'].toString()) ?? 0.0 : 0.0,
      status: map['status'],
      bankShare: map['bankShare'] != null ? int.tryParse(map['bankShare'].toString()) : null,
      customerShare: map['customerShare'] != null ? int.tryParse(map['customerShare'].toString()) : null,
      members: map['members'] != null
          ? List<JointMemberInfo>.from(
              (map['members'] as List).map((x) => JointMemberInfo.fromMap(x)))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'email': email,
      'productType': productType,
      'fullName': fullName,
      'surname': surname,
      'motherName': motherName,
      'title': title,
      'sex': sex,
      'dateOfBirth': dateOfBirth,
      'maritalStatus': maritalStatus,
      'branch': branch,
      'documentName': documentName,
      'residenceCard': residenceCard,
      'residenceCardBack': residenceCardBack,
      'occupation': occupation,
      'monthlyIncome': monthlyIncome,
      'initialDeposit': initialDeposit,
      'sector': sector,
      'country': country,
      'state': state,
      'zoneSubCity': zoneSubCity,
      'streetAddress': streetAddress,
      'legalId': legalId,
      'issueAuthority': issueAuthority,
      'issueDate': issueDate,
      'expirayDate': expirayDate,
      'accountType': accountType,
      'currency': currency,
      'signature': signature,
      'photo': photo,
      'termsAccepted': termsAccepted,
      'percentageCompleted': percentageCompleted,
      'status': status,
      'bankShare': bankShare,
      'customerShare': customerShare,
      'members': members?.map((x) => x.toMap()).toList(),
    };
  }
} 