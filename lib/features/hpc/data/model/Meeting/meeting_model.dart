import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'meeting_model.freezed.dart';
part 'meeting_model.g.dart';

// JSON Parsing Functions
MeetingModel meetingFromJson(String str) =>
    MeetingModel.fromJson(json.decode(str));

String meetingToJson(MeetingModel data) => json.encode(data.toJson());

@freezed
class MeetingModel with _$MeetingModel {
  const factory MeetingModel({
    @JsonKey(name: "meetingId") required int meetingId,
    @JsonKey(name: "highProfileCustomerName")
    required String highProfileCustomerName,
    @JsonKey(name: "crmName") required String crmName,
    @JsonKey(name: "meetingDate") required String meetingDate,
    @JsonKey(name: "meetingTime") required String meetingTime,
    @JsonKey(name: "reason") String? reason,
    @JsonKey(name: "feeling") String? feeling,
    @JsonKey(name: "emotionalAttachment") String? emotionalAttachment,
    @JsonKey(name: "notes") String? notes,
    @JsonKey(name: "address") String? address,
    @JsonKey(name: "category") String? category,
    @JsonKey(name: "status") String? status,
    @JsonKey(name: "createdAt") required String createdAt,
    @JsonKey(name: "updatedAt") required String updatedAt,
  }) = _MeetingModel;

  factory MeetingModel.fromJson(Map<String, dynamic> json) =>
      _$MeetingModelFromJson(json);
}

// MeetingTime Model
@freezed
class MeetingTime with _$MeetingTime {
  const factory MeetingTime({
    @JsonKey(name: "hour") required int hour,
    @JsonKey(name: "minute") required int minute,
    @JsonKey(name: "second") required int second,
    @JsonKey(name: "nano") required int nano,
  }) = _MeetingTime;

  factory MeetingTime.fromJson(Map<String, dynamic> json) =>
      _$MeetingTimeFromJson(json);

  // Converts the model to a map
  Map<String, dynamic> toMap() {
    return {
      "hour": hour,
      "minute": minute,
      "second": second,
      "nano": nano,
    };
  }
}

// MeetingList for handling lists of MeetingModel
class MeetingList {
  final List<MeetingModel> meetings;

  MeetingList({required this.meetings});

  // Parse from JSON
  factory MeetingList.fromJson(List<dynamic> parsedJson) {
    return MeetingList(
      meetings: parsedJson.map((data) => MeetingModel.fromJson(data)).toList(),
    );
  }
}
