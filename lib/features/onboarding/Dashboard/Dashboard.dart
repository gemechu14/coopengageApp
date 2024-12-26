
// ignore_for_file: sort_child_properties_last, unused_local_variable, use_super_parameters, library_private_types_in_public_api, unnecessary_cast, avoid_print

import 'dart:convert';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:coopengageplus/Constant/SliderImage.dart';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/common_widgets/chart/AchievementBarChart.dart';
import 'package:coopengageplus/common_widgets/chart/SkeletonBarChart.dart';
import 'package:coopengageplus/common_widgets/text/custom_nav_heading.dart';
import 'package:coopengageplus/features/onboarding/pages/userListView.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/main.dart';
import 'package:coopengageplus/service/GlobalData.dart';
import 'package:coopengageplus/service/UserService.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../utils/language_store.dart';

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
    fetchData1();
  }

  List<Map<String, dynamic>> currentMonthData1 = [
    {'name': 'New Accounts', 'target': 100, 'achievements': 60},
    {'name': 'Inactive Accounts', 'target': 200, 'achievements': 30},
    {'name': 'Agents', 'target': 10, 'achievements': 338},
  ];

  List<Map<String, dynamic>>? currentMonthData;
  final storage = FlutterSecureStorage();
  int? UserID;
  int localCustomers = 0;
  int databaseCustomers = 0;
  int? userId;
  Map<String, int> data = {
    "Approved": 0,
    "Pending": 0,
    "Unsettled": 0,
    "Initial": 0,
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
    // "Total": true,
    "Approved": true,
    "Pending": true,
    "Initial": true,
    "Unsettled": true
  };
  void toggleOnlineStatus() {
    setState(() {
      isOnline = !isOnline;
      fetchUserCounts();
    });
  }

  final List<BarChartGroupData> showingBarGroups = [
    BarChartGroupData(
      x: 0,
      barRods: [
        BarChartRodData(
          toY: 100, // Main Branch Clients
          color: Colors.blue,
          width: 15,
          borderRadius: BorderRadius.zero,
        ),
      ],
    ),
    BarChartGroupData(
      x: 1,
      barRods: [
        BarChartRodData(
          toY: 50, // Other Branch Clients
          color: Colors.green,
          width: 15,
          borderRadius: BorderRadius.zero,
        ),
      ],
    ),
    BarChartGroupData(
      x: 2,
      barRods: [
        BarChartRodData(
          toY: 30, // Registered Agents
          color: Colors.orange,
          width: 15,
          borderRadius: BorderRadius.zero,
        ),
      ],
    ),
  ];
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
    double cardAspectRatio =
        isTablet ? 1.4 : 1.7; // Adjust card aspect ratio for tablets
    double padding = isTablet ? 13.0 : 10.0; // More padding on tabletsr

    Map<String, Color> iconColors = {
      // "Total": Colors.blue,
      "Approved": Colors.blue,
      "Pending": Colors.green,
      "Initial": Colors.black,
      "Unsettled": Colors.black54
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
                height: isTablet ? 300 : 240,
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
                      case "Approved":
                        iconData = Icons.check_circle;

                        break;
                      case "Unsettled":
                        iconData = Icons.pending;

                        break;
                      case "Approved":
                        iconData = Icons.check_circle;
                        break;
                      case "Pending":
                        iconData = Icons.hourglass_bottom;
                        break;
                      case "Initial":
                        iconData = Icons.hourglass_empty;
                        break;
                      default:
                        iconData = Icons.error;
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // builder: (context) => UserInfoPage(title: title),
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
                                    ? const CircularProgressIndicator()
                                    : Text(
                                        // title == "Total"
                                        //     ? approvedUsers?.toString() ?? "0"
                                        title == "Approved"
                                            ? approvedUsers!.toString() ?? "0"
                                            : title == "Pending"
                                                ? pendingUsers?.toString() ??
                                                    "0"
                                                : title == "Unsettled"
                                                    ? unsettledStatus
                                                            ?.toString() ??
                                                        "0"
                                                    : title == "Initial"
                                                        ? initialStatus
                                                                ?.toString() ??
                                                            "0"
                                                        : "0",
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

              const SizedBox(height: 20),
              if (!isOnline)
                CarouselSlider(
                  items: SliderImages.items.map((item) {
                    return Container(
                      width: double.infinity,
                      height: carouselHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: (item as Image).image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    height: carouselHeight,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 1100),
                    autoPlayInterval: const Duration(seconds: 4),
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentItem = index;
                      });
                    },
                  ),
                ),

              // const SizedBox(height: 20),
              if (!isOnline)
                AnimatedSmoothIndicator(
                  activeIndex: currentItem,
                  count: SliderImages.items.length,
                  effect: const WormEffect(
                    dotHeight: 13,
                    dotWidth: 13,
                    spacing: 5,
                    activeDotColor: Colors.blue,
                    paintStyle: PaintingStyle.fill,
                  ),
                ),

              // AnalyticsSection(),
              if (isOnline)
                Container(
                    height: 250,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 15),
                      child: currentMonthData != null
                          ? AchievementBarChart(data: currentMonthData!)
                          : Center(child: SkeletonBarChart()),
                    )),

              if (!isOnline) const SizedBox(height: 20),
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
                        child: const Text(
                          'Sync Now',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchUserCounts() async {
    setState(() {
      isLoadingCount = {
        "Total": true,
        "Approved": true,
        "Unsettled": true,
        "Pending": true,
        "Initial": true,
      };
    });

    if (isOnline) {
      String? token = await storage.read(key: "token");
      if (token != null && token.isNotEmpty) {
        try {
          var decodedToken = JwtDecoder.decode(token);
          String userId = decodedToken['userId'].toString();

          String url = '/api/v1/accounts/status-count?userId=$userId';
          print("userid");
          print(userId);
          var response = await networkHandler.fetchData(url);
          print("data21");
          print(response.statusCode);
          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = jsonDecode(response.body);
            setState(() {
              totalUsers = data['APPROVED'] + data["PENDING"] + data["INITIAL"];

              approvedUsers = data['APPROVED'];
              TOTALAPPROVED = approvedUsers;
              pendingUsers = data['PENDING'];
              TOTALPENDING = pendingUsers;
              initialStatus = data['INITIAL'];
              TOTALINITIAL = data['INITIAL'];
              unsettledStatus = data['UNSETTLED'];
              TOTALUNSETTLED = data['UNSETTLED'];

              isLoadingCount = {
                "Total": false,
                "Approved": false,
                "Pending": false,
                "Unsettled": false,
                "Initial": false,
              };
            });
          } else {
            throw Exception('Failed to load user counts');
          }
        } catch (error) {
          print("Error fetching user counts: $error");
          setState(() {
            isLoadingCount = {
              "Total": true,
              "Approved": true,
              "Pending": true,
              "Unsettled": true,
              "Initial": true,
            };
          });
        }
      } else {
        print("No token found");
        setState(() {
          isLoadingCount = {
            "Total": true,
            "Approved": true,
            "Pending": true,
            "Unsettled": true,
            "Initial": true,
          };
        });
      }
    } else {
      String? token = await storage.read(key: "token");
      if (token != null && token.isNotEmpty) {
        try {
          DatabaseHelper dbHelper = DatabaseHelper();

          List<Map<String, dynamic>> users =
              await dbHelper.getCustomers(UserID!);

          print("user id ");
          print(UserID);
          setState(() {
            totalUsers = users.length;
            approvedUsers =
                users.where((user) => user['status'] == 'APPROVED').length;
            TOTALAPPROVED = approvedUsers;
            pendingUsers =
                users.where((user) => user['status'] == 'PENDING').length;
            TOTALPENDING = pendingUsers;
            initialStatus =
                users.where((user) => user['status'] == 'INITIAL').length;
            TOTALINITIAL = initialStatus;
            unsettledStatus =
                users.where((user) => user['status'] == 'UNSETTLED').length;
            TOTALUNSETTLED = unsettledStatus;
            isLoadingCount = {
              "Total": false,
              "Approved": false,
              "Pending": false,
              "Unsettled": false,
              "Initial": false,
            };
          });
        } catch (error) {
          print("Error fetching local data: $error");
          setState(() {
            isLoadingCount = {
              "Total": false,
              "Approved": false,
              "Pending": false,
              "Unsettled": false,
              "Initial": false,
            };
          });
        }
      }
    }
  }

  Future<void> fetchData1() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: "token");

    if (token != null && token.isNotEmpty) {
      try {
        var decodedToken = JwtDecoder.decode(token);
        String userId = decodedToken['userId'].toString();

        String url = '/api/v1/users/report';
        var response = await networkHandler.fetchData(url);

        print("response");

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Parse the response data
          final data = jsonDecode(response.body);
          print(data);
          //  var data = response.data['currentMonth'];
          var currentMonthData = data['currentMonthTargetAchievements'];

          print("current month");
          print(currentMonthData);
          setState(() {
            this.currentMonthData =
                List<Map<String, dynamic>>.from(currentMonthData);
            print(currentMonthData);
          });
        }
      } catch (e) {
        print("Error: $e");
      }
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
