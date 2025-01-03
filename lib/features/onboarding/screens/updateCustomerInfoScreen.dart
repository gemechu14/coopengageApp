// ignore_for_file: unused_local_variable, constant_identifier_names, unused_element, avoid_print, unused_import, unnecessary_import, prefer_typing_uninitialized_variables, file_names, non_constant_identifier_names, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
// import 'package:csc_picker/csc_picker.dart';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/common_widgets/dropDown/DatePickerField.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/common_widgets/textField/PaymentMethod.dart';
import 'package:coopengageplus/common_widgets/textField/PhoneNumberWidget.dart';
import 'package:coopengageplus/common_widgets/textField/emailWidget.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/features/onboarding/pages/ConfirmationPage.dart';
import 'package:coopengageplus/features/onboarding/pages/old/HomePage.dart';
import 'package:coopengageplus/main.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:coopengageplus/service/GlobalData.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

// import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import '../../../widget/ButtonUploadTakePhoto .dart';

String selectedIdType = 'KEBELE_ID';
var phoneNumber;
final List<String> iDType = [
  'KEBELE_ID',
  'PASSPORT_ID',
  'EMPLOYEE_ID',
  'DRIVING_LICENSE_ID',
  'NATIONAL_ID',
];
Uint8List? residenceFront;
String? selectedMaritalStatus;
String? selectedCustomerType;
String? selectedDocumentType;
String? selectedSector;
bool registerStatus = true;

///
///
///
String? signaturePath;
int selectedAccountTypeValue = 1;
String? signatureUrl;

List<String> branchNames = [];
// selectedAccountTypeValue=1;
String residentCardBackPath = "";
String? selectedPaymentMethod;
bool isBankTransferSelected = false;
bool isBankTransferIconClicked = false;

String? signatureImagePath;
Uint8List? savedSignature;
String? amount;
List<Map<String, dynamic>> allBranches = [];
String? selectedBranch;
int? UserID = GlobalData()?.userId;
final globalData = GlobalData();

class UpdateCustomerINFOScreen extends StatefulWidget {
  final Map<String, dynamic>
      userInfo; // Use the appropriate type based on your data structure

  const UpdateCustomerINFOScreen({Key? key, required this.userInfo})
      : super(key: key);

  @override
  State<UpdateCustomerINFOScreen> createState() => _CustomerINFO();
}

class _CustomerINFO extends State<UpdateCustomerINFOScreen> {
  String? userId;
  String? signatureUrl;
  Uint8List? _combinedSignature;
  int? idOne;
  String? selectedBankingType;
  late SignatureController _signatureController1,
      _signatureController2,
      _signatureController3;
  String? selectedGender;
  String? selectedAccountTypeId;
  List<Map<String, dynamic>> filteredAccountTypes =
      []; // Declare the selectedGender variable
  final List<String> genders = ['MALE', 'FEMALE'];
  List<Map<String, dynamic>> accountTypes = [];
  final Map<String, dynamic> registrationData = {};
  Future<void> _initializeGlobalData() async {
    await GlobalData().fetchToken();
    GlobalData().initializeBranches();

    setState(() {});
  }

  @override
  void initState() {
    _initializeGlobalData();
    _signatureController1 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.transparent,
    );
    _signatureController2 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.transparent,
    );
    _signatureController3 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.transparent,
    );
    print(widget?.userInfo);
    fetchBranches();
    _initializeGlobal();
    super.initState();
    GlobalData().fetchToken();
    fetchToken();
    _setDateOfBirth();
    initializeBranches();
    String phoneNumber = isOnline
        ? (widget.userInfo['phone'] ?? '')
        : (widget.userInfo['phone'] ?? '');
    if (phoneNumber.startsWith('251')) {
      phoneNumber = phoneNumber.substring(3).trim();
    } else if (phoneNumber.startsWith('+251')) {
      phoneNumber = phoneNumber.substring(4).trim();
    }
    print("1234512345");
    print(widget.userInfo);
    print(allBranches);
    print(allBranches);

    phoneNumberController.text = phoneNumber;
    selectedTitle = widget.userInfo['title'] ?? ListContants.title.first;
    selectedMaritalStatus =
        widget.userInfo['maritalStatus'] ?? ListContants.maritalStatuses.first;
    print(widget.userInfo['signature']);
    idOne = widget.userInfo['id'];
    firstNameController.text = widget.userInfo['firstName'] ?? '';

    if (widget.userInfo['branch'] != null &&
        widget.userInfo['branch']!.isNotEmpty) {
      selectedBranch = widget.userInfo['branch'];
    }

    // selectedBranch = widget.userInfo['branch'];
    selectedDocumentType =
        widget.userInfo['documentName'] ?? ListContants.documentName.first;
    fullNameController.text = widget.userInfo['fullName'] ?? '';
    surNameController.text = widget.userInfo['surname'] ?? '';
    motherNameController.text = widget.userInfo['motherName'] ?? '';
    emailController.text = widget.userInfo['email'] ?? '';

    selectedCustomerType = widget.userInfo['customerType'];
    addressController.text = widget.userInfo['address'] ?? '';
    streetController.text = widget.userInfo['streetAddress'] ?? '';
    stateController.text = widget.userInfo['state'] ?? '';
    residenceAddressController.text = widget.userInfo['residenceAddress'] ?? '';
    nationalityController.text = widget.userInfo['nationality'] ?? '';
    cityController.text = widget.userInfo['city'] ?? '';
    zipCodeController.text = widget.userInfo['zipCode'] ?? '';
    accountCurrencyController.text = widget.userInfo['currency'] ?? '';
    occupationController.text = widget.userInfo['occupation'] ?? '';

    dateOfBirthController.text = widget.userInfo['dateOfBirth'] ?? '';
    // selectedGender = widget.userInfo["sex"];
    surNameController.text = widget.userInfo['surName'] ?? '';

    expireDateController.text = widget.userInfo['expirayDate'] ?? '';
    woredaController.text = widget.userInfo['streetAddress'] ?? '';
    issueAuthorityController.text = widget.userInfo['issueAuthority'] ?? '';
    issueDateController.text = widget.userInfo['issueDate'] ?? '';
    legalIDController.text = widget.userInfo['legalId'] ?? '';
    cityController.text = widget.userInfo['zoneSubcity'] ?? '';

    // // selectedAccountTypeValue =
    // //     int.tryParse(widget.userInfo['accountType'].toString()) ?? 1;
    // // selectedAccountTypeValue = widget.userInfo['accountType'] != null
    // //     ? int.tryParse(widget.userInfo['accountType'].toString()) ?? 1
    // //     : 1;

    initialDepositController.text =
        widget.userInfo['initialDeposit']?.toString() ?? '';
    monthlyIncomeController.text =
        widget.userInfo['monthlyIncome']?.toString() ?? '';

    if (widget.userInfo['photo'] is String) {
      profilePath = widget.userInfo['photo'];
    } else if (widget.userInfo['photo'] is Uint8List) {
      profilePath = base64Encode(widget.userInfo['photo']);
    }

    if (widget.userInfo['residenceCardBack'] is String) {
      residentCardBackPath = widget.userInfo['residenceCardBack'];
    } else if (widget.userInfo['residenceCardBack'] is Uint8List) {
      residentCardBackPath = base64Encode(widget.userInfo['residenceCardBack']);
    }
    if (widget.userInfo['residenceCard'] is String) {
      residentPath = widget.userInfo['residenceCard'];
    } else if (widget.userInfo['residenceCard'] is Uint8List) {
      residentPath = base64Encode(widget.userInfo['residenceCard']);
    }

    if (widget.userInfo['signature'] is String) {
      _combinedSignature = widget.userInfo['signature'];
    } else if (widget.userInfo['signature'] is Uint8List) {
      _combinedSignature = widget.userInfo['signature'];
    }
  }

  void _setDateOfBirth() {
    String? fullDateTime = widget.userInfo['dateOfBirth'];
    if (fullDateTime != null) {
      String dateOnly = fullDateTime.split(' ').first; // Gets "2024-10-19"

      // Optionally, you can also parse it to ensure correct formatting
      try {
        DateTime dateTime = DateTime.parse(fullDateTime);
        dateOnly = DateFormat('yyyy-MM-dd')
            .format(dateTime); // Formats it to "yyyy-MM-dd"
      } catch (e) {
        print('Error parsing date: $e'); // Handle parsing error if any
      }

      dateController.text = dateOnly; // Set the controller text
    } else {
      dateController.text = ''; // Handle null case
    }
  }

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
  );
  bool isApiCallProcess = false;
  bool validate = false;
  bool circular = false;
  bool isValid = true;
  String? selectedTitle;
  // String? selectedGender;
  String? selectedMaritalStatus;
  String? selectedDocumentType;
  String? selectedSector;
  String imagePath = "";
  String passportPath = "";
  String formPath = "";
  String residentPath = "";
  String profilePath = "";
  String selectedCountry = 'Ethiopia';
  String? selectedState;
  String? selectedCity;

  String? mainBranches;
  List<Map<String, dynamic>> branches1 = [];

  final List<String> currencies = [
    'USD',
    'ETB',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'CHF',
    'CNY',
    'SEK',
    'NZD',
    'INR',
    'RUB',
    'ZAR',
    'BRL',
    'MXN',
    'SGD',
    'HKD',
    'NOK',
    'KRW',
    'TRY',
  ];

  TextEditingController firstNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController surNameController = TextEditingController();
  TextEditingController motherNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController residenceAddressController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController accountCurrencyController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController initialDepositController = TextEditingController();
  TextEditingController monthlyIncomeController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController accountTypeController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController photoController = TextEditingController();
  TextEditingController signatureController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  TextEditingController legalIDController = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController expireDateController = TextEditingController();
  TextEditingController issueAuthorityController = TextEditingController();
  TextEditingController zoneSubsityController = TextEditingController();
  TextEditingController woredaController = TextEditingController();
  FocusNode focusNode = FocusNode();
  NetworkHandler networkHandler = NetworkHandler();
  final TextEditingController controller = TextEditingController();

  String imagepath2 = "";
  String imagepath3 = "";
  String selectedCurrency = 'ETB';

  final picker = ImagePicker();
  final picker2 = ImagePicker();
  final picker3 = ImagePicker();
  File? imageFile;
  File? passportImageFile;
  File? profileImageFile;
  var selectedDate;
  var selectedTime;

  String initialCountry = 'ET';
  PhoneNumber number = PhoneNumber(isoCode: 'ET');

  // final List<String> genders = ['MALE', 'FEMALE'];
  final List<String> titles = ['MR', 'MS', 'DR'];
  final List<String> maritalStatus = ['Single', 'Married'];

  final List<String> documentType = [
    'KEBELE ID',
    'PASSPORT ID',
    'EMPLOYEE ID',
    'STUDENT ID',
    'DRIVING LICENSE ID',
    'PENSION ID',
    'TAX ID'
  ];
  List<String> countries = ['Ethiopia'];
  List<String> ethiopianStates = [
    'Addis Ababa',
    'Oromia',
    'Amhara',
    'Tigray',
    'Sidama',
    "Afar",
    "Somale",
    "Benishangul Gumuz",
    "Gambela",
    "Harar",
    "Dire Dawa"
  ];
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey1 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey2 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey3 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey4 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey5 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey6 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey7 = GlobalKey<FormState>();
  List<Map<String, dynamic>> allBranches = [];
  Padding stateWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: DropdownButtonFormField<String>(
        value: selectedState, // Bind selectedState to the value
        hint: const Text(
          'Select State',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        items: ethiopianStates.map((String state) {
          return DropdownMenuItem<String>(
            value: state,
            child: Text(state),
          );
        }).toList(),
        onChanged: (String? newState) {
          setState(() {
            selectedState = newState; // Store the selected state
          });
        },

        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          prefixIcon: Icon(Icons.map),
        ),
      ),
    );
  }

  Padding genderWidget1() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Male'),
                  value: 'MALE', // Radio button value
                  groupValue: selectedGender, // Current selected gender
                  onChanged: (String? value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Female'),
                  value: 'FEMALE', // Radio button value
                  groupValue: selectedGender, // Current selected gender
                  onChanged: (String? value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          if (selectedGender == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Gender *',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Padding dateOfBirthWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: TextFormField(
        controller: dateController,
        onTap: () async {
          _setDateHandler(context);
        },
        decoration: const InputDecoration(
          hintText: "Date of Birth",
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
          prefixIcon: Icon(Icons.date_range),
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          // labelText: "Date of Birth *",
          labelStyle: TextStyle(fontSize: 15),
          isDense: true,
          // contentPadding: EdgeInsets.fromLTRB(
          //     20, 2, 2, 4), // Adjust the bottom value (40) for spacing
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Padding emailWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: "Email",
          labelStyle: TextStyle(fontSize: 5),
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Colors.black,
          ), // Adjust label size
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
          prefixIcon: Icon(Icons.email),
        ),
        controller: emailController,
        validator: (value) {
          if (value != null) {
            if (!isValid) {
              return "Email is not valid";
            }
          }
          return null;
        },
      ),
    );
  }

  Padding monthlyIncomeWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: monthlyIncomeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Only allow numbers
              // LengthLimitingTextInputFormatter(9), // Limit to 9 digits
            ],
            decoration: const InputDecoration(
              hintText: "Monthly Income",
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
              labelStyle: TextStyle(fontSize: 5), // Adjust label size
              isDense: true, // Makes the text field smaller vertically
              contentPadding: EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 10.0), // Adjust padding as needed
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.red),
              ),
              prefixIcon: Icon(Icons.trending_up),
            ),
            // Dynamic validator based on input value
          ),
        ],
      ),
    );
  }

  Padding countryWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: DropdownButtonFormField<String>(
        value: selectedCountry, // Bind selectedCountry to the value
        // hint: const Text('Country *'),
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
        items: ['Ethiopia'].map((String country) {
          return DropdownMenuItem<String>(
            value: country,
            child: Text(country),
          );
        }).toList(),
        onChanged: null,

        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          prefixIcon: Icon(Icons.public),
        ),
      ),
    );
  }

  Padding phoneNumberWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: phoneNumberController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Only allow numbers
              LengthLimitingTextInputFormatter(9), // Limit to 9 digits
            ],
            decoration: const InputDecoration(
              hintText: "Phone Number",
              labelStyle: TextStyle(fontSize: 5),
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Colors.black,
              ), // Adjust label size
              isDense: true, // Makes the text field smaller vertically
              contentPadding: EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 10.0), // Adjust padding as needed
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.red),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(10.0), // Adjust the padding as needed
                child: Text(
                  '+251',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
            validator: (value) {
              // Ensure the user enters exactly 9 digits
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              } else if (value.length != 9) {
                return 'Phone number must be 9 digits';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  int _activeStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    print("signatureUrl");
    print(signatureUrl);
    final SignatureController _signatureController = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
    );
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(),
          ),
          (route) => false,
        );

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            title: const Text(
              "Update",
              style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainPage(),
                      ),
                      (route) => false);
                },
                icon: const Icon(Icons.arrow_back))),
        body: Center(
          child: Container(
            width: width < 600 ? double.infinity : width * 0.5,
            child: Column(
              children: [
                Expanded(
                  child: Theme(
                    data: ThemeData(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.blue, // Color of the active step number
                        secondary:
                            Colors.blue, // Color of the completed step number
                      ),
                    ),
                    child: Form(
                      key: globalFormKey,
                      child: Stepper(
                        type: StepperType.horizontal,
                        steps: stepList(),
                        currentStep: _activeStepIndex,
                        controlsBuilder:
                            (BuildContext context, ControlsDetails details) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 25, right: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Custom positioning
                              children: <Widget>[
                                if (_activeStepIndex > 0)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      // onPressed: details.onStepCancel,
                                      onPressed: onStepCancel,
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors
                                            .blue, // Set the background color to blue
                                      ),
                                      child: const Text(
                                        '     Back     ',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: onStepContinue,
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors
                                          .blue, // Set the background color to blue
                                    ),
                                    child: Text(
                                      _activeStepIndex == 7
                                          ? 'Submit'
                                          : 'Continue',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showImagePicker(BuildContext context, String imageTypes) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Card(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 5.2,
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: InkWell(
                      child: const Column(
                        children: [
                          Icon(
                            Icons.image,
                            size: 60.0,
                          ),
                          SizedBox(height: 12.0),
                          Text(
                            "Gallery",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          )
                        ],
                      ),
                      onTap: () {
                        _imgFromGallery(imageTypes);
                        Navigator.pop(context);
                      },
                    )),
                    Expanded(
                        child: InkWell(
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 60.0,
                            ),
                            SizedBox(height: 12.0),
                            Text(
                              "Camera",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        _imgFromCamera(imageTypes);
                        Navigator.pop(context);
                      },
                    ))
                  ],
                )),
          );
        });
  }

  _imgFromGallery(String imageTypes) async {
    await picker
        .pickImage(source: ImageSource.gallery, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path), imageTypes);
      }
    });
  }

  _imgFromCamera(String imageTypes) async {
    await picker
        .pickImage(source: ImageSource.camera, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path), imageTypes);

        // _cropImage(File(value.path));
      }
    });
  }

  _cropImage(File imgFile, String imageTypes) async {
    final croppedFile =
        await ImageCropper().cropImage(sourcePath: imgFile.path, uiSettings: [
      AndroidUiSettings(
          toolbarTitle: "Image Cropper",
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      IOSUiSettings(
        title: "Image Cropper",
      )
    ]);
    if (croppedFile != null) {
      // imageCache.clear();
      setState(() {
        // imageFile = File(croppedFile.path);

        if (imageTypes == 'passport') {
          passportPath = croppedFile.path;
        } else if (imageTypes == 'profile') {
          profilePath = croppedFile.path;
        } else if (imageTypes == 'resident') {
          residentPath = croppedFile.path;
        } else if (imageTypes == 'residentCardBack') {
          residentCardBackPath = croppedFile.path;
        } else if (imageTypes == 'signature') {
          // signatureImagePath = croppedFile.path;
          // savedSignature = null;

          _signatureController1.clear();
          _signatureController2.clear();
          _signatureController3.clear();
          savedSignature = null;

          // Set the uploaded image as the combined signature
          signatureImagePath = croppedFile.path;
          _combinedSignature = File(croppedFile.path).readAsBytesSync();
        } else if (imageTypes == 'form') {
          formPath = croppedFile.path;
        }
      });
      // reload();
    }
  }

  Future<Uint8List> _getImageBytes(String path) async {
    final imageFile = File(path);
    if (await imageFile.exists()) {
      // throw Exception("File does not exist.");
      print("file not exist");
    }
    return await imageFile.readAsBytes();
  }

  void _clearSignature() {
    _signatureController.clear();
  }

  void _saveSignature() {}
  bool isStepComplete(int stepIndex) {
    // print(stepIndex);
    switch (stepIndex) {
      case 0:
        return phoneNumberController.text.isNotEmpty &&
            phoneNumberController.text.length == 9;
      case 1:
        return fullNameController.text.isNotEmpty;
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      default:
        return false;
    }
  }

  void _nextStep() {
    // if (isStepComplete(_activeStepIndex) &&
    //     globalFormKey.currentState?.validate() == true) {
    //   setState(() {
    //     _activeStepIndex += 1;
    //   });
    // } else {
    //   print("Please fill in all required fields before proceeding.");
    //   // Handle the case where the step is incomplete
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //       content:
    //           Text('Please fill in all required fields before proceeding.')));
    // }
  }

  void _previousStep() {
    if (_activeStepIndex > 0) {
      setState(() {
        _activeStepIndex -= 1;
      });
    }
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;

    isValid = EmailValidator.validate(emailController.text);
    print("datataaaaaa");

    if (form != null && form.validate()) {
      form.save();
      return true;
    }

    return false;
  }

  Future<void> onStepContinue() async {
    final formIsValid = validateData();

    if (formIsValid) {
      final isLastStep = _activeStepIndex == stepList().length - 1;

      if (_activeStepIndex == 0) {
        await handlefirstStep();
      }
      if (_activeStepIndex == 1) {}
      if (_activeStepIndex == 2) {}
      if (_activeStepIndex == 3) {}
      if (_activeStepIndex == 4) {}
      if (_activeStepIndex == 5) {}
      if (_activeStepIndex == 6) {}
      if (isLastStep) {
        await submitFormData1();
      } else {
        if (registerStatus == true) {
          setState(() {
            _activeStepIndex += 1;
          });
        } else {}
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out the required fields')),
      );
    }
  }

  bool validateData() {
    switch (_activeStepIndex) {
      case 0:
        isValid = true;
        print("check emial status");
        print(emailController.text);
        if (emailController.text.isNotEmpty) {
          isValid = EmailValidator.validate(emailController.text);
        }

        return (globalFormKey.currentState?.validate() ?? false) && isValid;
      case 1:
        return globalFormKey1.currentState?.validate() ?? false;
      case 2:
        return globalFormKey2.currentState?.validate() ?? false;
      case 3:
        return globalFormKey3.currentState?.validate() ?? false;
      case 4:
        return globalFormKey4.currentState?.validate() ?? false;
      case 5:
        return globalFormKey5.currentState?.validate() ?? false;
      case 6:
        return globalFormKey6.currentState?.validate() ?? false;
      case 7:
        return globalFormKey7.currentState?.validate() ?? false;

      default:
        return false;
    }
  }

  void onStepCancel() {
    if (_activeStepIndex > 0) {
      setState(() {
        _activeStepIndex -= 1;
      });
    }
  }

  _setDateHandler(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(seconds: 1)),
      firstDate: DateTime(1950),
      lastDate: DateTime(2024, 12, 31),
    );
    if (picked != null) {
      {
        dateController.text = picked.toString().split(" ")[0];
      }
    }
  }

  Padding TextLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Padding reusableTextFormField({
    required String hintText,
    required TextEditingController controller,
    String? errorMessage,
    IconData? leadingIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
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
              return errorMessage; // Return the error message if exists
            },
          ),
        ],
      ),
    );
  }

  Padding reusableTextFormField2({
    required String hintText,
    required TextEditingController controller,
    String? errorMessage,
    IconData? leadingIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
              labelStyle: const TextStyle(fontSize: 5),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
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
            // Dynamic validator based on input value
            validator: (value) {
              if (value == null || value.isEmpty) {
                return errorMessage ?? 'This field is required';
              }
              if (inputFormatters == null || inputFormatters.isEmpty) {
                return null;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Padding reusableTextFormField1({
    required String hintText,
    required TextEditingController controller,
    String? errorMessage,
    IconData? leadingIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
              labelStyle: const TextStyle(fontSize: 5), // Adjust label size
              isDense: true, // Makes the text field smaller vertically
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 10.0), // Adjust padding as needed
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
            // Dynamic validator based on input value
            validator: (value) {
              if (value == null || value.isEmpty) {
                return errorMessage ?? 'This field is required';
              }
              if (inputFormatters == null || inputFormatters.isEmpty) {
                return null; // No validation if there are no input formatters
              }
              return null; // Return null if no errors
            },
          ),
        ],
      ),
    );
  }

  Future<void> submitFormData1() async {
    Uint8List? signatureBytes = await _signatureController.toPngBytes();
    Uint8List? residentBytes;
    Uint8List? residentCardBackBytes;
    Uint8List? profileBytes;
    String phoneNumber = phoneNumberController.text;

    registrationData['fullName'] = fullNameController.text;
    registrationData['surname'] = surNameController.text;
    registrationData['motherName'] = motherNameController.text;
    registrationData['phone'] = '251$phoneNumber';
    registrationData['email'] = emailController.text;
    registrationData['sex'] = selectedGender;
    registrationData['dateOfBirth'] = dateOfBirthController.text;
    registrationData['city'] = cityController.text;
    registrationData['country'] = selectedCountry;
    registrationData['state'] = selectedState;
    // registrationData['zipCode'] = dateOfBirthController.text;
    registrationData['streetAddress'] = streetController.text;
    registrationData['accountType'] = "$selectedAccountTypeValue";
    registrationData['occupation'] = occupationController.text;
    registrationData['initialDeposit'] = initialDepositController.text;
    registrationData['monthlyIncome'] = monthlyIncomeController.text;
    registrationData['branch'] = selectedBranch;
    registrationData['currency'] = selectedCurrency;
    registrationData['signature'] = _combinedSignature;
//PROFILE PHOTO
    if (profilePath.isEmpty) {
      registrationData['photo'] = null;
    } else if (profilePath.startsWith('/9j/') ||
        profilePath.startsWith('data:image/jpeg;base64,')) {
      try {
        if (profilePath.startsWith('data:image/jpeg;base64,')) {
          profilePath = profilePath.replaceFirst('data:image/jpeg;base64,', '');
        }
        profileBytes = base64Decode(profilePath);
        registrationData['photo'] = profileBytes;
      } catch (e) {
        print("Error decoding base64 image: $e");
        return;
      }
    } else if (profilePath.startsWith('http') ||
        profilePath.startsWith('https')) {
      registrationData['photo'] = profilePath;
    } else {
      try {
        profileBytes = await _getImageBytes(profilePath);
        registrationData['photo'] = profileBytes;
      } catch (e) {
        print("Error loading image from file: $e");
        return;
      }
    }

    /////RESIDENT CARD
    if (residentPath.isEmpty) {
      registrationData['residenceCard'] = null;
    } else if (residentPath.startsWith('/9j/') ||
        residentPath.startsWith('data:image/jpeg;base64,')) {
      try {
        if (residentPath.startsWith('data:image/jpeg;base64,')) {
          residentPath =
              residentPath.replaceFirst('data:image/jpeg;base64,', '');
        }
        residentBytes = base64Decode(residentPath);
        registrationData['residenceCard'] = residentBytes;
      } catch (e) {
        print("Error decoding base64 image: $e");
        return;
      }
    } else if (residentPath.startsWith('http') ||
        residentPath.startsWith('https')) {
      registrationData['residenceCard'] = residentPath;
    } else {
      try {
        residentBytes = await _getImageBytes(residentPath);
        registrationData['residenceCard'] = residentBytes;
      } catch (e) {
        print("Error loading image from file: $e");
        return;
      }
    }

    if (residentCardBackPath.isEmpty) {
      registrationData['residenceCardBack'] = null;
    } else if (residentCardBackPath.startsWith('/9j/') ||
        residentCardBackPath.startsWith('data:image/jpeg;base64,')) {
      try {
        if (residentCardBackPath.startsWith('data:image/jpeg;base64,')) {
          residentCardBackPath =
              residentCardBackPath.replaceFirst('data:image/jpeg;base64,', '');
        }
        residentCardBackBytes = base64Decode(residentCardBackPath);
        registrationData['residenceCardBack'] = residentCardBackBytes;
      } catch (e) {
        print("Error decoding base64 image: $e");
        return;
      }
    } else if (residentCardBackPath.startsWith('http') ||
        residentCardBackPath.startsWith('https')) {
      registrationData['residenceCardBack'] = residentCardBackPath;
    } else {
      try {
        residentCardBackBytes = await _getImageBytes(residentCardBackPath);
        registrationData['residenceCardBack'] = residentCardBackBytes;
      } catch (e) {
        print("Error loading image from file: $e");
        return;
      }
    }
    registrationData['formCompleted'] = "true";
    registrationData['status'] = 'UNSETTLED';
    registrationData["percentageCompleted"] = 100;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationPage(
            registrationData: registrationData,
            userId: '$idOne',
            className: "update"),
      ),
    );

    if (result != null) {
      setState(() async {
        await Future.delayed(
            const Duration(milliseconds: 100)); // Optional delay
        FocusScope.of(context).unfocus();
        userId = result;
      });
    }
  }

  // Load JSON data from the asset

  Future<void> fetchToken() async {
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);

      if (decodedToken.containsKey("branch")) {
        branches1 = List<Map<String, dynamic>>.from(decodedToken["branch"]);
      } else {
        branches1 = [];
      }
      if (decodedToken.containsKey("mainBranch")) {
        mainBranches = decodedToken["mainBranch"];
        branches1.insert(0, {"companyName": mainBranches});
      }
    }
  }

  Future<void> fetchBranches() async {
    String? token = await storage.read(key: "token");

    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);

      if (decodedToken.containsKey("branch")) {
        List<Map<String, dynamic>> branches =
            List<Map<String, dynamic>>.from(decodedToken["branch"]);
        branchNames.addAll(branches
            .map((branch) => branch["companyName"] ?? "Unnamed Branch"));
      }

      if (decodedToken.containsKey("mainBranch")) {
        var mainBranch = decodedToken["mainBranch"];
        branchNames.insert(
            0, mainBranch["companyName"] ?? "Unnamed Main Branch");
      }

      setState(() {});
    }
  }

  List<Step> stepList() {
    bool isSmallScreen = MediaQuery.of(context).size.width < 1400;
    return [
      Step(
        title: Text(isSmallScreen ? "" : "Basic Information"),
        isActive: _activeStepIndex >= 0,
        // state: _activeStepIndex > 0 ? StepState.complete : StepState.indexed,
        state: isStepComplete(0) ? StepState.complete : StepState.indexed,
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8.0 : 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("Customer Type"),
              ReusableDropdown(
                selectedValue: selectedCustomerType,

                items: ListContants.customerType,
                hintText: 'Select Customer Type',
                onChanged: (newStatus) {
                  setState(() {
                    selectedCustomerType = newStatus!;
                  });
                },
                prefixIcon: selectedCustomerType == 'INDIVIDUAL' ||
                        selectedCustomerType == 'DIASPORA'
                    ? Icons.person
                    : Icons.business,
                errorMessage:
                    'Please select a customer Type ', // Pass the custom error message
                isRequired: false, // Make the field required
              ),
              TextLabel("PhoneNumber"),
              PhoneNumberWidget(phoneNumberController: phoneNumberController),
              TextLabel("Email"),
              EmailWidget(emailController: emailController),
            ],
          ),
        ),
      ),
      Step(
        title: Text(
          isSmallScreen ? "" : "ID TYPE",
        ),
        isActive: _activeStepIndex >= 1,
        state: _activeStepIndex > 1 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("Branch"),
              branchSelectorWidget1(),
              TextLabel("Document Type"),
              ReusableDropdown(
                selectedValue: selectedDocumentType,

                items: ListContants.documentName,
                hintText: 'Select Customer Type',
                onChanged: (newStatus) {
                  setState(() {
                    selectedDocumentType = newStatus!;
                  });
                },
                prefixIcon: Icons.document_scanner,
                errorMessage:
                    'Please select a Document  type', // Pass the custom error message
                isRequired: true, // Make the field required
              ),
              const SizedBox(
                height: 5,
              ),
              idCardPhoto(),
            ],
          ),
        ),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "Signature"),
        isActive: _activeStepIndex >= 2,
        state: _activeStepIndex > 2 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("Mother Name"),
              ReusableTextFormField(
                hintText: "Mother Name",
                controller: motherNameController,
                keyboardType: TextInputType.text,
                errorMessage: "Mother Name cannot be empty",
                leadingIcon: Icons.person,
                isRequired: false,
              ),
              TextLabel("Signature"),
              // signatureWidget1(context),
              signatureCard(),
              signaturePadSelection(),
            ],
          ),
        ),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "Financial Information"),
        isActive: _activeStepIndex >= 3,
        state: _activeStepIndex > 3 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("Personal Photo"),
              personalPhoto(),
            ],
          ),
        ),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "Personal photo"),
        isActive: _activeStepIndex >= 4,
        state: _activeStepIndex > 4 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("Sector"),
              ReusableDropdown(
                selectedValue: selectedSector,
                items: ListContants.sectors,
                hintText: 'Select Sector',
                onChanged: (newStatus) {
                  setState(() {
                    selectedSector = newStatus!;
                  });
                },
                prefixIcon: Icons.category,
                errorMessage:
                    'Please select a Sector status', // Pass the custom error message
                isRequired: true, // Make the field required
              ),
              TextLabel("Occupation "),
              ReusableTextFormField(
                hintText: "Enter Occupation",
                controller: occupationController,
                // keyboardType: TextInputType.number,
                errorMessage: "Occupation cannot be empty",
                leadingIcon: Icons.work,
                // return '';
                // inputFormatters: [
                //   FilteringTextInputFormatter.digitsOnly, // Only allow numbers
                // ],
                isRequired: true,
              ),
              TextLabel("Monthly Income"),
              ReusableTextFormField(
                hintText: "Enter Monthly Income",
                controller: monthlyIncomeController,
                keyboardType: TextInputType.number,
                errorMessage: "monthlyIncome cannot be empty",
                leadingIcon: Icons.trending_up,
                // return '';
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow numbers
                ],
                isRequired: true,
              ),
              TextLabel("InitialDeposit"),
              ReusableTextFormField(
                hintText: "InitialDeposit",
                controller: initialDepositController,
                keyboardType: TextInputType.number,
                errorMessage: "InitialDeposit cannot be empty",
                leadingIcon: Icons.account_balance_wallet,
                // return '';
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow numbers
                ],
                isRequired: true,
              ),
              TextLabel("Payment Method"),
              PaymentMethodWidget(
                initialDepositController: initialDepositController,
                phoneNumberController: phoneNumberController,
              ),
              // TextLabel("Occupation"),
              // reusableTextFormField(
              //   hintText: "Occupation",
              //   controller: occupationController,
              //   keyboardType: TextInputType.name,
              //   leadingIcon: Icons.work,
              // ),
              // TextLabel("MonthlyIncome"),
              // monthlyIncomeWidget(),
              // TextLabel("InitialDeposit"),
              // reusableTextFormField1(
              //   hintText: "InitialDeposit",
              //   controller: initialDepositController,
              //   keyboardType: TextInputType.number,
              //   errorMessage: "InitialDeposit cannot be empty",
              //   leadingIcon: Icons.account_balance,
              //   // return '';
              //   inputFormatters: [
              //     FilteringTextInputFormatter.digitsOnly, // Only allow numbers
              //     // LengthLimitingTextInputFormatter(9), // Limit to 9 digits
              //   ],
              // ),
              // TextLabel("Payment Method"),
              // paymentMethod(),
            ],
          ),
        ),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "Payment"),
        isActive: _activeStepIndex >= 5,
        state: _activeStepIndex > 5 ? StepState.complete : StepState.indexed,
        content: Form(
          key: globalFormKey5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextLabel("Title"),
              ReusableDropdown(
                selectedValue: selectedTitle,

                items: ListContants.title,
                hintText: 'Select title',
                onChanged: (newStatus) {
                  setState(() {
                    selectedTitle = newStatus!;
                  });
                },
                prefixIcon: Icons.person_outline,
                errorMessage:
                    'Please select a title', // Pass the custom error message
                isRequired: false, // Make the field required
              ),
              TextLabel("Full Name"),
              ReusableTextFormField(
                hintText: "Full Name",
                controller: fullNameController,
                keyboardType: TextInputType.text,
                errorMessage: "Full Name cannot be empty",
                leadingIcon: Icons.person,
                isRequired: true,
              ),

              TextLabel("SurName"),
              ReusableTextFormField(
                hintText: "SurName",
                controller: surNameController,
                keyboardType: TextInputType.text,
                errorMessage: "SurName cannot be empty",
                leadingIcon: Icons.person,
                isRequired: false,
              ),

              if (selectedCustomerType == 'INDIVIDUAL')
                TextLabel("Date of Birth"),
              if (selectedCustomerType == 'ORGANIZATION')
                TextLabel("Date of Estabilishment"),

              DatePickerField(
                controller: dateOfBirthController,
                hintText: (selectedCustomerType == 'INDIVIDUAL')
                    ? 'Date of Birth'
                    : "Date of Establishment",
                prefixIcon: Icons.date_range,
                initialDate: DateTime.now().add(const Duration(days: -10000)),
                firstDate: DateTime(1940),
                lastDate: DateTime.now(),
                isRequired: true,
                errorMessage: 'Please select a date of birth',
              ),

              // dateOfBirthWidget(),
              if (selectedCustomerType == 'INDIVIDUAL')
                TextLabel("Marital Status"),
              if (selectedCustomerType == 'INDIVIDUAL')
                ReusableDropdown(
                  selectedValue: selectedMaritalStatus,
                  items: ListContants.maritalStatuses,
                  hintText: 'Select Marital Status',
                  onChanged: (newStatus) {
                    setState(() {
                      selectedMaritalStatus = newStatus!;
                    });
                  },
                  prefixIcon: Icons.family_restroom,
                  errorMessage:
                      'Please select a marital status', // Pass the custom error message
                  isRequired: false, // Make the field required
                ),
              if (selectedCustomerType == 'INDIVIDUAL') TextLabel("Gender"),
              //Gender
              if (selectedCustomerType == 'INDIVIDUAL') genderWidget1(),

              // TextLabel("Full Name"),
              // reusableTextFormField1(
              //   hintText: "Full Name",
              //   controller: fullNameController,
              //   errorMessage: "Full Name cannot be empty",
              //   leadingIcon: Icons.person,
              // ),
              // TextLabel("SurName"),
              // reusableTextFormField1(
              //   hintText: "SurName",
              //   controller: surNameController,
              //   errorMessage: "SurName cannot be empty",
              //   leadingIcon: Icons.person,
              // ),

              // TextLabel("Mother Name"),
              // reusableTextFormField(
              //   hintText: "Mother Name",
              //   controller: motherNameController,
              //   // errorMessage: "Mother Name cannot be empty",
              //   leadingIcon: Icons.person,
              // ),
              // TextLabel("Date of Birth"),
              // dateOfBirthWidget(),
              // TextLabel("Gender"),
              // //Gender
              // genderWidget1(),
            ],
          ),
        ),
      ),
      Step(
        title: Text(isSmallScreen ? "" : "Personal Information "),
        isActive: _activeStepIndex >= 6,
        state: _activeStepIndex > 6 ? StepState.complete : StepState.indexed,
        content: Form(
            key: globalFormKey6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextLabel("State"),
                ReusableDropdown(
                  selectedValue: selectedState,
                  items: ListContants.ethiopianStates,
                  hintText: 'Select State',
                  onChanged: (newState) {
                    setState(() {
                      selectedState = newState;
                      print(selectedState);
                    });
                  },
                  errorMessage: 'Please select a state',
                  prefixIcon: Icons.map,
                  isRequired: false,
                ),

                TextLabel("Zone Subcity"),
                ReusableTextFormField(
                  hintText: "Zone Subcity",
                  controller: cityController,
                  // keyboardType: TextInputType.number,
                  errorMessage: "Zone Subcity cannot be empty",
                  leadingIcon: Icons.location_city,
                  isRequired: false,
                ),

                TextLabel("Woreda"),
                ReusableTextFormField(
                  hintText: "Woreda",
                  controller: woredaController,
                  // keyboardType: TextInputType.number,
                  errorMessage: "Woreda cannot be empty",
                  leadingIcon: Icons.location_city,
                  isRequired: false,
                ),

                TextLabel("Legal ID"),
                ReusableTextFormField(
                  hintText: "Legal ID",
                  controller: legalIDController,
                  // keyboardType: TextInputType.number,
                  errorMessage: "Legal ID cannot be empty",
                  leadingIcon: Icons.badge,
                  isRequired: false,
                ),
                TextLabel("ISSUE AUTHORITY"),

                ReusableTextFormField(
                  hintText: "ISSUE AUTHORITY",
                  controller: issueAuthorityController,
                  // keyboardType: TextInputType.number,
                  errorMessage: "ISSUE AUTHORITY cannot be empty",
                  leadingIcon: Icons.verified,
                  isRequired: false,
                ),

                TextLabel("ISSUE DATE"),
                DatePickerField(
                  controller: issueDateController,
                  hintText: 'Issue Date',
                  prefixIcon: Icons.calendar_today,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(
                      const Duration(days: 365 * 15)), // 15 years before today
                  lastDate: DateTime.now(),
                  isRequired: false,
                  errorMessage: 'Please select an issue date',
                ),

                TextLabel("EXPIRY DATE"),
                DatePickerField(
                  controller: expireDateController,
                  hintText: 'Expire Date',
                  prefixIcon: Icons.event_busy,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(), // First date is today
                  lastDate: DateTime.now().add(const Duration(days: 365 * 12)),
                  isRequired: false,
                  errorMessage: 'Please select an expire date',
                ),
                // TextLabel("Country"),
                // countryWidget(),
                // TextLabel("State"),
                // stateWidget(),
                // TextLabel("City"),
                // reusableTextFormField1(
                //   hintText: "City",
                //   controller: cityController,
                //   errorMessage: "City cannot be empty",
                //   leadingIcon: Icons.location_city,
                // ),
                // TextLabel("StreetAddress"),
                // reusableTextFormField1(
                //   hintText: "StreetAddress",
                //   controller: streetController,
                //   errorMessage: "StreetAddress cannot be empty",
                //   leadingIcon: Icons.location_city,
                // ),
                // TextLabel("ZipCode"),
                // reusableTextFormField(
                //   hintText: "ZipCode",
                //   controller: zipCodeController,
                //   keyboardType: TextInputType.number,
                //   leadingIcon: Icons.code,
                // ),
              ],
            )
            //signatureWidget(),
            ),
      ),

      /// INITIAL AMOUNT
      Step(
        title: Text(isSmallScreen ? "" : "Address "),
        isActive: _activeStepIndex >= 7,
        state: _activeStepIndex > 7 ? StepState.complete : StepState.indexed,
        content: Form(
            key: globalFormKey7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Type',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(
                  height: 20,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['Conventional', 'Alhuda'].map((bankingType) {
                    bool isSelected = selectedBankingType == bankingType;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBankingType = bankingType;
                          _filterAccountTypes(
                              bankingType); // Filter account types based on selected banking type
                          // selectedAccountTypeId =
                          //     null; // Reset account type selection
                        });
                      },
                      child: Card(
                        color: isSelected ? Colors.blue : Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Text(
                            bankingType,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

// Account Type List with Cards
                // TextLabel("Account Type"),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: filteredAccountTypes.map<Widget>((accountType) {
                      bool isSelected =
                          selectedAccountTypeId == accountType['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAccountTypeId = accountType['name'];
                            // selectedAccountId = accountType[
                            //     'id']; // Save the selected account ID
                            print(
                                'Selected Account Type ID: $selectedAccountTypeId');
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            margin: const EdgeInsets.all(10),
                            color: isSelected ? Colors.blue : Colors.white,
                            // elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 2),
                              child: ListTile(
                                title: Text(
                                  accountType['name'] as String,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  (int.tryParse(accountType['maxAge']
                                                      ?.toString() ??
                                                  '') ??
                                              0) >
                                          100
                                      ? 'Minimum Age: ${int.tryParse(accountType['minAge']?.toString() ?? '') != null ? int.parse(accountType['minAge'].toString()) : '___'}\n'
                                          'Min Amount: ${accountType['minAmount']}'
                                      : 'Age Range: ${int.tryParse(accountType['minAge']?.toString() ?? '') != null ? int.parse(accountType['minAge'].toString()) : '___'} - ${int.tryParse(accountType['maxAge']?.toString() ?? '0') ?? 0}\n'
                                          'Min Amount: ${accountType['minAmount']}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            )),
      ),
    ];
  }

  Padding idTypeWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: DropdownButtonFormField<String>(
        value: selectedIdType,
        hint: const Text(
          'Id Type',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
        ),
        items: iDType.map((String id) {
          return DropdownMenuItem<String>(
            value: id,
            child: Text(
              id.replaceAll('_', ' '),
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (String? idType) {
          setState(() {
            selectedIdType = idType!;
          });
        },
        validator: (String? value) {
          if (value == null) {
            return 'Id *';
          }
          return null;
        },
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          prefixIcon: Icon(Icons.perm_identity),
        ),
      ),
    );
  }

  // Column idCardPhoto() {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
  //         child: Text(
  //           "Front Photo of  ${selectedIdType.replaceAll('_', ' ')}  ",
  //           style: const TextStyle(
  //             fontSize: 13,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //       Center(
  //         child: Column(
  //           children: [
  //             const SizedBox(height: 20.0),
  //             Container(
  //               height: 150.0,
  //               width: MediaQuery.of(context).size.width * 0.8,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(20.0),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.1),
  //                     blurRadius: 10,
  //                     offset: const Offset(0, 5),
  //                   ),
  //                 ],
  //               ),
  //               child: residentPath.isEmpty
  //                   ? Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         const Icon(
  //                           Icons.add_a_photo,
  //                           color: Colors.black,
  //                           size: 50.0,
  //                         ),
  //                         const SizedBox(height: 5.0),
  //                         Text(
  //                           'Upload or Take Front Photo of ${selectedIdType.replaceAll('_', ' ')} ',
  //                           textAlign: TextAlign.center,
  //                           style: const TextStyle(
  //                             fontSize: 12.0,
  //                             color: Colors.black,
  //                           ),
  //                         ),
  //                       ],
  //                     )
  //                   : (residentPath.startsWith('http')
  //                       ? Image.network(
  //                           residentPath,
  //                           height: 180.0,
  //                           width: MediaQuery.of(context).size.width * 0.7,
  //                           fit: BoxFit.fill,
  //                         )
  //                       : (residentPath.startsWith('/9j/')
  //                           ? Image.memory(
  //                               base64Decode(residentPath),
  //                               height: 180.0,
  //                               width: MediaQuery.of(context).size.width * 0.7,
  //                               fit: BoxFit.fill,
  //                             )
  //                           : ClipRRect(
  //                               borderRadius: BorderRadius.circular(20.0),
  //                               child: Image.file(
  //                                 File(
  //                                     residentPath), // Use the file path if it's not base64
  //                                 height: 190.0,
  //                                 width:
  //                                     MediaQuery.of(context).size.width * 0.7,
  //                                 fit: BoxFit.fill,
  //                               ),
  //                             ))),
  //             ),
  //             const SizedBox(height: 20.0),
  //             ElevatedButton.icon(
  //               onPressed: () async {
  //                 _imgFromGallery("resident");
  //               },
  //               icon: const Icon(Icons.photo_library),
  //               label: const Text('Upload from Gallery'),
  //               style: ElevatedButton.styleFrom(
  //                 foregroundColor: Colors.white,
  //                 backgroundColor: Colors.black,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(20.0),
  //                 ),
  //                 textStyle: const TextStyle(
  //                   fontSize: 13.0,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //             ElevatedButton.icon(
  //               onPressed: () async {
  //                 _imgFromCamera("resident");
  //               },
  //               icon: const Icon(Icons.camera_alt),
  //               label: const Text('Take a Photo'),
  //               style: ElevatedButton.styleFrom(
  //                 foregroundColor: Colors.white,
  //                 backgroundColor: Colors.black,
  //                 padding: const EdgeInsets.symmetric(
  //                   vertical: 8.0,
  //                   horizontal: 17.0,
  //                 ),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(20.0),
  //                 ),
  //                 textStyle: const TextStyle(
  //                   fontSize: 14.0,
  //                   color: Colors.black,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(
  //         height: 10,
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
  //         child: Text(
  //           "Back Photo of ${selectedIdType.replaceAll('_', ' ')}",
  //           style: const TextStyle(
  //             fontSize: 13,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //       Center(
  //         child: Column(
  //           children: [
  //             const SizedBox(height: 20.0),
  //             Container(
  //               height: 150.0,
  //               width: MediaQuery.of(context).size.width * 0.8,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(20.0),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.1),
  //                     blurRadius: 10,
  //                     offset: const Offset(0, 5),
  //                   ),
  //                 ],
  //               ),
  //               child: residentCardBackPath.isEmpty
  //                   ? Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         const Icon(
  //                           Icons.add_a_photo,
  //                           color: Colors.black,
  //                           size: 50.0,
  //                         ),
  //                         const SizedBox(height: 5.0),
  //                         Text(
  //                           'Upload or Take Back Photo of  ${selectedIdType.replaceAll('_', ' ')} ',
  //                           textAlign: TextAlign.center,
  //                           style: const TextStyle(
  //                             fontSize: 12.0,
  //                             color: Colors.black,
  //                           ),
  //                         ),
  //                       ],
  //                     )
  //                   : (residentCardBackPath.startsWith('http')
  //                       ? Image.network(
  //                           residentCardBackPath,
  //                           height: 180.0,
  //                           width: MediaQuery.of(context).size.width * 0.7,
  //                           fit: BoxFit.fill,
  //                         )
  //                       : (residentCardBackPath.startsWith('/9j/')
  //                           ? Image.memory(
  //                               base64Decode(residentCardBackPath),
  //                               height: 180.0,
  //                               width: MediaQuery.of(context).size.width * 0.7,
  //                               fit: BoxFit.fill,
  //                             )
  //                           : ClipRRect(
  //                               borderRadius: BorderRadius.circular(20.0),
  //                               child: Image.file(
  //                                 File(
  //                                     residentCardBackPath), // Use the file path if it's not base64
  //                                 height: 190.0,
  //                                 width:
  //                                     MediaQuery.of(context).size.width * 0.7,
  //                                 fit: BoxFit.fill,
  //                               ),
  //                             ))),
  //             ),
  //             const SizedBox(height: 20.0),
  //             ElevatedButton.icon(
  //               onPressed: () async {
  //                 _imgFromGallery("residentCardBack");
  //               },
  //               icon: const Icon(Icons.photo_library),
  //               label: const Text('Upload from Gallery'),
  //               style: ElevatedButton.styleFrom(
  //                 foregroundColor: Colors.white,
  //                 backgroundColor: Colors.black,
  //                 padding: const EdgeInsets.symmetric(
  //                   vertical: 5.0,
  //                   horizontal: 21.0,
  //                 ),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(20.0),
  //                 ),
  //                 textStyle: const TextStyle(
  //                   fontSize: 13.0,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //             ElevatedButton.icon(
  //               onPressed: () async {
  //                 _imgFromCamera("passport");
  //               },
  //               icon: const Icon(Icons.camera_alt),
  //               label: const Text('Take a Photo'),
  //               style: ElevatedButton.styleFrom(
  //                 foregroundColor: Colors.white,
  //                 backgroundColor: Colors.black,
  //                 padding: const EdgeInsets.symmetric(
  //                   vertical: 8.0,
  //                   horizontal: 17.0,
  //                 ),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(20.0),
  //                 ),
  //                 textStyle: const TextStyle(
  //                   fontSize: 14.0,
  //                   color: Colors.black,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(
  //         height: 40,
  //       )
  //     ],
  //   );
  // }

  Column idCardPhoto() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
          child: Text(
            "Front Photo of  $selectedDocumentType ",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              Container(
                height: 150.0,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: residentPath.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/id_front.png',
                              height: 150.0,
                              width: MediaQuery.of(context).size.width * 0.7,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      )
                    : (residentPath.startsWith('http')
                        ? Image.network(
                            residentPath,
                            height: 180.0,
                            width: MediaQuery.of(context).size.width * 0.7,
                            fit: BoxFit.fill,
                          )
                        : (residentPath.startsWith('/9j/')
                            ? Image.memory(
                                base64Decode(residentPath),
                                height: 180.0,
                                width: MediaQuery.of(context).size.width * 0.7,
                                fit: BoxFit.fill,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.file(
                                  File(
                                      residentPath), // Use the file path if it's not base64
                                  height: 190.0,
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  fit: BoxFit.fill,
                                ),
                              ))),
              ),
              const SizedBox(height: 20.0),
              ButtonUploadTakePhoto(
                onUploadPressed: () => _imgFromGallery("resident"),
                onCapturePressed: () => _imgFromCamera("resident"),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
          child: Text(
            "Back Photo of $selectedDocumentType",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              Container(
                height: 150.0,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: residentCardBackPath.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/backpage.png',
                              height: 150.0,
                              width: MediaQuery.of(context).size.width * 0.7,
                              fit: BoxFit.fill,
                            ),
                          )
                        ],
                      )
                    : (residentCardBackPath.startsWith('http')
                        ? Image.network(
                            residentCardBackPath,
                            height: 180.0,
                            width: MediaQuery.of(context).size.width * 0.7,
                            fit: BoxFit.fill,
                          )
                        : (residentCardBackPath.startsWith('/9j/')
                            ? Image.memory(
                                base64Decode(residentCardBackPath),
                                height: 180.0,
                                width: MediaQuery.of(context).size.width * 0.7,
                                fit: BoxFit.fill,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.file(
                                  File(
                                      residentCardBackPath), // Use the file path if it's not base64
                                  height: 190.0,
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  fit: BoxFit.fill,
                                ),
                              ))),
              ),
              const SizedBox(height: 20.0),
              ButtonUploadTakePhoto(
                onUploadPressed: () => _imgFromGallery("residentCardBack"),
                onCapturePressed: () => _imgFromCamera("residentCardBack"),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        )
      ],
    );
  }

  Padding paymentMethod() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        children: [
          // Payment Method Dropdown
          DropdownButtonFormField<String>(
            value: selectedPaymentMethod,
            hint: const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 13, color: Colors.black),
            ),
            items: ['Cash', 'Transfer'].map((String method) {
              return DropdownMenuItem<String>(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: (String? newMethod) {
              setState(() {
                selectedPaymentMethod = newMethod;
                isBankTransferSelected = newMethod == 'Transfer';
                isBankTransferIconClicked = false; // Reset icon click state
              });
            },
            validator: (String? value) {
              if (value == null) {
                return 'Please select a payment method';
              }
              return null;
            },
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.black),
              ),
              prefixIcon: Icon(Icons.payment),
            ),
          ),
          const SizedBox(height: 10),

          if (isBankTransferSelected)
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isBankTransferIconClicked =
                          !isBankTransferIconClicked; // Toggle fields visibility
                    });
                  },
                  child: Image.asset(
                    'assets/ebirr.png',
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 10),
                if (isBankTransferIconClicked) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
                    child: TextFormField(
                      controller: phoneNumberController,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Only allow numbers
                        LengthLimitingTextInputFormatter(9),
                      ],
                      decoration: const InputDecoration(
                        isDense: true,

                        hintText: "Phone Number",
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 10.0), // Adjust padding as needed
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.black),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            '+251',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the phone number';
                        } else if (value.length != 9) {
                          return 'Phone number must be 9 digits';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          phoneNumber = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
                    child: TextFormField(
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      controller: initialDepositController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        isDense: true,
                        hintText: "Amount",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(top: 10, left: 3),
                          child: Text('ETB', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the amount';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          amount = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print("Phone Number: $phoneNumber, Amount: $amount");
                      },
                      child: Text('Send'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue, // White text
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  // Column personalPhoto() {
  //   return Column(
  //     children: [
  //       Center(
  //         child: Column(
  //           children: [
  //             const SizedBox(height: 10.0),
  //             Container(
  //               height: 150.0,
  //               width: MediaQuery.of(context).size.width * 0.8,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(20.0),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.1),
  //                     blurRadius: 10,
  //                     offset: const Offset(0, 5),
  //                   ),
  //                 ],
  //               ),
  //               child: profilePath.isEmpty
  //                   ? const Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Icon(
  //                           Icons.add_a_photo,
  //                           color: Colors.black,
  //                           size: 50.0,
  //                         ),
  //                         SizedBox(height: 5.0),
  //                         Text(
  //                           'Upload or Take a Photo ',
  //                           style: TextStyle(
  //                             fontSize: 17.0,
  //                             color: Colors.black,
  //                           ),
  //                         ),
  //                       ],
  //                     )
  //                   : (profilePath.startsWith('http') ||
  //                           profilePath.startsWith('https')
  //                       ? Image.network(
  //                           profilePath,
  //                           height: 180.0,
  //                           width: MediaQuery.of(context).size.width * 0.7,
  //                           fit: BoxFit.fill,
  //                         )
  //                       : (profilePath.startsWith('/9j/')
  //                           ? Image.memory(
  //                               base64Decode(profilePath),
  //                               height: 180.0,
  //                               width: MediaQuery.of(context).size.width * 0.7,
  //                               fit: BoxFit.fill,
  //                             )
  //                           : ClipRRect(
  //                               borderRadius: BorderRadius.circular(20.0),
  //                               child: Image.file(
  //                                 File(
  //                                     profilePath), // Use the file path if it's not base64
  //                                 height: 190.0,
  //                                 width:
  //                                     MediaQuery.of(context).size.width * 0.7,
  //                                 fit: BoxFit.fill,
  //                               ),
  //                             ))),
  //               // : ClipRRect(
  //               //     borderRadius: BorderRadius.circular(20.0),
  //               //     child: Image.file(
  //               //       File(profilePath),
  //               //       height: 180.0,
  //               //       width: MediaQuery.of(context).size.width * 0.7,
  //               //       fit: BoxFit.cover, // Use cover for better fit
  //               //     ),
  //               //   ),
  //             ),

  //             const SizedBox(height: 20.0),

  //             // Button to upload from gallery
  //             ElevatedButton.icon(
  //               onPressed: () async {
  //                 _imgFromGallery("profile");
  //               },
  //               icon: const Icon(Icons.photo_library),
  //               label: const Text('Upload from Gallery'),
  //               style: ElevatedButton.styleFrom(
  //                 foregroundColor: Colors.white,
  //                 backgroundColor: Colors.black,
  //                 padding: const EdgeInsets.symmetric(
  //                   vertical: 5.0,
  //                   horizontal: 21.0,
  //                 ),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(20.0),
  //                 ),
  //                 textStyle: const TextStyle(
  //                   fontSize: 13.0,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),

  //             ElevatedButton.icon(
  //               onPressed: () async {
  //                 _imgFromCamera("profile");
  //                 // _pickImage(
  //                 //     ImageSource.camera); // Take a photo with camera
  //               },
  //               icon: const Icon(Icons.camera_alt),
  //               label: const Text('Take a Photo'),
  //               style: ElevatedButton.styleFrom(
  //                 foregroundColor: Colors.white,
  //                 backgroundColor: Colors.black,
  //                 padding: const EdgeInsets.symmetric(
  //                   vertical: 8.0,
  //                   horizontal: 17.0,
  //                 ),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(20.0),
  //                 ),
  //                 textStyle: const TextStyle(
  //                   fontSize: 14.0,
  //                   color: Colors.black,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(
  //         height: 40,
  //       )
  //     ],
  //   );
  // }

  Column personalPhoto() {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              Container(
                height: 200.0,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: profilePath.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/photo1.png',
                              height: 170.0,
                              width: MediaQuery.of(context).size.width * 0.6,
                              fit: BoxFit.fill,
                            ),
                          )
                        ],
                      )
                    : (profilePath.startsWith('http') ||
                            profilePath.startsWith('https')
                        ? Image.network(
                            profilePath,
                            height: 180.0,
                            width: MediaQuery.of(context).size.width * 0.7,
                            fit: BoxFit.fill,
                          )
                        : (profilePath.startsWith('/9j/')
                            ? Image.memory(
                                base64Decode(profilePath),
                                height: 180.0,
                                width: MediaQuery.of(context).size.width * 0.7,
                                fit: BoxFit.fill,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.file(
                                  File(
                                      profilePath), // Use the file path if it's not base64
                                  height: 190.0,
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  fit: BoxFit.fill,
                                ),
                              ))),
              ),
              const SizedBox(height: 40.0),
              ButtonUploadTakePhoto(
                onUploadPressed: () => _imgFromGallery("profile"),
                onCapturePressed: () => _imgFromCamera("profile"),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        )
      ],
    );
  }

  Column signatureWidget1(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
            child: Container(
              height: 180,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                  ),
                ],
              ),
              child: savedSignature != null
                  ? Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.memory(
                          savedSignature!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : (signatureImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.file(
                            File(signatureImagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Draw or Upload a Signature',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),
                        )),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _showDrawSignatureDialog(context);
                      }, // Disable button if a signature is drawn or uploaded
                      icon: const Icon(Icons.draw),
                      label: const Text(' Draw Signature'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 17.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showImagePicker(context, "signature");
                      }, // Disable button if a signature is drawn or uploaded
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Upload or Take '),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 17.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Call API and update controllers
  Future<void> callApiAndUpdateControllers(Uint8List residentBytes) async {
    try {
      // API endpoint
      final url = Uri.parse('http://192.168.137.172:5000/process_id');

      // Prepare multipart request
      final request = http.MultipartRequest('POST', url);

      // Add the residentBytes as an image file
      request.files.add(http.MultipartFile.fromBytes(
        'image', // Field name in the API
        residentBytes,
        filename: 'residence_card.png', // Optional: Provide a filename
        contentType: MediaType('image', 'png'), // Set the appropriate MIME type
      ));

      // Send the multipart request
      final response = await request.send();

      if (response.statusCode == 200) {
        // Parse the response JSON
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);

        // Update TextEditingControllers
        setState(() {
          fullNameController.text =
              '${data['first_name']} ${data['middle_name']}';
          surNameController.text = data['surname'];
          String formattedDate = "";
          if (data['date_of_birth'] != null) {
            DateTime parsedDate = DateTime.parse(data['date_of_birth']);
            formattedDate = DateFormat('yyyy-MM-dd')
                .format(parsedDate); // Change to '-' separator
          }
          selectedGender = data['gender'].toUpperCase();
          dateController.text = formattedDate;
        });

        print("Controllers updated successfully");
      } else {
        print("Failed to call API: ${response.statusCode}");
      }
    } catch (e) {
      print("Error calling API: $e");
    }
  }

  void _showDrawSignatureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Draw Signature'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: Signature(
              controller: _signatureController,
              backgroundColor: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Clear'),
              onPressed: () {
                _signatureController.clear();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (_signatureController.isNotEmpty) {
                  // Capture the signature as an image
                  final signatureImage = await _signatureController.toImage();
                  final byteData = await signatureImage!
                      .toByteData(format: ImageByteFormat.png);

                  setState(() {
                    savedSignature = byteData!.buffer.asUint8List();
                    // isSignatureDrawn = true;
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget branchSelectorWidget1() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: selectedBranch,
            hint: const Text('Choose a branch'),
            onChanged: (String? newValue) {
              setState(() {
                selectedBranch = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Branch is required';
              }
              return null;
            },
            items: allBranches.map<DropdownMenuItem<String>>((branch) {
              return DropdownMenuItem<String>(
                value: branch['companyName'] ?? '',
                child: Text(branch['companyName'] ?? ''),
              );
            }).toList(),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.blue),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.red),
              ),
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
        ],
      ),
    );
  }

  void initializeBranches() async {
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);

      // Get regular branches
      List<Map<String, dynamic>> regularBranches =
          decodedToken.containsKey("branch")
              ? List<Map<String, dynamic>>.from(decodedToken["branch"])
              : [];

      setState(() {
        allBranches = [];

        // Add main branch first if it exists
        if (decodedToken.containsKey("mainBranch")) {
          allBranches.add(decodedToken["mainBranch"]);
          // Set main branch as default selected branch
          // selectedBranch = decodedToken["mainBranch"]["companyName"];
        }

        // Add regular branches
        allBranches.addAll(regularBranches);
      });
    }
  }

  Center signatureCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
        child: Container(
            height: 200,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                ),
              ],
            ),
            child: _combinedSignature != null
                ? Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.memory(
                        _combinedSignature!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
                      'assets/signature.png',
                      height: 10.0,
                      width: MediaQuery.of(context).size.width * 0.1,
                      fit: BoxFit.contain,
                    ),
                  )),
      ),
    );
  }

  Padding signaturePadSelection() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _showSignaturePadDialog(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            child: const Text("      Sign     "),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              showImagePicker(context, "signature");
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            child: const Text("Upload"),
          ),
        ],
      ),
    );
  }

  void _showSignaturePadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Draw Signatures',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // First Signature
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Signature(
                          controller: _signatureController1,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("Signature 1"),
                          TextButton(
                            onPressed: () => clearSignature(1),
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Second Signature
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Signature(
                          controller: _signatureController2,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Signature 2"),
                          TextButton(
                            onPressed: () => clearSignature(2),
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Third Signature
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Signature(
                          controller: _signatureController3,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Signature 3"),
                          TextButton(
                            onPressed: () => clearSignature(3),
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (areAllSignaturesCompleted()) {
                            _saveCombinedSignature();
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please complete all signatures'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool areAllSignaturesCompleted() {
    return _signatureController1.isNotEmpty &&
        _signatureController2.isNotEmpty &&
        _signatureController3.isNotEmpty;
  }

  void clearSignature(int index) {
    setState(() {
      switch (index) {
        case 1:
          _signatureController1.clear();
          break;
        case 2:
          _signatureController2.clear();
          break;
        case 3:
          _signatureController3.clear();
          break;
      }
    });
  }

  Future<Uint8List?> _combineSignatures() async {
    // Get individual signature bytes
    final signature1 = await _signatureController1.toPngBytes();
    final signature2 = await _signatureController2.toPngBytes();
    final signature3 = await _signatureController3.toPngBytes();

    if (signature1 == null || signature2 == null || signature3 == null) {
      print("One or more signatures are empty!");
      return null;
    }

    final ui.Image image1 = await decodeImageFromList(signature1);
    final ui.Image image2 = await decodeImageFromList(signature2);
    final ui.Image image3 = await decodeImageFromList(signature3);

    // Calculate the total width and height (maximum height of all signatures)
    final int totalWidth =
        image1.width + image2.width + image3.width + 20; // Add spacing
    final int maxHeight = [image1.height, image2.height, image3.height]
        .reduce((a, b) => a > b ? a : b);

    // Draw the images onto a single canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromLTWH(0, 0, totalWidth.toDouble(), maxHeight.toDouble()));

    double currentX = 0;

    // Draw signature 1
    canvas.drawImage(image1, Offset(currentX, 0), Paint());
    currentX += image1.width.toDouble() + 10; // Add spacing

    // Draw signature 2
    canvas.drawImage(image2, Offset(currentX, 0), Paint());
    currentX += image2.width.toDouble() + 10;

    // Draw signature 3
    canvas.drawImage(image3, Offset(currentX, 0), Paint());

    // End the recording
    final picture = recorder.endRecording();
    final combinedImage = await picture.toImage(totalWidth, maxHeight);

    // Convert the combined image to bytes
    final byteData =
        await combinedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  void _saveCombinedSignature() async {
    final Uint8List? combinedImage = await _combineSignatures();

    // Check if all signature pads are signed
    if (!areAllSignaturesCompleted()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete all signature pads before saving."),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop execution if not all pads are signed
    }
    if (combinedImage != null) {
      setState(() {
        _combinedSignature = combinedImage; // Store the combined signature
      });
      // Example: Save to a file
      final file = File('${Directory.systemTemp.path}/combined_signature.png');
      await file.writeAsBytes(combinedImage);
      print("Saved combined image at: ${file.path}");
    } else {
      print("Failed to generate combined signature image.");
    }
  }

  void _filterAccountTypes(String bankingType) {
    print("Filtering account types...");
    setState(() {
      // Get user's age from date of birth
      DateTime? dateOfBirth;
      try {
        dateOfBirth = DateTime.parse(dateOfBirthController.text);
      } catch (e) {
        print('Invalid date format: ${dateOfBirthController.text}');
        return;
      }

      int age = DateTime.now().year - dateOfBirth.year;
      if (DateTime.now().month < dateOfBirth.month ||
          (DateTime.now().month == dateOfBirth.month &&
              DateTime.now().day < dateOfBirth.day)) {
        age--;
      }

      // Normalize gender
      String normalizedGender = selectedGender!.trim().toUpperCase();

      // Parse initial deposit
      double initialDeposit =
          double.tryParse(initialDepositController.text) ?? 0;

      filteredAccountTypes = accountTypes.where((accountType) {
        print("AccountType: ${accountType}");
        print("Selected Gender: $normalizedGender");

        // Check banking type
        if (accountType['bankingType'] != bankingType) {
          print(
              "BankingType mismatch: ${accountType['bankingType']} != $bankingType");
          return false;
        }

        // Validate age range
        int minAge = int.tryParse(accountType['minAge']?.trim() ?? '0') ?? 0;
        int maxAge =
            int.tryParse(accountType['maxAge']?.trim() ?? '999') ?? 999;
        if (age < minAge || age > maxAge) {
          print("Age out of range: $age not in [$minAge, $maxAge]");
          return false;
        }

        // Validate minimum amount
        double minAmount =
            double.tryParse(accountType['minAmount']?.toString() ?? '0') ?? 0;
        if (initialDeposit < minAmount) {
          print(
              "Initial deposit $initialDeposit less than required $minAmount");
          return false;
        }

        // Validate sex with 'BOTH' inclusion
        String accountTypeSex =
            accountType['sex']?.trim().toUpperCase() ?? 'BOTH';
        if (accountTypeSex != 'BOTH' && accountTypeSex != normalizedGender) {
          print("Gender mismatch: $normalizedGender != $accountTypeSex");
          return false;
        }

        print("Account type matches!");
        return true;
      }).toList();

      // Show feedback if no account types match
      if (filteredAccountTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No account types available for your age ($age), gender ($selectedGender), and deposit ($initialDeposit)',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  String escapeSpecialChars(String input) {
    return input.replaceAll("'", "\\'");
  }

  Future<void> _initializeGlobal() async {
    List<Map<String, dynamic>> fetchedAccountTypes =
        await networkHandler.fetchAccountTypesFromDatabase();

    setState(() {
      accountTypes =
          fetchedAccountTypes; // Update the state with the fetched account types
    });
  }

  handlefirstStep() {
    if (GlobalData().role != 'ACCOUNT-CREATOR' ) {
      print(GlobalData().role);
      registerStatus = false;
      FormHelper.showSimpleAlertDialog(
        context,
        "Coop Engage +",
        "You dont have permission to create Account",
        "OK",
        () {
          Navigator.of(context).pop();
        },
      );
    }
  }
}
