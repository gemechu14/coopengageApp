// ignore_for_file: constant_identifier_names

// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:coopengageplus/features/screens/LoginScreen.dart';
import 'package:coopengageplus/shared/services/GlobalData.dart';
import 'package:coopengageplus/core/utils/language_store.dart';
// import 'package:crm/helpers/databaseHelper.dart';
// import 'package:crm/pages/LoginPage.dart';

bool isConventionalSelected = true;

enum AccountType { DEPOSIT, FIXED_TIME_DEPOSIT, NON_REPATRIABLE_BIRR }

enum AlhudaAccountType {
  ECOLFL,
  DIASPORA_WADIA_SAVING,
  DIASPORA_MUDARABAH_SAVING,
  DIASPORA_MUDARABAH_FIXED_TIME
}

// List of account types based on selection
List<AccountType> conventionalAccounts = [
  AccountType.DEPOSIT,
  AccountType.FIXED_TIME_DEPOSIT,
  AccountType.NON_REPATRIABLE_BIRR,
];

List<AlhudaAccountType> alhudaAccounts = [
  AlhudaAccountType.ECOLFL,
  AlhudaAccountType.DIASPORA_WADIA_SAVING,
  AlhudaAccountType.DIASPORA_MUDARABAH_SAVING,
  AlhudaAccountType.DIASPORA_MUDARABAH_FIXED_TIME,
];
AccountType? selectedAccountType;
AlhudaAccountType? selectedAlhudaAccountType;
// Map to get the display text and description for each account type
Map<AccountType, String> accountTypeText = {
  AccountType.DEPOSIT: "Deposit Account",
  AccountType.FIXED_TIME_DEPOSIT: "Fixed Time Deposit Account",
  AccountType.NON_REPATRIABLE_BIRR: "Non-Repatriable Birr Account",
};

Map<AccountType, String> accountTypeDescription = {
  AccountType.DEPOSIT:
      "A basic savings account where you can deposit and withdraw money  Additional Details"
          "This account type is suitable for those who need to manage their savings effectively"
          "It offers features such as interest rates, transaction limits, and more.",
  AccountType.FIXED_TIME_DEPOSIT:
      "A savings account with a fixed interest rate and maturiAdditional Details:\n"
          "This account type is suitable for those who need to manage their savings effectively"
          "It offers features such as interest rates, transaction limits, and more.",
  AccountType.NON_REPATRIABLE_BIRR:
      "A savings account for foreign currency that cannot be repatriated.",
};

Map<AlhudaAccountType, String> alhudaAccountTypeText = {
  AlhudaAccountType.ECOLFL: "ECOLFL",
  AlhudaAccountType.DIASPORA_WADIA_SAVING: "Diaspora Wadia Saving Account",
  AlhudaAccountType.DIASPORA_MUDARABAH_SAVING:
      "Diaspora Mudarabah Saving Account",
  AlhudaAccountType.DIASPORA_MUDARABAH_FIXED_TIME:
      "Diaspora Mudarabah Fixed Time",
};

Map<AlhudaAccountType, String> alhudaAccountTypeDescription = {
  AlhudaAccountType.ECOLFL: "A special account for ECOLFL purposes.",
  AlhudaAccountType.DIASPORA_WADIA_SAVING:
      "A savings account for diaspora community with Wadia scheme.",
  AlhudaAccountType.DIASPORA_MUDARABAH_SAVING:
      "A savings account for diaspora community with Mudarabah scheme.",
  AlhudaAccountType.DIASPORA_MUDARABAH_FIXED_TIME:
      "A fixed-time savings account for diaspora community with Mudarabah scheme.",
};

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding),
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          translation(context).profile,
          style: TextStyle(
              fontSize: 21, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: logout,
          ),
        ],
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
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black, // Change text color to black
                            ),
                          ),
                          Text(
                            role,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black, // Change text color to black
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
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
                                            fontSize: 15, color: Colors.black),
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
                    color: Colors.black, // Change settings title color to black
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
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help, color: Colors.blue),
                title: const Text("Help"),
                onTap: () {
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
            ]),
      // bottomNavigationBar: GoogleButtomNavBar(showBottomNavBar: true),
    );
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
      print(decodedToken);
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
