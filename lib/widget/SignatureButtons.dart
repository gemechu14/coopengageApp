import 'package:flutter/material.dart';

class SignatureButtons extends StatelessWidget {
  final VoidCallback onDrawSignature;
  final VoidCallback onUploadOrTake;

  const SignatureButtons({
    Key? key,
    required this.onDrawSignature,
    required this.onUploadOrTake,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onDrawSignature,
              icon: const Icon(Icons.draw),
              label: const Text('    Draw    '),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 17.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onUploadOrTake,
              icon: const Icon(Icons.camera_alt),
              label: const Text('  Upload '),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
