// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/Screen/LoginScreen.dart';
import 'package:coopengageplus/common_widgets/textField/ConfirmPasswordTextField.dart';
import 'package:coopengageplus/common_widgets/textField/CustomTextFormField.dart';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:http/http.dart' as http;

class AgentRegistration extends StatefulWidget {
  const AgentRegistration({super.key});

  @override
  State<AgentRegistration> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<AgentRegistration> {
  @override
  void initState() {
    super.initState();
    fetchBranches();
    fetchMultipleBranches();
  }

  bool isLoading = true;
  bool isDialogLoading = false;
  Set<String> selectedBranches = {};
  List<MultiSelectItem<String>> branchItems = [];
  List<dynamic> branches = [];
  int? selectedBranchId;
  List<dynamic> filteredBranches = [];
  int? selectedBrancId;
  bool isApiCallProcess = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  final TextEditingController _password = TextEditingController();
  late TextEditingController _confirmPassword = TextEditingController();

// Function to toggle password visibility
  void togglePasswordVisibility(bool isPasswordField) {
    setState(() {
      if (isPasswordField) {
        hidePassword = !hidePassword;
      } else {
        hideConfirmPassword = !hideConfirmPassword;
      }
    });
  }

  late String errorText;
  bool validate = false;
  bool circular = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessTypeController = TextEditingController();
  TextEditingController businessAddressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController tinController = TextEditingController();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();

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
      child: Container(
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
        child: Scaffold(
          backgroundColor: Colors.white,
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
    const storage = FlutterSecureStorage();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 70),
          Image.asset(
            'assets/coop_engage.png',
            width: 210,
            height: 90,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            TextLabel("Full Name"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                width: width < 600 ? double.infinity : width * 0.5,
                child: CustomTextFormField(
                  hintText: "Enter Full Name",
                  controller: fullNameController,
                  errorMessage: "Full Name cannot be empty",

                  // leadingIcon: Icons.person,
                ),
              ),
            ),
            TextLabel("PhoneNumber"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                width: width < 600 ? double.infinity : width * 0.5,
                child: CustomTextFormField(
                  hintText: "Enter phonenumber or email",
                  controller: phoneNumberController,
                  errorMessage: "PhoneNumber empty",

                  // leadingIcon: Icons.person,
                ),
              ),
            ),
            TextLabel("Business Name"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                width: width < 600 ? double.infinity : width * 0.5,
                child: CustomTextFormField(
                  hintText: "Enter Business Name",
                  controller: businessNameController,
                  errorMessage: "Business Name empty",
                  isRequired: false,

                  // leadingIcon: Icons.person,
                ),
              ),
            ),
            TextLabel("TIN"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                width: width < 600 ? double.infinity : width * 0.5,
                child: CustomTextFormField(
                  hintText: "Enter TIN",
                  keyboardType: TextInputType.number,
                  controller: tinController,
                  errorMessage: "TIN cannot be empty",
                  isRequired: true,
                ),
              ),
            ),
            TextLabel("Password"),
            passwordWidget(width),
            TextLabel("Confirm Password"),
            ConfirmPasswordTextField(
              title: "Confirm Password",
              hint: "Re-enter your password",
              textEditingController: _confirmPassword,
              hidePassword: hideConfirmPassword,
              togglePasswordVisibility: _togglePasswordVisibility,
              passwordController: _password,
            ),
            TextLabel("Main Branch"),
            branchSelectorWidget(width),
            TextLabel("Additional Branches"),
            branchesWidget(width),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: Container(
                width: width < 600
                    ? double.infinity
                    : width * 0.5, // Adjust width for tablet
                child: FormHelper.submitButton("Submit",
                    btnColor: Colors.blue,
                    txtColor: Colors.white,
                    borderColor: Colors.blueAccent, () async {
                  if (validateAndSave()) {
                    setState(() {
                      isApiCallProcess = true;
                    });

                    // Retrieve the text from the controllers
                    String username = _username.text.trim();
                    String password = _password.text.trim();
                    print("Selected Branches: $selectedBranches");
                    // List<int> branchIdsList = selectedBranches
                    //     .map((branch) => int.parse(branch))
                    //     .toList();

                    // Convert the list to a List<String>
                    List<String> branchIdsList = selectedBranches.toList();
                    print("branchIdsList");
                    print(branchIdsList);
                    // Login Logic start here
                    // Declare the map to accept dynamic types
                    Map<String, dynamic> data = {
                      "fullName": fullNameController.text.toString(),
                      "phone": phoneNumberController.text.toString(),
                      "business_name": businessNameController.text.toString(),
                      "tin_number": tinController.text.toString(),

                      "branchIds":
                          branchIdsList, // Directly assign the List<String>
                      "mainBranchId": selectedBranchId.toString(),
                      "password": _password.text
                    };

                    print(data);
                    try {
                      var response = await networkHandler
                          .postAgent("/api/v1/agents", data)
                          .timeout(const Duration(seconds: 20));

                      print('response');
                      print("response.statusCode");
                      print(response);

                      print(response);
                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        setState(() {
                          validate = true;
                          circular = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Registered successfully ')),
                        );

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Loginscreen(),
                            ),
                            (route) => false);
                      } else {
                        var errorResponse = jsonDecode(response.body);
                        errorText = errorResponse['message'] ??
                            "Unable to register, please try later";
                        setState(() {
                          isApiCallProcess = false;
                          validate = false;
                          errorText = errorText;
                          circular = false;
                        });
                        FormHelper.showSimpleAlertDialog(
                          context,
                          "Coop Engage +",
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
                        "Coop Engage +",
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
                        "Coop Engage +",
                        errorText,
                        "OK",
                        () {
                          Navigator.of(context).pop();
                        },
                      );
                    }
                  }
                }),
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Padding branchSelectorWidget(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 1),
      child: Container(
          width: width < 600 ? double.infinity : width * 0.5,
          child: DropdownButtonFormField<int>(
              value: selectedBranchId,
              hint: const Text(
                "Select Branch",
                style: TextStyle(fontSize: 14),
              ),
              items: branches.map((branch) {
                return DropdownMenuItem<int>(
                  value: branch['id'],
                  child: Text(branch['companyName'],
                      style: TextStyle(fontSize: 14)),
                );
              }).toList(),
              isDense: true,
              onChanged: (value) {
                setState(() {
                  selectedBranchId = value;
                  print(selectedBranchId);
                });
              },
              validator: (value) {
                // Check if value is null or 0 (or whatever indicates no selection)
                if (value == null || value == 0) {
                  return 'Please select a branch';
                }
                return null; // Return null if valid
              },
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.red),
                ),
                // prefixIcon: Icon(Icons.business_center)),
              ))),
    );
  }

  Padding passwordWidget(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
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

  Padding branchesWidget(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Container(
        width: width < 600 ? double.infinity : width * 0.5,
        child: Column(
          children: [
            // const SizedBox(height: 20),
            MultiSelectDialogField(
              items: branchItems,
              title: const Text("Branches"),
              selectedColor: const Color.fromRGBO(33, 150, 243, 1),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey,
                  // width: 2,
                ),
              ),
              chipDisplay: MultiSelectChipDisplay(
                chipColor: Colors.blue[50],
                textStyle: const TextStyle(color: Colors.black),
              ),
              buttonIcon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              ),

              buttonText: const Text(
                "Select Branches",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              searchable: true, // Enables the search field
              onConfirm: (values) {
                setState(() {
                  selectedBranches =
                      values.toSet().cast<String>(); // Ensures the correct type
                });
                print("Selected Branches: $selectedBranches");
              },
            ),
          ],
        ),
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

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true; // The device is online
    }

    return false; // The device is offline
  }

  Padding TextLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 1),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> fetchBranches() async {
    const url = '${AppConstants.baseURL}/api/branches';
    // const url =
    //     'http://10.2.125.41:9060/api/branches'; // Replace with your actual URL
    try {
      // print(url);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          branches = data; // Store the fetched branches
        });
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (error) {
      print("Error fetching branches: $error");
    }
  }

  Future<void> fetchMultipleBranches() async {
    const url = '${AppConstants.baseURL}/api/branches';
    // const url =
    //     'http://10.2.125.41:9060/api/branches'; // Replace with your actual URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          branches = data; // Store the fetched branches
          // Map fetched branches to MultiSelectItems
          branchItems = branches.map((branch) {
            return MultiSelectItem<String>(
              branch['id'].toString(), // Use the ID as the unique identifier
              branch['companyName'], // Use the company name for display
            );
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (error) {
      print("Error fetching branches: $error");
      setState(() {
        isLoading = true;
      });
    }
  }

  // Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      hideConfirmPassword = !hideConfirmPassword;
    });
  }
}
