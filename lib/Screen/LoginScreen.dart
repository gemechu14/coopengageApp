// ignore_for_file: sized_box_for_whitespace, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/common_widgets/AlertDialog/dialog_helper.dart';
import 'package:coopengageplus/constants/config/config.dart';
// import 'package:coopengageplus/constants/config/environment_config.dart';
import 'package:coopengageplus/service/certificate_service.dart';
// import 'package:coopengageplus/features/crm/CRMMainScreen.dart';
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
                  decoration: const InputDecoration(
                    hintText: "Username",
                    labelStyle: TextStyle(fontSize: 20),
                    contentPadding: EdgeInsets.fromLTRB(20, 2, 2, 4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.red),
                    ),
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
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AgentRegistration(),
                        ),
                        (route) => false);
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.blue,
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
          obscureText: hidePassword,
          decoration: InputDecoration(
            hintText: "Password",
            suffixIcon: IconButton(
              icon:
                  Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
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

    // Test certificate loading before making the request
    try {
      print('=== Testing Certificate Loading ===');
      String currentEnv = await CertificateService.getCurrentEnvironment();
      print('Current environment: $currentEnv');

      // Test if we can create a secure client
      HttpClient testClient = await CertificateService.createSecureHttpClient(
          environment: currentEnv);
      print('✅ Certificate loaded successfully for $currentEnv environment');
    } catch (e) {
      print('❌ Certificate loading failed: $e');
      print('Falling back to development mode...');
    }

    try {
      if (await isOnline()) {
        NetworkHandler networkHandler = NetworkHandler();
        print("BASE URLddddsddsdsdsdsdsdsdsdssds");
        print(AppConstants.baseURL);
        // ONLINE LOGIN
        final response = await networkHandler
            .post('${AppConstants.baseURL}/login', data)
            .timeout(const Duration(seconds: 40));
        print(
            "statusCodestatusCodestatusCodestatusCodestatusCodestdddatusCode");
        print(response.statusCode);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final output = json.decode(response.body);
          final token = output["access_token"];
          print("output tokent t ");
          print(token);
          await storage.write(key: "token", value: token);

          // Call /api/v1/users/me to get user data
          final userResponse = await networkHandler
              .get('/api/v1/users/me')
              .timeout(const Duration(seconds: 70));
          print("dkfkdfhdkdkkfkdkdkdjkjdjkdjkdfjkkjfjkdfkjd");
          print(userResponse);

          // Check if response is a Response object or direct data
          Map<String, dynamic> userData;
          if (userResponse is http.Response) {
            // It's a Response object
            if (userResponse.statusCode == 200) {
              userData = json.decode(userResponse.body);
            } else {
              DialogHelper.show(
                context,
                title: "Coop Engage+",
                message:
                    "Failed to fetch user data. Status: ${userResponse.statusCode}",
                type: DialogType.error,
              );
              return;
            }
          } else if (userResponse is Map<String, dynamic>) {
            // It's direct data (already parsed)
            userData = userResponse;
          } else {
            // Try to handle as string and parse
            try {
              userData = json.decode(userResponse.toString());
            } catch (e) {
              DialogHelper.show(
                context,
                title: "Coop Engage+",
                message: "Invalid user data format received.",
                type: DialogType.error,
              );
              return;
            }
          }

          final userId = userData["userId"];
          final role = userData["role"] ?? '';
          final clientId = userData["client"]["id"]?.toString();
          final fullName = userData["fullName"] ?? '';
          final email = userData["email"] ?? '';
          final status = userData["status"] ?? '';
          final lastLoggedIn = userData["lastLoggedIn"] ?? '';
          final registeredAt = userData["registeredAt"] ?? '';
          final updatedAt = userData["updatedAt"] ?? '';

          // Extract client data
          final clientData = userData["client"] ?? {};
          final clientName = clientData["name"] ?? '';
          final clientDescription = clientData["description"] ?? '';

          // Extract branches data
          final branches =
              List<Map<String, dynamic>>.from(userData["branches"] ?? []);

          // Extract main branch data
          final mainBranch = userData["mainBranch"] ?? {};
          final mainBranchId = mainBranch["id"];
          final mainBranchName = mainBranch["name"] ?? '';
          final mainBranchCode = mainBranch["branchCode"] ?? '';

          bool userExists = await dbHelper.userExists(username);
          await dbHelper.insertToken(token);

          if (!userExists) {
            await dbHelper.insertUser1(
              username: username,
              password: password,
              userId: userId,
              clientId: clientId,
              token: token,
              role: role,
              branches: branches,
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
          } else {
            // Update existing user with new data
            await dbHelper.updateUser(
              username: username,
              userId: userId,
              clientId: clientId,
              token: token,
              role: role,
              branches: branches,
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

          // SYNC ACCOUNT TYPES
          final accountTypesResponse =
              await networkHandler.get('/api/v1/account-types');

          if (accountTypesResponse is List<dynamic>) {
            int localCount = await dbHelper.getAccountTypeCount();
            int incomingCount = accountTypesResponse.length;

            var localdata = await dbHelper.getAllAccountTypes();
            print("local account types");
            print(localdata);

            if (localCount < incomingCount) {
              await dbHelper.clearAccountTypesTable();
              final typesToSave = accountTypesResponse.map((e) {
                return {
                  "id": e["id"].toString(),
                  "name": e["name"] ?? "",
                  "description": e["description"] ?? "",
                  "category": e["category"] ?? "",
                  "bankingType": e["bankingType"] ?? "",
                  "origin": e["origin"] ?? "",
                  "minAge": e["minAge"]?.toString() ?? "",
                  "maxAge": e["maxAge"]?.toString() ?? "",
                  "minAmount": e["minAmount"]?.toString() ?? "",
                  "sex": e["sex"] ?? "",
                  "status": e["status"] ?? "",
                  "code": e["code"].toString()
                };
              }).toList();

              await dbHelper.insertAccountTypes(typesToSave);
            }
          }

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
