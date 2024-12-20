// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'high_profile_clients.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HighProfileClientsModelImpl _$$HighProfileClientsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$HighProfileClientsModelImpl(
      id: (json['id'] as num?)?.toInt(),
      phone: json['phone'] as String,
      accHolderName: json['accHolderName'] as String,
      address: json['address'] as String,
      tinNumber: json['tinNumber'] as String,
      accountNumber: (json['accountNumber'] as num).toInt(),
      assignedCRMName: json['assignedCRMName'] as String?,
      gender: json['gender'] as String,
      birthDate: json['birthDate'] as String,
      maritalStatus: json['maritalStatus'] as String,
      nationality: json['nationality'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$$HighProfileClientsModelImplToJson(
        _$HighProfileClientsModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'accHolderName': instance.accHolderName,
      'address': instance.address,
      'tinNumber': instance.tinNumber,
      'accountNumber': instance.accountNumber,
      'assignedCRMName': instance.assignedCRMName,
      'gender': instance.gender,
      'birthDate': instance.birthDate,
      'maritalStatus': instance.maritalStatus,
      'nationality': instance.nationality,
      'email': instance.email,
    };
