// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskModelImpl _$$TaskModelImplFromJson(Map<String, dynamic> json) =>
    _$TaskModelImpl(
      taskId: (json['taskId'] as num).toInt(),
      highProfileCustomerName: json['highProfileCustomerName'] as String,
      crmName: json['crmName'] as String,
      taskDate: json['taskDate'] as String,
      taskTime: json['taskTime'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      reminder: json['reminder'] as bool,
      status: json['status'] as String,
    );

Map<String, dynamic> _$$TaskModelImplToJson(_$TaskModelImpl instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'highProfileCustomerName': instance.highProfileCustomerName,
      'crmName': instance.crmName,
      'taskDate': instance.taskDate,
      'taskTime': instance.taskTime,
      'title': instance.title,
      'description': instance.description,
      'address': instance.address,
      'reminder': instance.reminder,
      'status': instance.status,
    };

_$TaskTimeImpl _$$TaskTimeImplFromJson(Map<String, dynamic> json) =>
    _$TaskTimeImpl(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
      second: (json['second'] as num).toInt(),
      nano: (json['nano'] as num).toInt(),
    );

Map<String, dynamic> _$$TaskTimeImplToJson(_$TaskTimeImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
      'second': instance.second,
      'nano': instance.nano,
    };
