import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/features/crm/data/model/task/task.dart';

abstract class TaskRepo {
  Future<List<TaskModel>> getTasks({required String token});
  Future<TaskModel> addTask(
      {required int highProfileCustomerId,
      required String token,
      required String taskDate,
      required String taskTime,
      required String title,
      required String address,
      String? description});
}

final taskRepositoryProvider = Provider(TaskRepository.new);

class TaskRepository implements TaskRepo {
  final Ref _ref;

  TaskRepository(this._ref) {}

  @override
  Future<List<TaskModel>> getTasks({required String token}) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/tasks/me');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Access-Control_Allow_Origin": "*",
          "accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP error: ${response.statusCode}');
      }

      // Decode response
      final List<dynamic> jsonData = json.decode(response.body);

      // Parse into a list of models
      final List<TaskModel> tasks =
          jsonData.map((data) => TaskModel.fromJson(data)).toList();

      return tasks;
    } catch (e, stackTrace) {
      log('Error in gettasks: $e', stackTrace: stackTrace);
      print(e);
      throw Exception('Failed to load high profile clients');
    }
  }

  @override
  Future<TaskModel> addTask(
      {required int highProfileCustomerId,
      required String token,
      required String taskDate,
      required String taskTime,
      required String title,
      required String address,
      String? description}) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/tasks');
      final body = {
        "highProfileCustomerId": highProfileCustomerId,
        "taskDate": taskDate,
        "taskTime": taskTime,
        "title": title,
        "address": address,
        if (description != null) "description": description,
      };

      print("Request body: ${jsonEncode(body)}");
      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json",
          "Access-Control_Allow_Origin": "*",
          "accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 201) {
        throw Exception('HTTP error: ${response.statusCode}');
      }

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final newTask = TaskModel.fromJson(responseData);
      print(responseData);
      return newTask;
    } catch (e, stackTrace) {
      log('Error creating a task: $e', stackTrace: stackTrace);
      print(e);
      print(stackTrace);
      throw Exception('Failed to create task');
    }
  }
}
