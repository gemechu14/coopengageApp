// ignore_for_file: constant_identifier_names, use_build_context_synchronously, non_constant_identifier_names, use_super_parameters, library_private_types_in_public_api
import 'package:coopengageplus/Screen/LoginScreen.dart';
import 'package:coopengageplus/common_widgets/text/custom_nav_heading.dart';
import 'package:coopengageplus/features/onboarding/pages/help.dart';
import 'package:coopengageplus/service/GlobalData.dart';
import 'package:coopengageplus/utils/language_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'dart:convert'; // Added for jsonDecode

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );

  String username = "";
  String firstLetter = "";
  String role = '';
  bool isProfileLoading = true;
  bool isBranchesLoading = true;

  List<Map<String, dynamic>>? branches;
  String? mainBranchCode;
  String? mainBranchCompanyName;
  int? mainBranchId;

  Map<String, dynamic>? selectedBranch;
  int? UserID;
  String? token;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);

    GlobalData().fetchToken();
    UserID = GlobalData().userId;
    _fetchToken();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          title: CustomNavHeading(
            text: translation(context).profile,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.power_settings_new),
              onPressed: logout,
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.transparent,
            child: Row(
              children: [
                // Profile Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.black,
                  child: isProfileLoading
                      ? _buildSkeletonCircle(40)
                      : Text(
                          firstLetter,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      if (isProfileLoading)
                        _buildSkeletonText(120, 16)
                      else
                        Text(
                          username,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                            color: Colors.black,
                          ),
                        ),
                      const SizedBox(height: 4),

                      // Role
                      if (isProfileLoading)
                        _buildSkeletonText(80, 14)
                      else
                        Text(
                          role,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Main Branch Section
                      _buildMainBranchSection(),
                      const SizedBox(height: 16),

                      // Other Branches Section
                      _buildOtherBranchesSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Settings Section
          _buildSettingsSection(),
        ],
      ),
    );
  }

  Widget _buildMainBranchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Main Branch:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (isProfileLoading)
          _buildSkeletonText(150, 14)
        else if (mainBranchCompanyName != null)
          Text(
            mainBranchCompanyName!,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          )
        else
          const Text(
            "No main branch available",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildOtherBranchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Other Branch Names:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (isProfileLoading)
          Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _buildSkeletonText(100 + (index * 20), 14),
              ),
            ),
          )
        else if (branches != null && branches!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: branches!.map((branch) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  branch['companyName'] ?? "Unnamed Branch",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
          )
        else
          const Text(
            "No branches available",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.info, color: Colors.blue),
          title: const Text("About"),
          onTap: () {
            // Navigate to About Page
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help, color: Colors.blue),
          title: const Text("Help"),
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HelpPage()),
              (route) => false,
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.sync, color: Colors.blue),
          title: const Text("Sync Registered Customer"),
          onTap: () async {
            await GlobalData.syncUnsyncedCustomers(context);
          },
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildSkeletonText(double width, double height) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color:
                Colors.grey[300]!.withOpacity(0.3 + (_animation.value * 0.4)),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCircle(double radius) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color:
                Colors.grey[300]!.withOpacity(0.3 + (_animation.value * 0.4)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  void logout() async {
    setState(() {
      isProfileLoading = true;
    });

    await storage.delete(key: "token");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Loginscreen()),
      (route) => false,
    );

    setState(() {
      isProfileLoading = false;
    });
  }

  Future<void> _fetchToken() async {
    String? token = await storage.read(key: "token");
    print("ProfileScreen: Token found: ${token != null ? 'Yes' : 'No'}");
    
    if (token != null && token.isNotEmpty) {
      try {
        // Try to decode the token to get user details
        var decodedToken = JwtDecoder.decode(token);
        print("ProfileScreen: JWT decoded successfully");
        
        setState(() {
          username = decodedToken['sub'] ?? "User";
          firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '';
          role = decodedToken['role'][0];
          UserID = decodedToken['userId'];
          
          // Don't get branches from token, we'll get them from database
          branches = [];
          
          // Decode mainBranch if available in the token
          if (decodedToken.containsKey("mainBranch")) {
            mainBranchCode = decodedToken["mainBranch"]["branchCode"];
            mainBranchCompanyName = decodedToken["mainBranch"]["companyName"];
            mainBranchId = decodedToken["mainBranch"]["id"];
          }

          isProfileLoading = false;
          isBranchesLoading = false;
        });
        
        // After setting basic info, fetch branches from database
        await _fetchBranchesFromDatabase();
        
      } catch (e) {
        print("ProfileScreen: JWT decoding failed: $e");
        // If JWT decoding fails, try to get user data from local database
        final dbHelper = DatabaseHelper();
        final user = await dbHelper.getUserByToken(token);
        print("ProfileScreen: User found by token: ${user != null ? 'Yes' : 'No'}");
        
        if (user != null) {
          print("ProfileScreen: Using data from database");
          setState(() {
            username = user['username'] ?? user['fullName'] ?? "User";
            firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '';
            role = user['role'] ?? '';
            UserID = user['userId'];
            
            // Set main branch from database
            mainBranchCode = user['mainBranchCode'];
            mainBranchCompanyName = user['mainBranchName'];
            mainBranchId = user['mainBranchId'];

            isProfileLoading = false;
            isBranchesLoading = false;
          });
          
          // Fetch branches from database
          await _fetchBranchesFromDatabase();
          
        } else {
          // If no user found by token, try to get the first user from database
          final users = await dbHelper.getUsers();
          print("ProfileScreen: Total users in database: ${users.length}");
          
          if (users.isNotEmpty) {
            final firstUser = users.first;
            print("ProfileScreen: Using first user from database");
            setState(() {
              username = firstUser['username'] ?? firstUser['fullName'] ?? "User";
              firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '';
              role = firstUser['role'] ?? '';
              UserID = firstUser['userId'];
              
              // Set main branch from database
              mainBranchCode = firstUser['mainBranchCode'];
              mainBranchCompanyName = firstUser['mainBranchName'];
              mainBranchId = firstUser['mainBranchId'];

              isProfileLoading = false;
              isBranchesLoading = false;
            });
            
            // Fetch branches from database
            await _fetchBranchesFromDatabase();
            
          } else {
            print("ProfileScreen: No users found in database");
            setState(() {
              isProfileLoading = false;
              isBranchesLoading = false;
            });
          }
        }
      }
    } else {
      print("ProfileScreen: No token found, checking database for any user");
      // If no token, try to get any user from database
      final dbHelper = DatabaseHelper();
      final users = await dbHelper.getUsers();

      print("kdfkdfkdjfjkdkjfjeuueurueurueueruur");
      print(users);
      if (users.isNotEmpty) {
        final firstUser = users.first;
        print("ProfileScreen: Using first user from database (no token)");
        setState(() {
          username = firstUser['username'] ?? firstUser['fullName'] ?? "User";
          firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '';
          role = firstUser['role'] ?? '';
          UserID = firstUser['userId'];
          
          // Set main branch from database
          mainBranchCode = firstUser['mainBranchCode'];
          mainBranchCompanyName = firstUser['mainBranchName'];
          mainBranchId = firstUser['mainBranchId'];

          isProfileLoading = false;
          isBranchesLoading = false;
        });
        
        // Fetch branches from database
        await _fetchBranchesFromDatabase();
        
      } else {
        setState(() {
          isProfileLoading = false;
          isBranchesLoading = false;
        });
      }
    }
    
    print("ProfileScreen: Final data - username: $username, role: $role, UserID: $UserID");
  }

  Future<void> _fetchBranchesFromDatabase() async {
    print("ProfileScreen: Fetching branches from database...");
    final dbHelper = DatabaseHelper();
    
    try {
      // Get all branches from the Branches table
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> branchResults = await db.query('Branches');
      
      print("ProfileScreen: Raw branches from database: $branchResults");
      
      if (branchResults.isNotEmpty) {
        // Convert database results to the expected format
        final List<Map<String, dynamic>> formattedBranches = branchResults.map((branch) {
          return {
            'id': branch['id'],
            'name': branch['branchName'] ?? 'Unnamed Branch',
            'branchCode': branch['branchCode'] ?? '',
            'companyName': branch['companyName'] ?? branch['branchName'] ?? 'Unnamed Branch',
          };
        }).toList();
        
        print("ProfileScreen: Formatted branches: $formattedBranches");
        
        setState(() {
          branches = formattedBranches;
          isBranchesLoading = false;
        });
      } else {
        print("ProfileScreen: No branches found in database");
        setState(() {
          branches = [];
          isBranchesLoading = false;
        });
      }
    } catch (e) {
      print("ProfileScreen: Error fetching branches: $e");
      setState(() {
        branches = [];
        isBranchesLoading = false;
      });
    }
  }
}
