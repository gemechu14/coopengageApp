// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/Screen/LoginScreen.dart';
import 'package:coopengageplus/helper/databaseHelper.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';

class SuuqPassLoginscreen extends StatefulWidget {
  const SuuqPassLoginscreen({super.key});

  @override
  State<SuuqPassLoginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<SuuqPassLoginscreen> {
  @override
  void initState() {
    super.initState();
    loadBranches();
  }

  bool isApiCallProcess = false;
  bool hidePassword = true;
  late String errorText;
  bool validate = false;
  bool circular = false;
  Set<String> selectedBranches = {};
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController branchController = TextEditingController();

  List<String> _selectedItems = [];
  List<String> branches = []; // Stores all branches loaded from JSON
  List<String> filteredBranches =
      []; // Stores branches filtered by search query

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const Loginscreen(),
            ),
            (route) => false);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.blue,
                  Color.fromARGB(255, 185, 218, 245),
                ],
              ),
            ),
            child: ProgressHUD(
              key: UniqueKey(),
              inAsyncCall: isApiCallProcess,
              child: Form(
                key: globalFormKey,
                child: _loginUI(context),
              ),
            )),
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
    List<MultiSelectItem<String>> branchItems =
        branches.map((branch) => MultiSelectItem(branch, branch)).toList();
    return SizedBox(
      // height: height - (MediaQuery.of(context).padding.top + 200),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              // topLeft: Radius.circular(30),
              // topRight: Radius.circular(30),
              ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 120),
            Image.asset(
              'assets/coop_engage.png',
              width: 210,
              height: 100,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 30),
            userWidget(width),
            passwordWidget(width),
            // branchesWidget(branchItems, width),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
            ),
            loginWidget(width, networkHandler, storage, context),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Padding branchesWidget(
      List<MultiSelectItem<String>> branchItems, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Container(
        width: width < 600 ? double.infinity : width * 0.5,
        child: Column(
          children: [
            const SizedBox(height: 20),
            MultiSelectDialogField(
              items: branchItems,
              title: const Text("Branches"),
              selectedColor: Colors.blue,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              buttonIcon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.blue,
              ),
              buttonText: const Text(
                "Select Branches",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
              searchable: true,
              onConfirm: (values) {
                setState(() {
                  selectedBranches = values.toString() as Set<String>;
                });
                print("Selected Branches: $selectedBranches");
              },
            ),
          ],
        ),
      ),
    );
  }

  Padding userWidget(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Container(
        width: width < 600 ? double.infinity : width * 0.5,
        child: TextFormField(
          decoration: const InputDecoration(
            hintText: "Username",
            // labelText: "Username",
            labelStyle: TextStyle(fontSize: 20),
            contentPadding: EdgeInsets.fromLTRB(20, 2, 2, 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
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
    );
  }

  Padding loginWidget(double width, NetworkHandler networkHandler,
      FlutterSecureStorage storage, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Container(
        width: width < 600 ? double.infinity : width * 0.5,
        child: FormHelper.submitButton("Login",
            txtColor: Colors.white,
            btnColor: Colors.blue,
            borderColor: const Color.fromARGB(255, 102, 163, 238), () async {
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

                if (response.statusCode == 200 || response.statusCode == 201) {
                  Map<String, dynamic> output = json.decode(response.body);
                  await storage.write(
                      key: "token", value: output["access_token"]);
                  Map<String, dynamic> decodedToken = json.decode(utf8.decode(
                      base64Url.decode(base64Url
                          .normalize(output["access_token"].split(".")[1]))));

                  String? clientId = decodedToken["clientId"];
                  String role = decodedToken["role"][0];
                  int userId = decodedToken["userId"];
                  List<Map<String, dynamic>> branches =
                      List<Map<String, dynamic>>.from(decodedToken["branch"]);

                  // Check if the user is already registered in local storage
                  DatabaseHelper dbHelper = DatabaseHelper();
                  bool userExists = await dbHelper.userExists(username);

                  if (!userExists) {
                    // Register the user locally
                    await dbHelper.insertUser1(
                      username: username,
                      password:
                          password, // Note: Ideally, do not store plain text passwords
                      userId: userId,
                      clientId: clientId,
                      role: role,
                      branches: branches,
                    );
                    print("User registered locally for future use.");
                  } else {
                    print("User already exists in local storage.");
                  }
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
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainPage(),
                    ),
                    (route) => false);
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
              FormHelper.showSimpleAlertDialog(
                context,
                "Coop Engage+",
                "You are curruntly offline please try to connect to internet",
                "OK",
                () {
                  Navigator.of(context).pop();
                },
              );
            }
          }
        }),
      ),
    );
  }

  Padding passwordWidget(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Container(
        width: width < 600
            ? double.infinity
            : width * 0.5, // Adjust width for tablet
        child: TextFormField(
          obscureText: hidePassword,
          decoration: InputDecoration(
            hintText: "Password",
            // labelText: "Password",
            // fillColor: Colors.grey,
            // filled: true,

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
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
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
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/engage+.png',
              width: 180,
              height: 90,
              color: Colors.white,
              fit: BoxFit.contain,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 5, left: 20, bottom: 30, right: 20),
            child: Text(
              "Coop Engage+",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
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

  void _showMultiSelect() async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API
    final List<String> items = [
      'Flutter',
      'Node.js',
      'React Native',
      'Java',
      'Docker',
      'MySQL'
    ];
  }

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  } // this function is called when the Cancel button is pressed

  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  Future<void> loadBranches() async {
    final String response = await rootBundle.loadString('assets/branches.json');
    final Map<String, dynamic> data = json.decode(response);
    setState(() {
      branches = List<String>.from(data['branches']);
      filteredBranches = branches; // Initialize filtered list
      print('Loaded branches: ${branches.length}'); // Print length
      print('Branches: $branches'); // Print branches
    });
  }

// Modified filterBranches function
  void filterBranches(String query) {
    final filtered = branches.where((branch) {
      return branch.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredBranches = filtered;
    });
  }
  // void filterBranches(String query) {
  //   final filtered = branches.where((branch) {
  //     return branch.toLowerCase().contains(query.toLowerCase());
  //   }).toList();

  //   setState(() {
  //     filteredBranches = filtered;
  //   });
  // }
  void _showBranchSelector(BuildContext context) {
    // Temporary Set to hold selected branches
    Set<String> tempSelectedBranches = Set.from(selectedBranches);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Branches'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Field
                    TextField(
                      controller: branchController,
                      onChanged: (query) {
                        filterBranches(query);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Branch List with checkboxes
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredBranches.length,
                        itemBuilder: (context, index) {
                          final branch = filteredBranches[index];
                          return CheckboxListTile(
                            title: Text(branch),
                            value: tempSelectedBranches.contains(branch),
                            onChanged: (isChecked) {
                              // Ensure setState is called within StatefulBuilder
                              setState(() {
                                if (isChecked == true) {
                                  tempSelectedBranches.add(branch);
                                } else {
                                  tempSelectedBranches.remove(branch);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        // Set the main selectedBranches Set to the tempSelectedBranches
                        setState(() {
                          selectedBranches = Set.from(tempSelectedBranches);
                        });
                        Navigator.pop(context); // Close the dialog
                      },
                      child: const Text('Confirm Selection'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget branchWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showBranchSelector(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedBranches.isNotEmpty
                          ? selectedBranches.join(', ')
                          : 'Select Branches',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List of selected branches
          if (selectedBranches.isNotEmpty) ...[
            ...selectedBranches.toList().asMap().entries.map((entry) {
              int index = entry.key;
              String branch = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${index + 1}. $branch',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}
