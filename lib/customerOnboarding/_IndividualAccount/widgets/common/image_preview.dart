import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final String imagePath;

  const ImagePreview({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.9),
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Center(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
