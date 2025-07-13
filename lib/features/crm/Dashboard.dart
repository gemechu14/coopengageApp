// ignore_for_file: sort_child_properties_last, use_super_parameters, sized_box_for_whitespace, unused_local_variable

import 'dart:convert';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/service/GlobalData.dart';
import 'package:coopengageplus/service/UserService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Dashboard extends StatefulWidget {
  final VoidCallback onSettingsTap; 
  const Dashboard({Key? key, required this.onSettingsTap})
      : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  void initState() {
    super.initState();
    fetchUsers();
    _fetchToken();
    fetchUserCounts(); 
  }

  final storage = FlutterSecureStorage();
  int? UserID;
  int localCustomers = 0; 
  int databaseCustomers = 0;
  Map<String, int> data = {
    "Total": 0,
    "Approved": 0,
    "Pending": 0,
    "Initial": 0,
  };
  final UserService userService = UserService();
  List<Map<String, dynamic>> users = [];
  final NetworkHandler networkHandler = NetworkHandler();
  int? totalUsers;
  int? approvedUsers;
  int? pendingUsers;
  int? initialStatus;
  bool isLoading = true;
  int currentItem = 0;
  Map<String, bool> isLoadingCount = {
    "Total": true,
    "Approved": true,
    "Pending": true,
    "Initial": true,
  };
  bool isOnline = true;
  void toggleOnlineStatus() {
    setState(() {
      isOnline = !isOnline; // Toggle the overall online/offline status.
      fetchUserCounts();
    });
  }

  final List<Widget> items = [
    const Image(
      image: AssetImage('assets/slider1.jpg'),
      fit: BoxFit.cover,
    ),
    const Image(
      image: AssetImage('assets/slider2.jpg'),
      fit: BoxFit.cover,
    ),
    const Image(
      image: AssetImage('assets/slider3.jpg'),
      fit: BoxFit.cover,
    ),
    const Image(
      image: AssetImage('assets/slider4.jpg'),
      fit: BoxFit.cover,
    ),
    const Image(
      image: AssetImage('assets/slider10.jpg'),
      fit: BoxFit.cover,
    ),
    const Image(
      image: AssetImage('assets/slider6.png'),
      fit: BoxFit.cover,
    ),
    const Image(
      image: AssetImage('assets/slider7.jpg'),
      fit: BoxFit.cover,
    ),
    const Image(
      image: AssetImage('assets/slider8.jpg'),
      fit: BoxFit.cover,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjust sizes based on screen width for tablet optimization
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

    // Adjustments to optimize layout on tablets
    double carouselHeight = isTablet ? 200 : 150; // Larger carousel for tablets
    int gridCrossAxisCount = isTablet ? 4 : 2; // More grid columns on tablets
    double cardAspectRatio =
        isTablet ? 1.4 : 1.7; // Adjust card aspect ratio for tablets
    double padding = isTablet ? 13.0 : 10.0; // More padding on tabletsr

    Map<String, Color> iconColors = {
      "Total": Colors.blue,
      "Approved": Colors.green,
      "Pending": Colors.orange,
      "Initial": Colors.black,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
              fontSize: 31, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        actions: [
          Row(
            children: [
              Text(
                isOnline ? 'Active' : 'Offline',
                style: TextStyle(
                  fontSize: 18, // Optional: adjust font size
                  color: isOnline
                      ? Colors.green
                      : Colors.red, // Match text color with icon
                  fontWeight: FontWeight.bold, // Optional: make the text bold
                ),
              ),
              IconButton(
                icon: Icon(
                  isOnline ? Icons.toggle_on : Icons.toggle_off,
                  color: isOnline
                      ? Colors.green
                      : Colors.red, // Green for online, red for offline
                  size: 36, // Optional: adjust icon size
                ),
                onPressed:
                    toggleOnlineStatus, // Toggle system-wide online/offline status.
              ),
              const SizedBox(
                  width: 2), // Add some spacing between the icon and the text
            ],
          )
    
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Container(
                height: isTablet ? 350 : 300,
                child: GridView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(), 
                  shrinkWrap:
                      true, 
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        gridCrossAxisCount,
                    childAspectRatio:
                        cardAspectRatio,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    String title = data.keys.elementAt(index);
                    IconData iconData;

                    switch (title) {
                      case "Total":
                        iconData = Icons.person_add;

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
                          MaterialPageRoute(builder: (context) => SizedBox()
                          
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
                              const Spacer(), // Pushes the number to the bottom
                              Align(
                                alignment: Alignment
                                    .bottomLeft, // Aligns the number to the bottom right
                                child: isLoadingCount[title]!
                                    ? const CircularProgressIndicator() // Show loading indicator
                                    : Text(
                                        title == "Total"
                                            ? totalUsers?.toString() ?? "0"
                                            : title == "Approved"
                                                ? approvedUsers?.toString() ??
                                                    "0"
                                                : title == "Pending"
                                                    ? pendingUsers
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
              const SizedBox(height: 1), 
              CarouselSlider(
                items: items.map((item) {
                  return Container(
                    width: double.infinity,
                    height:
                        carouselHeight, 
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
                  autoPlayAnimationDuration: const Duration(milliseconds: 1100),
                  autoPlayInterval: const Duration(seconds: 4),
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentItem = index;
                    });
                  },
                ),
              ),
              const SizedBox(height: 1),
              AnimatedSmoothIndicator(
                activeIndex: currentItem,
                count: items.length,
                effect: const WormEffect(
                  dotHeight: 18,
                  dotWidth: 18,
                  spacing: 5,
                  activeDotColor: Color.fromARGB(255, 5, 56, 44),
                  paintStyle: PaintingStyle.fill,
                ),
              ),
              const SizedBox(
                height: 20,
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
                      // leading: const Icon(Icons.sync, color: Colors.orange),
                      title: Text(
                        'You have $localCustomers unsynced customers!',
                        style: const TextStyle(
                            // fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                      subtitle: const Text(
                        'Please sync to avoid data loss.',
                        style: TextStyle(
                           
                            color: Colors.orange,
                            fontSize: 14),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await GlobalData.syncUnsyncedCustomers(context);
                          setState(() {
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
    // Indicate that we are loading all counts
    setState(() {
      isLoadingCount = {
        "Total": true,
        "Approved": true,
        "Pending": true,
        "Initial": true,
      };
    });

    if (isOnline) {
      // String url = '/api/v1/accounts/status-count?userId=254';
      // Retrieve the token from storage
      String? token = await storage.read(key: "token");
      if (token != null && token.isNotEmpty) {
        try {
      

          // Decode the token to get userId
          var decodedToken = JwtDecoder.decode(token);
          String userId = decodedToken['userId'].toString();

          String url = '/api/v1/accounts/status-count?userId=$userId';
          var response = await networkHandler.fetchData(url);
          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = jsonDecode(response.body);
            setState(() {
              totalUsers = data['APPROVED'] + data["PENDING"] + data["INITIAL"];
              approvedUsers = data['APPROVED'];
              pendingUsers = data['PENDING'];
              initialStatus = data['INITIAL'];
              isLoadingCount = {
                "Total": false,
                "Approved": false,
                "Pending": false,
                "Initial": false,
              };
            });
          } else {
            throw Exception('Failed to load user counts');
          }
        } catch (error) {
          setState(() {
            isLoadingCount = {
              "Total": true,
              "Approved": true,
              "Pending": true,
              "Initial": true,
            };
          });
        }
      } else {
       
        setState(() {
          isLoadingCount = {
            "Total": true,
            "Approved": true,
            "Pending": true,
            "Initial": true,
          };
        });
      }
    } else {
      // If offline, fetch data from local storage
      try {
        DatabaseHelper dbHelper = DatabaseHelper();
        List<Map<String, dynamic>> users = await dbHelper.getCustomers(1);

        // For example, setting these values based on the number of users in local storage
        setState(() {
          totalUsers = users.length;
          print(users);
          approvedUsers =
              users.where((user) => user['status'] == 'APPROVED').length;
          pendingUsers =
              users.where((user) => user['status'] == 'PENDING').length;
          initialStatus =
              users.where((user) => user['status'] == 'INITIAL').length;
          isLoadingCount = {
            "Total": false,
            "Approved": false,
            "Pending": false,
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
            "Initial": false,
          };
        });
      }
    }
  }

  Future<void> fetchUsers() async {
 
    try {
      // Fetch all users from backend
      List<Map<String, dynamic>> fetchedUsers =
          await userService.fetchAllUsers();
  


     
      setState(() {
   
        localCustomers =
            fetchedUsers.length; // Set the count of database customers
      });
    } catch (e) {
      // print("Error fetching users: $e");
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
