class MerchantApiException implements Exception {
  MerchantApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class RegionOption {
  const RegionOption({required this.displayName, required this.code});

  final String displayName;
  final String code;

  factory RegionOption.fromJson(Map<String, dynamic> json) {
    return RegionOption(
      displayName: json['displayName']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }
}

class BranchOption {
  const BranchOption({
    required this.id,
    required this.branchCode,
    required this.name,
    this.city,
  });

  final String id;
  final String branchCode;
  final String name;
  final String? city;

  String get displayLabel {
    final c = city?.trim();
    if (c != null && c.isNotEmpty) return '$name ($branchCode · $c)';
    return '$name ($branchCode)';
  }

  factory BranchOption.fromJson(Map<String, dynamic> json) {
    return BranchOption(
      id: json['id']?.toString() ?? '',
      branchCode: json['branchCode']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Branch',
      city: json['city']?.toString(),
    );
  }
}

class MccOption {
  const MccOption({required this.code, required this.description});

  final String code;
  final String description;
}

class MerchantDocumentFile {
  const MerchantDocumentFile({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });

  final String name;
  final List<int> bytes;
  final String mimeType;
}

class MerchantResponse {
  MerchantResponse({
    required this.id,
    this.merchantName,
    this.dbaName,
    this.puid,
    this.email,
    this.phoneNumber,
    this.merchantCategoryCode,
    this.businessType,
    this.address,
    this.bankDetails = const [],
    this.readyForQrRequest = false,
    this.portalAccountCreated = false,
    this.portalLoginEmail,
    this.wantsAcrylicQr = false,
    this.wantsStickerQr = false,
    this.qrPurposeCode,
  });

  final String id;
  final String? merchantName;
  final String? dbaName;
  final String? puid;
  final String? email;
  final String? phoneNumber;
  final String? merchantCategoryCode;
  final String? businessType;
  final Map<String, dynamic>? address;
  final List<Map<String, dynamic>> bankDetails;
  final bool readyForQrRequest;
  final bool portalAccountCreated;
  final String? portalLoginEmail;
  final bool wantsAcrylicQr;
  final bool wantsStickerQr;
  final String? qrPurposeCode;

  factory MerchantResponse.fromJson(Map<String, dynamic> json) {
    final bank = json['bankDetails'];
    return MerchantResponse(
      id: json['id']?.toString() ?? '',
      merchantName: json['merchantName']?.toString(),
      dbaName: json['dbaName']?.toString(),
      puid: json['puid']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      merchantCategoryCode: json['merchantCategoryCode']?.toString(),
      businessType: json['businessType']?.toString(),
      address: json['address'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['address'] as Map)
          : null,
      bankDetails: bank is List
          ? bank
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : const [],
      readyForQrRequest: _toBool(json['readyForQrRequest']),
      portalAccountCreated: _toBool(json['portalAccountCreated']),
      portalLoginEmail: json['portalLoginEmail']?.toString(),
      wantsAcrylicQr: _toBool(json['wantsAcrylicQr']),
      wantsStickerQr: _toBool(json['wantsStickerQr']),
      qrPurposeCode: json['qrPurposeCode']?.toString(),
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value.toInt() != 0;
    return false;
  }

  String? get primaryAccountNumber {
    for (final b in bankDetails) {
      if (_toBool(b['primary'])) {
        return b['accountNumber']?.toString();
      }
    }
    if (bankDetails.isNotEmpty) {
      return bankDetails.first['accountNumber']?.toString();
    }
    return null;
  }
}
