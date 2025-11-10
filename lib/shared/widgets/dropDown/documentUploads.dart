import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FilePickerService {
  // Function to pick a single PDF file
  static Future<File?> pickSinglePDF(String documentType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false, // Allow only one file
    );

    if (result != null) {
      File selectedFile = File(result.files.single.path!);
      print("Selected $documentType: ${selectedFile.path}");
      return selectedFile;
    }

    print("No $documentType selected.");
    return null;
  }
}
