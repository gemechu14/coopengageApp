import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import '../../constants/reusable_dropdown.dart';
import '../../providers/registration_providers.dart';
import 'package:intl/intl.dart';

class StepAddressInformation extends ConsumerStatefulWidget {
  const StepAddressInformation({super.key});

  @override
  ConsumerState<StepAddressInformation> createState() => _StepPaymentState();
}

class _StepPaymentState extends ConsumerState<StepAddressInformation> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController surNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();

  // Address fields
  final TextEditingController zoneSubCityController = TextEditingController();
  final TextEditingController woredaController = TextEditingController();
  final TextEditingController legalIdController = TextEditingController();
  final TextEditingController issueAuthorityController =
      TextEditingController();
  final TextEditingController issueDateController = TextEditingController();
  final TextEditingController expireDateController = TextEditingController();

  String? selectedTitle;
  String? selectedMaritalStatus;
  String? selectedGender;
  String? selectedCustomerType;
  String? selectedState;
  String? selectedCountry = 'ETHIOPIA'; // Default country

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void _loadExistingData() {
    final registrationData = ref.read(registrationDataProvider);

    // Load existing data into controllers and selected values
    if (registrationData.fullName != null) {
      fullNameController.text = registrationData.fullName!;
    }
    if (registrationData.surname != null) {
      surNameController.text = registrationData.surname!;
    }
    if (registrationData.dateOfBirth != null) {
      dateOfBirthController.text = registrationData.dateOfBirth!;
    }

    // Load address data
    if (registrationData.zoneSubCity != null) {
      zoneSubCityController.text = registrationData.zoneSubCity!;
    }
    if (registrationData.streetAddress != null) {
      woredaController.text = registrationData.streetAddress!;
    }
    if (registrationData.legalId != null) {
      legalIdController.text = registrationData.legalId!;
    }
    if (registrationData.issueAuthority != null) {
      issueAuthorityController.text = registrationData.issueAuthority!;
    }
    if (registrationData.issueDate != null) {
      issueDateController.text = registrationData.issueDate!;
    }
    if (registrationData.expirayDate != null) {
      expireDateController.text = registrationData.expirayDate!;
    }

    selectedTitle = registrationData.title ?? 'MR'; // Default to MR
    selectedMaritalStatus =
        registrationData.maritalStatus ?? ListContants.maritalStatuses.first;
    selectedGender = registrationData.sex ?? 'MALE'; // Default to Male
    selectedCustomerType = registrationData.productType ?? 'INDIVIDUAL';
    selectedState = registrationData.state;
    selectedCountry = registrationData.country ?? 'ETHIOPIA';

    setState(() {});
  }

  @override
  void dispose() {
    fullNameController.dispose();
    surNameController.dispose();
    dateOfBirthController.dispose();

    // Dispose address controllers
    zoneSubCityController.dispose();
    woredaController.dispose();
    legalIdController.dispose();
    issueAuthorityController.dispose();
    issueDateController.dispose();
    expireDateController.dispose();

    super.dispose();
  }

  bool _validateTitleGender() {
    final Map<String, String> titleGenderMap = {
      'MR': 'MALE',
      'MRS': 'FEMALE',
      'MS': 'FEMALE',
      'MISS': 'FEMALE',
      'DR': 'Both',
    };

    if (selectedTitle == 'DR') {
      return true;
    } else if (titleGenderMap[selectedTitle] == selectedGender) {
      return true;
    }
    return false;
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
        issueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      // Update registration data when date is selected
      ref.read(registrationDataProvider.notifier).updateAddressInfo(
            issueDate: issueDateController.text,
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
        expireDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      // Update registration data when date is selected
      ref.read(registrationDataProvider.notifier).updateAddressInfo(
            expirayDate: expireDateController.text,
          );
      // Clear validation error
      ref.read(formValidationProvider.notifier).clearError('expireDate');
    }
  }

  Widget _buildLabel(String text) {
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

  @override
  Widget build(BuildContext context) {
    final validationErrors = ref.watch(formValidationProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: graybackgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Address Information Section
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
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Address Information',
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
                    'Please provide your address and legal identification details.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // State
            _buildLabel("State"),
            ReusableDropdown(
              hintText: "Select State",
              selectedValue: selectedState,
              items: ListContants.ethiopianStates,
              onChanged: (value) {
                setState(() {
                  selectedState = value;
                });
                // Update registration data
                ref.read(registrationDataProvider.notifier).updateAddressInfo(
                      stateValue: value,
                    );
                ref.read(formValidationProvider.notifier).clearError('state');
              },
              errorMessage: validationErrors['state'] ?? '',
              isRequired: false,
            ),
            // Error display under State
            if (validationErrors['state'] != null &&
                validationErrors['state']!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Text(
                  validationErrors['state']!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Zone Subcity
            _buildLabel("Zone Subcity"),
            ReusableTextFormField(
              hintText: "Zone Subcity",
              controller: zoneSubCityController,
              keyboardType: TextInputType.text,
              errorMessage: validationErrors['zoneSubCity'] ?? '',
              leadingIcon: Icons.location_city,
              isRequired: false,
              onChanged: (value) {
                // Update registration data
                ref.read(registrationDataProvider.notifier).updateAddressInfo(
                      zoneSubCity: value,
                    );
                // Clear validation errors when user makes changes
                if (value.isNotEmpty) {
                  ref
                      .read(formValidationProvider.notifier)
                      .clearError('zoneSubCity');
                }
              },
            ),
            // Error display under Zone Subcity
            if (validationErrors['zoneSubCity'] != null &&
                validationErrors['zoneSubCity']!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Text(
                  validationErrors['zoneSubCity']!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Woreda
            _buildLabel("Woreda"),
            ReusableTextFormField(
              hintText: "Woreda",
              controller: woredaController,
              keyboardType: TextInputType.text,
              errorMessage: validationErrors['streetAddress'] ?? '',
              leadingIcon: Icons.location_city,
              isRequired: false,
              onChanged: (value) {
                // Update registration data
                ref.read(registrationDataProvider.notifier).updateAddressInfo(
                      streetAddress: value,
                    );
                // Clear validation errors when user makes changes
                if (value.isNotEmpty) {
                  ref
                      .read(formValidationProvider.notifier)
                      .clearError('streetAddress');
                }
              },
            ),
            // Error display under Woreda
            if (validationErrors['streetAddress'] != null &&
                validationErrors['streetAddress']!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Text(
                  validationErrors['streetAddress']!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Legal ID
            _buildLabel("Legal ID *"),
            ReusableTextFormField(
              hintText: "Legal ID",
              controller: legalIdController,
              keyboardType: TextInputType.text,
              errorMessage: validationErrors['legalId'] ?? '',
              leadingIcon: Icons.badge,
              isRequired: true,
              onChanged: (value) {
                // Update registration data
                ref.read(registrationDataProvider.notifier).updateAddressInfo(
                      legalId: value,
                    );
                // Clear validation errors when user makes changes
                if (value.isNotEmpty) {
                  ref
                      .read(formValidationProvider.notifier)
                      .clearError('legalId');
                }
              },
            ),
            // Error display under Legal ID
            if (validationErrors['legalId'] != null &&
                validationErrors['legalId']!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Text(
                  validationErrors['legalId']!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Issue Authority
            _buildLabel("Issue Authority"),
            ReusableTextFormField(
              hintText: "Issue Authority",
              controller: issueAuthorityController,
              keyboardType: TextInputType.text,
              errorMessage: validationErrors['issueAuthority'] ?? '',
              leadingIcon: Icons.verified,
              isRequired: false,
              onChanged: (value) {
                // Update registration data
                ref.read(registrationDataProvider.notifier).updateAddressInfo(
                      issueAuthority: value,
                    );
                // Clear validation errors when user makes changes
                if (value.isNotEmpty) {
                  ref
                      .read(formValidationProvider.notifier)
                      .clearError('issueAuthority');
                }
              },
            ),
            // Error display under Issue Authority
            if (validationErrors['issueAuthority'] != null &&
                validationErrors['issueAuthority']!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Text(
                  validationErrors['issueAuthority']!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Issue Date
            _buildLabel("Issue Date"),
            GestureDetector(
              onTap: () => _selectIssueDate(context),
              child: AbsorbPointer(
                child: ReusableTextFormField(
                  hintText: "Issue Date",
                  controller: issueDateController,
                  keyboardType: TextInputType.none,
                  errorMessage: validationErrors['issueDate'] ?? '',
                  leadingIcon: Icons.calendar_today,
                  isRequired: false,
                ),
              ),
            ),
            // Error display under Issue Date
            if (validationErrors['issueDate'] != null &&
                validationErrors['issueDate']!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Text(
                  validationErrors['issueDate']!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Expire Date
            _buildLabel("Expire Date"),
            GestureDetector(
              onTap: () => _selectExpireDate(context),
              child: AbsorbPointer(
                child: ReusableTextFormField(
                  hintText: "Expire Date",
                  controller: expireDateController,
                  keyboardType: TextInputType.none,
                  errorMessage: validationErrors['expireDate'] ?? '',
                  leadingIcon: Icons.event_busy,
                  isRequired: false,
                ),
              ),
            ),
            // Error display under Expire Date
            if (validationErrors['expireDate'] != null &&
                validationErrors['expireDate']!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Text(
                  validationErrors['expireDate']!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
