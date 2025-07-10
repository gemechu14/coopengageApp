import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:coopengageplus/features/onboarding/corporateCustomer/RegistrationServices.dart' as legacy;

class RegistrationService {
  Future<void> pickFile(Function(String?) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      onFilePicked(result.files.single.path);
    }
  }

  Future<Uint8List?> getImageBytes(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  Future<Map<String, dynamic>> registerAllUsers(Map<String, dynamic> requestData) async {
    legacy.RegistrationService registrationService = legacy.RegistrationService();
    var response = await registrationService.registerCustomers(requestData);
    return response;
  }
} 