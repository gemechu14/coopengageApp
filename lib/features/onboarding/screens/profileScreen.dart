// ignore_for_file: constant_identifier_names, use_build_context_synchronously, non_constant_identifier_names, use_super_parameters, library_private_types_in_public_api
import 'package:coopengageplus/Screen/LoginScreen.dart';
import 'package:coopengageplus/common_widgets/text/custom_nav_heading.dart';
import 'package:coopengageplus/features/onboarding/pages/help.dart';
import 'package:coopengageplus/service/GlobalData.dart';
import 'package:coopengageplus/utils/language_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
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
            children: List.generate(3, (index) => 
              Padding(
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
            color: Colors.grey[300]!.withOpacity(0.3 + (_animation.value * 0.4)),
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
            color: Colors.grey[300]!.withOpacity(0.3 + (_animation.value * 0.4)),
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
    if (token != null && token.isNotEmpty) {
      // Decode the token to get user details
      var decodedToken = JwtDecoder.decode(token);
      setState(() {
        username = decodedToken['sub'] ?? "User";
        firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '';
        role = decodedToken['role'][0];
        UserID = decodedToken['userId'];
        branches = decodedToken.containsKey("branch")
            ? List<Map<String, dynamic>>.from(decodedToken["branch"])
            : [];
        
        // Decode mainBranch if available in the token
        if (decodedToken.containsKey("mainBranch")) {
          mainBranchCode = decodedToken["mainBranch"]["branchCode"];
          mainBranchCompanyName = decodedToken["mainBranch"]["companyName"];
          mainBranchId = decodedToken["mainBranch"]["id"];
        }

        isProfileLoading = false;
        isBranchesLoading = false;
      });
    } else {
      setState(() {
        isProfileLoading = false;
        isBranchesLoading = false;
      });
    }
  }
}
