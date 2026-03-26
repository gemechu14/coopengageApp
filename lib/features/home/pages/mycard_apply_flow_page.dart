import 'dart:async';

import 'package:coopengageplus/core/constants/mycard_link_constants.dart';
import 'package:coopengageplus/features/home/widgets/mycard_registration/horizontal_registration_stepper.dart';
import 'package:coopengageplus/features/home/widgets/mycard_registration/mycard_flow_actions.dart';
import 'package:coopengageplus/features/home/widgets/mycard_registration/mycard_registration_step_panel.dart';
import 'package:coopengageplus/features/home/widgets/mycard_registration/mycard_user_branches_loader.dart';
import 'package:coopengageplus/shared/widgets/mycard_share_fab.dart';
import 'package:flutter/material.dart';

/// **MyCard** registration for **branch staff** assisting customers (COOP × Visa).
class MycardApplyFlowPage extends StatefulWidget {
  const MycardApplyFlowPage({super.key});

  @override
  State<MycardApplyFlowPage> createState() => _MycardApplyFlowPageState();
}

class _MycardApplyFlowPageState extends State<MycardApplyFlowPage> {
  static const Color _coopCyan = Color(0xFF00AEEF);
  static const Color _coopBlue = Color(0xFF0D47A1);
  static const Color _bannerFill = Color(0xFFE8F7FD);
  static const Color _muted = Color(0xFF64748B);

  static const String _coopLogoAsset = 'assets/logo.png';
  static const String _visaLogoAsset = 'assets/visa.png';

  static const List<RegistrationStepDef> _steps = [
    RegistrationStepDef(label: 'Account'),
    RegistrationStepDef(label: 'OTP'),
    RegistrationStepDef(label: 'Branch'),
    RegistrationStepDef(label: 'Success'),
  ];

  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  int _step = 0;
  bool _sendingOtp = false;
  bool _verifyingOtp = false;
  Timer? _otpTimer;
  int _otpSecondsLeft = 0;
  Map<String, dynamic>? _selectedBranch;

  List<Map<String, dynamic>> _branches = [];
  bool _loadingBranches = false;

  bool get _canSendOtp => _accountController.text.trim().length == 13;

  bool get _canVerifyOtp =>
      _otpController.text.replaceAll(RegExp(r'\D'), '').length == 6;

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_onFormChanged);
    _otpController.addListener(_onFormChanged);
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() => _loadingBranches = true);
    try {
      final list = await MycardUserBranchesLoader.load();
      if (!mounted) return;
      setState(() {
        _branches = list;
        _loadingBranches = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _branches = [];
        _loadingBranches = false;
      });
    }
  }

  @override
  void dispose() {
    _accountController.removeListener(_onFormChanged);
    _otpController.removeListener(_onFormChanged);
    _otpTimer?.cancel();
    _accountController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _cancelOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = null;
  }

  void _startOtpTimer() {
    _cancelOtpTimer();
    setState(() => _otpSecondsLeft = 180);
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_otpSecondsLeft <= 0) {
        t.cancel();
        setState(() {});
        return;
      }
      setState(() => _otpSecondsLeft--);
    });
  }

  Future<void> _onSendOtp() async {
    final digits = _accountController.text.trim();
    if (digits.length != 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter exactly 13 digits.')),
      );
      return;
    }
    setState(() => _sendingOtp = true);
    try {
      await MycardFlowActions.sendOtp(digits);
      if (!mounted) return;
      setState(() {
        _sendingOtp = false;
        _step = 1;
      });
      _otpController.clear();
      _startOtpTimer();
    } catch (e) {
      if (mounted) {
        setState(() => _sendingOtp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send OTP: $e')),
        );
      }
    }
  }

  Future<void> _onVerifyOtp() async {
    if (_otpSecondsLeft <= 0) return;
    final digits = _otpController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit OTP.')),
      );
      return;
    }
    setState(() => _verifyingOtp = true);
    try {
      final account = _accountController.text.trim();
      final ok = await MycardFlowActions.verifyOtp(
        accountNumber: account,
        otp: _otpController.text,
      );
      if (!mounted) return;
      if (!ok) {
        setState(() => _verifyingOtp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Try again.')),
        );
        return;
      }
      _cancelOtpTimer();
      await _loadBranches();
      if (!mounted) return;
      setState(() {
        _verifyingOtp = false;
        _step = 2;
        _selectedBranch = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _verifyingOtp = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    }
  }

  void _onBranchChosen(Map<String, dynamic> branch) {
    setState(() {
      _selectedBranch = branch;
      _step = 3;
    });
  }

  void _resetFlow() {
    _cancelOtpTimer();
    setState(() {
      _step = 0;
      _sendingOtp = false;
      _verifyingOtp = false;
      _selectedBranch = null;
      _otpSecondsLeft = 0;
      _accountController.clear();
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _coopCyan,
        title: const Text(
          'MyCard registration',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 20,
          0,
          compact ? 16 : 20,
          20 + bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                  _BrandHeader(
                    compact: compact,
                    coopCyan: _coopCyan,
                    coopBlue: _coopBlue,
                    coopLogoAsset: _coopLogoAsset,
                    visaLogoAsset: _visaLogoAsset,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'From Card to World Cup!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 17 : 19,
                      fontWeight: FontWeight.w800,
                      color: _coopCyan,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoBanner(
                    compact: compact,
                    bannerFill: _bannerFill,
                    coopCyan: _coopCyan,
                    muted: _muted,
                  ),
                  const SizedBox(height: 14),
                  HorizontalRegistrationStepper(
                    steps: _steps,
                    accentColor: _coopCyan,
                    mutedColor: _muted,
                    currentIndex: _step,
                    compact: compact,
                  ),
                  const SizedBox(height: 14),
                  if (_step == 0)
                    MycardAccountStepPanel(
                      accentColor: _coopCyan,
                      mutedColor: _muted,
                      controller: _accountController,
                      sending: _sendingOtp,
                      canSendOtp: _canSendOtp,
                      onSendOtp: _onSendOtp,
                    ),
                  if (_step == 1)
                    MycardOtpStepPanel(
                      accentColor: _coopCyan,
                      mutedColor: _muted,
                      controller: _otpController,
                      otpSecondsLeft: _otpSecondsLeft,
                      verifying: _verifyingOtp,
                      canVerifyOtp: _canVerifyOtp,
                      onVerify: _onVerifyOtp,
                    ),
                  if (_step == 2)
                    _loadingBranches
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(color: _coopCyan),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Loading branches…',
                                    style: TextStyle(color: _muted, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              MycardBranchStepPanel(
                                accentColor: _coopCyan,
                                mutedColor: _muted,
                                branches: _branches,
                                selected: _selectedBranch,
                                onSelect: _onBranchChosen,
                              ),
                              if (_branches.isEmpty) ...[
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _loadBranches,
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: const Text('Reload branches'),
                                ),
                              ],
                            ],
                          ),
                  if (_step == 3)
                    MycardSuccessStepPanel(
                      accentColor: _coopCyan,
                      mutedColor: _muted,
                      branchName: MycardBranchStepPanel.branchLabel(
                        _selectedBranch ?? {},
                      ),
                      accountNumber: _accountController.text.trim(),
                      onStartAgain: _resetFlow,
                    ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => showMycardShareSheet(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _coopCyan,
                      side: BorderSide(color: _coopCyan.withOpacity(0.45)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text(
                      'Share link with customer',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Text(
                  //   _shortUrl(MycardLinkConstants.newCardUrl),
                  //   textAlign: TextAlign.center,
                  //   maxLines: 2,
                  //   style: TextStyle(
                  //     color: _muted.withOpacity(0.85),
                  //     fontSize: 11,
                  //   ),
                  // ),
          ],
        ),
      ),
    );
  }

  String _shortUrl(String url) {
    try {
      final u = Uri.parse(url);
      final host = u.host;
      final path = u.path;
      if (path.isEmpty || path == '/') return host;
      return '$host$path';
    } catch (_) {
      return url;
    }
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.compact,
    required this.coopCyan,
    required this.coopBlue,
    required this.coopLogoAsset,
    required this.visaLogoAsset,
  });

  final bool compact;
  final Color coopCyan;
  final Color coopBlue;
  final String coopLogoAsset;
  final String visaLogoAsset;

  @override
  Widget build(BuildContext context) {
    final trophySize = compact ? 40.0 : 48.0;
    final logoH = compact ? 28.0 : 32.0;
    final visaH = compact ? 22.0 : 26.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              coopLogoAsset,
              height: logoH,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _CoopWordmarkFallback(
                coopCyan: coopCyan,
                coopBlue: coopBlue,
                compact: compact,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              SizedBox(
                width: 28,
                child: Divider(height: 1, thickness: 1, color: coopCyan.withOpacity(0.35)),
              ),
              SizedBox(
                height: trophySize,
                width: trophySize + 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/world_cup.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.emoji_events_rounded,
                      size: trophySize * 0.85,
                      color: const Color(0xFFC9A227),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                child: Divider(height: 1, thickness: 1, color: coopCyan.withOpacity(0.35)),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.centerRight,
            child: Image.asset(
              visaLogoAsset,
              height: visaH,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.credit_card, color: coopBlue, size: visaH),
            ),
          ),
        ),
      ],
    );
  }
}

class _CoopWordmarkFallback extends StatelessWidget {
  const _CoopWordmarkFallback({
    required this.coopCyan,
    required this.coopBlue,
    required this.compact,
  });

  final Color coopCyan;
  final Color coopBlue;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.w800,
              color: coopBlue,
              height: 1.1,
            ),
            children: [
              TextSpan(text: 'COOP', style: TextStyle(color: coopCyan)),
              const TextSpan(text: ' Bank'),
            ],
          ),
        ),
        Text(
          'of Oromia',
          style: TextStyle(
            fontSize: compact ? 10.5 : 11,
            fontWeight: FontWeight.w600,
            color: coopBlue.withOpacity(0.85),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.compact,
    required this.bannerFill,
    required this.coopCyan,
    required this.muted,
  });

  final bool compact;
  final Color bannerFill;
  final Color coopCyan;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: bannerFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: coopCyan.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: coopCyan, size: compact ? 20 : 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Walk the customer through: account number, OTP, branch, then confirmation.',
              style: TextStyle(
                fontSize: compact ? 12 : 13,
                color: muted,
                height: 1.38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
