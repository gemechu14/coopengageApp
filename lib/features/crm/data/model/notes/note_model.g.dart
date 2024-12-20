// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteModelImpl _$$NoteModelImplFromJson(Map<String, dynamic> json) =>
    _$NoteModelImpl(
      id: (json['id'] as num).toInt(),
      highProfileCustomerId: (json['highProfileCustomerId'] as num).toInt(),
      highProfileCustomerName: json['highProfileCustomerName'] as String,
      addedById: (json['addedById'] as num).toInt(),
      addedByName: json['addedByName'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      color: json['color'] as String?,
      voiceNote: json['voiceNote'] as String?,
    );

Map<String, dynamic> _$$NoteModelImplToJson(_$NoteModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'highProfileCustomerId': instance.highProfileCustomerId,
      'highProfileCustomerName': instance.highProfileCustomerName,
      'addedById': instance.addedById,
      'addedByName': instance.addedByName,
      'title': instance.title,
      'content': instance.content,
      'color': instance.color,
      'voiceNote': instance.voiceNote,
    };
