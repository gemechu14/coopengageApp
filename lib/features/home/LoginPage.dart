// ignore_for_file: sized_box_for_whitespace, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:coopengageplus/core/database/database_helper.dart';
import 'package:coopengageplus/core/network/network_handler.dart';
import 'package:coopengageplus/features/home/main_page.dart';
import 'package:flutter/material.dart';

import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../NetworkHandler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// Import your database helper here

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          colors: [Color.fromARGB(255, 20, 169, 75), Colors.red],
        )),
        child: Scaffold(
          body: ProgressHUD(
            key: UniqueKey(),
            inAsyncCall: isApiCallProcess,
            child: Form(
              key: globalFormKey,
              child: _loginUI(context),
            ),
          ),
        ),
      ),
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

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 70),
          Column(
            children: [
              Image.asset(
                "assets/engage.png",
                width: MediaQuery.of(context).size.width * 0.5,
                height: 150,
                fit: BoxFit.fill,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 30, right: 20),
            child: Text(
              "Coop Engage +",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: Color.fromARGB(255, 2, 107, 142)),
            ),
          ),
          const SizedBox(height: 10),

          // Username Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: SizedBox(
              width: width < 600
                  ? double.infinity
                  : width * 0.5, // Adjust width for tablet
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: "Username",
                  labelText: "Username",
                  labelStyle: TextStyle(fontSize: 20),
                  contentPadding: EdgeInsets.fromLTRB(20, 2, 2, 4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  prefixIcon: Icon(Icons.person), // Leading icon
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
                  labelText: "Password",
                  // fillColor: Colors.grey,
                  // filled: true,

                  suffixIcon: IconButton(
                    icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                  labelStyle: const TextStyle(fontSize: 20),
                  contentPadding: const EdgeInsets.fromLTRB(20, 2, 2, 4),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  prefixIcon: const Icon(Icons.lock), // Leading icon
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
              width: width < 600
                  ? double.infinity
                  : width * 0.5, // Adjust width for tablet
              child: FormHelper.submitButton("Login",
                  btnColor: Colors.blueAccent,
                  borderColor: Colors.blueAccent, () async {
                if (validateAndSave()) {
                  setState(() {
                    isApiCallProcess = true;
                  });

                  // Retrieve the text from the controllers
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
                          .post("/login", data)
                          .timeout(const Duration(seconds: 9));

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        Map<String, dynamic> output =
                            json.decode(response.body);
                        var data = await storage.write(
                            key: "token", value: output["access_token"]);
                        
                        // Decode token to extract user data
                        Map<String, dynamic> decodedToken = json.decode(
                            utf8.decode(base64Url.decode(base64Url.normalize(
                                output["access_token"].split(".")[1]))));

                        // Extract user information from token
                        // String username = decodedToken["sub"];
                        String? clientId = decodedToken["clientId"];
                        String role = decodedToken["role"][0];
                        int userId = decodedToken["userId"];
                        List<Map<String, dynamic>> branches =
                            List<Map<String, dynamic>>.from(
                                decodedToken["branch"]);

                        // Check if the user is already registered in local storage
                        DatabaseHelper dbHelper = DatabaseHelper();
                        bool userExists = await dbHelper.userExists(username);

                        if (!userExists) {
                          // Register the user locally
                          await dbHelper.insertUser1(
                            username: username,
                            password: password,
                            userId: userId,
                            clientId: clientId,
                            role: role,
                            branches: branches,
                          );
                        } else {}
                        setState(() {
                          validate = true;
                          circular = false;
                        });
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainPage(),
                            ),
                            (route) => false);
                      } else {
                        setState(() {
                          isApiCallProcess = false;
                          validate = false;
                          errorText = "Invalid Username or Password.";
                          circular = false;
                        });
                        FormHelper.showSimpleAlertDialog(
                          context,
                          "Customer Onboarding",
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
                        "Customer Onboarding",
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
                        "Customer Onboarding",
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
                            "Customer Onboarding",
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
                          "Customer Onboarding",
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
                          "Customer Onboarding",
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
                        "Customer Onboarding",
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

          const SizedBox(height: 20),

          // Sign Up option
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?",
                  style: TextStyle(color: Colors.black)),
              TextButton(
                onPressed: () {
                  // Navigate to the Sign Up page
                },
                child: const Text("Sign Up",
                    style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
          SizedBox(height: 5),

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
              onTap: () {},
              child: Container(
                width: width < 600 ? double.infinity : width * 0.5,
                height: 50,
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
                          'assets/logo.png',
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
    print("Connectivity Result: $connectivityResult"); // Debugging line

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      print("Hello from: $connectivityResult");
      return true; // The device is online
    }

    return false; // The device is offline
  }
}
