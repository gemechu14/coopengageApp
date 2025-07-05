import 'package:flutter/material.dart';

class ButtonUploadTakePhotoWidget extends StatelessWidget {
  final VoidCallback onUploadPressed;
  final VoidCallback onCapturePressed;

  const ButtonUploadTakePhotoWidget({
    Key? key,
    required this.onUploadPressed,
    required this.onCapturePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          icon: Icons.upload_file,
          label: 'Upload',
          onPressed: onUploadPressed,
          color: Colors.blue,
        ),
        const SizedBox(width: 20),
        _buildButton(
          icon: Icons.camera_alt,
          label: 'Take Photo',
          onPressed: onCapturePressed,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
