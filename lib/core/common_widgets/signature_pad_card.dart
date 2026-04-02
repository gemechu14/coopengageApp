import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';

/// A styled signature drawing pad card.
///
/// Displays a labelled canvas where the user can draw a signature,
/// with a clear button. Designed to be stacked vertically when
/// multiple specimens are needed.
class SignaturePadCard extends StatelessWidget {
  final SignatureController controller;
  final String label;
  final String? subtitle;
  final VoidCallback onClear;
  final double height;
  final Color accentColor;

  const SignaturePadCard({
    super.key,
    required this.controller,
    required this.label,
    this.subtitle,
    required this.onClear,
    this.height = 150,
    this.accentColor = cyanblueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildCanvas(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(Icons.draw_outlined, size: 18, color: accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blueGrey.shade400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        size: 16, color: Colors.redAccent.shade100),
                    const SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(bottom: Radius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: accentColor.withOpacity(0.12)),
          ),
        ),
        child: Signature(
          controller: controller,
          backgroundColor: const Color(0xFFFCFDFE),
          height: height,
          width: double.infinity,
        ),
      ),
    );
  }
}
