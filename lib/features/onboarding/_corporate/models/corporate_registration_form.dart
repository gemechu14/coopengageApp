import 'dart:typed_data';

class CorporateRegistrationForm {
  String? companyName;
  String? email;
  String? phoneNumber;
  String? dateOfEstablishment;
  String? residence;
  String? state;
  String? zone;
  String? woreda;
  String? branch;
  String? currency;
  String? accountType;
  String? initialDeposit;
  String? percentageCompleted;
  List<Map<String, dynamic>> customers;
  Uint8List? letterOfRequest;
  Uint8List? tradeLicense;
  Uint8List? articlesOfAssociation;
  String? tin;

  CorporateRegistrationForm({
    this.companyName,
    this.email,
    this.phoneNumber,
    this.dateOfEstablishment,
    this.residence,
    this.state,
    this.zone,
    this.woreda,
    this.branch,
    this.currency = 'ETB',
    this.accountType,
    this.initialDeposit = '1000',
    this.percentageCompleted = '0',
    this.customers = const [],
    this.letterOfRequest,
    this.tradeLicense,
    this.articlesOfAssociation,
    this.tin,
  });

  CorporateRegistrationForm copyWith({
    String? companyName,
    String? email,
    String? phoneNumber,
    String? dateOfEstablishment,
    String? residence,
    String? state,
    String? zone,
    String? woreda,
    String? branch,
    String? currency,
    String? accountType,
    String? initialDeposit,
    String? percentageCompleted,
    List<Map<String, dynamic>>? customers,
    Uint8List? letterOfRequest,
    Uint8List? tradeLicense,
    Uint8List? articlesOfAssociation,
    String? tin,
  }) {
    return CorporateRegistrationForm(
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfEstablishment: dateOfEstablishment ?? this.dateOfEstablishment,
      residence: residence ?? this.residence,
      state: state ?? this.state,
      zone: zone ?? this.zone,
      woreda: woreda ?? this.woreda,
      branch: branch ?? this.branch,
      currency: currency ?? this.currency,
      accountType: accountType ?? this.accountType,
      initialDeposit: initialDeposit ?? this.initialDeposit,
      percentageCompleted: percentageCompleted ?? this.percentageCompleted,
      customers: customers ?? this.customers,
      letterOfRequest: letterOfRequest ?? this.letterOfRequest,
      tradeLicense: tradeLicense ?? this.tradeLicense,
      articlesOfAssociation: articlesOfAssociation ?? this.articlesOfAssociation,
      tin: tin ?? this.tin,
    );
  }
} 