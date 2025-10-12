import 'dart:convert';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/main.dart';
import 'package:coopengageplus/service/GlobalData.dart';
import 'package:coopengageplus/services/token_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/dashboard_state.dart';

/// Dashboard Repository
/// Handles all data operations for the dashboard
class DashboardRepository {
  final NetworkHandler _networkHandler = NetworkHandler();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );

  /// Fetch user ID from stored token
  Future<int?> fetchUserId() async {
    final token = await _storage.read(key: "token");
    if (token == null || token.isEmpty) return null;

    try {
      final isTokenValid = await TokenService.isTokenValid();
      if (!isTokenValid) {
        throw Exception("Token expired");
      }

      final decodedToken = JwtDecoder.decode(token);
      return decodedToken["userId"] as int?;
    } catch (e) {
      print("Error fetching user ID: $e");
      rethrow;
    }
  }

  /// Fetch user counts from API
  Future<UserCounts> fetchUserCountsFromAPI() async {
    final token = await _storage.read(key: "token");
    if (token == null || token.isEmpty) {
      throw Exception("No token found");
    }

    try {
      // Validate token before API call
      final isTokenValid = await TokenService.isTokenValid();
      if (!isTokenValid) {
        throw Exception("Token expired during fetchUserCounts");
      }

      final url = '/api/v1/accounts/status-count';
      final response = await _networkHandler.fetchData(url);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception("Unauthorized access");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Group 1: New Applicants (INITIAL + REGISTERED)
        final newApplicants = (data['INITIAL'] ?? 0) + (data['REGISTERED'] ?? 0);

        // Group 2: Awaiting Action (UNAUTHORIZED + UNSETTLED + AUTHORIZED)
        final awaitingAction = (data['UNAUTHORIZED'] ?? 0) +
            (data['UNSETTLED'] ?? 0) +
            (data['AUTHORIZED'] ?? 0);

        // Group 3: Approved
        final approved = data['APPROVED'] ?? 0;

        // Group 4: Rejected
        final rejected = data['REJECTED'] ?? 0;

        // Update global variables (maintaining backward compatibility)
        TOTALAPPROVED = approved;
        TOTALPENDING = awaitingAction;
        TOTALINITIAL = newApplicants;
        TOTALUNSETTLED = rejected;

        return UserCounts(
          newApplicants: newApplicants,
          awaitingAction: awaitingAction,
          approved: approved,
          rejected: rejected,
        );
      } else {
        throw Exception('Failed to load user counts: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching user counts: $error");
      rethrow;
    }
  }

  /// Fetch user counts from local database
  Future<UserCounts> fetchUserCountsFromDatabase(int userId) async {
    try {
      final dbHelper = DatabaseHelper();
      final users = await dbHelper.getCustomers(userId);

      // Group 1: New Applicants
      final newApplicants = users
          .where((user) =>
              user['status'] == 'INITIAL' || user['status'] == 'REGISTERED')
          .length;

      // Group 2: Awaiting Action
      final awaitingAction = users
          .where((user) =>
              user['status'] == 'PENDING' ||
              user['status'] == 'UNAUTHORIZED' ||
              user['status'] == 'UNSETTLED' ||
              user['status'] == 'AUTHORIZED')
          .length;

      // Group 3: Approved
      final approved = users.where((user) => user['status'] == 'APPROVED').length;

      // Group 4: Rejected
      final rejected = users.where((user) => user['status'] == 'REJECTED').length;

      // Update global variables (maintaining backward compatibility)
      TOTALAPPROVED = approved;
      TOTALPENDING = awaitingAction;
      TOTALINITIAL = newApplicants;
      TOTALUNSETTLED = rejected;

      return UserCounts(
        newApplicants: newApplicants,
        awaitingAction: awaitingAction,
        approved: approved,
        rejected: rejected,
      );
    } catch (error) {
      print("Error fetching local data: $error");
      rethrow;
    }
  }

  /// Fetch local unsynced customers count
  Future<int> fetchLocalCustomersCount(int userId) async {
    try {
      final token = await _storage.read(key: "token");
      if (token == null || token.isEmpty) return 0;

      // Validate token
      final isTokenValid = await TokenService.isTokenValid();
      if (!isTokenValid) {
        throw Exception("Token expired during fetchUsers");
      }

      final dbHelper = DatabaseHelper();
      final fetchedUsers = await dbHelper.getCustomers(userId);

      return fetchedUsers.length;
    } catch (e) {
      print("Error fetching local customers: $e");
      if (e.toString().contains("Token") ||
          e.toString().contains("Unauthorized")) {
        rethrow;
      }
      return 0;
    }
  }

  /// Sync unsynced customers
  Future<void> syncUnsyncedCustomers() async {
    // This calls the global sync method
    // Note: Context is handled at the UI level
    // await GlobalData.syncUnsyncedCustomers(context);
  }
}

