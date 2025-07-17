import 'package:coopengageplus/constants/kconstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Update_IndividualAccount -/widgets/common/button_upload_take_photo.dart';
import '../providers/national_id_provider.dart';
import '../providers/stepper_provider.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:coopengageplus/features/onboarding/CorporateAccountOpening/widgets/personal_info_section.dart';
import 'package:coopengageplus/features/onboarding/CorporateAccountOpening/widgets/document_info_section.dart';
import 'package:coopengageplus/features/onboarding/CorporateAccountOpening/widgets/id_info_section.dart';
import 'package:coopengageplus/features/onboarding/CorporateAccountOpening/widgets/id_card_photo.dart';

class NationalIdAuthWidget extends ConsumerStatefulWidget {
  const NationalIdAuthWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<NationalIdAuthWidget> createState() =>
      _NationalIdAuthWidgetState();
}

class _NationalIdAuthWidgetState extends ConsumerState<NationalIdAuthWidget> {
  WebViewController? _webViewController;
  bool _disposed = false;
  String? _expectedFinalUrl;
  int? _selectedMemberIndex;
  int? expandedIndex;
  int? _prevNumberOfMembers;
  List<TextEditingController> fullNameControllers = [];
  List<TextEditingController> phoneControllers = [];
  List<TextEditingController> emailControllers = [];
  List<String?> selectedGender = [];
  List<String?> selectedTitle = [];
  List<int?> expandedSubIndexList = [];
  // Document Info
  List<String?> selectedDocumentType = [];
  List<TextEditingController> legalIDControllers = [];
  List<TextEditingController> issueAuthorityControllers = [];
  List<TextEditingController> cityControllers = [];
  List<TextEditingController> woredaControllers = [];
  List<TextEditingController> residenceControllers = [];
  List<TextEditingController> issueDateControllers = [];
  List<TextEditingController> expireDateControllers = [];
  // Add more controllers as needed for photos, signatures, etc.
  List<String> residentPaths = [];
  List<String> residentCardBackPaths = [];
  List<String> profilePaths = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        ref.read(nationalIdProvider.notifier).reset();

        ref.read(nationalIdProvider.notifier).callEsignetApi();
      }
    });
  }

  void _initMemberControllers(int numberOfMembers) {
    fullNameControllers =
        List.generate(numberOfMembers, (_) => TextEditingController());
    phoneControllers =
        List.generate(numberOfMembers, (_) => TextEditingController());
    emailControllers =
        List.generate(numberOfMembers, (_) => TextEditingController());
    selectedGender = List.generate(numberOfMembers, (_) => null);
    selectedTitle = List.generate(numberOfMembers, (_) => null);
    expandedIndex = 0;
    expandedSubIndexList = List.generate(
        numberOfMembers, (_) => 0); // 0: Personal, 1: Document, 2: ID
    selectedDocumentType = List.generate(numberOfMembers, (_) => null);
    legalIDControllers =
        List.generate(numberOfMembers, (_) => TextEditingController());
    issueAuthorityControllers =
        List.generate(numberOfMembers, (_) => TextEditingController());
    cityControllers =
        List.generate(numberOfMembers, (_) => TextEditingController());
    woredaControllers =
        List.generate(numberOfMembers, (_) => TextEditingController());
    residenceControllers =
        List.generate(numberOfMembers, (_) => TextEditingController());
    issueDateControllers =
        List.generate(numberOfMembers, (_) => TextEditingController());
    expireDateControllers =
        List.generate(numberOfMembers, (_) => TextEditingController());
    residentPaths = List.generate(numberOfMembers, (_) => "");
    residentCardBackPaths = List.generate(numberOfMembers, (_) => "");
    profilePaths = List.generate(numberOfMembers, (_) => "");
  }

  @override
  void dispose() {
    _disposed = true;

    for (final c in fullNameControllers) {
      c.dispose();
    }
    for (final c in phoneControllers) {
      c.dispose();
    }
    for (final c in emailControllers) {
      c.dispose();
    }
    for (final c in legalIDControllers) {
      c.dispose();
    }
    for (final c in issueAuthorityControllers) {
      c.dispose();
    }
    for (final c in cityControllers) {
      c.dispose();
    }
    for (final c in woredaControllers) {
      c.dispose();
    }
    for (final c in residenceControllers) {
      c.dispose();
    }
    for (final c in issueDateControllers) {
      c.dispose();
    }
    for (final c in expireDateControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return const SizedBox.shrink();

    try {
      final stepperState = ref.watch(stepperProvider);
      final numberOfMembers = stepperState.numberOfMembers;

      if (_prevNumberOfMembers != numberOfMembers) {
        _initMemberControllers(numberOfMembers);
        _prevNumberOfMembers = numberOfMembers;
      }
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Theme(
                data: Theme.of(context).copyWith(
                  cardColor: whiteColor, // or any color you want
                ),
                child: ExpansionPanelList.radio(
                  // backgroundColor: Colors.amber[100],

                  expandedHeaderPadding: EdgeInsets.zero,
                  initialOpenPanelValue: expandedIndex,
                  children: List.generate(numberOfMembers, (i) {
                    return ExpansionPanelRadio(
                      value: i,
                      headerBuilder: (context, isExpanded) => ListTile(
                        title: Text('Person  ${i + 1}'),
                      ),
                      body: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExpansionPanelList.radio(
                                expandedHeaderPadding: EdgeInsets.zero,
                                initialOpenPanelValue: expandedSubIndexList[i],
                                children: [
                                  ExpansionPanelRadio(
                                    value: 0,
                                    headerBuilder: (context, isExpanded) =>
                                        ListTile(
                                            title:
                                                Text('Personal Information')),
                                    body: PersonalInfoSection(
                                      fullNameController:
                                          fullNameControllers[i],
                                      phoneController: phoneControllers[i],
                                      emailController: emailControllers[i],
                                      selectedGender: selectedGender[i],
                                      selectedTitle: selectedTitle[i],
                                      onGenderChanged: (newStatus) {
                                        setState(() {
                                          selectedGender[i] = newStatus;
                                        });
                                      },
                                      onTitleChanged: (newStatus) {
                                        setState(() {
                                          selectedTitle[i] = newStatus;
                                        });
                                      },
                                    ),
                                  ),
                                  ExpansionPanelRadio(
                                    value: 1,
                                    headerBuilder: (context, isExpanded) =>
                                        ListTile(
                                            title:
                                                Text('Document Information')),
                                    body: DocumentInfoSection(
                                      selectedDocumentType:
                                          selectedDocumentType[i],
                                      onDocumentTypeChanged: (newStatus) {
                                        setState(() {
                                          selectedDocumentType[i] = newStatus;
                                        });
                                      },
                                      idCardPhotoWidget: IdCardPhoto(
                                        index: i,
                                        selectedDocumentType:
                                            selectedDocumentType[i],
                                        residentPath: residentPaths[i],
                                        residentCardBackPath:
                                            residentCardBackPaths[i],
                                        profilePath: profilePaths[i],
                                        onUploadFront: () =>
                                            _imgFromGallery(i, "resident"),
                                        onCaptureFront: () =>
                                            _imgFromCamera(i, "resident"),
                                        onUploadBack: () => _imgFromGallery(
                                            i, "residentCardBack"),
                                        onCaptureBack: () => _imgFromCamera(
                                            i, "residentCardBack"),
                                        onUploadProfile: () =>
                                            _imgFromGallery(i, "profilePath"),
                                        onCaptureProfile: () =>
                                            _imgFromCamera(i, "profilePath"),
                                        showFullScreen: (path) =>
                                            _showFullScreenImage(context, path),
                                      ),
                                      personalPhotoWidget: null,
                                    ),
                                  ),
                                  ExpansionPanelRadio(
                                    value: 2,
                                    headerBuilder: (context, isExpanded) =>
                                        ListTile(title: Text('ID Information')),
                                    body: IDInfoSection(
                                      legalIDController: legalIDControllers[i],
                                      issueAuthorityController:
                                          issueAuthorityControllers[i],
                                      issueDateController:
                                          issueDateControllers[i],
                                      expireDateController:
                                          expireDateControllers[i],
                                    ),
                                  ),
                                ],
                                expansionCallback: (panelIndex, isExpanded) {
                                  setState(() {
                                    expandedSubIndexList[i] =
                                        isExpanded ? null : panelIndex;
                                  });
                                },
                              ),
                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return const Center(
        child: Text(
          'Error loading authentication widget',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }

  // void _showFullScreenImage(BuildContext context, String imagePath) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => Dialog(
  //       child: Image.file(File(imagePath)),
  //     ),
  //   );
  // }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _imgFromGallery(int i, String imageTypes) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File originalFile = File(pickedFile.path);

      // Step 1: Check if the original file exists
      bool originalExists = await originalFile.exists();

      if (!originalExists) {
        return;
      }

      // Step 2: Get the application's document directory
      Directory appDir = await getApplicationDocumentsDirectory();
      String newPath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        // Step 3: Copy the file to the permanent directory
        File newImage = await originalFile.copy(newPath);

        // Step 4: Verify the new file exists
        bool newFileExists = await newImage.exists();

        if (newFileExists) {
          setState(() {
            if (imageTypes == 'resident') {
              residentPaths[i] = newPath;
            } else if (imageTypes == 'residentCardBack') {
              residentCardBackPaths[i] = newPath;
            } else if (imageTypes == 'profilePath') {
              profilePaths[i] = newPath;
            }
            // Add other imageTypes as needed
          });
        } else {}
      } catch (e) {
        print("Error copying file: $e");
      }
    }
  }

  Future<void> _imgFromCamera(int i, String imageTypes) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File originalFile = File(pickedFile.path);

      bool originalExists = await originalFile.exists();

      if (!originalExists) {
        return;
      }

      Directory appDir = await getApplicationDocumentsDirectory();
      String newPath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        File newImage = await originalFile.copy(newPath);
        bool newFileExists = await newImage.exists();

        if (newFileExists) {
          setState(() {
            if (imageTypes == 'resident') {
              residentPaths[i] = newPath;
            } else if (imageTypes == 'residentCardBack') {
              residentCardBackPaths[i] = newPath;
            } else if (imageTypes == 'profilePath') {
              profilePaths[i] = newPath;
            }
            // Add other imageTypes as needed
          });
        } else {}
      } catch (e) {
        print("Error copying file: $e");
      }
    }
  }
}

class PersonalPhotoSection extends StatelessWidget {
  final String profilePath;
  final VoidCallback onUploadPressed;
  final VoidCallback onCapturePressed;
  final void Function(String path) showFullScreen;

  const PersonalPhotoSection({
    Key? key,
    required this.profilePath,
    required this.onUploadPressed,
    required this.onCapturePressed,
    required this.showFullScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    : GestureDetector(
                        onTap: () => showFullScreen(profilePath),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.file(
                            File(profilePath),
                            height: 200,
                            width: MediaQuery.of(context).size.width * 0.8,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 40.0),
              ButtonUploadTakePhoto(
                onUploadPressed: onUploadPressed,
                onCapturePressed: onCapturePressed,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
