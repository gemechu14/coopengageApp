// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously, non_constant_identifier_names, sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/Screen/LoginScreen.dart';
import 'package:coopengageplus/common_widgets/textField/CustomTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';


import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:http/http.dart' as http;

import '../../../common_widgets/dropDown/DatePickerField.dart'; // For making API calls

class MarchentregistrationForm extends StatefulWidget {
  const MarchentregistrationForm({super.key});

  @override
  State<MarchentregistrationForm> createState() => _Marchentregistration();
}

class _Marchentregistration extends State<MarchentregistrationForm> {
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
  List<dynamic> branches = []; // Store the fetched branches
  int? selectedBranchId;
  List<dynamic> filteredBranches = [];
  int? selectedBrancId; // To hold the selected branch ID
  bool isApiCallProcess = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true; // For Confirm Password

// Function to toggle password visibility
  void togglePasswordVisibility(bool isPasswordField) {
    setState(() {
      if (isPasswordField) {
        hidePassword = !hidePassword; // Toggle Password visibility
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text(
              "Marchent Registration",
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                  color: Colors.blue),
            ),
          ),
          backgroundColor: Colors.white,
          body: ProgressHUD(
            key: UniqueKey(),
            inAsyncCall: isApiCallProcess,
            child: Form(
              key: globalFormKey,
              child: _registrationUI(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _registrationUI(BuildContext context) {
    NetworkHandler networkHandler = NetworkHandler();
    const storage = FlutterSecureStorage();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // const SizedBox(height: 70),

          // Image.asset(
          //   'assets/coop_engage.png',
          //   width: 210,
          //   height: 90,
          //   fit: BoxFit.fill,
          // ),
          // const SizedBox(height: 20),
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
      child: Center(
        child: Container(
          width: width < 600 ? double.infinity : width * 0.5,
          // decoration: const BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.only(
          //     topLeft: Radius.circular(30),
          //     topRight: Radius.circular(30),
          //   ),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              TextLabel("Full Name"),
              CustomTextFormField(
                hintText: "Enter First Name",
                controller: fullNameController,
                errorMessage: "First Name cannot be empty",

                // leadingIcon: Icons.person,
              ),
              TextLabel("Last Name"),
              CustomTextFormField(
                hintText: "Enter Last Name",
                controller: fullNameController,
                errorMessage: "Last Name cannot be empty",

                // leadingIcon: Icons.person,
              ),
              TextLabel("Business Name"),
              CustomTextFormField(
                hintText: "Enter Business name",
                controller: phoneNumberController,
                errorMessage: "Business name cannot be empty",

                // leadingIcon: Icons.person,
              ),
              TextLabel("Business Type"),
              CustomTextFormField(
                hintText: "Enter Business Type",
                controller: businessNameController,
                errorMessage: "Business Type empty",
                isRequired: false,

                // leadingIcon: Icons.person,
              ),
              TextLabel("Business Address"),
              CustomTextFormField(
                hintText: "Enter Business Address",
                controller: tinController,
                errorMessage: "Business Address cannot be empty",
                isRequired: true,

                // leadingIcon: Icons.person,
              ),
              TextLabel("TIN"),
              CustomTextFormField(
                hintText: "Enter TIN",
                controller: tinController,
                errorMessage: "TIN cannot be empty",
                isRequired: true,

                // leadingIcon: Icons.person,
              ),
              TextLabel("Date of Estabilishment"),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 3),
                child: DatePickerField(
                  controller: fullNameController,
                  hintText: 'Date of Establishment',
                  // prefixIcon: Icons.date_range,
                  suffixIcon: Icons.date_range,
                  initialDate: DateTime.now(), // Default value is today
                  firstDate: DateTime(1540), // The earliest selectable date
                  lastDate:
                      DateTime.now(), // The latest selectable date (today)
                  isRequired: true,
                  isGreyBorder: true,
                  errorMessage: 'Please select a date of Establishment',
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                child: Container(
                  color: Colors.transparent,
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

                      List<String> branchIdsList = selectedBranches.toList();
                      print("branchIdsList");
                      print(branchIdsList);
                      // Login Logic start here
                      // Declare the map to accept dynamic types
                      Map<String, dynamic> data = {
                        "fullName": fullNameController.text.toString(),
                        "phone": phoneNumberController.text.toString(),
                        // "business_name": businessNameController.text.toString(),
                        // "tin_number": tinController.text.toString(),

                        "branchIds":
                            branchIdsList, // Directly assign the List<String>
                        // "mainBranchId": selectedBranchId.toString(),
                        "password": "123456uh"
                      };

                      print(data);
                      try {
                        var response = await networkHandler
                            .postAgent("/api/v1/agents", data)
                            .timeout(const Duration(seconds: 5));

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
                        } else {
                          var errorResponse = jsonDecode(response.body);
                          errorText = errorResponse['password'] ??
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
    const url =
        'http://10.2.125.41:9060/api/branches'; // Replace with your actual URL
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
    const url =
        'http://10.2.125.41:9060/api/branches'; // Replace with your actual URL
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
}
