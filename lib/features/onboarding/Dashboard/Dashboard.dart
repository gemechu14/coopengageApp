import 'dart:convert';

import 'package:coopengageplus/NetworkHandler.dart';

import 'package:coopengageplus/common_widgets/text/custom_nav_heading.dart';
import 'package:coopengageplus/features/onboarding/pages/userInfoList/userListView.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/main.dart';
import 'package:coopengageplus/service/GlobalData.dart';
import 'package:coopengageplus/service/UserService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
  }

  List<Map<String, dynamic>> currentMonthData1 = [
    {'name': 'New Accounts', 'target': 1000, 'achievements': 360},
    {'name': 'Inactive Accounts', 'target': 200, 'achievements': 30},
    {'name': 'Agents', 'target': 10, 'achievements': 0},
  ];

  List<Map<String, dynamic>> currentMonthData2 = [
    {'name': 'New Accounts', 'target': 1000, 'achievements': 100},
    {'name': 'Inactive Accounts', 'target': 200, 'achievements': 300},
    {'name': 'Agents', 'target': 10, 'achievements': 0},
  ];

  List<Map<String, dynamic>>? currentMonthData;
  final storage = FlutterSecureStorage();
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
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            Row(
              children: [
                Text(
                  isOnline ? 'Active' : 'Offline',
                  style: TextStyle(
                    fontSize: 18,
                    color: isOnline ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isOnline ? Icons.toggle_on : Icons.toggle_off,
                    color: isOnline ? Colors.green : Colors.red,
                    size: 36,
                  ),
                  onPressed: toggleOnlineStatus,
                ),
                const SizedBox(width: 2),
              ],
            )
          ],
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
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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

              const SizedBox(height: 20),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E40AF), // Deep blue
                        Color(0xFF3B82F6), // Medium blue
                        Color.fromARGB(255, 51, 56, 57), // Cyan accent
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Left: Content
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.account_balance,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Cooperative Bank of Oromia',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // const Text(
                                //   'Empowering Communities, Transforming Lives.',
                                //   style: TextStyle(
                                //     color: Colors.white,
                                //     fontSize: 11,
                                //     fontStyle: FontStyle.italic,
                                //     fontWeight: FontWeight.w500,
                                //   ),
                                // ),
                                const SizedBox(height: 1),
                                // Text(
                                //   'Welcome New Members to Our Banking Family',
                                //   style: TextStyle(
                                //     color: Colors.white.withOpacity(0.85),
                                //     fontSize: 12,
                                //     fontWeight: FontWeight.w500,
                                //   ),
                                // ),
                                Text(
                                  'Transforming Lives — One Customer Registration at a Time',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          ),
                          // Right: Action area with icon
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_note_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          'rSync Now',
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
          var decodedToken = JwtDecoder.decode(token);
          String userId = decodedToken['userId'].toString();

          String url = '/api/v1/accounts/status-count';
          var response = await networkHandler.fetchData(url);

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
        DatabaseHelper dbHelper = DatabaseHelper();

        List<Map<String, dynamic>> fetchedUsers =
            await dbHelper.getCustomers(UserID!);

        setState(() {
          localCustomers = fetchedUsers.length;
        });
      } catch (e) {
        print("Error fetching users: $e");
      }
    }
  }

  Future<void> _fetchToken() async {
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);
      setState(() {
        UserID = decodedToken["userId"];

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
}
