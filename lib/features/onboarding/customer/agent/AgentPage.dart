// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coopengageplus/core/network/network_handler.dart';
import 'package:coopengageplus/shared/widgets/textField/CustomTextFormField.dart';
import 'package:coopengageplus/shared/widgets/textField/small_form_widgets.dart';
import 'package:coopengageplus/core/config/config.dart';
import 'package:coopengageplus/core/constants/text_styles.dart';
import 'package:coopengageplus/core/database/database_helper.dart';
import 'package:coopengageplus/features/home/main_page.dart';
import 'package:coopengageplus/features/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

// import 'package:searchfield/searchfield.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:http/http.dart' as http; // For making API calls

class AgentPage extends StatefulWidget {
  const AgentPage({super.key});

  @override
  State<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  @override
  void initState() {
    super.initState();
    fetchBranches();
    fetchMultipleBranches();
  }

  Set<String> selectedBranches = {};
  List<MultiSelectItem<String>> branchItems = [];
  List<dynamic> branches = []; // Store the fetched branches
  List<dynamic> filteredBranches = [];
  bool isApiCallProcess = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true; // For Confirm Password
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Agent Registration",
            style: TextStyle(
                fontSize: 21, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          // centerTitle: true,
          elevation: 0,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ProgressHUD(
          key: UniqueKey(),
          inAsyncCall: isApiCallProcess,
          child: Form(
            key: globalFormKey,
            child: _loginUI(context),
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
          storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding),
    );
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // _buildHeader(),
            _buildFormContainer(
                width, height, networkHandler, storage, context),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContainer(
      double width,
      height,
      NetworkHandler networkHandler,
      FlutterSecureStorage storage,
      BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // ── Profile-style Form Card ──────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card header with avatar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.6), width: 2),
                        ),
                        child: const Icon(Icons.person,
                            size: 25, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "New Agent",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Fill in  details below",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
              // branchWidget(),
              // branchesWidget(width),
              SmallLabel(text: "Full Name"),
              SmallTextFormField(
                controller: fullNameController,
                errorMessage: "Full Name cannot be empty",
                hintText: "",
              ),
              SmallLabel(text: "PhoneNumber or Email"),
              SmallTextFormField(
                controller: phoneNumberController,
                isPhoneOrEmail: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9a-zA-Z@._-]')),
                  LengthLimitingTextInputFormatter(50),
                ],
                errorMessage: "PhoneNumber empty",
                hintText: '',
              ),
              SmallLabel(text: "Business Name"),
              SmallTextFormField(
                controller: businessNameController,
                errorMessage: "Business Name empty",
                isRequired: false,
                hintText: '',
              ),
              SmallLabel(text: "TIN"),
              SmallTextFormField(
                controller: tinController,
                keyboardType: TextInputType.number,
                errorMessage: "TIN cannot be empty",
                isRequired: true,
                exactLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                hintText: "Enter TIN",
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 15, right: 15),
              //   child: TextFormField(
              //     controller: tinController,
              //     keyboardType: TextInputType.number,
              //     inputFormatters: [
              //       FilteringTextInputFormatter.digitsOnly,
              //       LengthLimitingTextInputFormatter(10), // Prevent typing > 10
              //     ],
              //     decoration: InputDecoration(
              //       isDense: true,
              //       hintText: '',
              //       hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
              //       labelStyle: const TextStyle(fontSize: 20),
              //       contentPadding: const EdgeInsets.fromLTRB(20, 2, 2, 4),
              //       border: const OutlineInputBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(15)),
              //         borderSide: BorderSide(color: Colors.grey),
              //       ),
              //       focusedBorder: const OutlineInputBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(15)),
              //         borderSide: BorderSide(color: Colors.grey),
              //       ),
              //       errorBorder: const OutlineInputBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(15)),
              //         borderSide: BorderSide(color: Colors.red),
              //       ),
              //     ),
              //     validator: (value) {
              //       if (value == null || value.isEmpty) {
              //         return 'TIN cannot be empty';
              //       }
              //       if (value.length != 10) {
              //         return 'TIN must be exactly 10 digits';
              //       }
              //       return null;
              //     },
              //   ),
              // ),

              // reusableTextFormField(
              //   hintText: "Enter TIN",
              //   controller: tinController,
              //   errorMessage: "TIN cannot be empty",

              //   // leadingIcon: Icons.account_box,
              // ),
              // TextLabel("Main Branch"),
              // branchSelectorWidget(width),

              // TextLabel("Additional Branches"),
              // branchesWidget(width),
              SmallLabel(text: "Password"),
              SmallPasswordField(
                controller: _password,
                hidePassword: hidePassword,
                togglePasswordVisibility: () => togglePasswordVisibility(true),
                hintText: '',
              ),
              SmallLabel(text: "Confirm Password"),
              SmallConfirmPasswordField(
                controller: _confirmPassword,
                passwordController: _password,
                hidePassword: hideConfirmPassword,
                togglePasswordVisibility: () => togglePasswordVisibility(false),
                hintText: '',
              ),

              const SizedBox(
                height: 16,
              ),
              SmallButton(
                text: "Submit",
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                onPressed: () async {
                    if (validateAndSave()) {
                      setState(() {
                        isApiCallProcess = true;
                      });

                      // Retrieve the text from the controllers
                      String password = _password.text.trim();

                      final int? mainBranchId =
                          await _loggedInUserMainBranchId(storage);

                      final List<int> branchIdsInts = selectedBranches
                          .map((e) => int.tryParse(e))
                          .whereType<int>()
                          .toList();
                      // API rejects empty branchIds; default to logged-in user's main branch.
                      final List<int> branchIdsForApi = branchIdsInts.isNotEmpty
                          ? branchIdsInts
                          : (mainBranchId != null
                              ? <int>[mainBranchId!]
                              : <int>[]);

                      final Map<String, dynamic> data = {
                        "fullName": fullNameController.text.trim(),
                        "phone": phoneNumberController.text.trim(),
                        "business_name": businessNameController.text.trim(),
                        "tin_number": tinController.text.trim(),
                        "branchIds": branchIdsForApi,
                        "password": password,
                      };
                      if (mainBranchId != null) {
                        data["mainBranchId"] = mainBranchId;
                      }

                      try {
                        var response = await networkHandler
                            .postAgentRegistration("/api/v1/agents", data)
                            .timeout(const Duration(seconds: 50));

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
                                builder: (context) => const MainPage(),
                              ),
                              (route) => false);
                        } else {
                          var errorResponse = jsonDecode(response.body);
                          errorText = errorResponse['message'] ??
                              "Unable to register, please try later";
                          setState(() {
                            isApiCallProcess = false;
                            validate = false;
                            // errorText = "Unable to register try later";
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
                          circular = false;
                        });

                        // Handle token expiration specifically
                        if (e.toString().contains('Token expired') ||
                            e.toString().contains('Invalid token') ||
                            e.toString().contains('please login again')) {
                          // Show logout message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Session expired. Please login again.'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 1),
                            ),
                          );

                          // Navigate to login screen
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Loginscreen(),
                            ),
                            (route) => false,
                          );
                        } else {
                          // Handle other errors
                          errorText = "An error occurred. Please try again.";
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
                    }
                },
              ),
                const SizedBox(height: 36),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Info Card below the form card ────────────────────────────
          // _buildInfoCard(),
          // const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Widget _buildInfoCard() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 15),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         gradient: const LinearGradient(
  //           colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //         ),
  //         borderRadius: BorderRadius.circular(16),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.blue.withOpacity(0.25),
  //             blurRadius: 12,
  //             offset: const Offset(0, 6),
  //           ),
  //         ],
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Container(
  //                   padding: const EdgeInsets.all(8),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white.withOpacity(0.2),
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   child: const Icon(Icons.info_outline,
  //                       color: Colors.white, size: 18),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 const Text(
  //                   "Registration Requirements",
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 13,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             // const SizedBox(height: 14),
  //             // _infoRow(Icons.check_circle_outline, "Full name must match your national ID"),
  //             // const SizedBox(height: 8),
  //             // _infoRow(Icons.check_circle_outline, "TIN must be exactly 10 digits"),
  //             // const SizedBox(height: 8),
  //             // _infoRow(Icons.check_circle_outline, "Phone number must be 10 digits or a valid email"),
  //             // const SizedBox(height: 8),
  //             // _infoRow(Icons.check_circle_outline, "Password must be kept confidential"),
  //             // const SizedBox(height: 14),
  //             // Container(
  //             //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //             //   decoration: BoxDecoration(
  //             //     color: Colors.white.withOpacity(0.15),
  //             //     borderRadius: BorderRadius.circular(8),
  //             //   ),
  //             //   child: Row(
  //             //     children: const [
  //             //       Icon(Icons.support_agent, color: Colors.white, size: 16),
  //             //       SizedBox(width: 8),
  //             //       Expanded(
  //             //         child: Text(
  //             //           "Need help? Contact support at support@coopengageplus.com",
  //             //           style: TextStyle(
  //             //             color: Colors.white70,
  //             //             fontSize: 11,
  //             //           ),
  //             //         ),
  //             //       ),
  //             //     ],
  //             //   ),
  //             // ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.greenAccent, size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }

  Padding passwordWidget(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: SizedBox(
        width: width < 600
            ? double.infinity
            : width * 0.5, // Adjust width for tablet
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
      child: SizedBox(
        width: width < 600 ? double.infinity : width * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: subtitleStyle,
                labelStyle: const TextStyle(fontSize: 5),
                isDense: true,
                // contentPadding:
                //     const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
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
      child: SizedBox(
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
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black,
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

  int? _coerceStoredBranchId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  /// Logged-in user's [Users.mainBranchId] from SQLite (ProfileScreen DB path).
  Future<int?> _loggedInUserMainBranchId(FlutterSecureStorage storage) async {
    final String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUserByToken(token);
      if (user != null) {
        return _coerceStoredBranchId(user['mainBranchId']);
      }
      final users = await dbHelper.getUsers();
      if (users.isNotEmpty) {
        return _coerceStoredBranchId(users.first['mainBranchId']);
      }
      return null;
    }

    final users = await DatabaseHelper().getUsers();
    if (users.isEmpty) return null;
    return _coerceStoredBranchId(users.first['mainBranchId']);
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
        child: Text(text,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)));
  }

  Future<void> fetchBranches() async {
    const url = "${AppConstants.baseURL}/api/branches";
    // const url =
    //     'http://10.2.125.41:9061/api/branches'; // Replace with your actual URL
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

      // Handle token expiration if it's a network error
      if (error.toString().contains('Token expired') ||
          error.toString().contains('Invalid token') ||
          error.toString().contains('please login again')) {
        // Show logout message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 1),
            ),
          );

          // Navigate to login screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const Loginscreen(),
            ),
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> fetchMultipleBranches() async {
    // const url = 'http://10.2.125.41:9060/api/branches';
    const url = "${AppConstants.baseURL}/api/branches";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          branches = data; // Store the branches
          // Map fetched branches to MultiSelectItems
          branchItems = branches.map((branch) {
            return MultiSelectItem<String>(
              branch['id'].toString(), // Use the ID as the unique identifier
              branch['companyName'], // Use the company name for display
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (error) {
      print("Error fetching branches: $error");

      // Handle token expiration if it's a network error
      if (error.toString().contains('Token expired') ||
          error.toString().contains('Invalid token') ||
          error.toString().contains('please login again')) {
        // Show logout message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please login again.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 1),
            ),
          );

          // Navigate to login screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const Loginscreen(),
            ),
            (route) => false,
          );
        }
      }
    }
  }
}
