/// TIN Verification Response Model
class TinVerificationResponse {
  final String regNo;
  final String businessNameAmh;
  final String businessName;
  final String regDate;
  final String tinNumber;
  final List<Licence> licences;
  final double paidUpCapital;

  TinVerificationResponse({
    required this.regNo,
    required this.businessNameAmh,
    required this.businessName,
    required this.regDate,
    required this.tinNumber,
    required this.licences,
    required this.paidUpCapital,
  });

  factory TinVerificationResponse.fromJson(Map<String, dynamic> json) {
    return TinVerificationResponse(
      regNo: json['regNo'] ?? '',
      businessNameAmh: json['businessNameAmh'] ?? '',
      businessName: json['businessName'] ?? '',
      regDate: json['regDate'] ?? '',
      tinNumber: json['tinNumber'] ?? '',
      licences: (json['licences'] as List<dynamic>?)
              ?.map((e) => Licence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      paidUpCapital: (json['paidUpCapital'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regNo': regNo,
      'businessNameAmh': businessNameAmh,
      'businessName': businessName,
      'regDate': regDate,
      'tinNumber': tinNumber,
      'licences': licences.map((e) => e.toJson()).toList(),
      'paidUpCapital': paidUpCapital,
    };
  }
}

/// Licence Model
class Licence {
  final String renewedTo;
  final bool isMain;
  final String licenceNumber;
  final String renewedFrom;
  final String? licenceFileUrl;
  final String renewalDate;
  final List<LicenceSector> licenceSectors;
  final String tradesName;

  Licence({
    required this.renewedTo,
    required this.isMain,
    required this.licenceNumber,
    required this.renewedFrom,
    this.licenceFileUrl,
    required this.renewalDate,
    required this.licenceSectors,
    required this.tradesName,
  });

  factory Licence.fromJson(Map<String, dynamic> json) {
    return Licence(
      renewedTo: json['renewedTo'] ?? '',
      isMain: json['isMain'] ?? false,
      licenceNumber: json['licenceNumber'] ?? '',
      renewedFrom: json['renewedFrom'] ?? '',
      licenceFileUrl: json['licenceFileUrl'],
      renewalDate: json['renewalDate'] ?? '',
      licenceSectors: (json['licenceSectors'] as List<dynamic>?)
              ?.map((e) => LicenceSector.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tradesName: json['tradesName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'renewedTo': renewedTo,
      'isMain': isMain,
      'licenceNumber': licenceNumber,
      'renewedFrom': renewedFrom,
      'licenceFileUrl': licenceFileUrl,
      'renewalDate': renewalDate,
      'licenceSectors': licenceSectors.map((e) => e.toJson()).toList(),
      'tradesName': tradesName,
    };
  }
}

/// Licence Sector Model
class LicenceSector {
  final int code;
  final String description;

  LicenceSector({
    required this.code,
    required this.description,
  });

  factory LicenceSector.fromJson(Map<String, dynamic> json) {
    return LicenceSector(
      code: json['code'] ?? 0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
    };
  }
}

