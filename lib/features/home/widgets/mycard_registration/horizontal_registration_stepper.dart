import 'package:flutter/material.dart';

/// One step in a horizontal registration flow (label only; optional short subtitle).
class RegistrationStepDef {
  const RegistrationStepDef({
    required this.label,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
}

/// Horizontal stepper: numbered circles connected by lines, labels below.
///
/// [currentIndex] is 0-based. Steps with index `< currentIndex` are completed
/// (checkmark). Step `currentIndex` is active (filled). Later steps are pending.
/// If [currentIndex] is null, all steps show numbers (informational layout).
class HorizontalRegistrationStepper extends StatelessWidget {
  const HorizontalRegistrationStepper({
    super.key,
    required this.steps,
    required this.accentColor,
    required this.mutedColor,
    this.currentIndex,
    this.compact = false,
  });

  final List<RegistrationStepDef> steps;
  final Color accentColor;
  final Color mutedColor;
  /// Active step (0-based), or null for a neutral "all steps" display.
  final int? currentIndex;
  final bool compact;

  static const Color _pendingFill = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final n = steps.length;
    if (n == 0) return const SizedBox.shrink();

    final circleSize = compact ? 28.0 : 32.0;
    final fontSize = compact ? 11.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < n; i++) ...[
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: circleSize + 4,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (i > 0)
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    margin: EdgeInsets.only(right: circleSize * 0.35),
                                    decoration: BoxDecoration(
                                      color: _lineColor(i),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ),
                              _StepCircle(
                                size: circleSize,
                                stepNumber: i + 1,
                                accentColor: accentColor,
                                mutedColor: mutedColor,
                                pendingFill: _pendingFill,
                                state: _stateFor(i),
                              ),
                              if (i < n - 1)
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    margin: EdgeInsets.only(left: circleSize * 0.35),
                                    decoration: BoxDecoration(
                                      color: _lineColor(i + 1),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      steps[i].label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: _labelColor(i),
                        height: 1.15,
                      ),
                    ),
                    if (steps[i].subtitle != null) ...[
                      SizedBox(height: compact ? 2 : 4),
                      Text(
                        steps[i].subtitle!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: fontSize - 1,
                          fontWeight: FontWeight.w500,
                          color: mutedColor,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  _StepVisualState _stateFor(int index) {
    final cur = currentIndex;
    if (cur == null) return _StepVisualState.informational;
    if (index < cur) return _StepVisualState.completed;
    if (index == cur) return _StepVisualState.active;
    return _StepVisualState.pending;
  }

  Color _lineColor(int segmentAfterIndex) {
    final cur = currentIndex;
    if (cur == null) return accentColor.withOpacity(0.35);
    final completedThrough = segmentAfterIndex - 1;
    return completedThrough < cur
        ? accentColor.withOpacity(0.55)
        : accentColor.withOpacity(0.2);
  }

  Color _labelColor(int index) {
    final cur = currentIndex;
    if (cur == null) return accentColor;
    if (index < cur) return accentColor;
    if (index == cur) return accentColor;
    return mutedColor;
  }
}

enum _StepVisualState { completed, active, pending, informational }

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.size,
    required this.stepNumber,
    required this.accentColor,
    required this.mutedColor,
    required this.pendingFill,
    required this.state,
  });

  final double size;
  final int stepNumber;
  final Color accentColor;
  final Color mutedColor;
  final Color pendingFill;
  final _StepVisualState state;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.45;
    switch (state) {
      case _StepVisualState.completed:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.28),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.check_rounded, color: Colors.white, size: iconSize + 2),
        );
      case _StepVisualState.active:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.32),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.42,
              ),
            ),
          ),
        );
      case _StepVisualState.pending:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: pendingFill,
            shape: BoxShape.circle,
            border: Border.all(color: mutedColor.withOpacity(0.35)),
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: TextStyle(
                color: mutedColor.withOpacity(0.85),
                fontWeight: FontWeight.w800,
                fontSize: size * 0.42,
              ),
            ),
          ),
        );
      case _StepVisualState.informational:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: accentColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.42,
              ),
            ),
          ),
        );
    }
  }
}
