// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/Screen/suuqpassLoginScreen.dart';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/features/crm/CRMMainScreen.dart';
import 'package:coopengageplus/features/onboarding/agent/agentRegistration.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';

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
          decoration: const BoxDecoration(
            
              ),
          child: ProgressHUD(
            key: UniqueKey(),
            inAsyncCall: isApiCallProcess,
            child: Form(
              key: globalFormKey,
              child: _loginUI(context),
            ),
          )),
    );
  }

  Widget _loginUI(BuildContext context) {
    NetworkHandler networkHandler = NetworkHandler();
    const storage = FlutterSecureStorage();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // _buildHeader(),
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
      // height: height - (MediaQuery.of(context).padding.top + 200),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Align at the top
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
            // Username Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                width: width < 600
                    ? double.infinity
                    : width * 0.5, // Adjust width for tablet
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Username",
                    // labelText: "Username",
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
                    // prefixIcon: Icon(Icons.person), // Leading icon
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                width: width < 600
                    ? double.infinity
                    : width * 0.5, // Adjust width for tablet
                child: TextFormField(
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    hintText: "Password",

                    suffixIcon: IconButton(
                      icon: Icon(hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
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
                    // prefixIcon: const Icon(Icons.lock), // Leading icon
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
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                width: width < 600 ? double.infinity : width * 0.5,
                child: FormHelper.submitButton("Login",
                    txtColor: Colors.white,
                    btnColor: Colors.blue,
                    // btnColor: const Color.fromARGB(255, 102, 163, 238),
                    borderColor: const Color.fromARGB(255, 102, 163, 238),
                    () async {
                  if (validateAndSave()) {
                    setState(() {
                      isApiCallProcess = true;
                    });

                    String username = _username.text.trim();
                    String password = _password.text.trim();

                    // Login Logic start here
                    Map<String, String> data = {
                      "username": username,
                      "password": password,
                    };

                    if (await isOnline()) {
                      try {
                        var response = await networkHandler
                            .post('${AppConstants.baseURL}/login', data)
                            .timeout(const Duration(seconds: 19));

                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          Map<String, dynamic> output =
                              json.decode(response.body);
                          await storage.write(
                              key: "token", value: output["access_token"]);
                          Map<String, dynamic> decodedToken = json.decode(
                              utf8.decode(base64Url.decode(base64Url.normalize(
                                  output["access_token"].split(".")[1]))));
                          String? token = output["access_token"];
                          String? clientId =
                              decodedToken["clientId"].toString();
                          String role = decodedToken["role"][0];
                          int userId = decodedToken["userId"];
                          List<Map<String, dynamic>> branches =
                              List<Map<String, dynamic>>.from(
                                  decodedToken["branch"]);

                          DatabaseHelper dbHelper = DatabaseHelper();
                          bool userExists = await dbHelper.userExists(username);
                          await dbHelper.insertToken(token!);
// await dbHelper ensureLanguageSet();
                          if (!userExists) {
                            // Register the user locally
                            await dbHelper.insertUser1(
                                username: username,
                                password: password,
                                userId: userId,
                                clientId: clientId,
                                role: role,
                                // token: token,
                                branches: branches);

                            print("User registered locally for future use.");
                          } else {
                            print("User already exists in local storage.");
                          }

                          /////////CHECK ACCOUNT TYPE
                      
                          bool isTableEmpty =
                              await dbHelper.isAccountTypeTableEmpty();
                          if (isTableEmpty) {
                            print(
                                "AccountTypes table is empty. Fetching account types from server...");
                            var accountTypesResponse = await networkHandler
                                .get('/api/v1/account-types?type=Saving');
                            print("datataa");

                            print(accountTypesResponse);
                            if (accountTypesResponse is List<dynamic>) {
                              print("Fetched account types successfully.");


                              List<Map<String, dynamic>> accountTypesToSave =
                                  accountTypesResponse.map((e) {
                                return {
                                  "id": e["id"],
                                  "name":
                                      e["name"], // Sanitize the 'name' field
                                  "type": e["type"],
                                  "minAge": e["minAge"] ?? "",
                                  "maxAge": e["maxAge"] ?? "",
                                  "minAmount": e["minAmount"] ?? "",
                                  "sex": e["sex"] ?? "",
                                  "bankingType": e["bankingType"],
                                };
                              }).toList();

                              await dbHelper
                                  .insertAccountTypes(accountTypesToSave);
                              print("Account types saved successfully.");
                            } else {
                              print(
                                  "Failed to fetch account types: ${accountTypesResponse.body}");
                            }
                          } else {
                            print("AccountTypes table already has data.");
                          }

                          ///

                          setState(() {
                            validate = true;
                            circular = false;
                          });

                          List<dynamic> roles = decodedToken['role'] ?? [];

                          if (roles.contains("CRM")) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CRMMainScreen(),
                                ),
                                (route) => false);
                          } else {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainPage(),
                                ),
                                (route) => false);
                          }
                        } else {
                          setState(() {
                            isApiCallProcess = false;
                            validate = false;
                            errorText = "Invalid Username or Password.";
                            circular = false;
                          });
                          FormHelper.showSimpleAlertDialog(
                            context,
                            "Coop Engage+",
                            errorText,
                            "OK",
                            () {
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      } on TimeoutException catch (_) {
                        setState(() {
                          isApiCallProcess = false;
                          validate = false;
                          errorText = "Request timed out. Please try again.";
                          circular = false;
                        });
                        FormHelper.showSimpleAlertDialog(
                          context,
                          "Coop Engage+",
                          errorText,
                          "OK",
                          () {
                            Navigator.of(context).pop();
                          },
                        );
                      } catch (e) {
                        setState(() {
                          isApiCallProcess = false;
                          validate = false;
                          errorText = "An error occurred. Please try again.";
                          circular = false;
                        });
                        FormHelper.showSimpleAlertDialog(
                          context,
                          "Coop Engage+",
                          errorText,
                          "OK",
                          () {
                            Navigator.of(context).pop();
                          },
                        );
                      }
                    } else {
                      // Offline Login
                      DatabaseHelper dbHelper = DatabaseHelper();
                      bool userExists = await dbHelper.userExists(username);

                      if (userExists) {
                        // User is offline, retrieve credentials and log in locally
                        try {
                          List<Map<String, dynamic>> users = await dbHelper
                              .getUsers()
                              .timeout(const Duration(seconds: 4));

                          bool loginSuccessful = false;

                          // Check if the user exists in the local users list
                          for (var user in users) {
                            if (user['username'] == username &&
                                user['password'] == password) {
                              loginSuccessful = true;
                              break;
                            }
                          }

                          if (loginSuccessful) {
                            // Navigate to the main page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainPage()),
                            );
                          } else {
                            setState(() {
                              isApiCallProcess = false;
                              errorText = "Invalid Username or Password.";
                            });
                            FormHelper.showSimpleAlertDialog(
                              context,
                              "Coop Engage+",
                              errorText,
                              "OK",
                              () {
                                Navigator.of(context).pop();
                              },
                            );
                          }
                        } on TimeoutException catch (_) {
                          setState(() {
                            isApiCallProcess = false;
                            errorText =
                                "Request timed out while accessing local storage.";
                          });
                          FormHelper.showSimpleAlertDialog(
                            context,
                            "Coop Engage+",
                            errorText,
                            "OK",
                            () {
                              Navigator.of(context).pop();
                            },
                          );
                        } catch (e) {
                          setState(() {
                            isApiCallProcess = false;
                            errorText =
                                "An error occurred while accessing local storage: $e";
                          });
                          FormHelper.showSimpleAlertDialog(
                            context,
                            "Coop Engage+",
                            errorText,
                            "OK",
                            () {
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      } else {
                        setState(() {
                          isApiCallProcess = false;
                          errorText =
                              "User is offline and does not exist in local storage.";
                        });
                        FormHelper.showSimpleAlertDialog(
                          context,
                          "Coop Engage+",
                          errorText,
                          "OK",
                          () {
                            Navigator.of(context).pop();
                          },
                        );
                      }
                    }
                  }
                }),
              ),
            ),
            const SizedBox(height: 5),

            // Sign Up option
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
            // Divider and Sign in with Google
            // "or sign in with" Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                width: width < 600 ? double.infinity : width * 0.5,
                child: const Row(
                  children: [
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SuuqPassLoginscreen(),
                      ),
                      (route) => false);
                },
                child: Container(
                  width: width < 600
                      ? double.infinity
                      : width * 0.5, // Match login button width
                  height: 50, // Match login button height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0), // Adjust space from left
                        child: Container(
                          height: 30, // Set a fixed height for the image
                          width: 30, // Set a fixed width for the image
                          child: Image.asset(
                            'assets/coop_engage.png',
                            fit: BoxFit
                                .contain, // Make the image fit the container
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Sign In with Suuq-Pass",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // const SizedBox(height: 30),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/coop_engage.png',
              width: 300,
              height: 290,
              // color: Colors.white,
              fit: BoxFit.fill,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 5, left: 20, bottom: 30, right: 20),
            child: Text(
              "Coop Engage+",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
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
    print("Connectivity Result: $connectivityResult");

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      print("Hello from: $connectivityResult");
      return true;
    }

    return false;
  }

  String sanitizeInput(String input) {
    return input
        .replaceAll("'", "&#39;") // Escape single quote
        .replaceAll('"', "&quot;") // Escape double quote
        .replaceAll('<', "&lt;") // Escape less than symbol
        .replaceAll('>', "&gt;"); // Escape greater than symbol
  }
}
