// ignore_for_file: file_names, use_build_context_synchronously

import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


class GlobalData with ChangeNotifier {
  static final GlobalData _instance = GlobalData._internal();
  factory GlobalData() => _instance;

  GlobalData._internal();

  final FlutterSecureStorage storage = FlutterSecureStorage();

  String? username;
  String? firstLetter;
  String? role;
  int? userId;
  static int? UserId;
  List<Map<String, dynamic>> branches = [];
  List<Map<String, dynamic>> mainBranches = [];
  bool isLoading = true;
  List<Map<String, dynamic>> allBranches = [];
  void initializeBranches() async {
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);

      // Get regular branches
      List<Map<String, dynamic>> regularBranches =
          decodedToken.containsKey("branch")
              ? List<Map<String, dynamic>>.from(decodedToken["branch"])
              : [];

      allBranches = [];

      // Add main branch first if it exists
      if (decodedToken.containsKey("mainBranch")) {
        allBranches.add(decodedToken["mainBranch"]);
      }

      // Add regular branches
      allBranches.addAll(regularBranches);

      // Notify listeners to update the UI
      notifyListeners();
    }
  }

  Future<void> fetchToken() async {
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);

      username = decodedToken['sub'] ?? "User";
      firstLetter = username!.isNotEmpty ? username![0].toUpperCase() : '';
      role = decodedToken['role'][0];
      userId = decodedToken['userId'];
      UserId = decodedToken['userId'];

      branches = decodedToken.containsKey("branch")
          ? List<Map<String, dynamic>>.from(decodedToken["branch"])
          : [];

      if (decodedToken.containsKey("mainBranch")) {
        branches.insert(0, decodedToken["mainBranch"]);
      }

      print(branches);
      isLoading = false;
    } else {
      isLoading = false;
    }

    notifyListeners();
  }

  static Future<void> syncUnsyncedCustomers(BuildContext context) async {
    final dbHelper = DatabaseHelper();
    const storage = FlutterSecureStorage();
    GlobalData globalData = GlobalData();

    // Call fetchToken to decode and fetch token-related data
    await globalData.fetchToken();

    // Check if userId is available
    if (GlobalData.UserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("User ID not found. Please log in again.")),
      );
      return; // Exit early if UserId is not set
    }

    String? token = await storage.read(key: "token");
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token not found")),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    if (token != null && token.isNotEmpty) {
      try {
        List<Map<String, dynamic>> unsyncedCustomers =
            await dbHelper.getUnsyncedCustomersByUserId(UserId!);
        print("unsyncedCustomers");
        print(unsyncedCustomers.length);

        if (unsyncedCustomers.isNotEmpty) {
          print(unsyncedCustomers);
          bool isSuccess =
              await dbHelper.syncCustomersToServer(unsyncedCustomers, token);

          if (isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Your data has been synced successfully!")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to sync customers")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No unsynced customers to sync")),
          );
        }
      } catch (e) {
        // Handle exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        Navigator.of(context).pop();
      }
    }
  }
}
