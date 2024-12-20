import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePad extends StatelessWidget {
  final String title;
  final SignatureController controller;
  final VoidCallback onClear;

  const SignaturePad({
    Key? key,
    required this.title,
    required this.controller,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.65,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 2, color: Colors.black),
              ),
            ),
            child: Signature(
              controller: controller,
              height: 170,
              backgroundColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onClear,
                child: const Text("Clear"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UploadOrSignButtons extends StatelessWidget {
  final VoidCallback onSign;
  final VoidCallback onUpload;

  const UploadOrSignButtons({
    Key? key,
    required this.onSign,
    required this.onUpload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onSign,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
          ),
          child: const Text("Sign"),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: onUpload,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
          ),
          child: const Text("Upload"),
        ),
      ],
    );
  }
}
