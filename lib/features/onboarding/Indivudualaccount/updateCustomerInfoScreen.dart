// ignore_for_file: unused_local_variable, constant_identifier_names, unused_element, avoid_print, unused_import, unnecessary_import, prefer_typing_uninitialized_variables, file_names, non_constant_identifier_names, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, deprecated_member_use, sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:coopengageplus/NetworkHandler.dart';
import 'package:coopengageplus/common_widgets/dropDown/DatePickerField.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/common_widgets/textField/PaymentMethod.dart';
import 'package:coopengageplus/common_widgets/textField/PhoneNumberWidget.dart';
import 'package:coopengageplus/common_widgets/textField/emailWidget.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/features/onboarding/pages/ConfirmationPage.dart';
import 'package:coopengageplus/features/onboarding/pages/home/HomePage.dart';
import 'package:coopengageplus/features/onboarding/pages/updateConfirmationPage.dart';
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

var selectedAccountTypeData;
Uint8List? residenceFront;
String? selectedMaritalStatus;
String? selectedCustomerType;
String? selectedDocumentType;
String? selectedSector;
bool registerStatus = true;
String? signaturePath;
int selectedAccountTypeValue = 1;
String? signatureUrl;
List<String> branchNames = [];
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
  String? selectedAccountTypeIdValue;
  List<Map<String, dynamic>> filteredAccountTypes =
      []; // Declare the selectedGender variable
  final List<String> genders = ['MALE', 'FEMALE'];
  List<Map<String, dynamic>> accountTypes = [];
  final Map<String, dynamic> registrationData = {};
  final Map<String, dynamic> registrationFormData = {};
  Future<void> _initializeGlobalData() async {
    await GlobalData().fetchToken();
    GlobalData().initializeBranches();

    setState(() {});
  }

  bool isEditingAccountType = false;
  late bool showAccountSelector;

  @override
  void initState() {
    loadSignature();
    _initializeGlobalData();
    _signatureController1 = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 5,
      exportBackgroundColor: Colors.transparent,
    );
    showAccountSelector =
        widget.userInfo['accountType'] == "1" || isEditingAccountType;
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
    print(phoneNumber.runtimeType);
    phoneNumber = phoneNumber.trim();
    print(phoneNumber.startsWith('0'));

    if (phoneNumber.startsWith('251')) {
      phoneNumber = phoneNumber.substring(3).trim();
    } else if (phoneNumber.startsWith('+251')) {
      phoneNumber = phoneNumber.substring(4).trim();
    } else if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1).trim();
    } else {
      phoneNumber = phoneNumber;
    }
    String? userBranch = widget.userInfo['branch']?.toString();
    if (userBranch != null &&
        allBranches.any((branch) => branch['companyName'] == userBranch)) {
      selectedBranch = userBranch;
    } else {
      selectedBranch = null;
    }
    phoneNumberController.text = phoneNumber;
    selectedTitle = widget.userInfo['title'] ?? ListContants.title.first;

    if (ListContants.maritalStatuses
        .contains(widget.userInfo['maritalStatus'])) {
      selectedMaritalStatus = widget.userInfo['maritalStatus'];
    }

    if (ListContants.ethiopianStates.contains(widget.userInfo['state'])) {
      selectedState = widget.userInfo['state'];
    }
    print(widget.userInfo['signature']);
    idOne = widget.userInfo['id'];
    firstNameController.text = widget.userInfo['firstName'] ?? '';

    if (widget.userInfo['branch'] != null &&
        widget.userInfo['branch']!.isNotEmpty) {
      selectedBranch = widget.userInfo['branch'];
    }

    if (widget.userInfo['accountType'] != null &&
        widget.userInfo['accountType']!.isNotEmpty) {
      selectedAccountTypeData = widget.userInfo['accountType'].toString();
    }

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
    cityController.text = widget.userInfo['zoneSubCity'] ?? '';
    zipCodeController.text = widget.userInfo['zipCode'] ?? '';
    accountCurrencyController.text = widget.userInfo['currency'] ?? '';
    occupationController.text = widget.userInfo['occupation'] ?? '';
    dateOfBirthController.text = widget.userInfo['dateOfBirth'] ?? '';
    selectedGender = widget.userInfo["sex"];
    surNameController.text = widget.userInfo['surName'] ?? '';
    expireDateController.text = widget.userInfo['expirayDate'] ?? '';
    woredaController.text = widget.userInfo['streetAddress'] ?? '';
    issueAuthorityController.text = widget.userInfo['issueAuthority'] ?? '';
    issueDateController.text = widget.userInfo['issueDate'] ?? '';
    legalIDController.text = widget.userInfo['legalId'] ?? '';
    cityController.text = widget.userInfo['zoneSubcity'] ?? '';
    initialDepositController.text =
        widget.userInfo['initialDeposit']?.toString() ?? '';
    monthlyIncomeController.text =
        widget.userInfo['monthlyIncome']?.toString() ?? '';
    if (widget.userInfo['photo'] != null && widget.userInfo['photo'] != '') {
      if (widget.userInfo['photo'] is String) {
        profilePath = widget.userInfo['photo'];
      } else if (widget.userInfo['photo'] is Uint8List) {
        profilePath = base64Encode(widget.userInfo['photo']);
      }
    }

    if (widget.userInfo['residenceCardBack'] != null &&
        widget.userInfo['residenceCardBack'] != '') {
      if (widget.userInfo['residenceCardBack'] is String) {
        residentCardBackPath = widget.userInfo['residenceCardBack'];
      } else if (widget.userInfo['residenceCardBack'] is Uint8List) {
        residentCardBackPath =
            base64Encode(widget.userInfo['residenceCardBack']);
      }
    }

    if (widget.userInfo['residenceCard'] != null &&
        widget.userInfo['residenceCard'] != '') {
      if (widget.userInfo['residenceCard'] is String) {
        residentPath = widget.userInfo['residenceCard'];
      } else if (widget.userInfo['residenceCard'] is Uint8List) {
        residentPath = base64Encode(widget.userInfo['residenceCard']);
      }
    }
  }

  void _setDateOfBirth() {
    String? fullDateTime = widget.userInfo['dateOfBirth'];
    if (fullDateTime != null) {
      String dateOnly = fullDateTime.split(' ').first;

      try {
        DateTime dateTime = DateTime.parse(fullDateTime);
        dateOnly = DateFormat('yyyy-MM-dd').format(dateTime);
      } catch (e) {
        print('Error parsing date: $e');
      }

      dateController.text = dateOnly;
    } else {
      dateController.text = '';
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
  String signaturePath = "";
  String? mainBranches;
  List<Map<String, dynamic>> branches1 = [];
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
  String? selectedProductType;
  String initialCountry = 'ET';
  PhoneNumber number = PhoneNumber(isoCode: 'ET');
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
  // List<String> ethiopianStates = [
  //   'Addis Ababa',
  //   'Oromia',
  //   'Amhara',
  //   'Tigray',
  //   'Sidama',
  //   "Afar",
  //   "Somale",
  //   "Benishangul Gumuz",
  //   "Gambela",
  //   "Harar",
  //   "Dire Dawa"
  // ];
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey1 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey2 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey3 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey4 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey5 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey6 = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKey7 = GlobalKey<FormState>();
  List<Map<String, dynamic>> allBranches = [];
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
                  value: 'FEMALE',
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
        backgroundColor: Colors.white,
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
                  // Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const MainPage(),
                  //     ),
                  //     (route) => false);

                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.blue,
                ))),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                if (_activeStepIndex > 0)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: onStepCancel,
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.blue,
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
                                      backgroundColor: Colors.blue,
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
        if (imageTypes == 'passport') {
          passportPath = croppedFile.path;
        } else if (imageTypes == 'profile') {
          profilePath = croppedFile.path;
        } else if (imageTypes == 'resident') {
          residentPath = croppedFile.path;
        } else if (imageTypes == 'residentCardBack') {
          residentCardBackPath = croppedFile.path;
        } else if (imageTypes == 'signature') {
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

  Future<Uint8List?> _getImageBytes(String path, String tempFileName) async {
    final imageFile = File(path);

    if (await imageFile.exists()) {
      Uint8List bytes = await imageFile.readAsBytes();

      final tempFile = File('${Directory.systemTemp.path}/$tempFileName');
      await tempFile.writeAsBytes(bytes);

      print("✅ Saved temporary image at: ${tempFile.path}");
      return bytes; // Return the image bytes
    } else {
      print("❌ File does not exist at: $path");
      return null;
    }
  }

  void _clearSignature() {
    _signatureController.clear();
  }

  void _saveSignature() {}
  bool isStepComplete(int stepIndex) {
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

  void _nextStep() {}

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
      if (_activeStepIndex == 1) {
        registerStatus = true;
      }
      if (_activeStepIndex == 2) {}
      if (_activeStepIndex == 3) {}
      if (_activeStepIndex == 4) {
        registerStatus = true;
      }
      if (_activeStepIndex == 5) {
        registerStatus = true;
      }
      if (_activeStepIndex == 6) {
        isEditingAccountType = false;
        registerStatus = true;
      }
      if (isLastStep) {
        isEditingAccountType = false;
        var id;
        if (selectedAccountTypeId != null) {
          var accountTypeDetails =
              getAccountTypeDetails(selectedAccountTypeId!);

          id = accountTypeDetails != null ? accountTypeDetails['id'] : null;
          await submitFormData1();
        }

        if (id == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select account type'),
                backgroundColor: Colors.red,
              ),
            );
            registerStatus = false;
          }
        }
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
        registerStatus = true;
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

  Future<void> submitFormData1() async {
    registerStatus = true;
    Uint8List? signatureBytes = await _signatureController.toPngBytes();
    Uint8List? residentBytes;
    Uint8List? residentCardBackBytes;
    Uint8List? profileBytes;
    String phoneNumber = phoneNumberController.text;

    var id;
    var selectedAccountTypeName;
    if (selectedAccountTypeId != null) {
      var accountTypeDetails = getAccountTypeDetails(selectedAccountTypeId!);

      selectedAccountTypeData =
          accountTypeDetails != null ? accountTypeDetails['id'] : null;
      selectedAccountTypeName = accountTypeDetails?['name'];
    }

    registrationFormData['fullName'] = fullNameController.text;
    registrationFormData['surname'] = surNameController.text;
    registrationFormData['motherName'] = motherNameController.text;
    registrationFormData['phone'] = '251$phoneNumber';
    registrationFormData['email'] = emailController.text;
    registrationFormData['sex'] = selectedGender;
    registrationFormData['dateOfBirth'] = dateOfBirthController.text;
    registrationFormData['city'] = cityController.text;
    registrationFormData['country'] = selectedCountry;
    registrationFormData['state'] = selectedState;
    registrationFormData['streetAddress'] = streetController.text;
    registrationFormData['accountType'] = selectedAccountTypeData;
    registrationFormData['occupation'] = occupationController.text;
    registrationFormData['initialDeposit'] = initialDepositController.text;
    registrationFormData['monthlyIncome'] = monthlyIncomeController.text;
    registrationFormData['branch'] = selectedBranch;
    registrationFormData['currency'] = selectedCurrency;
    registrationFormData['signature'] = _combinedSignature;

    if (isOnline) {
      registrationData['customerInfo.fullName'] = fullNameController.text;
      registrationData['customerInfo.surname'] = surNameController.text;
      registrationData['customerInfo.motherName'] = motherNameController.text;
      registrationData['customerInfo.hone'] = '251$phoneNumber';
      registrationData['customerInfo.email'] = emailController.text;
      registrationData['customerInfo.sex'] = selectedGender;
      registrationData['customerInfo.dateOfBirth'] = dateOfBirthController.text;
      registrationData['customerInfo.zoneSubCity'] = cityController.text;
      registrationData['customerInfo.country'] = selectedCountry;
      registrationData['customerInfo.state'] = selectedState;
      // registrationData['zipCode'] = dateOfBirthController.text;
      registrationData['customerInfo.sreetAddress'] = streetController.text;
      registrationData['accountType'] = "$selectedAccountTypeIdValue";
      registrationData['customerInfo.occupation'] = occupationController.text;
      registrationData['initialDeposit'] = initialDepositController.text;
      registrationData['customerInfo.monthlyIncome'] =
          monthlyIncomeController.text;

      registrationData['customerInfo.issueAuthority'] =
          issueAuthorityController.text;
      registrationData['customerInfo.issueDate'] = issueDateController.text;
      registrationData['customerInfo.expiryDate'] = expireDateController.text;
      registrationData['customerInfo.documentName'] = selectedDocumentType;
      registrationData['customerInfo.legalId'] = legalIDController.text;
      registrationData['branch'] = selectedBranch;
      registrationData['currency'] = selectedCurrency;
      registrationData['customerInfo.signature'] = _combinedSignature;
      if (profilePath.isEmpty) {
        registrationData['customerInfo.photo'] = null;
        registrationFormData['photo'] = null;
        // return;
      } else if (profilePath.startsWith('data:image/')) {
        try {
          final base64Prefix = '${profilePath.split(',')[0]},';
          profilePath = profilePath.replaceFirst(base64Prefix, '');
          profileBytes = base64Decode(profilePath);
          registrationFormData['photo'] = profileBytes;
          registrationData['customerInfo.photo'] = profileBytes;
        } catch (e) {
          print("Error decoding base64 image: $e");
          return;
        }
      } else if (profilePath.startsWith('http') ||
          profilePath.startsWith('https')) {
        print("Assigning image URL: $profilePath");
        registrationFormData['photo'] = profilePath;
        registrationData['customerInfo.photo'] = profilePath;
      } else {
        try {
          print("Loading image from file: $profilePath");
          profileBytes = await _getImageBytes(profilePath, "profileimage.png");
          registrationFormData['photo'] = profileBytes;
          registrationData['customerInfo.photo'] = profileBytes;
        } catch (e) {
          print("Error loading image from file ($profilePath): $e");
          return;
        }
      }
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
          registrationFormData['residenceCard'] = residentBytes;
          registrationData['residenceCard'] = residentBytes;
        } catch (e) {
          print("Error decoding base64 image: $e");
          return;
        }
      } else if (residentPath.startsWith('http') ||
          residentPath.startsWith('https')) {
        registrationData['customerInfo.residenceCard'] = residentPath;
        registrationFormData['residenceCard'] = residentPath;
      } else {
        try {
          residentBytes =
              await _getImageBytes(residentPath, "residentCard.png");
          registrationFormData['residenceCard'] = residentBytes;
          registrationData['customerInfo.residenceCard'] = residentBytes;
        } catch (e) {
          print("Error loading image from file: $e");
          return;
        }
      }
      registrationData['formCompleted'] = "true";
      registrationData['status'] = 'UNSETTLED';
      registrationData["percentageCompleted"] = 100;
    } else {
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
      registrationData['streetAddress'] = streetController.text;
      registrationData['accountType'] = "$selectedAccountTypeData";
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
            profilePath =
                profilePath.replaceFirst('data:image/jpeg;base64,', '');
          }
          profileBytes = base64Decode(profilePath);
          registrationFormData['photo'] = profileBytes;
          registrationData['photo'] = profileBytes;
        } catch (e) {
          print("Error decoding base64 image: $e");
          return;
        }
      } else if (profilePath.startsWith('http') ||
          profilePath.startsWith('https')) {
        registrationFormData['photo'] = profilePath;
        registrationData['photo'] = profilePath;
      } else {
        try {
          profileBytes = await _getImageBytes(profilePath, "profilePhoto.png");
          registrationFormData['photo'] = profileBytes;
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

          registrationFormData['residenceCard'] = residentBytes;
          registrationData['residenceCard'] = residentBytes;
        } catch (e) {
          print("Error decoding base64 image: $e");
          return;
        }
      } else if (residentPath.startsWith('http') ||
          residentPath.startsWith('https')) {
        registrationData['residenceCard'] = residentPath;
        registrationFormData['residenceCard'] = residentPath;
      } else {
        try {
          residentBytes =
              await _getImageBytes(residentPath, "residentcard.png");
          registrationData['residenceCard'] = residentBytes;
          registrationFormData['residenceCard'] = residentBytes;
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
            residentCardBackPath = residentCardBackPath.replaceFirst(
                'data:image/jpeg;base64,', '');
          }
          residentCardBackBytes = base64Decode(residentCardBackPath);
          registrationData['residenceCardBack'] = residentCardBackBytes;
          registrationFormData['residenceCardBack'] = residentCardBackBytes;
        } catch (e) {
          print("Error decoding base64 image: $e");
          return;
        }
      } else if (residentCardBackPath.startsWith('http') ||
          residentCardBackPath.startsWith('https')) {
        registrationData['residenceCardBack'] = residentCardBackPath;
        registrationFormData['residenceCardBack'] = residentCardBackPath;
      } else {
        try {
          residentCardBackBytes = await _getImageBytes(
              residentCardBackPath, "residentcardback.png");
          registrationData['residenceCardBack'] = residentCardBackBytes;

          registrationFormData['residenceCardBack'] = residentCardBackBytes;
        } catch (e) {
          print("Error loading image from file: $e");
          return;
        }
      }
      registrationData['formCompleted'] = "true";
      registrationData['status'] = 'UNSETTLED';
      registrationData["percentageCompleted"] = 100;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateConfirmationPage(
            registrationData: registrationData,
            registrationFormData: registrationFormData,
            userId: '$idOne',
            className: "update"),
      ),
    );

    if (result != null) {
      setState(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        FocusScope.of(context).unfocus();
        userId = result;
      });
    }
  }

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
                errorMessage: 'Please select a Document  type',
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
              TextLabel("Occupation "),
              ReusableTextFormField(
                hintText: "Enter Occupation",
                controller: occupationController,
                errorMessage: "Occupation cannot be empty",
                leadingIcon: Icons.work,
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
              // TextLabel("Payment Method"),
              // PaymentMethodWidget(
              //   initialDepositController: initialDepositController,
              //   phoneNumberController: phoneNumberController,
              // ),
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                  TextInputFormatter.withFunction(
                    (oldValue, newValue) {
                      return newValue.copyWith(
                          text: newValue.text.toUpperCase());
                    },
                  ),
                ],
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                  TextInputFormatter.withFunction(
                    (oldValue, newValue) {
                      return newValue.copyWith(
                          text: newValue.text.toUpperCase());
                    },
                  ),
                ],
                leadingIcon: Icons.person,
                isRequired: false,
              ),

              TextLabel("Date of Birth"),

              DatePickerField(
                controller: dateOfBirthController,
                hintText: "Date of Birth",
                prefixIcon: Icons.date_range,
                initialDate: DateTime.now().add(const Duration(days: -10000)),
                firstDate: DateTime(1940),
                lastDate: DateTime.now(),
                isRequired: true,
                errorMessage: 'Please select a date of birth',
              ),

              TextLabel("Marital Status"),

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
              TextLabel("Gender"),
              //Gender
              genderWidget1(),
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
                  errorMessage: "Legal ID cannot be empty",
                  leadingIcon: Icons.badge,
                  isRequired: false,
                ),
                TextLabel("ISSUE AUTHORITY"),
                ReusableTextFormField(
                  hintText: "ISSUE AUTHORITY",
                  controller: issueAuthorityController,
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
              ],
            )),
      ),

      /// INITIAL AMOUNT
      ///

      // Step(
      //   title: Text(isSmallScreen ? "" : "Address "),
      //   isActive: _activeStepIndex >= 7,
      //   state: _activeStepIndex > 7 ? StepState.complete : StepState.indexed,
      //   content: Form(
      //     key: globalFormKey7,
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.start,
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         const SizedBox(height: 20),
      //         Text(widget.userInfo[
      //             'accountType']), // 🔍 Display current selection (if not type 1)
      //         if (widget.userInfo['accountType'] != "1" &&
      //             !isEditingAccountType) ...[
      //           TextLabel("Selected Account Type"),
      //           Padding(
      //             padding:
      //                 const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      //             child: Card(
      //               child: Text(
      //                 getAccountTypeNameById(widget.userInfo['accountType']),
      //                 style: const TextStyle(
      //                     fontSize: 21, fontWeight: FontWeight.w600),
      //               ),
      //             ),
      //           ),
      //           TextButton.icon(
      //             icon: Icon(Icons.edit, size: 18),
      //             label: Text("Change Account Type"),
      //             onPressed: () {
      //               setState(() {
      //                 isEditingAccountType = true;
      //               });
      //             },
      //           ),
      //         ],

      //         // 👇 Show product/account type selectors for type 1 or if editing
      //         if (widget.userInfo['accountType'] == "1" ||
      //             isEditingAccountType) ...[
      //           TextLabel("Product Type"),
      //           ReusableDropdown(
      //             selectedValue: selectedProductType,
      //             items: ListContants.productType,
      //             hintText: 'Select Product Type',
      //             onChanged: (newStatus) {
      //               setState(() {
      //                 selectedProductType = newStatus;
      //                 selectedAccountTypeId = null;
      //               });

      //               if (selectedProductType != null) {
      //                 _filterAccountTypes(selectedProductType!);
      //               }
      //             },
      //             prefixIcon: Icons.business,
      //             errorMessage: 'Please select a product type',
      //             isRequired: true,
      //           ),
      //           const SizedBox(height: 10),
      //           TextLabel("Account Type"),
      //           TextLabel("Account Type"),
      //           Padding(
      //             padding: const EdgeInsets.only(left: 15, right: 15),
      //             child: Column(
      //               mainAxisAlignment: MainAxisAlignment.start,
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: filteredAccountTypes.map<Widget>((accountType) {
      //                 bool isSelected =
      //                     selectedAccountTypeId == accountType['name'];
      //                 return GestureDetector(
      //                   onTap: () {
      //                     setState(() {
      //                       selectedAccountTypeId = accountType['name'];

      //                       // selectedAccountId = accountType[
      //                       //     'id']; // Save the selected account ID
      //                       print(
      //                           'Selected Account Type ID: $selectedAccountTypeId');
      //                     });
      //                   },
      //                   child: Container(
      //                     width: MediaQuery.of(context).size.width,
      //                     child: Card(
      //                       margin: const EdgeInsets.all(10),
      //                       color: isSelected ? Colors.blue : Colors.white,
      //                       // elevation: 4,
      //                       shape: RoundedRectangleBorder(
      //                         borderRadius: BorderRadius.circular(10),
      //                       ),
      //                       child: Padding(
      //                         padding: const EdgeInsets.symmetric(
      //                             vertical: 1, horizontal: 2),
      //                         child: ListTile(
      //                           title: Text(
      //                             accountType['name'] as String,
      //                             style: TextStyle(
      //                                 color: isSelected
      //                                     ? Colors.white
      //                                     : Colors.black,
      //                                 fontWeight: FontWeight.bold),
      //                           ),
      //                           subtitle: Text(
      //                             (int.tryParse(accountType['maxAge']
      //                                                 ?.toString() ??
      //                                             '') ??
      //                                         0) >
      //                                     100
      //                                 ? 'Minimum Age: ${int.tryParse(accountType['minAge']?.toString() ?? '') != null ? int.parse(accountType['minAge'].toString()) : '___'}\n'
      //                                     'Min Amount: ${accountType['minAmount']}'
      //                                 : 'Age Range: ${int.tryParse(accountType['minAge']?.toString() ?? '') != null ? int.parse(accountType['minAge'].toString()) : '___'} - ${int.tryParse(accountType['maxAge']?.toString() ?? '0') ?? 0}\n'
      //                                     'Min Amount: ${accountType['minAmount']}',
      //                             style: TextStyle(
      //                               color: isSelected
      //                                   ? Colors.white
      //                                   : Colors.black,
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 );
      //               }).toList(),
      //             ),
      //           ),
      //         ]
      //       ],
      //     ),
      //   ),
      // )

// Step 7 - Address
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
              const SizedBox(height: 20),
              if (widget.userInfo['accountType'] != "1" &&
                  !isEditingAccountType) ...[
                TextLabel("Selected Account Type"),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        getAccountTypeNameById(
                            selectedAccountTypeData.toString()),
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Icon(Icons.account_balance),
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.edit, size: 18),
                      label: Text("Change Account Type"),
                      onPressed: () {
                        setState(() {
                          isEditingAccountType = true;
                        });
                      },
                    ),
                  ],
                ),
              ],

              // Show dropdowns if type is 1 or if editing
              if (widget.userInfo['accountType'] == "1" ||
                  isEditingAccountType) ...[
                TextLabel("Product Type"),
                ReusableDropdown(
                  selectedValue: selectedProductType,
                  items: ListContants.productType,
                  hintText: 'Select Product Type',
                  onChanged: (newStatus) {
                    setState(() {
                      selectedProductType = newStatus;
                      selectedAccountTypeId = null;
                    });

                    if (selectedProductType != null) {
                      _filterAccountTypes(selectedProductType!);
                    }
                  },
                  prefixIcon: Icons.business,
                  errorMessage: 'Please select a product type',
                  isRequired: true,
                ),
                const SizedBox(height: 10),
                TextLabel("Account Type"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: filteredAccountTypes.map<Widget>((accountType) {
                      bool isSelected =
                          selectedAccountTypeId == accountType['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAccountTypeId = accountType['name'];
                          });
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 5,
                          color:
                              isSelected ? Colors.blue.shade100 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text(
                              accountType['name'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              (int.tryParse(accountType['maxAge']?.toString() ??
                                              '') ??
                                          0) >
                                      100
                                  ? 'Minimum Age: ${accountType['minAge']}\nMin Amount: ${accountType['minAmount']}'
                                  : 'Age Range: ${accountType['minAge']} - ${accountType['maxAge']}\nMin Amount: ${accountType['minAmount']}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.blue.shade700
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (widget.userInfo['accountType'] != "1")
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: Icon(Icons.cancel),
                      label: Text("Cancel"),
                      onPressed: () {
                        setState(() {
                          isEditingAccountType = false;
                          selectedProductType = null;
                          selectedAccountTypeId = null;
                        });
                      },
                    ),
                  ),
              ]
            ],
          ),
        ),
      )

      // Step(
      //   title: Text(isSmallScreen ? "" : "Address "),
      //   isActive: _activeStepIndex >= 7,
      //   state: _activeStepIndex > 7 ? StepState.complete : StepState.indexed,
      //   content: Form(
      //       key: globalFormKey7,
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.start,
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           const SizedBox(
      //             height: 20,
      //           ),
      //           TextLabel("Product Type"),
      //           ReusableDropdown(
      //             selectedValue: selectedProductType,
      //             items: ListContants.productType,
      //             hintText: 'Select Product Type',
      //             onChanged: (newStatus) {
      //               setState(() {
      //                 selectedProductType = newStatus;
      //                 selectedAccountTypeId = null;
      //               });

      //               if (selectedProductType != null) {
      //                 print("Gemechuuu");

      //                 setState(() {
      //                   _filterAccountTypes(selectedProductType!);
      //                 });
      //               }
      //             },
      //             prefixIcon: Icons.business,
      //             errorMessage: 'Please select a product type',
      //             isRequired: true,
      //           ),
      //           TextLabel("Account Type"),
      //           Padding(
      //             padding: const EdgeInsets.only(left: 15, right: 15),
      //             child: Column(
      //               mainAxisAlignment: MainAxisAlignment.start,
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: filteredAccountTypes.map<Widget>((accountType) {
      //                 bool isSelected =
      //                     selectedAccountTypeId == accountType['name'];
      //                 return GestureDetector(
      //                   onTap: () {
      //                     setState(() {
      //                       selectedAccountTypeId = accountType['name'];
      //                       // selectedAccountId = accountType[
      //                       //     'id']; // Save the selected account ID
      //                       print(
      //                           'Selected Account Type ID: $selectedAccountTypeId');
      //                     });
      //                   },
      //                   child: Container(
      //                     width: MediaQuery.of(context).size.width,
      //                     child: Card(
      //                       margin: const EdgeInsets.all(10),
      //                       color: isSelected ? Colors.blue : Colors.white,
      //                       // elevation: 4,
      //                       shape: RoundedRectangleBorder(
      //                         borderRadius: BorderRadius.circular(10),
      //                       ),
      //                       child: Padding(
      //                         padding: const EdgeInsets.symmetric(
      //                             vertical: 1, horizontal: 2),
      //                         child: ListTile(
      //                           title: Text(
      //                             accountType['name'] as String,
      //                             style: TextStyle(
      //                                 color: isSelected
      //                                     ? Colors.white
      //                                     : Colors.black,
      //                                 fontWeight: FontWeight.bold),
      //                           ),
      //                           subtitle: Text(
      //                             (int.tryParse(accountType['maxAge']
      //                                                 ?.toString() ??
      //                                             '') ??
      //                                         0) >
      //                                     100
      //                                 ? 'Minimum Age: ${int.tryParse(accountType['minAge']?.toString() ?? '') != null ? int.parse(accountType['minAge'].toString()) : '___'}\n'
      //                                     'Min Amount: ${accountType['minAmount']}'
      //                                 : 'Age Range: ${int.tryParse(accountType['minAge']?.toString() ?? '') != null ? int.parse(accountType['minAge'].toString()) : '___'} - ${int.tryParse(accountType['maxAge']?.toString() ?? '0') ?? 0}\n'
      //                                     'Min Amount: ${accountType['minAmount']}',
      //                             style: TextStyle(
      //                               color: isSelected
      //                                   ? Colors.white
      //                                   : Colors.black,
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 );
      //               }).toList(),
      //             ),
      //           ),
      //         ],
      //       )),
      // ),
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
            value: (allBranches
                    .any((branch) => branch['companyName'] == selectedBranch))
                ? selectedBranch
                : null, // Set to null if it doesn’t exist
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
                value: branch['companyName']?.toString() ?? '',
                child: Text(branch['companyName']?.toString() ?? ''),
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

        if (decodedToken.containsKey("mainBranch")) {
          allBranches.add(decodedToken["mainBranch"]);
        }

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
    canvas.drawImage(image2, Offset(currentX, 0), Paint());
    currentX += image2.width.toDouble() + 10;
    canvas.drawImage(image3, Offset(currentX, 0), Paint());
    final picture = recorder.endRecording();
    final combinedImage = await picture.toImage(totalWidth, maxHeight);
    final byteData =
        await combinedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  void _saveCombinedSignature() async {
    final Uint8List? combinedImage = await _combineSignatures();

    if (!areAllSignaturesCompleted()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete all signature pads before saving."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (combinedImage != null) {
      setState(() {
        _combinedSignature = combinedImage;
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

      String normalizedGender = selectedGender!.trim().toUpperCase();
      double initialDeposit =
          double.tryParse(initialDepositController.text) ?? 0;

      filteredAccountTypes = accountTypes.where((accountType) {
        print("AccountType: ${accountType}");
        print("Selected Gender: $normalizedGender");
        if (accountType['bankingType'] != bankingType) {
          print(
              "BankingType mismatch: ${accountType['bankingType']} != $bankingType");
          return false;
        }
        int minAge = int.tryParse(accountType['minAge']?.trim() ?? '0') ?? 0;
        int maxAge =
            int.tryParse(accountType['maxAge']?.trim() ?? '999') ?? 999;
        if (age < minAge || age > maxAge) {
          print("Age out of range: $age not in [$minAge, $maxAge]");
          return false;
        }
        double minAmount =
            double.tryParse(accountType['minAmount']?.toString() ?? '0') ?? 0;
        if (initialDeposit < minAmount) {
          print(
              "Initial deposit $initialDeposit less than required $minAmount");
          return false;
        }

        String accountTypeSex =
            accountType['sex']?.trim().toUpperCase() ?? 'BOTH';
        if (accountTypeSex != 'BOTH' && accountTypeSex != normalizedGender) {
          print("Gender mismatch: $normalizedGender != $accountTypeSex");
          return false;
        }
        return true;
      }).toList();
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
    if (GlobalData().role != 'ACCOUNT-CREATOR') {
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

  Future<void> loadSignature() async {
    if (widget.userInfo['signature'] is String) {
      String url = widget.userInfo['signature'];
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          setState(() {
            _combinedSignature = response.bodyBytes;
          });
        }
      } catch (e) {
        print('Error loading signature: $e');
      }
    } else if (widget.userInfo['signature'] is Uint8List) {
      setState(() {
        _combinedSignature = widget.userInfo['signature'];
      });
    }
  }

  Map<String, dynamic>? getAccountTypeDetails(String selectedAccountType) {
    if (selectedAccountType != null && filteredAccountTypes.isNotEmpty) {
      try {
        var selectedAccountTypeDetails = filteredAccountTypes.firstWhere(
          (accountType) => accountType['name'] == selectedAccountType,
        );

        return {
          "id": selectedAccountTypeDetails['id'],
          "name": selectedAccountTypeDetails['name'],
          "type": selectedAccountTypeDetails['type'],
          "minAge": selectedAccountTypeDetails["minAge"] ?? "",
          "maxAge": selectedAccountTypeDetails["maxAge"] ?? "",
          "minAmount": selectedAccountTypeDetails["minAmount"] ?? "",
          "sex": selectedAccountTypeDetails["sex"] ?? "",
          "bankingType": selectedAccountTypeDetails["bankingType"]
        };
      } catch (e) {
        print('Error finding account type: $e');
        return null;
      }
    }
    return null;
  }

  // String getAccountTypeNameById(String accountTypeId) {
  //   try {
  //     final match = accountTypes.firstWhere(
  //       (type) => type['id'].toString() == accountTypeId,
  //       orElse: () => {'name': 'Unknown'},
  //     );
  //     return match['name'] ?? 'Unknown';
  //   } catch (e) {
  //     print("Error finding account type name: $e");
  //     return 'Unknown';
  //   }
  // }

  String getAccountTypeNameById(String accountTypeId) {
    try {
      print("ddjjdjdjdjddjddjdjd");
      print(accountTypeId);
      final match = accountTypes.firstWhere(
        (type) => type['id'].toString() == accountTypeId,
        orElse: () =>
            {'name': 'Unknown'}, // Return a real Map with expected keys
      );
      return match['name'] ?? "Unknown";
    } catch (e) {
      print("Error finding account type name: $e");
      return "Unknown";
    }
  }
}
