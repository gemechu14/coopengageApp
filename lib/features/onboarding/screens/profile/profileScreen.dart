// ignore_for_file: constant_identifier_names, use_build_context_synchronously, non_constant_identifier_names, use_super_parameters, library_private_types_in_public_api
import 'package:coopengageplus/features/screens/LoginScreen.dart';
import 'package:coopengageplus/shared/widgets/text/custom_nav_heading.dart';
import 'package:coopengageplus/features/onboarding/pages/help.dart';
import 'package:coopengageplus/shared/services/GlobalData.dart';
import 'package:coopengageplus/core/utils/language_store.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/home/pages/mycard_link_stats_page.dart';
import 'package:coopengageplus/shared/widgets/mycard_share_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:coopengageplus/core/database/database_helper.dart';
import 'pages/overall_stats_page.dart';
import 'pages/recent_invitations_page.dart';

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

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
    _shimmerController.repeat();

    GlobalData().fetchToken();
    UserID = GlobalData().userId;
    _fetchToken();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: graybackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          title: CustomNavHeading(
            text: translation(context).profile,
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: primaryBlue),
                onPressed: logout,
                tooltip: 'Logout',
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(),
              const SizedBox(height: 10),
              _buildBranchInfoCard(),
              const SizedBox(height: 10),
              _buildQuickActionsCard(),
              const SizedBox(height: 10),
              _buildSettingsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Avatar with gradient background
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryBlue, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isProfileLoading
                    ? _buildShimmerContainer(64, 64, 16)
                    : Center(
                        child: Text(
                          firstLetter,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: whiteColor,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 14),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isProfileLoading)
                      _buildShimmerContainer(150, 20, 4)
                    else
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: blackColor,
                        ),
                      ),
                    const SizedBox(height: 6),
                    if (isProfileLoading)
                      _buildShimmerContainer(100, 16, 4)
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBranchInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: secondaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: secondaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Branch Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: blackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Branch
          _buildBranchSection(
            title: 'Main Branch',
            branchName: mainBranchCompanyName,
            icon: Icons.home_work_rounded,
            isMain: true,
          ),

          if (branches != null && branches!.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Other Branches
            _buildBranchSection(
              title: 'Other Branches',
              branches: branches,
              icon: Icons.account_tree_rounded,
              isMain: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBranchSection({
    required String title,
    String? branchName,
    List<Map<String, dynamic>>? branches,
    required IconData icon,
    required bool isMain,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (isProfileLoading)
          _buildShimmerContainer(200, 14, 4)
        else if (isMain)
          _buildBranchTile(branchName ?? "No main branch available")
        else if (branches != null && branches.isNotEmpty)
          ...branches.map((branch) => _buildBranchTile(
                branch['companyName'] ?? "Unnamed Branch",
                isSubBranch: true,
              ))
        else
          _buildBranchTile("No branches available", isEmpty: true),
      ],
    );
  }

  Widget _buildBranchTile(String name,
      {bool isSubBranch = false, bool isEmpty = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isEmpty
            ? Colors.grey[50]
            : (isSubBranch
                ? tertiaryBlue.withOpacity(0.1)
                : primaryBlue.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEmpty
              ? Colors.grey[300]!
              : (isSubBranch
                  ? tertiaryBlue.withOpacity(0.3)
                  : primaryBlue.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isEmpty ? Icons.info_outline : Icons.business,
            size: 16,
            color: isEmpty
                ? Colors.grey[500]
                : (isSubBranch ? tertiaryBlue : primaryBlue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                color: isEmpty ? Colors.grey[600] : blackColor,
                fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cyanblueColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.dashboard_outlined,
                    color: cyanblueColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: blackColor,
                  ),
                ),
              ],
            ),
          ),
          _buildActionTile(
            icon: Icons.analytics_outlined,
            title: 'Overall Statistics',
            subtitle: 'Invitation performance',
            color: primaryBlue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OverallStatsPage(),
                ),
              );
            },
          ),
          _buildActionTile(
            icon: Icons.history_outlined,
            title: 'Recent Invitations',
            subtitle: 'Sent invitations',
            color: secondaryBlue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecentInvitationsPage(),
                ),
              );
            },
          ),
          _buildActionTile(
            icon: Icons.insights_rounded,
            title: 'MyCard link stats',
            subtitle: 'Local & server link metrics',
            color: primaryBlue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MycardLinkStatsPage(),
                ),
              );
            },
          ),
          _buildActionTile(
            icon: Icons.add_card_rounded,
            title: 'Share MyCard link',
            subtitle: 'WhatsApp, Telegram, email…',
            color: cyanblueColor,
            onTap: () => showMycardShareSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: yellowColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: yellowColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: blackColor,
                  ),
                ),
              ],
            ),
          ),
          _buildSettingsTile(
            icon: Icons.info_rounded,
            title: "About",
            subtitle: "App information and version",
            onTap: () {
              // Navigate to About Page
            },
          ),
          _buildSettingsTile(
            icon: Icons.help_rounded,
            title: "Help",
            subtitle: "Get support and assistance",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: blackColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: blackColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerContainer(double width, double height, double radius) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshProfile() async {
    setState(() {
      isProfileLoading = true;
      isBranchesLoading = true;
    });
    await _fetchToken();
  }

  void logout() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: primaryBlue),
            const SizedBox(height: 16),
            Text(
              'Logging out...',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );

    await storage.delete(key: "token");

    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Loginscreen()),
        (route) => false,
      );
    }
  }

  Future<void> _fetchToken() async {
    String? token = await storage.read(key: "token");
    print("ProfileScreen: Token found: ${token != null ? 'Yes' : 'No'}");

    if (token != null && token.isNotEmpty) {
      try {
        // Try to decode the token to get user details
        var decodedToken = JwtDecoder.decode(token);
        print("ProfileScreen: JWT decoded successfullyqq");

        setState(() {
          username = decodedToken['sub'] ?? "User";
          firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '';
          role = decodedToken['role'][0];
          UserID = decodedToken['userId'];

          // Don't get branches from token, we'll get them from database
          branches = [];

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
        print(
            "ProfileScreen: User found by token: ${user != null ? 'Yes' : 'No'}");

        if (user != null) {
          print("ProfileScreen: Using data from databasesds");
          setState(() {
            print(user['mainBranchName']);
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
              username =
                  firstUser['username'] ?? firstUser['fullName'] ?? "User";
              firstLetter =
                  username.isNotEmpty ? username[0].toUpperCase() : '';
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

    print(
        "ProfileScreen: Final data - username: $username, role: $role, UserID: $UserID");
  }

  Future<void> _fetchBranchesFromDatabase() async {
    print("ProfileScreen: Fetching branches from database...");
    final dbHelper = DatabaseHelper();

    try {
      // Get all branches from the Branches table
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> branchResults =
          await db.query('Branches');

      print("ProfileScreen: Raw branches from database11: $branchResults");

      if (branchResults.isNotEmpty) {
        print("dfdkjfdk");
        // Convert database results to the expected format
        final List<Map<String, dynamic>> formattedBranches =
            branchResults.map((branch) {
          return {
            'id': branch['id'],
            "userId": branch['userId'],
            'name': branch['branchName'] ?? 'Unnamed Branch',
            'branchCode': branch['branchCode'] ?? '',
            'companyName': branch['companyName'] ??
                branch['branchName'] ??
                'Unnamed Branch',
          };
        }).toList();

        print("ProfileScreen: Formatted branchess: $formattedBranches");

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
