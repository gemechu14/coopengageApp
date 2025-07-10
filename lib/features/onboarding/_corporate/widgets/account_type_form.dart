import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../_corporate/providers/registration_providers.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AccountTypeForm extends ConsumerStatefulWidget {
  final GlobalKey<FormState>? formKey;
  const AccountTypeForm({Key? key, this.formKey}) : super(key: key);

  @override
  ConsumerState<AccountTypeForm> createState() => _AccountTypeFormState();
}

class _AccountTypeFormState extends ConsumerState<AccountTypeForm> {
  String? selectedState;
  String? numberOfMembers;
  String? selectedBranch;
  List<Map<String, dynamic>> allBranches = [];
  late final TextEditingController cityController;
  late final TextEditingController woredaController;
  late final TextEditingController residenceController;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    final form = ref.read(corporateRegistrationProvider);
    selectedState = form.state;
    numberOfMembers =
        form.customers.isNotEmpty ? form.customers.length.toString() : null;
    selectedBranch = form.branch;
    cityController = TextEditingController(text: form.zone ?? '');
    woredaController = TextEditingController(text: form.woreda ?? '');
    residenceController = TextEditingController(text: form.residence ?? '');
    initializeBranches();
  }

  @override
  void didUpdateWidget(covariant AccountTypeForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final form = ref.read(corporateRegistrationProvider);
    setState(() {
      selectedState = form.state;
      numberOfMembers =
          form.customers.isNotEmpty ? form.customers.length.toString() : null;
      selectedBranch = form.branch;
      cityController.text = form.zone ?? '';
      woredaController.text = form.woreda ?? '';
      residenceController.text = form.residence ?? '';
    });
  }

  void initializeBranches() async {
    String? token = await storage.read(key: "token");
    if (token != null && token.isNotEmpty) {
      var decodedToken = JwtDecoder.decode(token);
      List<Map<String, dynamic>> regularBranches =
          decodedToken.containsKey("branch")
              ? List<Map<String, dynamic>>.from(decodedToken["branch"])
              : [];
      setState(() {
        allBranches = [];
        if (decodedToken.containsKey("mainBranch")) {
          allBranches.add(decodedToken["mainBranch"]);
          selectedBranch = decodedToken["mainBranch"]["companyName"];
        }
        allBranches.addAll(regularBranches);
      });
    }
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
              ref
                  .read(corporateRegistrationProvider.notifier)
                  .updateField('branch', newValue);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Branch is required';
              }
              return null;
            },
            dropdownColor: Colors.white,
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

  @override
  void dispose() {
    cityController.dispose();
    woredaController.dispose();
    residenceController.dispose();
    super.dispose();
  }

  Widget TextLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(corporateRegistrationProvider);
    final notifier = ref.read(corporateRegistrationProvider.notifier);

    final accountTypeController =
        TextEditingController(text: form.accountType ?? '');
    final initialDepositController =
        TextEditingController(text: form.initialDeposit ?? '');
    final currencyController = TextEditingController(text: form.currency ?? '');

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
      child: Form(
        key: widget.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextLabel('Branch'),
            branchSelectorWidget1(),
            const SizedBox(height: 4),
            TextLabel('State'),
            ReusableDropdown(
              selectedValue: selectedState,
              items: ListContants.ethiopianStates,
              hintText: 'Select State',
              onChanged: (newState) {
                setState(() {
                  selectedState = newState;
                });
                notifier.updateField('state', newState);
              },
              errorMessage: 'Please select a state',
              prefixIcon: Icons.map,
              isRequired: false,
            ),
            const SizedBox(height: 4),
            TextLabel('Zone Subcity'),
            ReusableTextFormField(
              hintText: 'Zone Subcity',
              controller: cityController,
              errorMessage: 'Zone Subcity cannot be empty',
              leadingIcon: Icons.location_city,
              isRequired: true,
              onChanged: (value) => notifier.updateField('zone', value),
            ),
            const SizedBox(height: 4),
            TextLabel('Woreda'),
            ReusableTextFormField(
              hintText: 'Woreda',
              controller: woredaController,
              errorMessage: 'Woreda cannot be empty',
              leadingIcon: Icons.location_city,
              isRequired: false,
              onChanged: (value) => notifier.updateField('woreda', value),
            ),
            const SizedBox(height: 4),
            TextLabel('Resident'),
            ReusableTextFormField(
              hintText: 'Resident',
              controller: residenceController,
              keyboardType: TextInputType.text,
              errorMessage: 'Resident cannot be empty',
              leadingIcon: Icons.location_city,
              isRequired: true,
              onChanged: (value) => notifier.updateField('residence', value),
            ),
            const SizedBox(height: 6),
            TextLabel('Select Number of Authorized Signers'),
            ReusableDropdown(
              selectedValue: numberOfMembers,
              items: ListContants.NumberOfMembersForOrganization,
              hintText: 'Select Number of Authorized Signers',
              onChanged: (newStatus) {
                setState(() {
                  numberOfMembers = newStatus;
                });
                // You can update the provider or handle logic for number of signers here
              },
              prefixIcon: Icons.person_add,
              errorMessage: 'Please select the number of authorized signers',
              isRequired: true,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
