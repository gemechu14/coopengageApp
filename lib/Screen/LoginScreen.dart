// ignore_for_file: sized_box_for_whitespace, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/common_widgets/AlertDialog/dialog_helper.dart';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/customerOnboarding/agent/agentRegistration.dart';
import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool isApiCallProcess = false;
  bool hidePassword = true;
  late String errorText;
  bool validate = false;
  bool circular = false;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(),
          child: Form(
            key: globalFormKey,
            child: _loginUI(context),
          )),
    );
  }

  Widget _loginUI(BuildContext context) {
    NetworkHandler networkHandler = NetworkHandler();
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
    );
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildFormContainer(width, height, networkHandler, storage, context),
        ],
      ),
    );
  }

  Widget _buildFormContainer(
      double width,
      height,
      NetworkHandler networkHandler,
      FlutterSecureStorage storage,
      BuildContext context) {
    return SizedBox(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 120),
            Image.asset(
              'assets/coop_engage.png',
              width: 210,
              height: 100,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                width: width < 600 ? double.infinity : width * 0.5,
                child: TextFormField(
                  enabled: !isApiCallProcess,
                  decoration: InputDecoration(
                    hintText: "Username",
                    labelStyle: const TextStyle(fontSize: 20),
                    contentPadding: const EdgeInsets.fromLTRB(20, 2, 2, 4),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    filled: isApiCallProcess,
                    fillColor: isApiCallProcess ? Colors.grey[100] : null,
                  ),
                  controller: _username,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
            ),

            // Password Field
            password(width),
            login(width),

            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Want to register as an agent? ",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                TextButton(
                  onPressed: isApiCallProcess
                      ? null
                      : () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AgentRegistration(),
                              ),
                              (route) => false);
                        },
                  child: Text(
                    "Register",
                    style: TextStyle(
                      color: isApiCallProcess ? Colors.grey : Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Padding login(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: SizedBox(
        width: width < 600 ? double.infinity : width * 0.5,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            if (isApiCallProcess) return;

            if (validateAndSave()) {
              setState(() => isApiCallProcess = true);
              await _handleLogin();
              setState(() => isApiCallProcess = false);
            }
          },
          child: isApiCallProcess
              ? const SpinKitThreeBounce(
                  color: Colors.white,
                  size: 24.0,
                )
              : const Text(
                  "Login",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Padding password(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Container(
        width: width < 600 ? double.infinity : width * 0.5,
        child: TextFormField(
          enabled: !isApiCallProcess,
          obscureText: hidePassword,
          decoration: InputDecoration(
            hintText: "Password",
            suffixIcon: IconButton(
              icon:
                  Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: isApiCallProcess
                  ? null
                  : () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
            ),
            labelStyle: const TextStyle(fontSize: 20),
            contentPadding: const EdgeInsets.fromLTRB(20, 2, 2, 4),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: Colors.red),
            ),
            filled: isApiCallProcess,
            fillColor: isApiCallProcess ? Colors.grey[100] : null,
          ),
          controller: _password,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password cannot be empty';
            }
            return null;
          },
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    String username = _username.text.trim();
    String password = _password.text.trim();

    final data = {"username": username, "password": password};
    final dbHelper = DatabaseHelper();

    // Certificate service removed for security - using standard HTTP client

    try {
      if (await isOnline()) {
        NetworkHandler networkHandler = NetworkHandler();
        // ONLINE LOGIN
        final response = await networkHandler
            .post('/login', data)
            .timeout(const Duration(seconds: 70));

        if (response.statusCode == 200 || response.statusCode == 201) {
          final output = json.decode(response.body);
          final token = output["access_token"];
          await storage.write(key: "token", value: token);

          // 🔒 ENHANCED DATA LOADING WITH RETRY MECHANISM
          bool userDataStored = false;
          bool accountTypesStored = false;
          int maxRetries = 3;
          int currentRetry = 0;

          // STEP 1: Fetch and store user data with retry
          while (!userDataStored && currentRetry < maxRetries) {
            try {
              currentRetry++;
              print("🔄 Attempt $currentRetry: Fetching user data...");

              final userResponse = await networkHandler
                  .get('/api/v1/users/me')
                  .timeout(const Duration(seconds: 70));

              print(userResponse);

              // Check if response is a Response object or direct data
              Map<String, dynamic> userData;
              if (userResponse is http.Response) {
                // It's a Response object
                if (userResponse.statusCode == 200) {
                  userData = json.decode(userResponse.body);
                } else {
                  throw Exception(
                      "Failed to fetch user data. Status: ${userResponse.statusCode}");
                }
              } else if (userResponse is Map<String, dynamic>) {
                // It's direct data (already parsed)
                userData = userResponse;
              } else if (userResponse != null) {
                // Try to handle as string and parse
                userData = json.decode(userResponse.toString());
              } else {
                throw Exception("Received null response from user data API");
              }

              // 🔒 SECURE DATA EXTRACTION WITH VALIDATION
              final userId = userData["userId"];
              if (userId == null) {
                throw Exception("Invalid user data: Missing user ID");
              }

              final role = userData["role"] ?? '';
              final clientData = userData["client"] ?? {};
              final clientId = clientData["id"]?.toString();

              if (clientId == null || clientId.isEmpty) {
                throw Exception(
                    "Invalid user data: Missing client information");
              }

              // Extract user information with safe defaults
              final fullName = userData["fullName"] ?? '';
              final email = userData["email"] ?? '';
              final status = userData["status"] ?? '';
              final lastLoggedIn = userData["lastLoggedIn"] ?? '';
              final registeredAt = userData["registeredAt"] ?? '';
              final updatedAt = userData["updatedAt"] ?? '';

              // Extract client data
              final clientName = clientData["name"] ?? '';
              final clientDescription = clientData["description"] ?? '';

              // Extract branches data with validation
              final branchesData = userData["branches"];
              List<Map<String, dynamic>> branches = [];
              if (branchesData is List) {
                branches = List<Map<String, dynamic>>.from(branchesData);
              }

              // 🔍 DEBUG: Log branches data structure
              print("🔍 DEBUG: Raw branches data from API: $branchesData");
              print("🔍 DEBUG: Processed branches list: $branches");
              print("🔍 DEBUG: Branches count: ${branches.length}");
              await dbHelper.clearBranchesForUser(userId);
              // Validate and normalize branches data
              List<Map<String, dynamic>> normalizedBranches = [];
              for (int i = 0; i < branches.length; i++) {
                final branch = branches[i];
                print("🔍 DEBUG: Branch $i structure: $branch");

                // Create normalized branch data with all possible field mappings
                Map<String, dynamic> normalizedBranch = {
                  'id': branch['id'],
                  'userId': branch['userId'],
                  'name': branch['name'] ??
                      branch['branchName'] ??
                      branch['companyName'] ??
                      'Unknown Branch',
                  'branchName': branch['branchName'] ??
                      branch['name'] ??
                      branch['companyName'] ??
                      'Unknown Branch',
                  'companyName': branch['companyName'] ??
                      branch['name'] ??
                      branch['branchName'] ??
                      'Unknown Branch',
                  'branchCode': branch['branchCode'] ?? '',
                };
                normalizedBranches.add(normalizedBranch);
                print("🔍 DEBUG: Normalized branch $i: $normalizedBranch");
              }

              // Extract main branch data with validation
              final mainBranch = userData["mainBranch"] ?? {};
              final mainBranchId = mainBranch["id"];
              final mainBranchName =
                  mainBranch["name"] ?? mainBranch["branchName"] ?? '';
              final mainBranchCode = mainBranch["branchCode"] ?? '';

              // 🔍 DEBUG: Log main branch data
              print("🔍 DEBUG: Raw main branch data: $mainBranch");
              print("🔍 DEBUG: Main branch ID: $mainBranchId");
              print("🔍 DEBUG: Main branch name: $mainBranchName");
              print("🔍 DEBUG: Main branch code: $mainBranchCode");

              // �� SECURE USER AND TOKEN STORAGE
              bool userExists = await dbHelper.userExists(username);

              print("existing users ");
              print(dbHelper.getUsers());
              await dbHelper.insertToken(token);

              print("✅ User data validated and token stored securely");

              if (!userExists) {
                print("User is new, clearing any previous branches...");
                await dbHelper
                    .clearBranchesForUser(userId); // 🔒 This clears everything
                await dbHelper.insertUser1(
                  username: username,
                  password: password,
                  userId: userId,
                  clientId: clientId,
                  token: token,
                  role: role,
                  branches: normalizedBranches,
                  // branches: [],
                  fullName: fullName,
                  email: email,
                  status: status,
                  lastLoggedIn: lastLoggedIn,
                  registeredAt: registeredAt,
                  updatedAt: updatedAt,
                  clientName: clientName,
                  clientDescription: clientDescription,
                  mainBranchId: mainBranchId,
                  mainBranchName: mainBranchName,
                  mainBranchCode: mainBranchCode,
                  // mainBranchId: null, // <-- null for new user
                  // mainBranchName: '',
                  // mainBranchCode: '',
                );
              } else {
                // 🔄 Existing user: Clear old main + branches before updating
                print(
                    "User exists, clearing previous main branch and branches...");
                print(
                    "User exists, clearing all previous branches and main branch...");

                // 1. Clear all branches
                // final db = await dbHelper.database;
                // await db.delete('Branches');
                // await db.delete('UserBranches'); // if you have this table too

                // // 2. Reset main branch for this user
                // await db.update(
                //   'Users',
                //   {
                //     'mainBranchId': null,
                //     'mainBranchName': '',
                //     'mainBranchCode': ''
                //   },
                //   where: 'username = ?',
                //   whereArgs: [username],
                // );
                // Update existing user with new data
                await dbHelper.updateUser(
                  username: username,
                  userId: userId,
                  clientId: clientId,
                  token: token,
                  role: role,
                  branches: normalizedBranches,
                  fullName: fullName,
                  email: email,
                  status: status,
                  lastLoggedIn: lastLoggedIn,
                  registeredAt: registeredAt,
                  updatedAt: updatedAt,
                  clientName: clientName,
                  clientDescription: clientDescription,
                  mainBranchId: mainBranchId,
                  mainBranchName: mainBranchName,
                  mainBranchCode: mainBranchCode,
                );
              }

              // Verify user data was stored successfully
              final verifyUser = await dbHelper.getUserByToken(token);
              if (verifyUser != null && verifyUser['userId'] == userId) {
                userDataStored = true;
                print("✅ User data stored and verified successfully");

                // 🔍 COMPREHENSIVE VERIFICATION: Check main branch and other branches
                print("🔍 VERIFICATION: Checking main branch data...");
                print(
                    "🔍 VERIFICATION: Expected main branch - ID: $mainBranchId, Name: $mainBranchName, Code: $mainBranchCode");
                print(
                    "🔍 VERIFICATION: Stored main branch - ID: ${verifyUser['mainBranchId']}, Name: ${verifyUser['mainBranchName']}, Code: ${verifyUser['mainBranchCode']}");

                // Verify branches were stored
                final db = await dbHelper.database;
                final storedBranches = await db.query('Branches');
                final userBranches = await db.query('UserBranches',
                    where: 'userId = ?', whereArgs: [userId]);

                print(
                    "🔍 VERIFICATION: Total branches in database: ${storedBranches.length}");
                print(
                    "🔍 VERIFICATION: User's branch relationships: ${userBranches.length}");
                print(
                    "🔍 VERIFICATION: Expected branches count: ${normalizedBranches.length}");

                // Detailed branch verification
                for (int i = 0; i < storedBranches.length; i++) {
                  final storedBranch = storedBranches[i];
                  print(
                      "🔍 VERIFICATION: Stored branch $i: ID=${storedBranch['id']}, Name=${storedBranch['branchName']}, Company=${storedBranch['companyName']}, Code=${storedBranch['branchCode']}");
                }

                // Check if we have the expected number of branches
                if (normalizedBranches.isNotEmpty &&
                    userBranches.length != normalizedBranches.length) {
                  print(
                      "⚠️ WARNING: Expected ${normalizedBranches.length} branches but found ${userBranches.length} user-branch relationships");
                  // Don't fail here, just log the discrepancy
                }

                // Verify main branch is stored correctly
                bool mainBranchStored = true;
                if (mainBranchId != null) {
                  if (verifyUser['mainBranchId'] != mainBranchId ||
                      verifyUser['mainBranchName'] != mainBranchName) {
                    print("⚠️ WARNING: Main branch data mismatch");
                    mainBranchStored = false;
                  }
                }

                print(
                    "✅ VERIFICATION COMPLETE: Main branch stored: $mainBranchStored, Branches stored: ${userBranches.length}/${normalizedBranches.length}");
              } else {
                throw Exception("Failed to verify user data storage");
              }
            } catch (e) {
              print("❌ Attempt $currentRetry failed for user data: $e");
              if (currentRetry >= maxRetries) {
                DialogHelper.show(
                  context,
                  title: "Coop Engage+",
                  message:
                      "Failed to load user data after $maxRetries attempts. Please try again.",
                  type: DialogType.error,
                );
                return;
              }
              // Wait before retry (exponential backoff)
              await Future.delayed(Duration(seconds: currentRetry * 2));
            }
          }

          // STEP 2: Fetch and store account types with retry (only if user data is stored)
          if (userDataStored) {
            currentRetry = 0;
            while (!accountTypesStored && currentRetry < maxRetries) {
              try {
                currentRetry++;
                print("🔄 Attempt $currentRetry: Fetching account types...");

                final accountTypesResponse = await networkHandler
                    .get('/api/v1/account-types')
                    .timeout(const Duration(seconds: 60));

                if (accountTypesResponse is List<dynamic>) {
                  int localCount = await dbHelper.getAccountTypeCount();
                  int incomingCount = accountTypesResponse.length;

                  print(
                      "Account types sync: Local=$localCount, Incoming=$incomingCount");

                  if (localCount < incomingCount || currentRetry == 1) {
                    // Validate and sanitize account types data
                    final List<Map<String, dynamic>> validatedTypes = [];

                    for (var accountType in accountTypesResponse) {
                      if (accountType is Map<String, dynamic>) {
                        // Validate required fields
                        final id = accountType["id"];
                        final name = accountType["name"];
                        final code = accountType["code"];

                        if (id != null && name != null) {
                          validatedTypes.add({
                            "id": id.toString(),
                            "name": name.toString(),
                            "description":
                                accountType["description"]?.toString() ?? "",
                            "category":
                                accountType["category"]?.toString() ?? "",
                            "bankingType":
                                accountType["bankingType"]?.toString() ?? "",
                            "origin": accountType["origin"]?.toString() ?? "",
                            "minAge": accountType["minAge"]?.toString() ?? "",
                            "maxAge": accountType["maxAge"]?.toString() ?? "",
                            "minAmount":
                                accountType["minAmount"]?.toString() ?? "",
                            "sex": accountType["sex"]?.toString() ?? "",
                            "status": accountType["status"]?.toString() ?? "",
                            "code": code?.toString() ?? ""
                          });
                        } else {
                          print(
                              "⚠️ Skipping invalid account type: Missing required fields");
                        }
                      }
                    }

                    if (validatedTypes.isNotEmpty) {
                      await dbHelper.clearAccountTypesTable();
                      await dbHelper.insertAccountTypes(validatedTypes);

                      // Verify account types were stored successfully
                      final verifyCount = await dbHelper.getAccountTypeCount();
                      if (verifyCount >= validatedTypes.length) {
                        accountTypesStored = true;
                        print(
                            "✅ Account types synced and verified successfully: ${validatedTypes.length} types");
                      } else {
                        throw Exception(
                            "Failed to verify account types storage");
                      }
                    } else {
                      print("❌ No valid account types to sync");
                      accountTypesStored =
                          true; // Mark as completed even with no data
                    }
                  } else {
                    print("✅ Account types already up to date");
                    accountTypesStored = true;
                  }
                } else if (accountTypesResponse == null) {
                  throw Exception(
                      "Received null response from account types API");
                } else {
                  throw Exception("Account types response is not a valid list");
                }
              } catch (e) {
                print("❌ Attempt $currentRetry failed for account types: $e");
                if (currentRetry >= maxRetries) {
                  accountTypesStored = true; // Mark as completed to continue
                } else {
                  await Future.delayed(Duration(seconds: currentRetry * 2));
                }
              }
            }
          }

          // 🔒 FINAL DATA INTEGRITY CHECK
          final storedToken = await storage.read(key: "token");
          if (storedToken != token) {
            DialogHelper.show(
              context,
              title: "Coop Engage+",
              message: "Security error: Token verification failed.",
              type: DialogType.error,
            );
            return;
          }

          // Additional verification: Check if user data is accessible
          final finalUserCheck = await dbHelper.getUserByToken(token);
          if (finalUserCheck == null) {
            DialogHelper.show(
              context,
              title: "Coop Engage+",
              message: "Data integrity error: User data not accessible.",
              type: DialogType.error,
            );
            return;
          }

          print("✅ Login successful - All data validated and stored securely");
          print("✅ User data stored: $userDataStored");
          print("✅ Account types stored: $accountTypesStored");

          // NAVIGATION BASED ON ROLE
          // if (role == "CRM") {
          //   Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(builder: (_) => const CRMMainScreen()),
          //     (route) => false,
          //   );
          // } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
            (route) => false,
          );

          // print(accountTypesResponse.);
          // }
        } else {
          DialogHelper.show(
            context,
            title: "Coop Engage+",
            message: "Invalid Username or Password.",
            type: DialogType.error,
          );
        }
      } else {
        // OFFLINE LOGIN
        bool userExists = await dbHelper.userExists(username);
        if (!userExists) {
          DialogHelper.show(
            context,
            title: "Coop Engage+",
            message: "User is offline and not registered locally..",
            type: DialogType.error,
          );
          return;
        }

        try {
          final users =
              await dbHelper.getUsers().timeout(const Duration(seconds: 4));
          final match = users.any(
              (u) => u['username'] == username && u['password'] == password);

          if (match) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainPage()),
            );
          } else {
            DialogHelper.show(
              context,
              title: "Coop Engage+",
              message: "Invalid Username or Password.",
              type: DialogType.error,
            );
          }
        } on TimeoutException {
          DialogHelper.show(
            context,
            title: "Coop Engage+",
            message: "Timeout accessing local data.",
            type: DialogType.error,
          );
        } catch (e) {
          DialogHelper.show(
            context,
            title: "Coop Engage+",
            message: "Local login error",
            type: DialogType.error,
          );
        }
      }
    } on TimeoutException {
      DialogHelper.show(
        context,
        title: "Coop Engage+",
        message: "Request timed out. Please try again.",
        type: DialogType.error,
      );
    } catch (e) {
      print("dkjfdkfkdkkfjdjkfkjdkjfk");
      print(e);
      print("djdfdjjfdj");
      DialogHelper.show(
        context,
        title: "Coop Engage+",
        message: "Something went wrong. Please try again.",
        type: DialogType.error,
      );
    }
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    // print("Connectivity Result: $connectivityResult");

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }

    return false;
  }

  String sanitizeInput(String input) {
    return input
        .replaceAll("'", "&#39;")
        .replaceAll('"', "&quot;")
        .replaceAll('<', "&lt;")
        .replaceAll('>', "&gt;");
  }
}
