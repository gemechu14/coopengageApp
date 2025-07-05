import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePadDialog extends StatelessWidget {
  final SignatureController controller1;
  final SignatureController controller2;
  final SignatureController controller3;
  final VoidCallback onSave;
  final VoidCallback Function(int index) onClear;

  const SignaturePadDialog({
    super.key,
    required this.controller1,
    required this.controller2,
    required this.controller3,
    required this.onSave,
    required this.onClear,
  });

  bool _areAllSignaturesCompleted() {
    return !controller1.isEmpty && !controller2.isEmpty && !controller3.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Draw Signatures',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSignatureBox(context, controller1, 1, "Signature 1"),
              const SizedBox(height: 20),
              _buildSignatureBox(context, controller2, 2, "Signature 2"),
              const SizedBox(height: 20),
              _buildSignatureBox(context, controller3, 3, "Signature 3"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_areAllSignaturesCompleted()) {
                        onSave();
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please complete all signatures'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureBox(
      BuildContext context, SignatureController controller, int index, String label) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Signature(
            controller: controller,
            backgroundColor: Colors.white,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            TextButton(
              onPressed: () => onClear(index),
              child: const Text("Clear"),
            ),
          ],
        ),
      ],
    );
  }
}
