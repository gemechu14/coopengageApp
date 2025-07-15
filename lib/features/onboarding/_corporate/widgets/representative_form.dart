import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../_corporate/providers/registration_providers.dart';
// import '../../_corporate/models/corporate_registration_form.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/common_widgets/dropDown/DatePickerField.dart';
import 'package:flutter/services.dart';
// import 'package:expandable/expandable.dart';

class RepresentativeForm extends ConsumerStatefulWidget {
  const RepresentativeForm({Key? key}) : super(key: key);

  @override
  ConsumerState<RepresentativeForm> createState() => _RepresentativeFormState();
}

class _RepresentativeFormState extends ConsumerState<RepresentativeForm> {
  int? openPersonIndex = 0; // null means all closed
  void _togglePerson(int index) {
    setState(() {
      if (openPersonIndex == index) {
        openPersonIndex = null;
      } else {
        openPersonIndex = index;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final form = ref.watch(corporateRegistrationProvider);
    int count = form.customers.isNotEmpty ? form.customers.length : 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(count, (i) {
            final isOpen = openPersonIndex == i;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text('Person ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    trailing: Icon(
                      isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.blue,
                      size: 32,
                    ),
                    onTap: () => _togglePerson(i),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
                      child: _PersonSectionsAccordion(index: i),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _PersonSectionsAccordion extends StatefulWidget {
  final int index;
  const _PersonSectionsAccordion({Key? key, required this.index}) : super(key: key);
  @override
  State<_PersonSectionsAccordion> createState() => _PersonSectionsAccordionState();
}

class _PersonSectionsAccordionState extends State<_PersonSectionsAccordion> {
  int? openSection; // null means all closed
  void _toggleSection(int section) {
    setState(() {
      if (openSection == section) {
        openSection = null;
      } else {
        openSection = section;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Personal Information',
          section: 0,
          child: _PersonalInfoSection(index: widget.index),
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          title: 'Document Information',
          section: 1,
          child: _DocumentInfoSection(index: widget.index),
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          title: 'ID Information',
          section: 2,
          child: _IDInfoSection(index: widget.index),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required int section, required Widget child}) {
    final isOpen = openSection == section;
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.blue,
              size: 28,
            ),
            onTap: () => _toggleSection(section),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoSection extends ConsumerWidget {
  final int index;
  const _PersonalInfoSection({Key? key, required this.index}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(corporateRegistrationProvider);
    final notifier = ref.read(corporateRegistrationProvider.notifier);
    final customer = (form.customers.length > index)
        ? form.customers[index]
        : <String, dynamic>{};
    final fullNameController = TextEditingController(text: customer['fullName'] ?? '');
    final emailController = TextEditingController(text: customer['email'] ?? '');
    final phoneController = TextEditingController(text: customer['phone'] ?? '');
    String? selectedGender = customer['gender'];
    String? selectedTitle = customer['title'];

    void updateCustomerField(String key, dynamic value) {
      final updated = Map<String, dynamic>.from(customer);
      updated[key] = value;
      notifier.updateCustomer(index, updated);
    }

    Widget textLabel(String text) => Padding(
      padding: const EdgeInsets.only(top: 0, left: 10, right: 3),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textLabel("Full Name"),
        ReusableTextFormField(
          hintText: "Full Name",
          controller: fullNameController,
          keyboardType: TextInputType.text,
          errorMessage: "Full Name cannot be empty",
          leadingIcon: Icons.person,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
            TextInputFormatter.withFunction(
              (oldValue, newValue) {
                return newValue.copyWith(text: newValue.text.toUpperCase());
              },
            ),
          ],
          isRequired: true,
          onChanged: (value) => updateCustomerField('fullName', value),
        ),
        const SizedBox(height: 12),
        textLabel("Phone Number"),
        ReusableTextFormField(
          hintText: "Phone Number",
          controller: phoneController,
          keyboardType: TextInputType.phone,
          errorMessage: "Phone number cannot be empty",
          leadingIcon: Icons.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          isRequired: true,
          onChanged: (value) => updateCustomerField('phone', value),
        ),
        const SizedBox(height: 12),
        textLabel("Email"),
        ReusableTextFormField(
          hintText: "Email",
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          errorMessage: "Email cannot be empty",
          leadingIcon: Icons.email,
          isRequired: true,
          onChanged: (value) => updateCustomerField('email', value),
        ),
        const SizedBox(height: 12),
        textLabel("Gender"),
        ReusableDropdown(
          selectedValue: selectedGender,
          items: ListContants.gender,
          hintText: 'Select Gender',
          onChanged: (newStatus) => updateCustomerField('gender', newStatus),
          prefixIcon: Icons.person,
          errorMessage: 'Please select Gender',
          isRequired: false,
        ),
        const SizedBox(height: 12),
        textLabel("Title"),
        ReusableDropdown(
          selectedValue: selectedTitle,
          items: ListContants.title,
          hintText: 'Select Title',
          onChanged: (newStatus) => updateCustomerField('title', newStatus),
          prefixIcon: Icons.category,
          errorMessage: 'Please select a Title',
          isRequired: true,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _DocumentInfoSection extends ConsumerWidget {
  final int index;
  const _DocumentInfoSection({Key? key, required this.index}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(corporateRegistrationProvider);
    final notifier = ref.read(corporateRegistrationProvider.notifier);
    final customer = (form.customers.length > index)
        ? form.customers[index]
        : <String, dynamic>{};
    String? selectedDocumentType = customer['documentName'];

    void updateCustomerField(String key, dynamic value) {
      final updated = Map<String, dynamic>.from(customer);
      updated[key] = value;
      notifier.updateCustomer(index, updated);
    }

    Widget textLabel(String text) => Padding(
      padding: const EdgeInsets.only(top: 0, left: 10, right: 3),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textLabel("Document Type"),
        ReusableDropdown(
          selectedValue: selectedDocumentType,
          items: ListContants.documentName,
          hintText: 'Select Document Type',
          onChanged: (newStatus) => updateCustomerField('documentName', newStatus),
          prefixIcon: Icons.category,
          errorMessage: 'Please select a Document Type',
          isRequired: true,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _IDInfoSection extends ConsumerWidget {
  final int index;
  const _IDInfoSection({Key? key, required this.index}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(corporateRegistrationProvider);
    final notifier = ref.read(corporateRegistrationProvider.notifier);
    final customer = (form.customers.length > index)
        ? form.customers[index]
        : <String, dynamic>{};
    final legalIdController = TextEditingController(text: customer['legalId'] ?? '');
    final issueAuthorityController = TextEditingController(text: customer['issueAuthority'] ?? '');
    final issueDateController = TextEditingController(text: customer['issueDate'] ?? '');
    final expiryDateController = TextEditingController(text: customer['expiryDate'] ?? '');

    void updateCustomerField(String key, dynamic value) {
      final updated = Map<String, dynamic>.from(customer);
      updated[key] = value;
      notifier.updateCustomer(index, updated);
    }

    Widget textLabel(String text) => Padding(
      padding: const EdgeInsets.only(top: 0, left: 10, right: 3),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textLabel("Legal ID"),
        ReusableTextFormField(
          hintText: "Legal ID",
          controller: legalIdController,
          errorMessage: "Legal ID cannot be empty",
          leadingIcon: Icons.badge,
          isRequired: true,
          onChanged: (value) => updateCustomerField('legalId', value),
        ),
        const SizedBox(height: 12),
        textLabel("ISSUE AUTHORITY"),
        ReusableTextFormField(
          hintText: "ISSUE AUTHORITY",
          controller: issueAuthorityController,
          errorMessage: "ISSUE AUTHORITY cannot be empty",
          leadingIcon: Icons.verified,
          isRequired: false,
          onChanged: (value) => updateCustomerField('issueAuthority', value),
        ),
        const SizedBox(height: 12),
        textLabel("ISSUE DATE"),
        DatePickerField(
          controller: issueDateController,
          hintText: 'Issue Date',
          prefixIcon: Icons.calendar_today,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 15)),
          lastDate: DateTime.now(),
          isRequired: false,
          errorMessage: 'Please select an issue date',
        ),
        const SizedBox(height: 12),
        textLabel("EXPIRY DATE"),
        DatePickerField(
          controller: expiryDateController,
          hintText: 'Expire Date',
          prefixIcon: Icons.event_busy,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 12)),
          isRequired: false,
          errorMessage: 'Please select an expire date',
        ),
        const SizedBox(height: 12),
      ],
    );
  }
} 