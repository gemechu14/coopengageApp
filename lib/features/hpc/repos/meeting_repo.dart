import 'dart:convert';
import 'dart:developer';

import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/features/crm/data/model/meeting/meeting_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';


abstract class MeetingRepo {
  Future<List<MeetingModel>> getMeetings({required String token});
  Future<MeetingModel> addMeeting({
    required int highProfileCustomerId,
    required String token,
    required String meetingDate,
    required String meetingTime,
    String? reason,
    required String address,
  });
  Future<MeetingModel> updateMeeting({
    required int meetingId,
    String? notes,
    required String token,
    required String meetingDate,
    required String meetingTime,
    String? reason,
    required String address,
    String? feeling,
    String? status,
  });
}

final meetingRepositoryProvider = Provider(MeetingRepository.new);

class MeetingRepository implements MeetingRepo {
  final Ref _ref;

  MeetingRepository(this._ref) {}

  @override
  Future<List<MeetingModel>> getMeetings({required String token}) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/meetings/me');
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
      final List<MeetingModel> meetings =
          jsonData.map((data) => MeetingModel.fromJson(data)).toList();

      return meetings;
    } catch (e, stackTrace) {
      log('Error in getMeetings: $e', stackTrace: stackTrace);
      print(e);
      throw Exception('Failed to load high profile clients');
    }
  }

  @override
  Future<MeetingModel> addMeeting({
    required int highProfileCustomerId,
    required String token,
    required String meetingDate,
    required String meetingTime,
    String? reason,
    required String address,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/meetings');
      final body = {
        "highProfileCustomerId": highProfileCustomerId,
        "meetingDate": meetingDate,
        "meetingTime": meetingTime,
        "address": address,
        if (reason != null) "reason": reason,
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
      final newMeeting = MeetingModel.fromJson(responseData);
      print(responseData);
      return newMeeting;
    } catch (e, stackTrace) {
      log('Error creating a Meeting: $e', stackTrace: stackTrace);
      print(e);
      print(stackTrace);
      throw Exception('Failed to create Meeting');
    }
  }

  @override
  Future<MeetingModel> updateMeeting({
    required int meetingId,
    String? notes,
    required String token,
    required String meetingDate,
    required String meetingTime,
    String? reason,
    required String address,
    String? feeling,
    String? status,
  }) async {
    try {
      final url = Uri.parse(
          '${AppConstants.baseUrl}meetings/update?meetingId=$meetingId');
      final body = {
        "meetingDate": meetingDate,
        "meetingTime": meetingTime,
        "address": address,
        "reason": reason ?? "",
        "status": status ?? "",
        "feeling": feeling ?? "",
        "notes": notes ?? "",
      };

      print("Request body: ${jsonEncode(body)}");
      final response = await http.put(
        url,
        body: jsonEncode(body),
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

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final updatedMeeting = MeetingModel.fromJson(responseData);
      print(responseData);
      return updatedMeeting;
    } catch (e, stackTrace) {
      log('Error updating Meeting: $e', stackTrace: stackTrace);
      print(e);
      print(stackTrace);
      throw Exception('Failed to update Meeting');
    }
  }
}
