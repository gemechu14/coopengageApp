import 'package:flutter/material.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/constants/listConstants.dart';

class DocumentInfoSection extends StatelessWidget {
  final String? selectedDocumentType;
  final ValueChanged<String?> onDocumentTypeChanged;
  final Widget idCardPhotoWidget;

  const DocumentInfoSection({
    Key? key,
    required this.selectedDocumentType,
    required this.onDocumentTypeChanged,
    required this.idCardPhotoWidget, required personalPhotoWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReusableDropdown(
          selectedValue: selectedDocumentType,
          items: ListContants.documentName,
          hintText: 'Select Document Type',
          onChanged: onDocumentTypeChanged,
          prefixIcon: Icons.category,
          errorMessage: 'Please select a Sector status',
          isRequired: true,
        ),
        idCardPhotoWidget,
      ],
    );
  }
} 