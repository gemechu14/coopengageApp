import 'dart:io';
import 'package:flutter/material.dart';

void showFullScreenImage(BuildContext context, String imagePath) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      // ignore: deprecated_member_use
      backgroundColor: Colors.black.withOpacity(0.9),
      insetPadding: EdgeInsets.zero, // Fullscreen effect
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
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    ),
  );
}
