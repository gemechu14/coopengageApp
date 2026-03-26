import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared white card shell for each MyCard flow step (matches web-style border).
class MycardFlowCard extends StatelessWidget {
  const MycardFlowCard({
    super.key,
    required this.accentColor,
    required this.child,
  });

  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.28)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MycardAccountStepPanel extends StatelessWidget {
  const MycardAccountStepPanel({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.controller,
    required this.sending,
    required this.canSendOtp,
    required this.onSendOtp,
  });

  final Color accentColor;
  final Color mutedColor;
  final TextEditingController controller;
  final bool sending;
  /// True when the account field has exactly 13 digits (button becomes active).
  final bool canSendOtp;
  final VoidCallback onSendOtp;

  @override
  Widget build(BuildContext context) {
    return MycardFlowCard(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card_outlined, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Text(
                'Your account number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 13,
            style: const TextStyle(fontSize: 14),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              counterText: '',
              prefixIcon: Icon(Icons.account_balance_outlined, color: mutedColor, size: 20),
              hintText: '0000000000000',
              hintStyle: TextStyle(fontSize: 13, color: mutedColor.withOpacity(0.7)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: accentColor.withOpacity(0.35)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: accentColor.withOpacity(0.35)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your 13-digit customer account number',
            style: TextStyle(fontSize: 11.5, color: mutedColor, height: 1.3),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: (sending || !canSendOtp) ? null : onSendOtp,
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCBD5E1),
              disabledForegroundColor: const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: sending
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 17),
            label: Text(
              sending ? 'Sending OTP…' : 'Send OTP',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class MycardOtpStepPanel extends StatelessWidget {
  const MycardOtpStepPanel({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.controller,
    required this.otpSecondsLeft,
    required this.verifying,
    required this.canVerifyOtp,
    required this.onVerify,
  });

  final Color accentColor;
  final Color mutedColor;
  final TextEditingController controller;
  final int otpSecondsLeft;
  final bool verifying;
  /// True when OTP field has exactly 6 digits.
  final bool canVerifyOtp;
  final VoidCallback onVerify;

  String get _timerLabel {
    if (otpSecondsLeft <= 0) return '0:00';
    final m = otpSecondsLeft ~/ 60;
    final s = otpSecondsLeft % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final expired = otpSecondsLeft <= 0;

    return MycardFlowCard(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.key_outlined, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Text(
                'OTP code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(fontSize: 14, letterSpacing: 2),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: !expired,
            decoration: InputDecoration(
              counterText: '',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              hintText: '000000',
              hintStyle: TextStyle(fontSize: 13, color: mutedColor.withOpacity(0.7)),
              filled: true,
              fillColor: expired ? const Color(0xFFF1F5F9) : const Color(0xFFE8F7FD),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: accentColor.withOpacity(0.45)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: accentColor.withOpacity(0.45)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            expired
                ? 'OTP expired — go back and send again.'
                : 'OTP expires in $_timerLabel · 6 digits',
            style: TextStyle(fontSize: 11.5, color: mutedColor, height: 1.3),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: (verifying || expired || !canVerifyOtp) ? null : onVerify,
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCBD5E1),
              disabledForegroundColor: const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: verifying
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  )
                : const Text(
                    'Verify OTP',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
          ),
        ],
      ),
    );
  }
}

class MycardBranchStepPanel extends StatelessWidget {
  const MycardBranchStepPanel({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.branches,
    required this.selected,
    required this.onSelect,
  });

  final Color accentColor;
  final Color mutedColor;
  final List<Map<String, dynamic>> branches;
  final Map<String, dynamic>? selected;
  final ValueChanged<Map<String, dynamic>> onSelect;

  static String branchLabel(Map<String, dynamic> b) {
    final raw =
        '${b['name'] ?? b['branchName'] ?? b['companyName'] ?? ''}'.trim();
    return raw.isEmpty ? 'Branch' : raw;
  }

  static bool sameBranch(Map<String, dynamic>? a, Map<String, dynamic> b) {
    if (a == null) return false;
    final ai = a['id'];
    final bi = b['id'];
    if (ai != null && bi != null) return ai == bi;
    return branchLabel(a) == branchLabel(b);
  }

  @override
  Widget build(BuildContext context) {
    return MycardFlowCard(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_outlined, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Text(
                'Pickup branch',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Main branch and your other assigned branches',
            style: TextStyle(fontSize: 11.5, color: mutedColor, height: 1.3),
          ),
          const SizedBox(height: 14),
          if (branches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No branches found for your profile. Try logging in again.',
                style: TextStyle(color: mutedColor, fontSize: 13),
              ),
            )
          else
            ...List.generate(branches.length, (index) {
              final b = branches[index];
              final label = branchLabel(b);
              final isMain = index == 0;
              final isSelected = sameBranch(selected, b);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isSelected ? accentColor.withOpacity(0.1) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => onSelect(b),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? accentColor : mutedColor,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isMain)
                                  Text(
                                    'Main',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: accentColor,
                                    ),
                                  ),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class MycardSuccessStepPanel extends StatelessWidget {
  const MycardSuccessStepPanel({
    super.key,
    required this.accentColor,
    required this.mutedColor,
    required this.branchName,
    required this.accountNumber,
    this.onStartAgain,
  });

  final Color accentColor;
  final Color mutedColor;
  final String branchName;
  final String accountNumber;
  final VoidCallback? onStartAgain;

  @override
  Widget build(BuildContext context) {
    return MycardFlowCard(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFC107).withOpacity(0.25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withOpacity(0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Color(0xFFC9A227), size: 32),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Successfully submitted.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.amber.shade800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Thank you for joining the Card to World Cup experience. '
            'Your card will be ready soon. Please visit $branchName to collect your card once it is prepared.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: mutedColor, height: 1.45),
          ),
          const SizedBox(height: 8),
          Text(
            'Account $accountNumber',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: mutedColor.withOpacity(0.85)),
          ),
          const SizedBox(height: 16),
          Text(
            'Need assistance? Call 609.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          if (onStartAgain != null) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: onStartAgain,
              child: Text(
                'Register another customer',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
