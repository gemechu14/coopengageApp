// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:coopengageplus/NetworkHandler.dart';

import 'package:coopengageplus/common_widgets/text/custom_nav_heading.dart';
import 'package:coopengageplus/features/onboarding/pages/userInfoList/userListView.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/main.dart';
import 'package:coopengageplus/service/GlobalData.dart';
import 'package:coopengageplus/service/UserService.dart';
import 'package:coopengageplus/services/token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  final VoidCallback onSettingsTap;

  const Dashboard({Key? key, required this.onSettingsTap}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  void initState() {
    super.initState();
    _fetchToken();
    fetchUserCounts();
    fetchUsers();
    // Initialize token monitoring
    TokenService.initialize(context);
  }

  List<Map<String, dynamic>>? currentMonthData;
  final storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );
  int? UserID;
  int localCustomers = 0;
  int databaseCustomers = 0;
  int? userId;
  Map<String, int> data = {
    "New Applicants": 0,
    "Awaiting Action": 0,
    "Approved": 0,
    "Rejected": 0,
  };
  final UserService userService = UserService();
  List<Map<String, dynamic>> users = [];
  final NetworkHandler networkHandler = NetworkHandler();
  int? totalUsers;
  int? approvedUsers;
  int? pendingUsers;
  int? initialStatus;
  int? unsettledStatus;
  bool isLoading = true;
  int currentItem = 0;
  Map<String, bool> isLoadingCount = {
    "New Applicants": true,
    "Awaiting Action": true,
    "Approved": true,
    "Rejected": true
  };

  void toggleOnlineStatus() {
    setState(() {
      isOnline = !isOnline;
      fetchUserCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = screenWidth >= 600;
    double titleFontSize = screenWidth < 400
        ? 17
        : (screenWidth < 600 ? 17 : (screenWidth < 800 ? 19 : 23));
    double valueFontSize = screenWidth < 400
        ? 27
        : (screenWidth < 600 ? 29 : (screenWidth < 800 ? 29 : 34));
    double iconSize = screenWidth < 400
        ? 21
        : (screenWidth < 600 ? 27 : (screenWidth < 800 ? 33 : 37));

    double carouselHeight = isTablet ? 200 : 150;
    int gridCrossAxisCount = isTablet ? 4 : 2;
    double cardAspectRatio = isTablet ? 1.4 : 1.7;
    double padding = isTablet ? 13.0 : 10.0;

    Map<String, Color> iconColors = {
      "New Applicants": Colors.blue,
      "Awaiting Action": Colors.orange,
      "Approved": Colors.green,
      "Rejected": Colors.red,
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: CustomNavHeading(
            text: "Home",
          ),
          // backgroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Container(
                height: isTablet ? 240 : 240,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCrossAxisCount,
                    childAspectRatio: cardAspectRatio,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    String title = data.keys.elementAt(index);
                    IconData iconData;

                    switch (title) {
                      case "New Applicants":
                        iconData = Icons.person_add;
                        break;
                      case "Awaiting Action":
                        iconData = Icons.hourglass_bottom;
                        break;
                      case "Approved":
                        iconData = Icons.check_circle;
                        break;
                      case "Rejected":
                        iconData = Icons.cancel;
                        break;
                      default:
                        iconData = Icons.error;
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserListPage(title: title),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    width: iconSize,
                                    height: iconSize,
                                    child: Icon(
                                      iconData,
                                      size: iconSize,
                                      color: iconColors[title],
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: isLoadingCount[title]!
                                    ? Text(
                                        "-",
                                        style: TextStyle(
                                          fontSize: valueFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: iconColors[title],
                                        ),
                                      )
                                    : Text(
                                        getDisplayCount(title),
                                        style: TextStyle(
                                          fontSize: valueFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: iconColors[title],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Rest of your widgets...

              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white), // Optional border
                  borderRadius:
                      BorderRadius.circular(16), // Adjust the radius as needed
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      16), // Same as container's borderRadius
                  child: Image.asset(
                    "assets/step3.png",
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 150,
                    fit: BoxFit.fill,
                  ),
                ),
              ),

              if (localCustomers > 0)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color.fromARGB(255, 53, 52, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        'You have $localCustomers unsynced customers!',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      subtitle: const Text(
                        'Please sync to avoid data loss.',
                        style: TextStyle(color: Colors.orange, fontSize: 14),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await GlobalData.syncUnsyncedCustomers(context);
                          setState(() {
                            _fetchToken();
                            fetchUsers();
                            fetchUserCounts();
                          });
                        },
                        child: Text(
                          'Sync Now',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up token monitoring when widget is disposed
    TokenService.stopTokenMonitoring();
    super.dispose();
  }

  Future<void> fetchUserCounts() async {
    setState(() {
      isLoadingCount = {
        "New Applicants": true,
        "Awaiting Action": true,
        "Approved": true,
        "Rejected": true,
      };
    });

    if (isOnline) {
      String? token = await storage.read(key: "token");
      if (token != null && token.isNotEmpty) {
        try {
          // Check if token is still valid before making API call
          bool isTokenValid = await TokenService.isTokenValid();
          if (!isTokenValid) {
            print("Token expired during fetchUserCounts, logging out user");
            await TokenService.forceLogoutWithContext(context);
            return;
          }

          var decodedToken = JwtDecoder.decode(token);
          String userId = decodedToken['userId'].toString();

          String url = '/api/v1/accounts/status-count';
          var response = await networkHandler.fetchData(url);

          // Check for token errors first
          if (await _handleNetworkResponse(response)) {
            return; // Token error handled, exit
          }

          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = jsonDecode(response.body);

            setState(() {
              // Group 1: New Applicants (INITIAL + REGISTERED)
              int newApplicants =
                  (data['INITIAL'] ?? 0) + (data['REGISTERED'] ?? 0);

              // Group 2: Awaiting Action (PENDING + UNAUTHORIZED + UNSETTLED + AUTHORIZED)
              int awaitingAction = (data['UNAUTHORIZED'] ?? 0) +
                  (data['UNSETTLED'] ?? 0) +
                  (data['AUTHORIZED'] ?? 0);

              // Group 3: Approved
              int approved = data['APPROVED'] ?? 0;

              // Group 4: Rejected
              int rejected = data['REJECTED'] ?? 0;

              // Update the counts
              approvedUsers = approved;
              pendingUsers = awaitingAction;
              initialStatus = newApplicants;
              unsettledStatus = rejected;

              // Update global variables
              TOTALAPPROVED = approved;
              TOTALPENDING = awaitingAction;
              TOTALINITIAL = newApplicants;
              TOTALUNSETTLED = rejected;

              isLoadingCount = {
                "New Applicants": false,
                "Awaiting Action": false,
                "Approved": false,
                "Rejected": false,
              };
            });
          } else {
            // Check for specific token error
            final errorData = jsonDecode(response.body);
            if (await _handleTokenError(errorData)) {
              return; // Token error handled, exit
            }
            throw Exception('Failed to load user counts');
          }
        } catch (error) {
          print("Error fetching user counts: $error");
          setState(() {
            isLoadingCount = {
              "New Applicants": false,
              "Awaiting Action": false,
              "Approved": false,
              "Rejected": false,
            };
          });
        }
      }
    } else {
      String? token = await storage.read(key: "token");
      if (token != null && token.isNotEmpty) {
        try {
          DatabaseHelper dbHelper = DatabaseHelper();
          List<Map<String, dynamic>> users =
              await dbHelper.getCustomers(UserID!);

          setState(() {
            // Group 1: New Applicants
            int newApplicants = users
                .where((user) =>
                    user['status'] == 'INITIAL' ||
                    user['status'] == 'REGISTERED')
                .length;

            // Group 2: Awaiting Action
            int awaitingAction = users
                .where((user) =>
                    user['status'] == 'PENDING' ||
                    user['status'] == 'UNAUTHORIZED' ||
                    user['status'] == 'UNSETTLED' ||
                    user['status'] == 'AUTHORIZED')
                .length;

            // Group 3: Approved
            int approved =
                users.where((user) => user['status'] == 'APPROVED').length;

            // Group 4: Rejected
            int rejected =
                users.where((user) => user['status'] == 'REJECTED').length;

            approvedUsers = approved;
            pendingUsers = awaitingAction;
            initialStatus = newApplicants;
            unsettledStatus = rejected;

            TOTALAPPROVED = approved;
            TOTALPENDING = awaitingAction;
            TOTALINITIAL = newApplicants;
            TOTALUNSETTLED = rejected;

            isLoadingCount = {
              "New Applicants": false,
              "Awaiting Action": false,
              "Approved": false,
              "Rejected": false,
            };
          });
        } catch (error) {
          print("Error fetching local data: $error");
          setState(() {
            isLoadingCount = {
              "New Applicants": false,
              "Awaiting Action": false,
              "Approved": false,
              "Rejected": false,
            };
          });
        }
      }
    }
  }

  String getDisplayCount(String title) {
    switch (title) {
      case "New Applicants":
        return initialStatus?.toString() ?? "0";
      case "Awaiting Action":
        return pendingUsers?.toString() ?? "0";
      case "Approved":
        return approvedUsers?.toString() ?? "0";
      case "Rejected":
        return unsettledStatus?.toString() ?? "0";
      default:
        return "0";
    }
  }

  Future<void> fetchUsers() async {
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      try {
        // Check if token is still valid before accessing data
        bool isTokenValid = await TokenService.isTokenValid();
        if (!isTokenValid) {
          print("Token expired during fetchUsers, logging out user");
          await TokenService.forceLogoutWithContext(context);
          return;
        }

        DatabaseHelper dbHelper = DatabaseHelper();

        List<Map<String, dynamic>> fetchedUsers =
            await dbHelper.getCustomers(UserID!);

        setState(() {
          localCustomers = fetchedUsers.length;
        });
      } catch (e) {
        print("Error fetching users: $e");
        // Check if this is a token-related error
        if (e.toString().contains("Token") ||
            e.toString().contains("Unauthorized")) {
          await _handleTokenError({"error_message": e.toString()});
        }
      }
    }
  }

  Future<void> _fetchToken() async {
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      try {
        // Check if token is valid using TokenService
        bool isTokenValid = await TokenService.isTokenValid();

        if (!isTokenValid) {
          // Token is expired, force logout
          print("Token expired in Dashboard, logging out user");
          await TokenService.forceLogoutWithContext(context);
          return;
        }

        var decodedToken = JwtDecoder.decode(token);
        setState(() {
          UserID = decodedToken["userId"];
          isLoading = false;
        });

        // Check if token will expire soon and show warning
        // _checkTokenExpirationWarning();
      } catch (e) {
        print("Error decoding token: $e");
        // Token is invalid, force logout
        await TokenService.forceLogoutWithContext(context);
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Check for common token-related errors and handle them
  Future<bool> _handleTokenError(dynamic errorData) async {
    if (errorData is Map<String, dynamic>) {
      String? errorMessage = errorData['error_message'];

      if (errorMessage != null) {
        // Check for specific token invalidation errors
        if (errorMessage.contains("Token was issued before the latest login") ||
            errorMessage.contains("Token invalid") ||
            errorMessage.contains("Invalid token") ||
            errorMessage.contains("Token expired") ||
            errorMessage.contains("Unauthorized") ||
            errorMessage.contains("Forbidden")) {
          print("Token error detected: $errorMessage - Logging out user");

          // Show user-friendly message before logout
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          'Your session has been invalidated. Please login again.'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }

          // Wait a moment for user to see the message, then logout
          await Future.delayed(Duration(seconds: 2));
          await TokenService.forceLogoutWithContext(context);
          return true; // Error was handled
        }
      }
    }
    return false; // Error was not handled
  }

  /// Handle network response and check for token errors
  Future<bool> _handleNetworkResponse(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      // Unauthorized or Forbidden - likely token issue
      try {
        final errorData = jsonDecode(response.body);
        if (await _handleTokenError(errorData)) {
          return true; // Token error handled
        }
      } catch (e) {
        // If we can't parse the error, still treat as token issue
        print("Network error ${response.statusCode}, treating as token issue");
        await _handleTokenError({"error_message": "Unauthorized access"});
        return true;
      }
    }
    return false; // No token error
  }
}
