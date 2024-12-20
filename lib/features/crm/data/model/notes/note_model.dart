import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'note_model.freezed.dart';
part 'note_model.g.dart';

// JSON Parsing Functions
NoteModel noteFromJson(String str) => NoteModel.fromJson(json.decode(str));

String noteToJson(NoteModel data) => json.encode(data.toJson());

@freezed
class NoteModel with _$NoteModel {
  const factory NoteModel({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "highProfileCustomerId") required int highProfileCustomerId,
    @JsonKey(name: "highProfileCustomerName")
    required String highProfileCustomerName,
    @JsonKey(name: "addedById") required int addedById,
    @JsonKey(name: "addedByName") required String addedByName,
    @JsonKey(name: "title") required String title,
    @JsonKey(name: "content") required String content,
    @JsonKey(name: "color") String? color,
    @JsonKey(name: "voiceNote") String? voiceNote,
  }) = _NoteModel;

  factory NoteModel.fromJson(Map<String, dynamic> json) =>
      _$NoteModelFromJson(json);
}

// NoteList for handling lists of NoteModel
class NoteList {
  final List<NoteModel> notes;

  NoteList({required this.notes});

  // Parse from JSON
  factory NoteList.fromJson(List<dynamic> parsedJson) {
    return NoteList(
      notes: parsedJson.map((data) => NoteModel.fromJson(data)).toList(),
    );
  }
}
