import 'package:flutter/material.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';

/// Reusable stepper bottom navigation bar with Previous / Next (or Submit) buttons.
class StepperNavBar extends StatelessWidget {
  final int activeStep;
  final int totalSteps;
  final bool isVisible;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const StepperNavBar({
    super.key,
    required this.activeStep,
    required this.totalSteps,
    required this.isVisible,
    required this.onPrevious,
    required this.onNext,
  });

  static LinearGradient get _cyanGradient => LinearGradient(
        colors: [cyanblueColor, cyanblueColor.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  bool get _isLastStep => activeStep >= totalSteps - 1;
  bool get _canGoPrevious => activeStep > 0;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _PreviousButton(enabled: _canGoPrevious, onPressed: onPrevious),
          _NextButton(isLastStep: _isLastStep, onPressed: onNext),
        ],
      ),
    );
  }
}

// ─── Previous Button ─────────────────────────────────────────────────────────

class _PreviousButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _PreviousButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: enabled ? null : Colors.grey.shade300,
          gradient: enabled ? StepperNavBar._cyanGradient : null,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: cyanblueColor.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.5),
          ),
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              disabledBackgroundColor: Colors.white,
              foregroundColor: Colors.transparent,
              disabledForegroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              minimumSize: const Size(118, 42),
              maximumSize: const Size(double.infinity, 42),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.5)),
              elevation: 0,
              splashFactory: InkRipple.splashFactory,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GradientIcon(
                    enabled: enabled,
                    icon: Icons.arrow_back_ios_new_rounded,
                    size: 14),
                const SizedBox(width: 6),
                _GradientLabel(enabled: enabled, text: 'Previous'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Next / Submit Button ────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  final bool isLastStep;
  final VoidCallback onPressed;

  const _NextButton({required this.isLastStep, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: StepperNavBar._cyanGradient,
          boxShadow: [
            BoxShadow(
              color: cyanblueColor.withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            minimumSize: const Size(118, 42),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLastStep ? 'Submit' : 'Next',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(width: 6),
              Icon(
                isLastStep ? Icons.check : Icons.arrow_forward_ios_rounded,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gradient helpers (file-private) ─────────────────────────────────────────

class _GradientLabel extends StatelessWidget {
  final bool enabled;
  final String text;

  const _GradientLabel({required this.enabled, required this.text});

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: cyanblueColor.withOpacity(0.38),
        ),
      );
    }
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          StepperNavBar._cyanGradient.createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _GradientIcon extends StatelessWidget {
  final bool enabled;
  final IconData icon;
  final double size;

  const _GradientIcon({
    required this.enabled,
    required this.icon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Icon(icon, size: size, color: cyanblueColor.withOpacity(0.38));
    }
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          StepperNavBar._cyanGradient.createShader(bounds),
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}
