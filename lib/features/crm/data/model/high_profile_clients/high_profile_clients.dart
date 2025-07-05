// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'dart:convert';

// part 'high_profile_clients.freezed.dart';
// part 'high_profile_clients.g.dart';

// HighProfileClientsModel highProfileClientFromJson(String str) =>
//     HighProfileClientsModel.fromJson(json.decode(str));

// String highProfileClientToJson(HighProfileClientsModel data) =>
//     json.encode(data.toJson());

// @freezed
// abstract class HighProfileClientsModel with _$HighProfileClientsModel {
//   const factory HighProfileClientsModel({
//     //coming as null
//     // @JsonKey(name: "category_description") required String category_description,
//     @JsonKey(name: "phone") required String phone,
//     @JsonKey(name: "accHolderName") required String accHolderName,
//     @JsonKey(name: "address") required String address,
//     @JsonKey(name: "tinNumber") required String tinNumber,
//     @JsonKey(name: "accountNumber") required String accountNumber,
//     @JsonKey(name: "assignedCRMName") required String assignedCRMName,
//     @JsonKey(name: "gender") required String gender,
//     @JsonKey(name: "birthDate") required String birthDate,
//     @JsonKey(name: "maritalStatus") required String maritalStatus,
//     @JsonKey(name: "nationality") required String nationality,
//     @JsonKey(name: "email") required String email,
//     @JsonKey(name: "id") int? id,
//   }) = _HighProfileClientsModel;

//   factory HighProfileClientsModel.fromJson(Map<String, dynamic> json) =>
//       _$HighProfileClientsModelFromJson(json);
// }

// class HighProfileClients {
//   final List<HighProfileClientsModel> highProfileClients;
//   HighProfileClients({
//     required this.highProfileClients,
//   });
//   factory HighProfileClients.fromJson(List<dynamic> parsedJson) {
//     List<HighProfileClientsModel> highProfileClients = [];
//     highProfileClients =
//         parsedJson.map((i) => HighProfileClientsModel.fromJson(i)).toList();
//     return HighProfileClients(highProfileClients: highProfileClients);
//   }
// }

// //  {
// //         "id": 2,
// //         "phone": "098765432",
// //         "accHolderName": "Hundaol",
// //         "address": "bole",
// //         "tinNumber": "1234",
// //         "accountNumber": 10234567874,
// //         "assignedCRMName": "crm",
// //         "gender": "MALE",
// //         "birthDate": "2024-09-23T00:00:00.000+00:00",
// //         "maritalStatus": "string",
// //         "nationality": "string",
// //         "email": "string@gmail.com",
// //         "createdBy": "2024-11-08T16:38:43.03972",
// //         "updatedBy": "2024-11-08T16:40:28.91634"
// //     }

// ignore_for_file: invalid_annotation_target

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
