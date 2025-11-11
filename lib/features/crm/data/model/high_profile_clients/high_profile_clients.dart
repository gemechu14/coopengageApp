

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'high_profile_clients.freezed.dart';
part 'high_profile_clients.g.dart';

// JSON Parsing Functions
HighProfileClientsModel highProfileClientFromJson(String str) =>
    HighProfileClientsModel.fromJson(json.decode(str));

String highProfileClientToJson(HighProfileClientsModel data) =>
    json.encode(data.toJson());

// HighProfileClientsModel with Freezed
@freezed
class HighProfileClientsModel with _$HighProfileClientsModel {
  const factory HighProfileClientsModel({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "phone") required String phone,
    @JsonKey(name: "accHolderName") required String accHolderName,
    @JsonKey(name: "address") required String address,
    @JsonKey(name: "tinNumber") required String tinNumber,
    @JsonKey(name: "accountNumber") required int accountNumber, // Updated type
    @JsonKey(name: "assignedCRMName") String? assignedCRMName, // Nullable
    @JsonKey(name: "gender") required String gender,
    @JsonKey(name: "birthDate") required String birthDate,
    @JsonKey(name: "maritalStatus") required String maritalStatus,
    @JsonKey(name: "nationality") required String nationality,
    @JsonKey(name: "email") required String email,
  }) = _HighProfileClientsModel;

  // From JSON Factory
  factory HighProfileClientsModel.fromJson(Map<String, dynamic> json) =>
      _$HighProfileClientsModelFromJson(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone': phone,
      'accHolderName': accHolderName,
      'address': address,
      'tinNumber': tinNumber,
      'accountNumber': accountNumber,
      'assignedCRMName': assignedCRMName,
      'gender': gender,
      'birthDate': birthDate,
      'maritalStatus': maritalStatus,
      'nationality': nationality,
      'email': email,
    };
  }

  Map<String, dynamic> toPartialMap() {
    return {
      // 'id': id,
      'accHolderName': accHolderName,
      'phone': phone,
      'email': email,
      'tinNumber': tinNumber,
      'accountNumber': accountNumber,
      'address': address,
    };
  }
}

class HighProfileClients {
  final List<HighProfileClientsModel> highProfileClients;

  HighProfileClients({required this.highProfileClients});

  // Parse from JSON
  factory HighProfileClients.fromJson(List<dynamic> parsedJson) {
    return HighProfileClients(
      highProfileClients: parsedJson
          .map((data) => HighProfileClientsModel.fromJson(data))
          .toList(),
    );
  }
}
