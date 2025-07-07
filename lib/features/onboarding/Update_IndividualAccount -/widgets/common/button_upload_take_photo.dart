import 'package:flutter/material.dart';

class ButtonUploadTakePhoto extends StatelessWidget {
  final VoidCallback onUploadPressed;
  final VoidCallback onCapturePressed;

  const ButtonUploadTakePhoto({
    Key? key,
    required this.onUploadPressed,
    required this.onCapturePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: onUploadPressed,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: onCapturePressed,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take Photo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }
}
