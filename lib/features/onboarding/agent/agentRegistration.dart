// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/Screen/LoginScreen.dart';
import 'package:coopengageplus/common_widgets/textField/CustomTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

// import 'package:searchfield/searchfield.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:http/http.dart' as http; // For making API calls

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
  List<dynamic> branches = []; // Store the fetched branches
  int? selectedBranchId;
  List<dynamic> filteredBranches = [];
  int? selectedBrancId; // To hold the selected branch ID
  bool isApiCallProcess = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true; // For Confirm Password
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

// Function to toggle password visibility
  void togglePasswordVisibility(bool isPasswordField) {
    setState(() {
      if (isPasswordField) {
        hidePassword = !hidePassword; // Toggle Password visibility
      } else {
        hideConfirmPassword =
            !hideConfirmPassword; // Toggle Confirm Password visibility
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
            CustomTextFormField(
              hintText: "Enter Full Name",
              controller: fullNameController,
              errorMessage: "Full Name cannot be empty",

              // leadingIcon: Icons.person,
            ),
            TextLabel("PhoneNumber"),
            CustomTextFormField(
              hintText: "Enter phonenumber or email",
              controller: phoneNumberController,
              errorMessage: "PhoneNumber empty",

              // leadingIcon: Icons.person,
            ),
            TextLabel("Business Name"),

            CustomTextFormField(
              hintText: "Enter Business Name",
              controller: businessNameController,
              errorMessage: "Business Name empty",
              isRequired: false,

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

            // reusableTextFormField(
            //   hintText: "Full Name",
            //   controller: fullNameController,
            //   errorMessage: "Full Name cannot be empty",
            //   leadingIcon: Icons.person,
            // ),
            // TextLabel("PhoneNumber or username "),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            //   child: Container(
            //     width: width < 600 ? double.infinity : width * 0.5,
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         TextFormField(
            //           controller: phoneNumberController,
            //           decoration: const InputDecoration(
            //             hintText: "PhoneNumber or username",
            //             hintStyle: TextStyle(
            //               fontSize: 13,
            //               color: Colors.black,
            //             ),
            //             labelStyle: TextStyle(fontSize: 5),
            //             isDense: true,
            //             // contentPadding:
            //             //     const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            //             border: OutlineInputBorder(
            //               borderRadius: BorderRadius.all(Radius.circular(10)),
            //             ),
            //             enabledBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.all(Radius.circular(10)),
            //               borderSide: BorderSide(color: Colors.black),
            //             ),
            //             focusedBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.all(Radius.circular(10)),
            //               borderSide: BorderSide(color: Colors.blue),
            //             ),
            //             errorBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.all(Radius.circular(10)),
            //               borderSide: BorderSide(color: Colors.red),
            //             ),
            //             focusedErrorBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.all(Radius.circular(10)),
            //               borderSide: BorderSide(color: Colors.red),
            //             ),
            //             // prefixIcon:  Icon(leadingIcon) ,
            //           ),
            //           validator: (value) {
            //             if (value == null || value.isEmpty) {
            //               return 'This field is required';
            //             }
            //             // return errorMessage; // Return the error message if exists
            //           },
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

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
    );
  }

  Padding branchSelectorWidget(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 1),
      child: Container(
          width: width < 600 ? double.infinity : width * 0.5,
          child: DropdownButtonFormField<int>(
              value: selectedBranchId, // Set the currently selected branch ID
              hint: const Text(
                "Select Branch",
                style: TextStyle(fontSize: 14),
              ),
              items: branches.map((branch) {
                return DropdownMenuItem<int>(
                  value: branch['id'], // Use branch ID as the value
                  child: Text(branch['companyName'],
                      style: TextStyle(
                          fontSize: 14)), // Show company name in dropdown
                );
              }).toList(),
              isDense: true,
              onChanged: (value) {
                setState(() {
                  selectedBranchId = value; // Update selected branch ID
                  print(selectedBranchId);
                });
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
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.red),
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
    );
  }

  // Method to create a reusable TextFormField
  Padding reusableTextFormField({
    required String hintText,
    required TextEditingController controller,
    String? errorMessage,
    IconData? leadingIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Container(
        width: width < 600 ? double.infinity : width * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                ),
                labelStyle: const TextStyle(fontSize: 5),
                isDense: true,
                // contentPadding:
                //     const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.red),
                ),
                prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return errorMessage ?? 'This field is required';
                }
                // return errorMessage; // Return the error message if exists
              },
            ),
          ],
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
// Add padding if needed for a 'dense' look
              chipDisplay: MultiSelectChipDisplay(
                chipColor: Colors.blue[50],
                textStyle: const TextStyle(color: Colors.black),
              ),
              // isDismissible: true,
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

  Widget _buildHeader() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/logo.png",
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

  // Future<bool> isOnline() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile ||
  //       connectivityResult == ConnectivityResult.wifi) {
  //     return true;
  //   }
  //   return false; // The device is offline
  // }
  Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true; // The device is online
    }

    return false; // The device is offline
  }

  // Padding branchWidget() {
  //   var branchController;
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
  //     child: SearchField(
  //       controller: branchController,
  //       suggestions: filteredBranches.map((branch) {
  //         return SearchFieldListItem(branch['companyName'],
  //             item: branch); // Pass the entire branch object if needed
  //       }).toList(),
  //       suggestionState: Suggestion.expand,
  //       hint: 'Search Branch',
  //       itemHeight: 50,
  //       searchInputDecoration: SearchInputDecoration(
  //         isDense: true,
  //         prefixIcon: const Icon(Icons.location_city),
  //         contentPadding:
  //             const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
  //         border: const OutlineInputBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(10)),
  //         ),
  //         hintStyle: const TextStyle(
  //           fontSize: 13,
  //           color: Colors.black,
  //         ),
  //         enabledBorder: const OutlineInputBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(10)),
  //           borderSide: BorderSide(color: Colors.black),
  //         ),
  //         focusedBorder: const OutlineInputBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(10)),
  //           borderSide: BorderSide(color: Colors.blue),
  //         ),
  //         errorBorder: const OutlineInputBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(10)),
  //           borderSide: BorderSide(color: Colors.red),
  //         ),
  //         focusedErrorBorder: const OutlineInputBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(10)),
  //           borderSide: BorderSide(color: Colors.red),
  //         ),
  //       ),
  //       onSuggestionTap: (x) {
  //         setState(() {
  //           // Cast x.item to Map<String, dynamic>
  //           final branch =
  //               x.item as Map<String, dynamic>?; // Safely cast to expected type
  //           print(branch);
  //           print(branch?['id']);
  //           if (branch != null) {
  //             // Access the 'id' and ensure it's properly set
  //             selectedBranchId =
  //                 branch?['id']; // This will work as 'id' is an int
  //             print(branch?['id']);
  //             print(selectedBrancId);
  //             branchController.text =
  //                 branch['companyName']; // Update with company name
  //             FocusScope.of(context).unfocus(); // Dismiss the keyboard
  //           }
  //         });
  //       },
  //       validator: (String? value) {
  //         if (value == null || value.isEmpty) {
  //           return 'Branch cannot be empty';
  //         }
  //         if (!branches
  //             .map((branch) => branch['companyName'])
  //             .contains(value)) {
  //           return 'Please select a valid branch';
  //         }
  //         return null;
  //       },
  //       onSearchTextChanged: (query) {
  //         setState(() {
  //           filteredBranches = branches
  //               .where((branch) => branch['companyName']
  //                   .toLowerCase()
  //                   .contains(query.toLowerCase()))
  //               .toList();
  //         });
  //       },
  //     ),
  //   );
  // }

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
