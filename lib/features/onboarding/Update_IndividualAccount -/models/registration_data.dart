import 'dart:typed_data';

class RegistrationData {
  // Basic Info
  String? phone;
  String? email;
  String? customerId; // ID of the new customer created in database
  double percentageCompleted = 0;
  String status = "INITIAL";
  bool formCompleted = false;

  // Customer Info
  String? fullName;
  String? surname;
  String? motherName;
  String? sex;
  String? dateOfBirth;
  String? title;
  String? maritalStatus;

  // Branch & Document
  String? branch;
  String? documentName;
  dynamic residenceCard; // can be Uint8List or String
  dynamic residenceCardBack; // can be Uint8List or String

  // Signature & Photo
  dynamic signature; // can be Uint8List or String
  dynamic photo; // can be Uint8List or String

  // Financial Info
  String? occupation;
  String? monthlyIncome;
  String? initialDeposit;
  String? sector;

  // Address Info
  String? country;
  String? issueAuthority;
  String? issueDate;
  String? expirayDate;
  String? legalId;
  String? state;
  String? zoneSubCity;
  String? streetAddress;

  // Account Info
  String? accountType;
  String? currency;
  
  // Terms and Conditions
  bool? termsAccepted;

  // Convert to API format
  Map<String, dynamic> toApiFormat() {
    return {
      'customerInfo.phone': phone,
      'customerInfo.email': email,
      'customerInfo.percentageCompleted': percentageCompleted,
      'customerInfo.status': status,
      'customerInfo.formCompleted': formCompleted,
      'customerInfo.fullName': fullName,
      'customerInfo.surname': surname,
      'customerInfo.motherName': motherName,
      'customerInfo.sex': sex,
      'customerInfo.dateOfBirth': dateOfBirth,
      'customerInfo.title': title,
      'customerInfo.maritalStatus': maritalStatus,
      'branch': branch,
      'customerInfo.documentName': documentName,
      'customerInfo.residenceCard': residenceCard,
      'customerInfo.residenceCardBack': residenceCardBack,
      'customerInfo.signature': signature,
      'customerInfo.photo': photo,
      'customerInfo.occupation': occupation,
      'customerInfo.monthlyIncome': monthlyIncome,
      'initialDeposit': initialDeposit,
      'customerInfo.sector': sector,
      'customerInfo.country': country,
      'customerInfo.issueAuthority': issueAuthority,
      'customerInfo.issueDate': issueDate,
      'customerInfo.expirayDate': expirayDate,
      'customerInfo.legalId': legalId,
      'customerInfo.state': state,
      'customerInfo.zoneSubCity': zoneSubCity,
      'customerInfo.streetAddress': streetAddress,
      'accountType': accountType,
      'currency': currency,
    };
  }

  // Convert to local storage format
  Map<String, dynamic> toLocalFormat() {
    return {
      'phone': phone,
      'email': email,
      'percentageCompleted': percentageCompleted,
      'status': status,
      'formCompleted': formCompleted ? 1 : 0,
      'fullName': fullName,
      'surname': surname,
      'motherName': motherName,
      'sex': sex,
      'dateOfBirth': dateOfBirth,
      'title': title,
      'maritalStatus': maritalStatus,
      'branch': branch,
      'documentName': documentName,
      'residenceCard': residenceCard,
      'residenceCardBack': residenceCardBack,
      'signature': signature,
      'photo': photo,
      'occupation': occupation,
      'monthlyIncome': monthlyIncome,
      'initialDeposit': initialDeposit,
      'sector': sector,
      'country': country,
      'issueAuthority': issueAuthority,
      'issueDate': issueDate,
      'expirayDate': expirayDate,
      'legalId': legalId,
      'state': state,
      'zoneSubCity': zoneSubCity,
      'streetAddress': streetAddress,
      'accountType': accountType,
      'currency': currency,
    };
  }

  String? productType;

  RegistrationData({
    this.phone,
    this.email,
    this.customerId,
    this.productType,
    this.fullName,
    this.surname,
    this.motherName,
    String? sex,
    this.dateOfBirth,
    String? title,
    this.maritalStatus,
    this.branch,
    this.documentName,
    this.residenceCard,
    this.residenceCardBack,
    this.signature,
    this.photo,
    this.occupation,
    this.monthlyIncome,
    this.initialDeposit,
    this.sector,
    this.country,
    this.issueAuthority,
    this.issueDate,
    this.expirayDate,
    this.legalId,
    this.state,
    this.zoneSubCity,
    this.streetAddress,
    this.accountType,
    this.currency,
    this.termsAccepted,
    this.percentageCompleted = 0,
    this.status = "INITIAL",
    this.formCompleted = false,
  }) : sex = sex ?? 'MALE', // Default to MALE
       title = title ?? 'MR'; // Default to MR

  RegistrationData copyWith({
    String? phone,
    String? email,
    String? customerId,
    String? productType,
    String? fullName,
    String? surname,
    String? motherName,
    String? sex,
    String? dateOfBirth,
    String? title,
    String? maritalStatus,
    String? branch,
    String? documentName,
    dynamic residenceCard,
    dynamic residenceCardBack,
    dynamic signature,
    dynamic photo,
    String? occupation,
    String? monthlyIncome,
    String? initialDeposit,
    String? sector,
    String? country,
    String? issueAuthority,
    String? issueDate,
    String? expirayDate,
    String? legalId,
    String? state,
    String? zoneSubCity,
    String? streetAddress,
    String? accountType,
    String? currency,
    bool? termsAccepted,
    double? percentageCompleted,
    String? status,
    bool? formCompleted,
  }) {
    return RegistrationData(
      phone: phone ?? this.phone,
      email: email ?? this.email,
      customerId: customerId ?? this.customerId,
      productType: productType ?? this.productType,
      fullName: fullName ?? this.fullName,
      surname: surname ?? this.surname,
      motherName: motherName ?? this.motherName,
      sex: sex ?? this.sex,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      title: title ?? this.title,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      branch: branch ?? this.branch,
      documentName: documentName ?? this.documentName,
      residenceCard: residenceCard ?? this.residenceCard,
      residenceCardBack: residenceCardBack ?? this.residenceCardBack,
      signature: signature ?? this.signature,
      photo: photo ?? this.photo,
      occupation: occupation ?? this.occupation,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      initialDeposit: initialDeposit ?? this.initialDeposit,
      sector: sector ?? this.sector,
      country: country ?? this.country,
      issueAuthority: issueAuthority ?? this.issueAuthority,
      issueDate: issueDate ?? this.issueDate,
      expirayDate: expirayDate ?? this.expirayDate,
      legalId: legalId ?? this.legalId,
      state: state ?? this.state,
      zoneSubCity: zoneSubCity ?? this.zoneSubCity,
      streetAddress: streetAddress ?? this.streetAddress,
      accountType: accountType ?? this.accountType,
      currency: currency ?? this.currency,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      percentageCompleted: percentageCompleted ?? this.percentageCompleted,
      status: status ?? this.status,
      formCompleted: formCompleted ?? this.formCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'email': email,
    'customerId': customerId,
    'productType': productType,
    'fullName': fullName,
    'surname': surname,
    'motherName': motherName,
    'sex': sex,
    'dateOfBirth': dateOfBirth,
    'title': title,
    'maritalStatus': maritalStatus,
    'branch': branch,
    'documentName': documentName,
    'occupation': occupation,
    'monthlyIncome': monthlyIncome,
    'initialDeposit': initialDeposit,
    'sector': sector,
    'country': country,
    'issueAuthority': issueAuthority,
    'issueDate': issueDate,
    'expirayDate': expirayDate,
    'legalId': legalId,
    'state': state,
    'zoneSubCity': zoneSubCity,
    'streetAddress': streetAddress,
    'accountType': accountType,
    'currency': currency,
    'percentageCompleted': percentageCompleted,
    'status': status,
    'formCompleted': formCompleted,
  };
}
