import 'package:flutter/material.dart';

class ButtonUploadTakePhoto extends StatelessWidget {
  final Function onUploadPressed;
  final Function onCapturePressed;

  const ButtonUploadTakePhoto({
    Key? key,
    required this.onUploadPressed,
    required this.onCapturePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Upload Button
          Flexible(
            child: ElevatedButton.icon(
              onPressed: () => onUploadPressed(),
              icon: const Icon(Icons.photo_library),
              label: const Text('Upload Photo'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                textStyle: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),

          // Capture Button
          Flexible(
            child: ElevatedButton.icon(
              onPressed: () => onCapturePressed(),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Photo'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 10.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                textStyle: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
