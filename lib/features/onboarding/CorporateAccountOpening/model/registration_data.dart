class JointMemberInfo {
  final String? nationalId;
  final String? fullName;
  final String? phone;
  final String? motherName;
  final String? title;
  final String? sex;
  final String? dateOfBirth;
  final String? maritalStatus;
  final String? email;
  final dynamic signature;
  final bool isVerified;
  final Map<String, dynamic>? verifiedData;
  final String? zoneSubCity;
  final String? woreda;
  final String? state;
  final String? issueDate;
  final String? expirayDate;
  final String? documentType;
  final String? residentPath;
  final String? residentCardBackPath;
  final String? profilePath;
  final String? legalId;
  final String? issueAuthority;

  JointMemberInfo({
    this.nationalId,
    this.fullName,
    this.phone,
    this.motherName,
    this.title,
    this.sex,
    this.dateOfBirth,
    this.maritalStatus,
    this.email,
    this.signature,
    this.isVerified = false,
    this.verifiedData,
    this.zoneSubCity,
    this.woreda,
    this.state,
    this.issueDate,
    this.expirayDate,
    this.documentType,
    this.residentPath,
    this.residentCardBackPath,
    this.profilePath,
    this.legalId,
    this.issueAuthority,
  });

  JointMemberInfo copyWith({
    String? nationalId,
    String? fullName,
    String? phone,
    String? motherName,
    String? title,
    String? sex,
    String? dateOfBirth,
    String? maritalStatus,
    String? email,
    dynamic signature,
    bool? isVerified,
    Map<String, dynamic>? verifiedData,
    String? zoneSubCity,
    String? woreda,
    String? state,
    String? issueDate,
    String? expirayDate,
    String? documentType,
    String? residentPath,
    String? residentCardBackPath,
    String? profilePath,
    String? legalId,
    String? issueAuthority,
  }) {
    return JointMemberInfo(
      nationalId: nationalId ?? this.nationalId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      motherName: motherName ?? this.motherName,
      title: title ?? this.title,
      sex: sex ?? this.sex,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      email: email ?? this.email,
      signature: signature ?? this.signature,
      isVerified: isVerified ?? this.isVerified,
      verifiedData: verifiedData ?? this.verifiedData,
      zoneSubCity: zoneSubCity ?? this.zoneSubCity,
      woreda: woreda ?? this.woreda,
      state: state ?? this.state,
      issueDate: issueDate ?? this.issueDate,
      expirayDate: expirayDate ?? this.expirayDate,
      documentType: documentType ?? this.documentType,
      residentPath: residentPath ?? this.residentPath,
      residentCardBackPath: residentCardBackPath ?? this.residentCardBackPath,
      profilePath: profilePath ?? this.profilePath,
      legalId: legalId ?? this.legalId,
      issueAuthority: issueAuthority ?? this.issueAuthority,
    );
  }

  factory JointMemberInfo.fromMap(Map<String, dynamic> map) {
    bool safeIsVerified;
    if (map.containsKey('isVerified')) {
      final v = map['isVerified'];
      safeIsVerified = v is bool ? v : (v == true);
    } else {
      safeIsVerified = false;
    }
    return JointMemberInfo(
      nationalId: map['nationalId'],
      fullName: map['fullName'],
      phone: map['phone'],
      motherName: map['motherName'],
      title: map['title'],
      sex: map['sex'],
      dateOfBirth: map['dateOfBirth'],
      maritalStatus: map['maritalStatus'],
      email: map['email'],
      signature: map['signature'],
      isVerified: safeIsVerified,
      verifiedData: map['verifiedData'],
      zoneSubCity: map['zoneSubCity'],
      woreda: map['woreda'],
      state: map['state'],
      issueDate: map['issueDate'],
      expirayDate: map['expirayDate'],
      documentType: map['documentType'],
      residentPath: map['residentPath'],
      residentCardBackPath: map['residentCardBackPath'],
      profilePath: map['profilePath'],
      legalId: map['legalId'],
      issueAuthority: map['issueAuthority'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nationalId': nationalId,
      'fullName': fullName,
      'phone': phone,
      'motherName': motherName,
      'title': title,
      'sex': sex,
      'dateOfBirth': dateOfBirth,
      'maritalStatus': maritalStatus,
      'email': email,
      'signature': signature,
      'isVerified': isVerified,
      'verifiedData': verifiedData,
      'zoneSubCity': zoneSubCity,
      'woreda': woreda,
      'state': state,
      'issueDate': issueDate,
      'expirayDate': expirayDate,
      'documentType': documentType,
      'residentPath': residentPath,
      'residentCardBackPath': residentCardBackPath,
      'profilePath': profilePath,
      'legalId': legalId,
      'issueAuthority': issueAuthority,
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
  final String? licenseFile;
  final String? articleFile;
  final String? letterOfRequestFile;
  final String? tinNumberPhoto;
  final String? tradeName;
  final List<String>? otherFiles;
  final String? companyName;
  final String? companyPhoneNumber;
  final String? companyEmail;
  final String? companyTinNumber;
  final String? companyDateOfEstablishment;
  final String? companyState;
  final String? companyZoneSubCity;
  final String? companyWoreda;

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
    this.licenseFile,
    this.articleFile,
    this.letterOfRequestFile,
    this.tinNumberPhoto,
    this.tradeName,
    this.otherFiles,
    this.companyName,
    this.companyPhoneNumber,
    this.companyEmail,
    this.companyTinNumber,
    this.companyDateOfEstablishment,
    this.companyState,
    this.companyZoneSubCity,
    this.companyWoreda,
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
      licenseFile: map['licenseFile'],
      articleFile: map['articleFile'],
      letterOfRequestFile: map['letterOfRequestFile'],
      tinNumberPhoto: map['tinNumberPhoto'],
      tradeName: map['tradeName'],
      otherFiles: map['otherFiles'] != null ? List<String>.from(map['otherFiles']) : null,
      companyName: map['companyName'],
      companyPhoneNumber: map['companyPhoneNumber'],
      companyEmail: map['companyEmail'],
      companyTinNumber: map['companyTinNumber'],
      companyDateOfEstablishment: map['companyDateOfEstablishment'],
      companyState: map['companyState'],
      companyZoneSubCity: map['companyZoneSubCity'],
      companyWoreda: map['companyWoreda'],
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
      'licenseFile': licenseFile,
      'articleFile': articleFile,
      'letterOfRequestFile': letterOfRequestFile,
      'tinNumberPhoto': tinNumberPhoto,
      'tradeName': tradeName,
      'otherFiles': otherFiles,
      'companyName': companyName,
      'companyPhoneNumber': companyPhoneNumber,
      'companyEmail': companyEmail,
      'companyTinNumber': companyTinNumber,
      'companyDateOfEstablishment': companyDateOfEstablishment,
      'companyState': companyState,
      'companyZoneSubCity': companyZoneSubCity,
      'companyWoreda': companyWoreda,
    };
  }
} 