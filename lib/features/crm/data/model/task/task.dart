// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'task.freezed.dart';
part 'task.g.dart';

// JSON Parsing Functions
TaskModel taskFromJson(String str) => TaskModel.fromJson(json.decode(str));

String taskToJson(TaskModel data) => json.encode(data.toJson());

// TaskModel with Freezed
@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    @JsonKey(name: "taskId") required int taskId,
    @JsonKey(name: "highProfileCustomerName")
    required String highProfileCustomerName,
    @JsonKey(name: "crmName") required String crmName,
    @JsonKey(name: "taskDate") required String taskDate,
    @JsonKey(name: "taskTime") required String taskTime,
    @JsonKey(name: "title") String? title,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "address") String? address,
    @JsonKey(name: "reminder") required bool reminder,
    @JsonKey(name: "status") required String status,
  }) = _TaskModel;

  // From JSON Factory
  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
}

// TaskTime Model
@freezed
class TaskTime with _$TaskTime {
  const factory TaskTime({
    @JsonKey(name: "hour") required int hour,
    @JsonKey(name: "minute") required int minute,
    @JsonKey(name: "second") required int second,
    @JsonKey(name: "nano") required int nano,
  }) = _TaskTime;

  // From JSON Factory
  factory TaskTime.fromJson(Map<String, dynamic> json) =>
      _$TaskTimeFromJson(json);

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

// TaskList for handling lists of TaskModel
class TaskList {
  final List<TaskModel> tasks;

  TaskList({required this.tasks});

  // Parse from JSON
  factory TaskList.fromJson(List<dynamic> parsedJson) {
    return TaskList(
      tasks: parsedJson.map((data) => TaskModel.fromJson(data)).toList(),
    );
  }

  // Converts the list of tasks to JSON
  // List<Map<String, dynamic>> toMap() {
  //   return tasks.map((task) => task.toMap()).toList();
  // }
}
