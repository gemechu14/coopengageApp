import 'dart:convert';
import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/invitation_stats_model.dart';
import '../models/invitation_model.dart';

// const storage = FlutterSecureStorage();

class InvitationService {
  final Dio _dio;
  final String baseUrl;

  InvitationService({
    required Dio dio,
    required this.baseUrl,
  }) : _dio = dio;

  /// Fetch invitation statistics
  Future<InvitationStats> fetchStats() async {
    try {
      final token = await storage.read(key: "token");
      
      final response = await _dio.get(
        '$baseUrl/api/v1/invitations/stats',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data is String 
            ? jsonDecode(response.data) 
            : response.data;
        
        return InvitationStats.fromJson(data['data']);
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      throw Exception('Error fetching stats: $e');
    }
  }

  /// Fetch my invitations with pagination
  Future<List<Invitation>> fetchMyInvitations({
    int page = 0,
    int size = 10,
    String sortBy = 'sentAt',
    String sortDirection = 'DESC',
  }) async {
    try {
      final token = await storage.read(key: "token");
      
      final response = await _dio.get(
        '$baseUrl/api/v1/invitations/my-invitations',
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'sortDirection': sortDirection,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data is String 
            ? jsonDecode(response.data) 
            : response.data;
        
        final List<dynamic> invitationsJson = data is List 
            ? data 
            : (data['content'] ?? data['data'] ?? []);
        
        return invitationsJson
            .map((json) => Invitation.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load invitations');
      }
    } catch (e) {
      throw Exception('Error fetching invitations: $e');
    }
  }
}

