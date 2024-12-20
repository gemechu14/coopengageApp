// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeetingModelImpl _$$MeetingModelImplFromJson(Map<String, dynamic> json) =>
    _$MeetingModelImpl(
      meetingId: (json['meetingId'] as num).toInt(),
      highProfileCustomerName: json['highProfileCustomerName'] as String,
      crmName: json['crmName'] as String,
      meetingDate: json['meetingDate'] as String,
      meetingTime: json['meetingTime'] as String,
      reason: json['reason'] as String?,
      feeling: json['feeling'] as String?,
      emotionalAttachment: json['emotionalAttachment'] as String?,
      notes: json['notes'] as String?,
      address: json['address'] as String?,
      category: json['category'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$MeetingModelImplToJson(_$MeetingModelImpl instance) =>
    <String, dynamic>{
      'meetingId': instance.meetingId,
      'highProfileCustomerName': instance.highProfileCustomerName,
      'crmName': instance.crmName,
      'meetingDate': instance.meetingDate,
      'meetingTime': instance.meetingTime,
      'reason': instance.reason,
      'feeling': instance.feeling,
      'emotionalAttachment': instance.emotionalAttachment,
      'notes': instance.notes,
      'address': instance.address,
      'category': instance.category,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_$MeetingTimeImpl _$$MeetingTimeImplFromJson(Map<String, dynamic> json) =>
    _$MeetingTimeImpl(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
      second: (json['second'] as num).toInt(),
      nano: (json['nano'] as num).toInt(),
    );

Map<String, dynamic> _$$MeetingTimeImplToJson(_$MeetingTimeImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
      'second': instance.second,
      'nano': instance.nano,
    };
