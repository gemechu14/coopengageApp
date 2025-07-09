import 'package:coopengageplus/constants/kconstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:intl/intl.dart';
import '../../providers/registration_providers.dart';

class StepPersonalInfo extends ConsumerStatefulWidget {
  const StepPersonalInfo({super.key});

  @override
  ConsumerState<StepPersonalInfo> createState() => _StepPersonalInfoState();
}

class _StepPersonalInfoState extends ConsumerState<StepPersonalInfo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  // Address fields

  final TextEditingController _issueAuthorityController =
      TextEditingController();
  final TextEditingController _issueDateController = TextEditingController();
  final TextEditingController _expireDateController = TextEditingController();

  String? _selectedTitle;
  String? _selectedGender;
  String? _selectedMaritalStatus;


  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final registrationData = ref.read(registrationDataProvider);

    // Load existing data into text controllers
    if (registrationData.fullName != null && registrationData.fullName!.isNotEmpty)
      _fullNameController.text = registrationData.fullName!;
    if (registrationData.surname != null && registrationData.surname!.isNotEmpty)
      _surnameController.text = registrationData.surname!;
    if (registrationData.motherName != null && registrationData.motherName!.isNotEmpty)
      _motherNameController.text = registrationData.motherName!;
    if (registrationData.dateOfBirth != null && registrationData.dateOfBirth!.isNotEmpty)
      _dateOfBirthController.text = registrationData.dateOfBirth!;

    // Set defaults for title and gender
    _selectedTitle = registrationData.title ?? 'MR'; // Default to MR
    _selectedGender = registrationData.sex ?? 'MALE'; // Default to Male
    _selectedMaritalStatus = registrationData.maritalStatus;

    // Update registration data with defaults if not already set
    if (registrationData.title == null) {
      ref.read(registrationDataProvider.notifier).updatePersonalInfo(
        title: 'MR',
      );
    }
    if (registrationData.sex == null) {
      ref.read(registrationDataProvider.notifier).updatePersonalInfo(
        sex: 'MALE',
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _surnameController.dispose();
    _motherNameController.dispose();
    _dateOfBirthController.dispose();

    _issueAuthorityController.dispose();
    _issueDateController.dispose();
    _expireDateController.dispose();

    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate:
          DateTime.now().subtract(const Duration(days: 36500)), // 100 years ago
      lastDate:
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      // Update registration data when date is selected
      ref.read(registrationDataProvider.notifier).updatePersonalInfo(
            dateOfBirth: _dateOfBirthController.text,
          );
      // Clear validation error
      ref.read(formValidationProvider.notifier).clearError('dateOfBirth');
    }
  }

  Future<void> _selectIssueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now()
          .subtract(const Duration(days: 365 * 15)), // 15 years before today
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _issueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      // Update registration data when date is selected
      ref.read(registrationDataProvider.notifier).updateAddressInfo(
            issueDate: _issueDateController.text,
          );
      // Clear validation error
      ref.read(formValidationProvider.notifier).clearError('issueDate');
    }
  }

  Future<void> _selectExpireDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // First date is today
      lastDate: DateTime.now()
          .add(const Duration(days: 365 * 12)), // 12 years from today
    );
    if (picked != null) {
      setState(() {
        _expireDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      // Update registration data when date is selected
      ref.read(registrationDataProvider.notifier).updateAddressInfo(
            expirayDate: _expireDateController.text,
          );
      // Clear validation error
      ref.read(formValidationProvider.notifier).clearError('expireDate');
    }
  }

  // Method to validate and save data (called from parent)
  bool validateAndSave() {
    final validationNotifier = ref.read(formValidationProvider.notifier);
    final registrationNotifier = ref.read(registrationDataProvider.notifier);

    // Clear previous errors
    validationNotifier.clearAllErrors();

    bool isValid = true;

    // Validate title and gender compatibility
    if (_selectedTitle != null && _selectedGender != null) {
      final Map<String, String> titleGenderMap = {
        'MR': 'MALE',
        'MRS': 'FEMALE',
        'MS': 'FEMALE',
        'MISS': 'FEMALE',
        'DR': 'Both',
      };

      bool isValidTitle = false;
      if (_selectedTitle == 'DR') {
        isValidTitle = true;
      } else if (titleGenderMap[_selectedTitle] == _selectedGender) {
        isValidTitle = true;
      }

      if (!isValidTitle) {
        validationNotifier.setError('titleGender',
            'Invalid Title: "$_selectedTitle" is not valid for gender "$_selectedGender"');
        isValid = false;
      }
    }

    // Validate required fields
    if (_selectedTitle == null || _selectedTitle!.isEmpty) {
      validationNotifier.setError('title', 'Please select a title');
      isValid = false;
    }

    if (_fullNameController.text.trim().isEmpty) {
      validationNotifier.setError('fullName', 'Full Name is required');
      isValid = false;
    }

    if (_selectedGender == null || _selectedGender!.isEmpty) {
      validationNotifier.setError('gender', 'Please select a gender');
      isValid = false;
    }

    if (_dateOfBirthController.text.trim().isEmpty) {
      validationNotifier.setError('dateOfBirth', 'Date of Birth is required');
      isValid = false;
    }

    if (_selectedMaritalStatus == null || _selectedMaritalStatus!.isEmpty) {
      validationNotifier.setError(
          'maritalStatus', 'Please select a marital status');
      isValid = false;
    }

    if (isValid) {
      // Save personal data
      registrationNotifier.updatePersonalInfo(
        fullName: _fullNameController.text.trim(),
        surname: _surnameController.text.trim(),
        motherName: _motherNameController.text.trim(),
        sex: _selectedGender,
        dateOfBirth: _dateOfBirthController.text.trim(),
        title: _selectedTitle,
        maritalStatus: _selectedMaritalStatus,
      );

      // // Save address data
      // registrationNotifier.updateAddressInfo(
      //   country: _selectedCountry,
      //   issueAuthority: _issueAuthorityController.text.trim(),
      //   issueDate: _issueDateController.text.trim(),
      //   expirayDate: _expireDateController.text.trim(),
      //   legalId: _legalIdController.text.trim(),
      //   stateValue: _selectedState,
      //   zoneSubCity: _zoneSubCityController.text.trim(),
      //   streetAddress: _woredaController.text.trim(),
      // );

      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final validationErrors = ref.watch(formValidationProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: graybackgroundColor,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide your personal details.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                _buildLabel("Title *"),
                ReusableDropdown(
                  hintText: "Select Title",
                  selectedValue: _selectedTitle,
                  items: ListContants.title,
                  onChanged: (value) {
                    setState(() {
                      _selectedTitle = value;
                    });
                    // Update registration data
                    ref
                        .read(registrationDataProvider.notifier)
                        .updatePersonalInfo(
                          title: value,
                        );
                    ref
                        .read(formValidationProvider.notifier)
                        .clearError('title');
                    ref
                        .read(formValidationProvider.notifier)
                        .clearError('titleGender');
                  },
                  errorMessage: validationErrors['title'] ?? '',
                  isRequired: true,
                ),
                // Error display under Title
                if (validationErrors['title'] != null &&
                    validationErrors['title']!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                    child: Text(
                      validationErrors['title']!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Full Name
                _buildLabel("Full Name *"),
                ReusableTextFormField(
                  hintText: "Full Name",
                  controller: _fullNameController,
                  keyboardType: TextInputType.text,
                  errorMessage: validationErrors['fullName'] ?? '',
                  leadingIcon: Icons.person,
                  isRequired: true,
                  onChanged: (value) {
                    // Update registration data
                    ref
                        .read(registrationDataProvider.notifier)
                        .updatePersonalInfo(
                          fullName: value,
                        );
                    // Clear validation errors when user makes changes
                    if (value.isNotEmpty) {
                      ref
                          .read(formValidationProvider.notifier)
                          .clearError('fullName');
                    }
                  },
                ),
                // Error display under Full Name
                if (validationErrors['fullName'] != null &&
                    validationErrors['fullName']!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                    child: Text(
                      validationErrors['fullName']!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Surname
                _buildLabel("Surname"),
                ReusableTextFormField(
                  hintText: "Surname",
                  controller: _surnameController,
                  keyboardType: TextInputType.text,
                  errorMessage: validationErrors['surname'] ?? '',
                  leadingIcon: Icons.person,
                  isRequired: false,
                  onChanged: (value) {
                    // Update registration data
                    ref
                        .read(registrationDataProvider.notifier)
                        .updatePersonalInfo(
                          surname: value,
                        );
                    // Clear validation errors when user makes changes
                    if (value.isNotEmpty) {
                      ref
                          .read(formValidationProvider.notifier)
                          .clearError('surname');
                    }
                  },
                ),
                // Error display under Surname
                if (validationErrors['surname'] != null &&
                    validationErrors['surname']!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                    child: Text(
                      validationErrors['surname']!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Mother Name
                // _buildLabel("Mother Name"),
                // ReusableTextFormField(
                //   hintText: "Mother Name",
                //   controller: _motherNameController,
                //   keyboardType: TextInputType.text,
                //   errorMessage: validationErrors['motherName'] ?? '',
                //   leadingIcon: Icons.person,
                //   isRequired: false,
                // ),

                const SizedBox(height: 20),

                // Date of Birth
                _buildLabel("Date of Birth *"),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: ReusableTextFormField(
                      hintText: "Date of Birth",
                      controller: _dateOfBirthController,
                      keyboardType: TextInputType.none,
                      errorMessage: validationErrors['dateOfBirth'] ?? '',
                      leadingIcon: Icons.calendar_today,
                      isRequired: true,
                    ),
                  ),
                ),
                // Error display under Date of Birth
                if (validationErrors['dateOfBirth'] != null &&
                    validationErrors['dateOfBirth']!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                    child: Text(
                      validationErrors['dateOfBirth']!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Marital Status
                _buildLabel("Marital Status *"),
                ReusableDropdown(
                  hintText: "Select Marital Status",
                  selectedValue: _selectedMaritalStatus,
                  items: ListContants.maritalStatuses,
                  onChanged: (value) {
                    setState(() {
                      _selectedMaritalStatus = value;
                    });
                    // Update registration data
                    ref
                        .read(registrationDataProvider.notifier)
                        .updatePersonalInfo(
                          maritalStatus: value,
                        );
                    ref
                        .read(formValidationProvider.notifier)
                        .clearError('maritalStatus');
                  },
                  errorMessage: validationErrors['maritalStatus'] ?? '',
                  isRequired: true,
                ),
                // Error display under Marital Status
                if (validationErrors['maritalStatus'] != null &&
                    validationErrors['maritalStatus']!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                    child: Text(
                      validationErrors['maritalStatus']!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Gender
                _buildLabel("Gender *"),
                _buildGenderWidget(),

                // Error display under Gender
                if (validationErrors['gender'] != null &&
                    validationErrors['gender']!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                    child: Text(
                      validationErrors['gender']!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                // Title-Gender validation error
                if (validationErrors['titleGender'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      validationErrors['titleGender']!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderWidget() {
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
                  groupValue: _selectedGender, // Current selected gender
                  activeColor:
                      cyanblueColor, // Use cyanblue color for selection
                  onChanged: (String? value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                    // Update registration data
                    ref
                        .read(registrationDataProvider.notifier)
                        .updatePersonalInfo(
                          sex: value,
                        );
                    ref
                        .read(formValidationProvider.notifier)
                        .clearError('gender');
                    ref
                        .read(formValidationProvider.notifier)
                        .clearError('titleGender');
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Female'),
                  value: 'FEMALE', // Radio button value
                  groupValue: _selectedGender, // Current selected gender
                  activeColor:
                      cyanblueColor, // Use cyanblue color for selection
                  onChanged: (String? value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                    // Update registration data
                    ref
                        .read(registrationDataProvider.notifier)
                        .updatePersonalInfo(
                          sex: value,
                        );
                    ref
                        .read(formValidationProvider.notifier)
                        .clearError('gender');
                    ref
                        .read(formValidationProvider.notifier)
                        .clearError('titleGender');
                  },
                ),
              ),
            ],
          ),
          if (_selectedGender == null)
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
