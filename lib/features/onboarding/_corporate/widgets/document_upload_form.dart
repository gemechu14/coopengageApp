import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../_corporate/providers/registration_providers.dart';
import '../../_corporate/models/corporate_registration_form.dart';
import 'dart:typed_data';

class DocumentUploadForm extends ConsumerWidget {
  const DocumentUploadForm({Key? key}) : super(key: key);

  Future<void> _pickFile(BuildContext context, WidgetRef ref, String field) async {
    // You can use file_picker or image_picker here. For now, just simulate.
    // Uint8List? fileBytes = await ...
    // ref.read(corporateRegistrationProvider.notifier).updateField(field, fileBytes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File picker for $field not implemented.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(corporateRegistrationProvider);
    final notifier = ref.read(corporateRegistrationProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUploadTile(context, ref, 'Letter of Request', form.letterOfRequest, 'letterOfRequest'),
        _buildUploadTile(context, ref, 'Trade License', form.tradeLicense, 'tradeLicense'),
        _buildUploadTile(context, ref, 'Articles of Association', form.articlesOfAssociation, 'articlesOfAssociation'),
      ],
    );
  }

  Widget _buildUploadTile(BuildContext context, WidgetRef ref, String label, Uint8List? file, String field) {
    return ListTile(
      title: Text(label),
      subtitle: file != null ? const Text('File selected') : const Text('No file selected'),
      trailing: ElevatedButton(
        onPressed: () => _pickFile(context, ref, field),
        child: const Text('Upload'),
      ),
    );
  }
} 