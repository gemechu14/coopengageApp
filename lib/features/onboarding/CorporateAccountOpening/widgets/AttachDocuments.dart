// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:coopengageplus/features/onboarding/CorporateAccountOpening/providers/stepper_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class AttachDocumentsStep extends ConsumerStatefulWidget {
  const AttachDocumentsStep({Key? key}) : super(key: key);

  @override
  ConsumerState<AttachDocumentsStep> createState() =>
      _AttachDocumentsStepStepState();
}

class _AttachDocumentsStepStepState extends ConsumerState<AttachDocumentsStep> {
  int expandedIndex = 0;
  final List<TextEditingController> motherNameControllers = [];
  final TextEditingController initialDepositController =
      TextEditingController();

  @override
  void dispose() {
    for (final controller in motherNameControllers) {
      controller.dispose();
    }
    initialDepositController.dispose();
    super.dispose();
  }

  Widget _buildUploadSection({
    required BuildContext context,
    required String label,
    required IconData icon,
    required List<String> filePaths,
    required VoidCallback onUpload,
    required Function(int index) onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onUpload,
            icon: Icon(icon, color: Colors.white),
            label: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.black45,
            ),
          ),
        ),
        if (filePaths.isNotEmpty)
          ...filePaths.asMap().entries.map((entry) {
            int index = entry.key;
            String filePath = entry.value;
            return Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(
                  filePath.split('/').last,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => onDelete(index),
                ),
              ),
            );
          }).toList(),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stepperState = ref.watch(stepperProvider);
    final notifier = ref.read(stepperProvider.notifier);
    final memberCount = stepperState.numberOfMembers;

    // Ensure controllers are up to date
    while (motherNameControllers.length < memberCount) {
      motherNameControllers.add(TextEditingController());
    }
    while (motherNameControllers.length > memberCount) {
      motherNameControllers.removeLast().dispose();
    }

    final licenseFiles = stepperState.licenseFiles;
    final articleFiles = stepperState.articleFiles;
    final letterOfRequestFiles = stepperState.letterOfRequestFiles;
    final tinNumberPhotos = stepperState.tinNumberPhotos;
    final tradeNameFiles = stepperState.tradeNameFiles;
    final otherFiles = stepperState.otherFiles;

    // Debug: Print current file states
    print('Current file states:');
    print('License: $licenseFiles');
    print('Article: $articleFiles');
    print('Letter: $letterOfRequestFiles');
    print('TIN: $tinNumberPhotos');
    print('Trade: $tradeNameFiles');
    print('Other: $otherFiles');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadSection(
              context: context,
              label: "Upload License",
              icon: Icons.upload_file,
              filePaths: licenseFiles,
              onUpload: () => showFilePickerOptions(
                context: context,
                onFilePicked: (path) {
                  notifier.addLicenseFile(path);
                },
              ),
              onDelete: (index) {
                print('Deleting license file at index $index');
                notifier.removeLicenseFile(index);
              },
            ),
            _buildUploadSection(
              context: context,
              label: "Upload Articles of Association",
              icon: Icons.description_rounded,
              filePaths: articleFiles,
              onUpload: () => showFilePickerOptions(
                context: context,
                onFilePicked: (path) {
                  notifier.addArticleFile(path);
                },
              ),
              onDelete: (index) {
                print('Deleting article file at index $index');
                notifier.removeArticleFile(index);
              },
            ),
            _buildUploadSection(
              context: context,
              label: "Letter Of Request",
              icon: Icons.description_rounded,
              filePaths: letterOfRequestFiles,
              onUpload: () => showFilePickerOptions(
                context: context,
                onFilePicked: (path) {
                  notifier.addLetterOfRequestFile(path);
                },
              ),
              onDelete: (index) {
                print('Deleting letter of request file at index $index');
                notifier.removeLetterOfRequestFile(index);
              },
            ),
            _buildUploadSection(
              context: context,
              label: "TIN Photo",
              icon: Icons.description_rounded,
              filePaths: tinNumberPhotos,
              onUpload: () => showFilePickerOptions(
                context: context,
                onFilePicked: (path) {
                  notifier.addTinNumberPhoto(path);
                },
              ),
              onDelete: (index) {
                print('Deleting TIN photo at index $index');
                notifier.removeTinNumberPhoto(index);
              },
            ),
            _buildUploadSection(
              context: context,
              label: "Trade Name Registration",
              icon: Icons.description_rounded,
              filePaths: tradeNameFiles,
              onUpload: () => showFilePickerOptions(
                context: context,
                onFilePicked: (path) {
                  notifier.addTradeNameFile(path);
                },
              ),
              onDelete: (index) {
                print('Deleting trade name file at index $index');
                notifier.removeTradeNameFile(index);
              },
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => pickFiles(context, (List<String> files) {
                  notifier.updateOtherFiles(files);
                }),
                icon: Icon(Icons.upload_file, color: Colors.white),
                label: Text(
                  "Upload other documents",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: Colors.black45,
                ),
              ),
            ),
            if (otherFiles.isNotEmpty)
              Column(
                children: otherFiles.asMap().entries.map((entry) {
                  int index = entry.key;
                  String filePath = entry.value;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                      title: Text(
                        filePath.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          final updated = List<String>.from(otherFiles)
                            ..removeAt(index);
                          notifier.updateOtherFiles(updated);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            SizedBox(height: 27),
          ],
        ),
      ),
    );
  }

  Future<void> showFilePickerOptions({
    required BuildContext context,
    required Function(String path) onFilePicked,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('Upload PDF'),
              onTap: () async {
                Navigator.pop(context);
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result != null && result.files.single.path != null) {
                  onFilePicked(result.files.single.path!);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Capture with Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (image != null) {
                  onFilePicked(image.path);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Pick from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image != null) {
                  onFilePicked(image.path);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> pickFiles(BuildContext context,
      void Function(List<String> files) onFilesPicked) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('Upload PDF(s)'),
              onTap: () async {
                Navigator.pop(context);
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                  allowMultiple: true,
                );
                if (result != null) {
                  onFilesPicked(
                    result.paths.whereType<String>().toList(),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Pick Image(s) from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                List<XFile>? images = await ImagePicker().pickMultiImage();
                if (images != null) {
                  onFilesPicked(images.map((img) => img.path).toList());
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Capture with Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (image != null) {
                  onFilesPicked([image.path]);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
