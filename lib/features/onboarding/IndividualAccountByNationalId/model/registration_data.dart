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
  });
} 