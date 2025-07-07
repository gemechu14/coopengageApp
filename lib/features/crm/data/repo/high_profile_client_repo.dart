import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/features/crm/data/model/high_profile_clients/high_profile_clients.dart';

abstract class HighProfileClientRepo {
  Future<List<HighProfileClientsModel>> getHighProfileClients(
      {required String token});
}

final highProfileClientRepoProvider = Provider(HighProfileClientRepository.new);

class HighProfileClientRepository implements HighProfileClientRepo {
  final Ref _ref;

  HighProfileClientRepository(this._ref) {}

  @override
  Future<List<HighProfileClientsModel>> getHighProfileClients(
      {required String token}) async {
    try {
      final url =
          Uri.parse('${AppConstants.baseUrl}/high-profile-customers/crm/me');
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
      final List<HighProfileClientsModel> highProfileClients = jsonData
          .map((data) => HighProfileClientsModel.fromJson(data))
          .toList();

      return highProfileClients;
    } catch (e, stackTrace) {
      log('Error in getHighProfileClients: $e', stackTrace: stackTrace);
      throw Exception('Failed to load high profile clients');
    }
  }
}
