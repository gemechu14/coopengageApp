// Riverpod-based rewrite of the corporate account registration flow
// This file is self-contained and does not affect the original implementation

import 'dart:io';
import 'dart:typed_data';
import 'package:coopengageplus/features/onboarding/corporateCustomer/update/basic_info_step_riverpod.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
// Import other necessary widgets and helpers as in the original file
// ... existing code ...

// --- Providers for state management ---
final stepIndexProvider = StateProvider<int>((ref) => 0);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final selectedProductTypeProvider = StateProvider<String?>((ref) => null);
final companyNameControllerProvider =
    Provider((ref) => TextEditingController());
final phoneNumberControllerProvider =
    Provider((ref) => TextEditingController());
final emailControllerProvider = Provider((ref) => TextEditingController());
final tinNumberControllerProvider = Provider((ref) => TextEditingController());
final dateOfEstablishmentControllerProvider =
    Provider((ref) => TextEditingController());
final residenceControllersProvider = Provider((ref) => TextEditingController());
final selectedBranchProvider = StateProvider<String?>((ref) => null);
final selectedStateProvider = StateProvider<String?>((ref) => null);
final cityControllerProvider = Provider((ref) => TextEditingController());
final woredaControllerProvider = Provider((ref) => TextEditingController());
final numberOfMembersProvider = StateProvider<String?>((ref) => null);
final initialDepositControllerProvider =
    Provider((ref) => TextEditingController());
final licenseFileProvider = StateProvider<String?>((ref) => null);
final articleFileProvider = StateProvider<String?>((ref) => null);
final letterOfRequestFileProvider = StateProvider<String?>((ref) => null);
final tinNumberPhotoProvider = StateProvider<String?>((ref) => null);
final tradeNameProvider = StateProvider<String?>((ref) => null);
final selectedFilesProvider = StateProvider<List<File>>((ref) => []);
// ... add more providers for other fields as needed ...

// --- Additional Providers for full feature parity ---
final membersCountProvider = StateProvider<int>((ref) => 1);
final fullNameControllersProvider = Provider<List<TextEditingController>>(
  (ref) => List.generate(
      ref.watch(membersCountProvider), (_) => TextEditingController()),
);
final phoneControllersProvider = Provider<List<TextEditingController>>(
  (ref) => List.generate(
      ref.watch(membersCountProvider), (_) => TextEditingController()),
);
final emailControllersProvider = Provider<List<TextEditingController>>(
  (ref) => List.generate(
      ref.watch(membersCountProvider), (_) => TextEditingController()),
);
final genderProvider = StateProvider<List<String?>>(
    (ref) => List.generate(ref.watch(membersCountProvider), (_) => null));
final titleProvider = StateProvider<List<String?>>(
    (ref) => List.generate(ref.watch(membersCountProvider), (_) => null));
final documentTypeProvider = StateProvider<List<String?>>(
    (ref) => List.generate(ref.watch(membersCountProvider), (_) => null));
final legalIDControllersProvider = Provider<List<TextEditingController>>(
  (ref) => List.generate(
      ref.watch(membersCountProvider), (_) => TextEditingController()),
);
final issueAuthorityControllersProvider = Provider<List<TextEditingController>>(
  (ref) => List.generate(
      ref.watch(membersCountProvider), (_) => TextEditingController()),
);
final issueDateControllersProvider = Provider<List<TextEditingController>>(
  (ref) => List.generate(
      ref.watch(membersCountProvider), (_) => TextEditingController()),
);
final expireDateControllersProvider = Provider<List<TextEditingController>>(
  (ref) => List.generate(
      ref.watch(membersCountProvider), (_) => TextEditingController()),
);
final personalPhotoPathsProvider = StateProvider<List<String>>(
    (ref) => List.generate(ref.watch(membersCountProvider), (_) => ''));
final residentPathsProvider = StateProvider<List<String>>(
    (ref) => List.generate(ref.watch(membersCountProvider), (_) => ''));
final residentCardBackPathsProvider = StateProvider<List<String>>(
    (ref) => List.generate(ref.watch(membersCountProvider), (_) => ''));
final combinedSignaturesProvider = StateProvider<List<Uint8List>>((ref) =>
    List.generate(ref.watch(membersCountProvider), (_) => Uint8List(0)));
final isExpandedListProvider = StateProvider<List<bool>>(
    (ref) => List.generate(ref.watch(membersCountProvider), (_) => false));
final isExpandedPersonalListProvider = StateProvider<List<List<bool>>>(
    (ref) => List.generate(ref.watch(membersCountProvider), (_) => [false]));
final isExpandedDocumentInfoListProvider = StateProvider<List<List<bool>>>(
    (ref) => List.generate(ref.watch(membersCountProvider), (_) => [false]));
final isExpandedIDInfoListProvider = StateProvider<List<List<bool>>>(
    (ref) => List.generate(ref.watch(membersCountProvider), (_) => [false]));
// ... add more providers for all other state as needed ...

// --- Main Widget ---
class CorporateAccountRiverpodPage extends ConsumerWidget {
  const CorporateAccountRiverpodPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepIndex = ref.watch(stepIndexProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final membersCount = ref.watch(membersCountProvider);
    // Controllers
    final companyNameController = ref.watch(companyNameControllerProvider);
    final phoneNumberController = ref.watch(phoneNumberControllerProvider);
    final emailController = ref.watch(emailControllerProvider);
    final tinNumberController = ref.watch(tinNumberControllerProvider);
    final dateOfEstablishmentController =
        ref.watch(dateOfEstablishmentControllerProvider);
    final residenceControllers = ref.watch(residenceControllersProvider);
    final selectedProductType = ref.watch(selectedProductTypeProvider);
    final selectedBranch = ref.watch(selectedBranchProvider);
    final selectedState = ref.watch(selectedStateProvider);
    final cityController = ref.watch(cityControllerProvider);
    final woredaController = ref.watch(woredaControllerProvider);
    final numberOfMembers = ref.watch(numberOfMembersProvider);
    final initialDepositController =
        ref.watch(initialDepositControllerProvider);
    final licenseFile = ref.watch(licenseFileProvider);
    final articleFile = ref.watch(articleFileProvider);
    final letterOfRequestFile = ref.watch(letterOfRequestFileProvider);
    final tinNumberPhoto = ref.watch(tinNumberPhotoProvider);
    final tradeName = ref.watch(tradeNameProvider);
    final selectedFiles = ref.watch(selectedFilesProvider);
    // ... other fields ...

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Corporate Account Opening",
          style: TextStyle(
              fontSize: 19, fontWeight: FontWeight.bold, color: Colors.blue),
        ),

        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
                (route) => false,
              );
            }),
        // actions: [
        //   IconButton(
        //       icon: const Icon(Icons.sync_outlined), onPressed: () {}),
        // ],
        // centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: stepIndex,
        margin: EdgeInsets.zero,
        steps: [
          Step(
            title: const SizedBox.shrink(),
            content: BasicInfoStepRiverpod(),
            isActive: stepIndex >= 0,
          ),
          Step(
            title: const SizedBox.shrink(),
            content: _SignatureStep(),
            isActive: stepIndex >= 1,
          ),
          Step(
            title: const SizedBox.shrink(),
            content: Column(
              children: List.generate(
                  membersCount, (i) => _PersonalInfoMemberStep(index: i)),
            ),
            isActive: stepIndex >= 2,
          ),
          Step(
            title: const SizedBox.shrink(),
            content: _FinancialStep(),
            isActive: stepIndex >= 3,
          ),
          Step(
            title: const SizedBox.shrink(),
            content: _DocumentsStep(),
            isActive: stepIndex >= 4,
          ),
          Step(
            title: const SizedBox.shrink(),
            content: _AccountTypeStep(),
            isActive: stepIndex >= 5,
          ),
        ],
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (stepIndex > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        if (stepIndex > 0) {
                          ref.read(stepIndexProvider.notifier).state--;
                        }
                      },
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
                    onPressed: isLoading
                        ? null
                        : () {
                            if (stepIndex == 0) {
                              // Validation for first step
                              final companyName = ref
                                  .read(companyNameControllerProvider)
                                  .text
                                  .trim();
                              final phoneNumber = ref
                                  .read(phoneNumberControllerProvider)
                                  .text
                                  .trim();
                              bool valid = true;
                              if (companyName.isEmpty) {
                                ref
                                    .read(companyNameErrorProvider.notifier)
                                    .state = "Company Name cannot be empty";
                                valid = false;
                              } else {
                                ref
                                    .read(companyNameErrorProvider.notifier)
                                    .state = null;
                              }
                              if (phoneNumber.isEmpty) {
                                ref
                                    .read(phoneNumberErrorProvider.notifier)
                                    .state = "Phone Number cannot be empty";
                                valid = false;
                              } else {
                                ref
                                    .read(phoneNumberErrorProvider.notifier)
                                    .state = null;
                              }
                              if (!valid) return;
                            }
                            if (stepIndex < 5) {
                              ref.read(stepIndexProvider.notifier).state++;
                            } else {
                              // Submit logic here
                            }
                          },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            stepIndex == 5 ? 'Submit' : 'Continue',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SignatureStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For demonstration, a simple signature pad using the signature package
    final signatureController = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Draw your signature below:'),
        const SizedBox(height: 12),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Signature(
            controller: signatureController,
            backgroundColor: Colors.white,
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => signatureController.clear(),
              child: const Text('Clear'),
            ),
            // Save logic can be added here
          ],
        ),
      ],
    );
  }
}

class _PersonalInfoStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Example: Only one person, but can be extended for multiple
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final genderOptions = ['MALE', 'FEMALE'];
    final titleOptions = ['MR', 'MS', 'DR'];
    String? selectedGender;
    String? selectedTitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: fullNameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedGender,
          decoration: const InputDecoration(
            labelText: 'Gender',
            border: OutlineInputBorder(),
          ),
          items: genderOptions
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (val) {
            selectedGender = val;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedTitle,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
          items: titleOptions
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (val) {
            selectedTitle = val;
          },
        ),
      ],
    );
  }
}

class _FinancialStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialDepositController =
        ref.watch(initialDepositControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: initialDepositController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Initial Deposit',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _DocumentsStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licenseFile = ref.watch(licenseFileProvider);
    final articleFile = ref.watch(articleFileProvider);
    final letterOfRequestFile = ref.watch(letterOfRequestFileProvider);
    final tinNumberPhoto = ref.watch(tinNumberPhotoProvider);
    final tradeName = ref.watch(tradeNameProvider);
    final selectedFiles = ref.watch(selectedFilesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform
                .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
            if (result != null && result.files.single.path != null) {
              ref.read(licenseFileProvider.notifier).state =
                  result.files.single.path;
            }
          },
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload License'),
        ),
        if (licenseFile != null)
          ListTile(
            title: Text(licenseFile.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () =>
                  ref.read(licenseFileProvider.notifier).state = null,
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform
                .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
            if (result != null && result.files.single.path != null) {
              ref.read(articleFileProvider.notifier).state =
                  result.files.single.path;
            }
          },
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Articles of Association'),
        ),
        if (articleFile != null)
          ListTile(
            title: Text(articleFile.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () =>
                  ref.read(articleFileProvider.notifier).state = null,
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform
                .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
            if (result != null && result.files.single.path != null) {
              ref.read(letterOfRequestFileProvider.notifier).state =
                  result.files.single.path;
            }
          },
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Letter of Request'),
        ),
        if (letterOfRequestFile != null)
          ListTile(
            title: Text(letterOfRequestFile.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () =>
                  ref.read(letterOfRequestFileProvider.notifier).state = null,
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform
                .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
            if (result != null && result.files.single.path != null) {
              ref.read(tinNumberPhotoProvider.notifier).state =
                  result.files.single.path;
            }
          },
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload TIN Photo'),
        ),
        if (tinNumberPhoto != null)
          ListTile(
            title: Text(tinNumberPhoto.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () =>
                  ref.read(tinNumberPhotoProvider.notifier).state = null,
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform
                .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
            if (result != null && result.files.single.path != null) {
              ref.read(tradeNameProvider.notifier).state =
                  result.files.single.path;
            }
          },
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Trade Name Registration'),
        ),
        if (tradeName != null)
          ListTile(
            title: Text(tradeName.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () =>
                  ref.read(tradeNameProvider.notifier).state = null,
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            FilePickerResult? result =
                await FilePicker.platform.pickFiles(allowMultiple: true);
            if (result != null) {
              final files = result.paths
                  .whereType<String>()
                  .map((path) => File(path))
                  .toList();
              ref.read(selectedFilesProvider.notifier).state = [
                ...selectedFiles,
                ...files
              ];
            }
          },
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Other Documents'),
        ),
        if (selectedFiles.isNotEmpty)
          ...selectedFiles.asMap().entries.map((entry) {
            int idx = entry.key;
            File file = entry.value;
            return ListTile(
              title: Text(file.path.split('/').last),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  final updated = [...selectedFiles]..removeAt(idx);
                  ref.read(selectedFilesProvider.notifier).state = updated;
                },
              ),
            );
          }),
      ],
    );
  }
}

class _AccountTypeStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Example account types, replace with your actual list
    final accountTypes = [
      {'name': 'Savings', 'description': 'Standard savings account.'},
      {'name': 'Current', 'description': 'Current account for business.'},
      {'name': 'Fixed', 'description': 'Fixed deposit account.'},
    ];
    String? selectedAccountType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Account Type:'),
        const SizedBox(height: 8),
        ...accountTypes.map((type) => Card(
              child: ListTile(
                title: Text(type['name'] ?? ''),
                subtitle: Text(type['description'] ?? ''),
                trailing: Radio<String>(
                  value: type['name']!,
                  groupValue: selectedAccountType,
                  onChanged: (val) {
                    selectedAccountType = val;
                  },
                ),
              ),
            )),
      ],
    );
  }
}
// ... Add more widgets and providers as needed to match the original functionality ...

// --- Placeholder for dynamic member personal info step ---
class _PersonalInfoMemberStep extends ConsumerWidget {
  final int index;
  const _PersonalInfoMemberStep({required this.index});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // To be filled in with full logic and UI for each member
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            Text('Personal Info for Member #${index + 1} (to be implemented)'),
      ),
    );
  }
}
