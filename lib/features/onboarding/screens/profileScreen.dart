// ignore_for_file: constant_identifier_names, use_build_context_synchronously, non_constant_identifier_names, use_super_parameters, library_private_types_in_public_api
import 'dart:convert';
import 'package:coopengageplus/Screen/LoginScreen.dart';
import 'package:coopengageplus/common_widgets/text/custom_nav_heading.dart';
import 'package:coopengageplus/features/onboarding/pages/help.dart';
import 'package:coopengageplus/features/onboarding/pages/language.dart';
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

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );
  String username = "";
  String firstLetter = "";
  String role = '';

  bool isLoading = true;
  // final branches = GlobalData().branches;
  List<Map<String, dynamic>>? branches;
  String? mainBranchCode;
  String? mainBranchCompanyName;
  int? mainBranchId;

  Map<String, dynamic>? selectedBranch;
  int? UserID;
  String? token;

  @override
  void initState() {
    super.initState();
    GlobalData().fetchToken();
    UserID = GlobalData().userId;
    _fetchToken();
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
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.transparent, // Set background to white
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.black,
                        child: Text(
                          firstLetter,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              role,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
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
                                  if (mainBranchCompanyName != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$mainBranchCompanyName',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    const Text("No main branch available"),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Other Branch Names:',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  if (branches != null && branches!.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: branches!.map((branch) {
                                        return Text(
                                          branch['companyName'] ??
                                              "Unnamed Branch",
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black),
                                        );
                                      }).toList(),
                                    )
                                  else
                                    const Text("No branches available"),
                                ],
                              ),
                            ),
                          ])
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          Colors.black, // Change settings title color to black
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.blue),
                  title: const Text("About"),
                  onTap: () {
                    // Navigate to About Page
                  },
                ),
                // const Divider(),
                // ListTile(
                //   leading: const Icon(Icons.language, color: Colors.blue),
                //   title: const Text("language"),
                //   onTap: () {
                //     Navigator.pushAndRemoveUntil(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => const ChangeLanguagePage()),
                //       (route) => false,
                //     );
                //   },
                // ),
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
                    // Navigate to Help Page
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
              ]));
  }

  void logout() async {
    setState(() {
      isLoading = true;
    });

    await storage.delete(key: "token");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Loginscreen()),
      (route) => false,
    );

    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }

  Future<void> _fetchToken() async {
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      // Decode the token to get user details
      var decodedToken = JwtDecoder.decode(token);
      setState(() {
        username = decodedToken['sub'] ?? "User"; // Set username
        firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '';

        role = decodedToken['role'][0];
        // branchs = List<Map<String, dynamic>>.from(decodedToken["branch"]);
        // print(branchs);
        // UserID = decodedToken["userId"];
        // Decode branches if available in the token

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

        isLoading = false; // Set loading to false
      });
    } else {
      setState(() {
        isLoading = false; // Set loading to false if no token found
      });
    }
  }
}
