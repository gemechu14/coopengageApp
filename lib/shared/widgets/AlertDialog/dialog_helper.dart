import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:flutter/material.dart';

enum DialogType { error, success, info }

class DialogHelper {
  static const _radius = 16.0;
  static const _titleColor = Color(0xFF263238);
  static const _bodyColor = Color(0xFF546E7A);

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    DialogType type = DialogType.info,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    final visuals = _visualsFor(type);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: visuals.iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        visuals.icon,
                        color: visuals.iconFg,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _titleColor,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: _bodyColor,
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          onPressed?.call();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: cyanblueColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DialogVisuals {
  const _DialogVisuals({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
}

_DialogVisuals _visualsFor(DialogType type) {
  switch (type) {
    case DialogType.error:
      return const _DialogVisuals(
        icon: Icons.lock_person_outlined,
        iconBg: Color(0xFFFFEBEE),
        iconFg: Color(0xFFC62828),
      );
    case DialogType.success:
      return _DialogVisuals(
        icon: Icons.check_circle_outline,
        iconBg: cyanblueColor.withOpacity(0.12),
        iconFg: cyanblueColor,
      );
    case DialogType.info:
      return _DialogVisuals(
        icon: Icons.info_outline_rounded,
        iconBg: cyanblueColor.withOpacity(0.12),
        iconFg: cyanblueColor,
      );
  }
}
