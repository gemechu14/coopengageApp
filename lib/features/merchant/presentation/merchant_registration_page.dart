import 'package:coopengageplus/features/home/widgets/mycard_registration/mycard_registration_step_panel.dart';
import 'package:coopengageplus/features/home/widgets/mycard_registration/horizontal_registration_stepper.dart';
import 'package:coopengageplus/features/merchant/data/mcc_data.dart';
import 'package:coopengageplus/features/merchant/data/merchant_qr_purpose_codes.dart';
// import 'package:coopengageplus/features/merchant/data/merchant_direct_api.dart';
import 'package:coopengageplus/features/merchant/data/merchant_models.dart';
import 'package:coopengageplus/features/merchant/data/merchant_qr_poster_actions.dart';
import 'package:coopengageplus/features/merchant/presentation/merchant_registration_controller.dart';
import 'package:coopengageplus/features/merchant/widgets/merchant_mycard_form_fields.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Branch-user merchant onboarding wizard (eth-qr New Entry parity).
class MerchantRegistrationPage extends ConsumerStatefulWidget {
  const MerchantRegistrationPage({super.key});

  @override
  ConsumerState<MerchantRegistrationPage> createState() =>
      _MerchantRegistrationPageState();
}

class _MerchantRegistrationPageState extends ConsumerState<MerchantRegistrationPage> {
  static const Color _coopCyan = Color(0xFF00AEEF);
  static const Color _coopBlue = Color(0xFF0D47A1);
  static const Color _bannerFill = Color(0xFFE8F7FD);
  static const Color _muted = Color(0xFF64748B);

  static const String _coopLogoAsset = 'assets/logo.png';

  static const List<RegistrationStepDef> _steps = [
    RegistrationStepDef(label: 'Account'),
    RegistrationStepDef(label: 'Details'),
    RegistrationStepDef(label: 'Address'),
    RegistrationStepDef(label: 'Success'),
  ];

  final _premiumSearchController = TextEditingController();

  // Debug: direct verify without Dio (re-enable for connectivity testing).
  // static const _testAccount = '1000026595928';
  // bool _testVerifyLoading = false;
  //
  // Future<void> _testVerifyAccount() async {
  //   setState(() => _testVerifyLoading = true);
  //   try {
  //     final data = await MerchantDirectApi.verifyAccount(
  //       accountNumber: _testAccount,
  //     );
  //     if (!mounted) return;
  //     final name = data['accountHolderName']?.toString() ?? '—';
  //     final acct = data['accountNumber']?.toString() ?? _testAccount;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Direct OK: $name ($acct)'),
  //         duration: const Duration(seconds: 6),
  //         backgroundColor: Colors.green.shade700,
  //       ),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: $e'),
  //         duration: const Duration(seconds: 8),
  //         backgroundColor: Colors.orange.shade800,
  //       ),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _testVerifyLoading = false);
  //   }
  // }

  @override
  void dispose() {
    _premiumSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantRegistrationControllerProvider);
    final notifier = ref.read(merchantRegistrationControllerProvider.notifier);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _coopCyan,
        title: Text(
          'Merchant Registration',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: state.step == 4
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (state.step == 1) {
                    Navigator.pop(context);
                  } else {
                    notifier.goBack();
                  }
                },
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
            // _MerchantBrandHeader(
            //   compact: compact,
            //   coopCyan: _coopCyan,
            //   coopBlue: _coopBlue,
            //   coopLogoAsset: _coopLogoAsset,
            // ),
            // const SizedBox(height: 14),
            // Text(
            //   'Register a new merchant',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: compact ? 17 : 19,
            //     fontWeight: FontWeight.w800,
            //     color: _coopCyan,
            //     height: 1.2,
            //   ),
            // ),
            // const SizedBox(height: 14),
            // _MerchantInfoBanner(
            //   compact: compact,
            //   bannerFill: _bannerFill,
            //   coopCyan: _coopCyan,
            //   muted: _muted,
            // ),
            const SizedBox(height: 20),
            HorizontalRegistrationStepper(
              steps: _steps,
              accentColor: _coopCyan,
              mutedColor: _muted,
              currentIndex: state.step - 1,
              compact: compact,
            ),
            const SizedBox(height: 14),
            // OutlinedButton.icon(
            //   onPressed: _testVerifyLoading ? null : _testVerifyAccount,
            //   icon: _testVerifyLoading
            //       ? const SizedBox(
            //           width: 18,
            //           height: 18,
            //           child: CircularProgressIndicator(strokeWidth: 2),
            //         )
            //       : const Icon(Icons.bug_report_outlined, size: 18),
            //   label: Text(
            //     _testVerifyLoading
            //         ? 'Testing…'
            //         : 'Test direct (no cert check) $_testAccount',
            //   ),
            //   style: OutlinedButton.styleFrom(
            //     foregroundColor: _coopCyan,
            //     side: BorderSide(color: _coopCyan.withOpacity(0.5)),
            //   ),
            // ),
            // const SizedBox(height: 14),
            if (state.errorMessage != null) ...[
              _ErrorBanner(message: state.errorMessage!),
              const SizedBox(height: 12),
            ],
            switch (state.step) {
              1 => _StepAccount(
                  state: state,
                  notifier: notifier,
                  coopCyan: _coopCyan,
                  muted: _muted,
                ),
              2 => _StepDetails(
                  state: state,
                  notifier: notifier,
                  premiumSearchController: _premiumSearchController,
                  coopCyan: _coopCyan,
                  muted: _muted,
                ),
              3 => _StepAddress(
                  state: state,
                  notifier: notifier,
                  coopCyan: _coopCyan,
                  muted: _muted,
                ),
              _ => _StepSuccess(
                  state: state,
                  coopCyan: _coopCyan,
                  muted: _muted,
                  onDone: () {
                    notifier.reset();
                    Navigator.pop(context);
                  },
                ),
            },
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade900, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepAccount extends StatefulWidget {
  const _StepAccount({
    required this.state,
    required this.notifier,
    required this.coopCyan,
    required this.muted,
  });

  final MerchantRegistrationState state;
  final MerchantRegistrationController notifier;
  final Color coopCyan;
  final Color muted;

  @override
  State<_StepAccount> createState() => _StepAccountState();
}

class _StepAccountState extends State<_StepAccount> {
  late final TextEditingController _accountController;

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController(text: widget.state.accountNumber);
    _accountController.addListener(_onAccountChanged);
  }

  void _onAccountChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant _StepAccount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.accountNumber != widget.state.accountNumber &&
        _accountController.text != widget.state.accountNumber) {
      _accountController.text = widget.state.accountNumber;
    }
  }

  @override
  void dispose() {
    _accountController.removeListener(_onAccountChanged);
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final notifier = widget.notifier;
    final coopCyan = widget.coopCyan;
    final muted = widget.muted;
    final canVerify = state.canVerifyAccount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MycardFlowCard(
          accentColor: coopCyan,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_outlined, color: coopCyan, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Coop account number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                maxLength: 13,
                style: const TextStyle(fontSize: 14),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  counterText: '',
                  prefixIcon: Icon(
                    Icons.account_balance_outlined,
                    color: muted,
                    size: 20,
                  ),
                  hintText: '0000000000000',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: muted.withOpacity(0.7),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: coopCyan.withOpacity(0.35)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: coopCyan.withOpacity(0.35)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: coopCyan, width: 1.5),
                  ),
                ),
                onChanged: notifier.setAccountNumber,
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your 13-digit customer account number',
                style: TextStyle(fontSize: 11.5, color: muted, height: 1.3),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: (state.isVerifying || !canVerify) ? null : notifier.verifyAccount,
                style: FilledButton.styleFrom(
                  backgroundColor: coopCyan,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: state.isVerifying
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      )
                    : const Icon(Icons.verified_outlined, size: 17),
                label: Text(
                  state.isVerifying ? 'Verifying…' : 'Verify',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        if (state.accountHolderName != null) ...[
          const SizedBox(height: 12),
          MerchantFlowReadOnlyField(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Legal name',
            value: state.accountHolderName!,
          ),
        ],
        if (state.accountVerified) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: !state.isVerifying ? notifier.goToStep2 : null,
            style: FilledButton.styleFrom(
              backgroundColor: coopCyan,
              disabledBackgroundColor: const Color(0xFFCBD5E1),
              disabledForegroundColor: const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Typed PUID field with inline availability check
// ──────────────────────────────────────────────────────────────────────────────

class _TypedPuidField extends StatefulWidget {
  const _TypedPuidField({
    required this.coopCyan,
    required this.muted,
    required this.puidLength,
    required this.typedPuid,
    required this.notifier,
  });

  final Color coopCyan;
  final Color muted;
  final int puidLength;
  final String typedPuid;
  final MerchantRegistrationController notifier;

  @override
  State<_TypedPuidField> createState() => _TypedPuidFieldState();
}

class _TypedPuidFieldState extends State<_TypedPuidField> {
  late final TextEditingController _ctrl;
  bool _checking = false;
  bool? _isPremium;
  bool? _isAvailable;
  String? _checkMessage;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.typedPuid);
    _ctrl.selection =
        TextSelection.collapsed(offset: _ctrl.text.length);
  }

  @override
  void didUpdateWidget(_TypedPuidField old) {
    super.didUpdateWidget(old);
    if (old.puidLength != widget.puidLength) {
      // Length changed — clear field and status
      _ctrl.clear();
      setState(() {
        _isPremium = null;
        _isAvailable = null;
        _checkMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final value = _ctrl.text.trim();
    if (value.length != widget.puidLength) {
      setState(() {
        _checkMessage =
            'Enter exactly ${widget.puidLength} digits to check availability.';
        _isPremium = null;
        _isAvailable = null;
      });
      return;
    }
    setState(() {
      _checking = true;
      _checkMessage = null;
      _isPremium = null;
      _isAvailable = null;
    });
    final result = await widget.notifier.checkTypedPuidAvailability(value);
    if (!mounted) return;
    if (result == null) {
      setState(() {
        _checking = false;
        _checkMessage = 'Could not check availability. Please try again.';
      });
      return;
    }
    final premium = result['premium'] == true;
    final available = result['available'] == true;
    setState(() {
      _checking = false;
      _isPremium = premium;
      _isAvailable = available;
      _checkMessage = result['message']?.toString();
    });
    if (!premium && available) {
      widget.notifier.setTypedPuid(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coopCyan = widget.coopCyan;
    final muted = widget.muted;
    final len = widget.puidLength;

    Color? statusColor;
    String? statusText;
    IconData? statusIcon;

    if (_isPremium == true) {
      statusColor = Colors.orange.shade700;
      statusIcon = Icons.star_rounded;
      statusText = 'This is a reserved premium number. Use Auto mode or contact your branch.';
    } else if (_isAvailable == false) {
      statusColor = Colors.red.shade600;
      statusIcon = Icons.cancel_outlined;
      statusText = _checkMessage ?? 'This PUID is already taken.';
    } else if (_isAvailable == true) {
      statusColor = Colors.green.shade600;
      statusIcon = Icons.check_circle_outline_rounded;
      statusText = _checkMessage ?? 'Available!';
    } else if (_checkMessage != null) {
      statusColor = Colors.red.shade600;
      statusIcon = Icons.info_outline;
      statusText = _checkMessage;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                maxLength: len,
                style: const TextStyle(
                  fontSize: 15,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  widget.notifier.setTypedPuid(v);
                  setState(() {
                    _isPremium = null;
                    _isAvailable = null;
                    _checkMessage = null;
                  });
                },
                onSubmitted: (_) => _check(),
                decoration: merchantFlowInputDecoration(
                  accentColor: coopCyan,
                  mutedColor: muted,
                  hintText: '0' * len,
                  prefixIcon: Icons.pin_outlined,
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _checking ? null : _check,
                style: FilledButton.styleFrom(
                  backgroundColor: coopCyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _checking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 17),
                          SizedBox(height: 2),
                          Text(
                            'Check',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
        if (statusText != null) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: statusColor,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 4),
          Text(
            'Enter $len digits, then tap Check to verify availability.',
            style: TextStyle(fontSize: 11.5, color: muted, height: 1.3),
          ),
        ],
      ],
    );
  }
}

class _StepDetails extends StatefulWidget {
  const _StepDetails({
    required this.state,
    required this.notifier,
    required this.premiumSearchController,
    required this.coopCyan,
    required this.muted,
  });

  final MerchantRegistrationState state;
  final MerchantRegistrationController notifier;
  final TextEditingController premiumSearchController;
  final Color coopCyan;
  final Color muted;

  @override
  State<_StepDetails> createState() => _StepDetailsState();
}

class _StepDetailsState extends State<_StepDetails> {
  List<String> _premiumResults = [];
  bool _loadingPremium = false;
  String? _premiumError;

  Future<void> _searchPremium(String query) async {
    setState(() {
      _loadingPremium = true;
      _premiumError = null;
    });
    final result = await widget.notifier.searchPremiumPuids(query);
    if (!mounted) return;
    setState(() {
      _premiumResults = result.puids;
      _premiumError = result.error;
      _loadingPremium = false;
    });
  }

  Future<void> _pickDocument(String key) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    final name = file.name;
    final ext = name.split('.').last.toLowerCase();
    final mime = ext == 'pdf'
        ? 'application/pdf'
        : ext == 'png'
            ? 'image/png'
            : 'image/jpeg';

    final doc = MerchantDocumentFile(name: name, bytes: bytes, mimeType: mime);
    switch (key) {
      case 'tradeLicense':
        widget.notifier.setDocument(tradeLicense: doc);
      case 'tradeRegistration':
        widget.notifier.setDocument(tradeRegistration: doc);
      case 'plcEstablishment':
        widget.notifier.setDocument(plcEstablishment: doc);
      case 'merchantContract':
        widget.notifier.setDocument(merchantContract: doc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final notifier = widget.notifier;
    final coopCyan = widget.coopCyan;
    final muted = widget.muted;
    final puidLocked = state.assignedPuid != null;

    return MycardFlowCard(
      accentColor: coopCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.storefront_outlined, color: coopCyan, size: 18),
              const SizedBox(width: 6),
              Text(
                'Merchant details',
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
            'Branch, business info, QR options, and documents',
            style: TextStyle(fontSize: 11.5, color: muted, height: 1.3),
          ),
          const SizedBox(height: 14),
          MerchantFlowSubheading(
            accentColor: coopCyan,
            mutedColor: muted,
            title: 'Branch',
            subtitle: 'Your branch from logged-in profile',
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 10),
          if (state.isLoadingBranches)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (state.branches.isEmpty)
            FilledButton.icon(
              onPressed: notifier.loadBranches,
              style: FilledButton.styleFrom(
                backgroundColor: coopCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text(
                'Reload branches',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            )
          else
            MerchantFlowDropdown<String>(
              accentColor: coopCyan,
              mutedColor: muted,
              label: 'Your branch',
              sheetTitle: 'Your branch',
              sheetSubtitle: 'Assigned to your logged-in profile',
              value: state.branchCode.isEmpty ? null : state.branchCode,
              prefixIcon: Icons.store_outlined,
              options: state.branches
                  .map(
                    (b) => MerchantFlowSelectOption(
                      value: b.branchCode,
                      title: b.displayLabel,
                      icon: Icons.account_balance_outlined,
                    ),
                  )
                  .toList(),
              onChanged: notifier.setBranchCode,
            ),
          if (state.accountHolderName != null) ...[
            const SizedBox(height: 16),
            MerchantFlowReadOnlyField(
              accentColor: coopCyan,
              mutedColor: muted,
              label: 'Legal name',
              value: state.accountHolderName!,
            ),
          ],
          if (state.assignedPuid != null) ...[
            const SizedBox(height: 12),
            MerchantFlowReadOnlyField(
              accentColor: coopCyan,
              mutedColor: muted,
              label: 'Assigned PUID',
              value: state.assignedPuid!,
            ),
          ] else if (!puidLocked) ...[
            const SizedBox(height: 16),
            MerchantFlowSubheading(
              accentColor: coopCyan,
              mutedColor: muted,
              title: 'PUID',
              subtitle: 'Choose PUID length and assignment mode',
              icon: Icons.tag_outlined,
            ),
            const SizedBox(height: 10),
            // Digit-length picker
            MerchantFlowDropdown<int>(
              accentColor: coopCyan,
              mutedColor: muted,
              label: 'Number of digits',
              sheetTitle: 'PUID length',
              sheetSubtitle: 'How many digits should the PUID contain?',
              value: state.puidLength,
              prefixIcon: Icons.dialpad_outlined,
              helperText: 'Default is 6 digits',
              options: puidLengthOptions
                  .map(
                    (len) => MerchantFlowSelectOption(
                      value: len,
                      title: '$len digits',
                      subtitle: '${'0' * len} – ${'9' * len}',
                      icon: Icons.tag_outlined,
                    ),
                  )
                  .toList(),
              onChanged: notifier.setPuidLength,
            ),
            const SizedBox(height: 12),
            MerchantFlowSegmentedToggle<PuidMode>(
              accentColor: coopCyan,
              mutedColor: muted,
              selected: state.puidMode,
              onChanged: notifier.setPuidMode,
              segments: const [
                (value: PuidMode.auto, label: 'Auto PUID'),
                (value: PuidMode.typed, label: 'Type Number'),
                (value: PuidMode.premium, label: 'Premium'),
              ],
            ),
            if (state.puidMode == PuidMode.typed) ...[
              const SizedBox(height: 12),
              Text(
                'Enter ${state.puidLength}-digit PUID',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              const SizedBox(height: 6),
              _TypedPuidField(
                coopCyan: coopCyan,
                muted: muted,
                puidLength: state.puidLength,
                typedPuid: state.typedPuid,
                notifier: notifier,
              ),
            ] else if (state.puidMode == PuidMode.premium) ...[
              const SizedBox(height: 12),
              Text(
                'Search premium PUID',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.premiumSearchController,
                      keyboardType: TextInputType.number,
                      maxLength: state.puidLength,
                      style: const TextStyle(fontSize: 14, letterSpacing: 1),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: merchantFlowInputDecoration(
                        accentColor: coopCyan,
                        mutedColor: muted,
                        hintText: '0' * state.puidLength,
                        prefixIcon: Icons.star_outline_rounded,
                        counterText: '',
                      ),
                      onSubmitted: _searchPremium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _loadingPremium
                          ? null
                          : () => _searchPremium(
                                widget.premiumSearchController.text,
                              ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: coopCyan,
                        side: BorderSide(color: coopCyan),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _loadingPremium
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: coopCyan,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_rounded,
                                    size: 18, color: coopCyan),
                                const SizedBox(height: 2),
                                Text(
                                  'Search',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    color: coopCyan,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (_premiumError != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline,
                        size: 13, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _premiumError!,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.orange.shade700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Enter up to ${state.puidLength} digits, then tap Search and select a result',
                  style: TextStyle(fontSize: 11.5, color: muted, height: 1.3),
                ),
              if (_premiumResults.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _premiumResults.map((puid) {
                    final selected = state.selectedPremiumPuid == puid;
                    return FilterChip(
                      label: Text(puid),
                      selected: selected,
                      selectedColor: coopCyan.withOpacity(0.15),
                      checkmarkColor: coopCyan,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selected ? coopCyan : Colors.blueGrey.shade800,
                      ),
                      onSelected: (_) => notifier.setSelectedPremiumPuid(puid),
                    );
                  }).toList(),
                ),
              ],
            ],
          ],
          const SizedBox(height: 16),
          MerchantFlowSubheading(
            accentColor: coopCyan,
            mutedColor: muted,
            title: 'Business info',
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: 12),
          MerchantFlowLabeledField(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'DBA name',
            hintText: 'Trading name shown on QR',
            prefixIcon: Icons.storefront_outlined,
            initialValue: state.dbaName,
            onChanged: notifier.setDbaName,
          ),
          const SizedBox(height: 12),
          MerchantFlowLabeledField(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Phone number',
            hintText: '0912345678',
            helperText: '10 digits only',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.number,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            initialValue: state.phoneNumber,
            onChanged: notifier.setPhoneNumber,
          ),
          const SizedBox(height: 12),
          MerchantFlowLabeledField(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Email (optional)',
            hintText: 'merchant@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            initialValue: state.email,
            onChanged: notifier.setEmail,
          ),
          const SizedBox(height: 12),
          _MccPicker(
            accentColor: coopCyan,
            mutedColor: muted,
            selectedCode: state.merchantCategoryCode,
            onSelected: notifier.setMcc,
          ),
          const SizedBox(height: 12),
          _QrPurposePicker(
            accentColor: coopCyan,
            mutedColor: muted,
            selectedCode: state.qrPurposeCode,
            onSelected: notifier.setQrPurposeCode,
          ),
          const SizedBox(height: 12),
          MerchantFlowDropdown<String>(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Language',
            sheetTitle: 'Portal language',
            value: state.languageCode,
            prefixIcon: Icons.language_outlined,
            options: const [
              MerchantFlowSelectOption(
                value: 'en',
                title: 'English',
                icon: Icons.translate_rounded,
              ),
              MerchantFlowSelectOption(
                value: 'om',
                title: 'Afaan Oromo',
                icon: Icons.translate_rounded,
              ),
              MerchantFlowSelectOption(
                value: 'am',
                title: 'Amharic',
                icon: Icons.translate_rounded,
              ),
            ],
            onChanged: notifier.setLanguageCode,
          ),
          const SizedBox(height: 12),
          MerchantFlowLabeledField(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Tax ID (optional)',
            hintText: 'Tax identification',
            prefixIcon: Icons.receipt_long_outlined,
            initialValue: state.taxId,
            onChanged: notifier.setTaxId,
          ),
          const SizedBox(height: 12),
          MerchantFlowLabeledField(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'TIN number (optional)',
            hintText: 'TIN if applicable',
            prefixIcon: Icons.numbers_outlined,
            initialValue: state.tinNumber,
            onChanged: notifier.setTinNumber,
          ),
          const SizedBox(height: 16),
          MerchantFlowSubheading(
            accentColor: coopCyan,
            mutedColor: muted,
            title: 'QR products',
            subtitle: 'Select which physical QR items to request',
            icon: Icons.qr_code_2_outlined,
          ),
          const SizedBox(height: 8),
          MerchantFlowToggleRow(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Acrylic QR',
            value: state.wantsAcrylicQr,
            onChanged: notifier.setWantsAcrylicQr,
          ),
          MerchantFlowToggleRow(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Sticker QR',
            value: state.wantsStickerQr,
            onChanged: notifier.setWantsStickerQr,
          ),
          const SizedBox(height: 12),
          MerchantFlowSubheading(
            accentColor: coopCyan,
            mutedColor: muted,
            title: 'Documents (optional)',
            subtitle: 'PDF, PNG, or JPG — max per server policy',
            icon: Icons.folder_open_outlined,
          ),
          const SizedBox(height: 8),
          MerchantFlowDocumentRow(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Trade license',
            fileName: state.tradeLicense?.name,
            onPick: () => _pickDocument('tradeLicense'),
          ),
          MerchantFlowDocumentRow(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Trade registration',
            fileName: state.tradeRegistration?.name,
            onPick: () => _pickDocument('tradeRegistration'),
          ),
          if (state.showPlcDocument)
            MerchantFlowDocumentRow(
              accentColor: coopCyan,
              mutedColor: muted,
              label: 'PLC establishment',
              fileName: state.plcEstablishment?.name,
              onPick: () => _pickDocument('plcEstablishment'),
            ),
          MerchantFlowDocumentRow(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Merchant contract',
            fileName: state.merchantContract?.name,
            onPick: () => _pickDocument('merchantContract'),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: state.canProceedFromStep2 && !state.isLoading
              ? notifier.saveMerchantDetails
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: coopCyan,
            disabledBackgroundColor: const Color(0xFFCBD5E1),
            disabledForegroundColor: const Color(0xFF94A3B8),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: state.isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withOpacity(0.95),
                  ),
                )
              : Text(
                  state.merchantId != null ? 'Update & Next' : 'Create & Next',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
        ),
        ],
      ),
    );
  }
}

class _StepAddress extends StatelessWidget {
  const _StepAddress({
    required this.state,
    required this.notifier,
    required this.coopCyan,
    required this.muted,
  });

  final MerchantRegistrationState state;
  final MerchantRegistrationController notifier;
  final Color coopCyan;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return MycardFlowCard(
      accentColor: coopCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: coopCyan, size: 18),
              const SizedBox(width: 6),
              Text(
                'Business address',
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
            'Region, city, and street for the merchant location',
            style: TextStyle(fontSize: 11.5, color: muted, height: 1.3),
          ),
          const SizedBox(height: 14),
          if (state.regions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Loading regions…',
                style: TextStyle(color: muted, fontSize: 13),
              ),
            )
          else
            MerchantFlowDropdown<String>(
              accentColor: coopCyan,
              mutedColor: muted,
              label: 'Region',
              sheetTitle: 'Select region',
              value: state.region.isEmpty ? null : state.region,
              prefixIcon: Icons.map_outlined,
              options: state.regions
                  .map(
                    (r) => MerchantFlowSelectOption(
                      value: r.code,
                      title: r.displayName,
                      icon: Icons.place_outlined,
                    ),
                  )
                  .toList(),
              onChanged: notifier.setRegion,
            ),
          const SizedBox(height: 12),
          MerchantFlowLabeledField(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'City',
            hintText: 'City name',
            prefixIcon: Icons.location_city_outlined,
            initialValue: state.city,
            onChanged: notifier.setCity,
          ),
          const SizedBox(height: 12),
          MerchantFlowLabeledField(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Street address',
            hintText: 'Street, building, floor',
            prefixIcon: Icons.signpost_outlined,
            initialValue: state.streetAddress,
            onChanged: notifier.setStreetAddress,
          ),
          const SizedBox(height: 12),
          MerchantFlowLabeledField(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Postal code (optional)',
            hintText: 'P.O. box or postal code',
            prefixIcon: Icons.markunread_mailbox_outlined,
            initialValue: state.postalCode,
            onChanged: notifier.setPostalCode,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: state.canProceedFromStep3 && !state.isLoading
                ? notifier.saveAddress
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: coopCyan,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCBD5E1),
              disabledForegroundColor: const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: state.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  )
                : const Text(
                    'Save & Complete',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StepSuccess extends ConsumerStatefulWidget {
  const _StepSuccess({
    required this.state,
    required this.coopCyan,
    required this.muted,
    required this.onDone,
  });

  final MerchantRegistrationState state;
  final Color coopCyan;
  final Color muted;
  final VoidCallback onDone;

  @override
  ConsumerState<_StepSuccess> createState() => _StepSuccessState();
}

class _StepSuccessState extends ConsumerState<_StepSuccess> {
  bool _isRequestingQr = false;
  String? _qrError;
  String? _qrSuccess;
  bool _isPosterLoading = false;

  String _maskAccount(String? account) {
    if (account == null || account.length < 4) return '****';
    return '****${account.substring(account.length - 4)}';
  }

  Future<void> _requestQrCode(MerchantResponse m, int acrylic, int sticker) async {
    final branchCode = widget.state.branchCode.trim();
    if (branchCode.isEmpty) {
      setState(() => _qrError = 'Branch code is missing.');
      return;
    }
    setState(() {
      _isRequestingQr = true;
      _qrError = null;
      _qrSuccess = null;
    });
    try {
      final service = ref.read(merchantRemoteServiceProvider);
      final msg = await service.requestQrCodes(
        branchCode: branchCode,
        requests: [(
          merchantId: m.id,
          acrylicQuantity: acrylic,
          stickerQuantity: sticker,
        )],
      );
      if (mounted) {
        setState(() {
          _isRequestingQr = false;
          _qrSuccess = msg;
        });
      }
    } on MerchantApiException catch (e) {
      if (mounted) {
        setState(() {
          _isRequestingQr = false;
          _qrError = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isRequestingQr = false;
          _qrError = 'QR request failed. Please try again.';
        });
      }
    }
  }

  Future<void> _viewPoster(MerchantResponse m, String templateType) async {
    final branchCode = widget.state.branchCode.trim();
    if (branchCode.isEmpty) {
      setState(() => _qrError = 'Branch code is missing.');
      return;
    }
    setState(() {
      _isPosterLoading = true;
      _qrError = null;
    });
    try {
      final service = ref.read(merchantRemoteServiceProvider);
      final bytes = await service.getQrPosterBytes(
        merchantId: m.id,
        branchCode: branchCode,
        templateType: templateType,
      );
      if (!mounted) return;
      setState(() => _isPosterLoading = false);
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _RegistrationQrPosterSheet(
          bytes: bytes,
          merchantName: m.dbaName ?? m.merchantName ?? 'Merchant',
          puid: m.puid ?? '',
          templateType: templateType,
        ),
      );
    } on MerchantApiException catch (e) {
      if (mounted) {
        setState(() {
          _isPosterLoading = false;
          _qrError = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isPosterLoading = false;
          _qrError = 'Could not load QR poster.';
        });
      }
    }
  }

  void _showQrRequestSheet(MerchantResponse m) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RegistrationQrRequestSheet(
        merchant: m,
        coopCyan: widget.coopCyan,
        onSubmit: ({required int acrylic, required int sticker}) async {
          Navigator.of(context).pop();
          await _requestQrCode(m, acrylic, sticker);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.state.lastMerchantResponse;
    final coopCyan = widget.coopCyan;
    final muted = widget.muted;

    if (m == null) {
      return MycardFlowCard(
        accentColor: coopCyan,
        child: Center(
          child: Text(
            'Registration complete.',
            style: TextStyle(color: muted, fontSize: 14),
          ),
        ),
      );
    }

    final ready = m.readyForQrRequest;
    final address = m.address;
    final addressText = address == null
        ? '—'
        : [
            address['streetAddress'],
            address['city'],
            address['region'],
          ].where((e) => e != null && '$e'.trim().isNotEmpty).join(', ');

    final qrTypes = [
      if (m.wantsAcrylicQr) 'Acrylic',
      if (m.wantsStickerQr) 'Sticker',
    ].join(', ');

    return MycardFlowCard(
      accentColor: coopCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ready
                    ? const Color(0xFFFFC107).withOpacity(0.25)
                    : Colors.orange.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: (ready ? const Color(0xFFFFC107) : Colors.orange)
                        .withOpacity(0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                ready ? Icons.check_rounded : Icons.info_outline_rounded,
                color: ready ? const Color(0xFFC9A227) : Colors.orange.shade800,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            ready ? 'Successfully registered.' : 'Profile incomplete',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ready ? Colors.amber.shade800 : Colors.orange.shade800,
            ),
          ),
          // const SizedBox(height: 10),
          Text(
            ready
                ? ''
                    
                : 'The merchant was saved but some requirements may still be pending before a QR request.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: muted, height: 1.45),
          ),
          // const SizedBox(height: 8),
          Text(
            'Account ${_maskAccount(m.primaryAccountNumber)}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: muted.withOpacity(0.85)),
          ),
          // const SizedBox(height: 16),
          MerchantFlowSubheading(
            accentColor: coopCyan,
            mutedColor: muted,
            title: 'Registration summary',
            icon: Icons.summarize_outlined,
          ),
          const SizedBox(height: 5),
          MerchantFlowSummaryTile(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Legal name',
            value: m.merchantName ?? '—',
          ),
          MerchantFlowSummaryTile(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'DBA',
            value: m.dbaName ?? '—',
          ),
          MerchantFlowSummaryTile(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'PUID',
            value: m.puid ?? '—',
            monospace: true,
          ),
          MerchantFlowSummaryTile(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'Address',
            value: addressText.isEmpty ? '—' : addressText,
          ),
          if (m.portalAccountCreated) ...[
            MerchantFlowSummaryTile(
              accentColor: coopCyan,
              mutedColor: muted,
              label: 'Portal username',
              value: m.portalLoginEmail ?? m.email ?? '—',
            ),
            MerchantFlowSummaryTile(
              accentColor: coopCyan,
              mutedColor: muted,
              label: 'Initial password',
              value: '123456',
              monospace: true,
            ),
          ],
          MerchantFlowSummaryTile(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'QR types',
            value: qrTypes.isEmpty ? '—' : qrTypes,
          ),
          // MerchantFlowSummaryTile(
          //   accentColor: coopCyan,
          //   mutedColor: muted,
          //   label: 'QR purpose',
          //   value: qrPurposeByValue(m.qrPurposeCode)?.label ??
          //       m.qrPurposeCode ??
          //       '—',
          // ),
          const SizedBox(height: 12),
          // QR feedback messages
          if (_qrError != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _qrError!,
                      style: TextStyle(fontSize: 12.5, color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (_qrSuccess != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _qrSuccess!,
                      style: TextStyle(fontSize: 12.5, color: Colors.green.shade700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
          ],
          // QR action buttons (only when ready and not yet requested)
          if (ready) ...[
            _QrActionRow(
              coopCyan: coopCyan,
              merchant: m,
              isRequestingQr: _isRequestingQr,
              isPosterLoading: _isPosterLoading,
              onRequestQr: () => _showQrRequestSheet(m),
              onViewPoster: (t) => _viewPoster(m, t),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 2),
          // Text(
          //   'Need assistance? Call 609.',
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     fontSize: 13,
          //     fontWeight: FontWeight.w700,
          //     color: coopCyan,
          //   ),
          // ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: widget.onDone,
            style: FilledButton.styleFrom(
              backgroundColor: coopCyan,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QR action row — shown on the success step
// ---------------------------------------------------------------------------

class _QrActionRow extends StatelessWidget {
  const _QrActionRow({
    required this.coopCyan,
    required this.merchant,
    required this.isRequestingQr,
    required this.isPosterLoading,
    required this.onRequestQr,
    required this.onViewPoster,
  });

  final Color coopCyan;
  final MerchantResponse merchant;
  final bool isRequestingQr;
  final bool isPosterLoading;
  final VoidCallback onRequestQr;
  final void Function(String templateType) onViewPoster;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0D47A1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 1,
          color: const Color(0xFFF1F5F9),
          margin: const EdgeInsets.only(bottom: 12),
        ),
        Text(
          'QR Actions',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: coopCyan,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _SuccessActionButton(
          label: 'Request QR Code',
          icon: Icons.send_rounded,
          color: blue,
          loading: isRequestingQr,
          onTap: isRequestingQr ? null : onRequestQr,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (merchant.wantsAcrylicQr || !merchant.wantsStickerQr)
              Expanded(
                child: _SuccessActionButton(
                  label: 'Acrylic Poster',
                  icon: Icons.image_rounded,
                  color: coopCyan,
                  loading: isPosterLoading,
                  onTap: isPosterLoading ? null : () => onViewPoster('acrylic'),
                ),
              ),
            if (merchant.wantsAcrylicQr && merchant.wantsStickerQr)
              const SizedBox(width: 8),
            if (merchant.wantsStickerQr)
              Expanded(
                child: _SuccessActionButton(
                  label: 'Sticker Poster',
                  icon: Icons.image_outlined,
                  color: const Color(0xFF6366F1),
                  loading: isPosterLoading,
                  onTap: isPosterLoading ? null : () => onViewPoster('sticker'),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SuccessActionButton extends StatelessWidget {
  const _SuccessActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QR request sheet (used on the success / registration step)
// ---------------------------------------------------------------------------

class _RegistrationQrRequestSheet extends StatefulWidget {
  const _RegistrationQrRequestSheet({
    required this.merchant,
    required this.coopCyan,
    required this.onSubmit,
  });

  final MerchantResponse merchant;
  final Color coopCyan;
  final Future<void> Function({required int acrylic, required int sticker}) onSubmit;

  @override
  State<_RegistrationQrRequestSheet> createState() =>
      _RegistrationQrRequestSheetState();
}

class _RegistrationQrRequestSheetState
    extends State<_RegistrationQrRequestSheet> {
  int _acrylic = 0;
  int _sticker = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.merchant.wantsAcrylicQr) _acrylic = 1;
    if (widget.merchant.wantsStickerQr) _sticker = 1;
  }

  bool get _canSubmit => !_submitting && (_acrylic > 0 || _sticker > 0);

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(acrylic: _acrylic, sticker: _sticker);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final cyan = widget.coopCyan;
    const blue = Color(0xFF0D47A1);
    final m = widget.merchant;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.send_rounded, color: blue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request QR Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      m.dbaName ?? m.merchantName ?? '',
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Select quantities. At least one must be greater than 0.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 16),
          _RegQtyRow(
            label: 'Acrylic Stand',
            icon: Icons.qr_code_2_rounded,
            color: cyan,
            value: _acrylic,
            onChanged: (v) => setState(() => _acrylic = v),
          ),
          const SizedBox(height: 10),
          _RegQtyRow(
            label: 'Sticker',
            icon: Icons.qr_code_rounded,
            color: const Color(0xFF6366F1),
            value: _sticker,
            onChanged: (v) => setState(() => _sticker = v),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _canSubmit ? _submit : null,
            style: FilledButton.styleFrom(
              backgroundColor: blue,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded, size: 18),
            label: Text(
              _submitting ? 'Submitting…' : 'Submit QR Request',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegQtyRow extends StatelessWidget {
  const _RegQtyRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final Color color;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: color),
            ),
          ),
          _Btn(
            icon: Icons.remove_rounded,
            color: color,
            onTap: value > 0 ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          _Btn(
            icon: Icons.add_rounded,
            color: color,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: onTap != null ? color : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      );
}

// ---------------------------------------------------------------------------
// QR Poster sheet (used on the success / registration step)
// ---------------------------------------------------------------------------

class _RegistrationQrPosterSheet extends StatefulWidget {
  const _RegistrationQrPosterSheet({
    required this.bytes,
    required this.merchantName,
    required this.puid,
    required this.templateType,
  });

  final Uint8List bytes;
  final String merchantName;
  final String puid;
  final String templateType;

  @override
  State<_RegistrationQrPosterSheet> createState() =>
      _RegistrationQrPosterSheetState();
}

class _RegistrationQrPosterSheetState
    extends State<_RegistrationQrPosterSheet> {
  bool _downloading = false;
  bool _sharing = false;

  String get _fileName =>
      '${widget.templateType}-${widget.puid.isNotEmpty ? widget.puid : 'poster'}.png';

  bool get _busy => _downloading || _sharing;

  Future<void> _download() async {
    if (_busy) return;
    setState(() => _downloading = true);
    try {
      final result = await MerchantQrPosterActions.downloadToDevice(
        bytes: widget.bytes,
        fileName: _fileName,
      );
      if (!mounted) return;
      showTopBanner(
        context,
        message: result.message ?? 'Download finished.',
        success: result.success,
      );
    } catch (e) {
      if (mounted) {
        showTopBanner(
          context,
          message: 'Could not download: $e',
          success: false,
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _sharing = true);
    try {
      await MerchantQrPosterActions.sharePoster(
        bytes: widget.bytes,
        fileName: _fileName,
        subject: '${widget.merchantName} QR Poster',
      );
    } catch (e) {
      if (mounted) {
        showTopBanner(
          context,
          message: 'Could not share: $e',
          success: false,
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Widget _busyIcon() {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    const cyan = Color(0xFF00AEEF);
    final label =
        widget.templateType == 'acrylic' ? 'Acrylic Poster' : 'Sticker Poster';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, color: cyan, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.merchantName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              label,
                              style: const TextStyle(fontSize: 12, color: cyan),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: _sharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: cyan),
                              )
                            : const Icon(Icons.share_rounded,
                                color: Colors.white),
                        onPressed: _busy ? null : _share,
                        tooltip: 'Share',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      child: Image.memory(
                        widget.bytes,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _download,
                          style: FilledButton.styleFrom(
                            backgroundColor: cyan,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: _downloading
                              ? _busyIcon()
                              : const Icon(Icons.download_rounded, size: 18),
                          label: Text(
                            _downloading ? 'Saving…' : 'Download Poster',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _share,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: cyan, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: _sharing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cyan,
                                  ),
                                )
                              : const Icon(Icons.share_rounded, size: 18),
                          label: Text(
                            _sharing ? 'Sharing…' : 'Share',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MccPicker extends StatelessWidget {
  const _MccPicker({
    required this.accentColor,
    required this.mutedColor,
    required this.selectedCode,
    required this.onSelected,
  });

  final Color accentColor;
  final Color mutedColor;
  final String selectedCode;
  final void Function(String code, String description) onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = merchantMccOptions.where((m) => m.code == selectedCode);
    final MccOption? match = selected.isEmpty ? null : selected.first;

    return MerchantFlowPickerField(
      accentColor: accentColor,
      mutedColor: mutedColor,
      label: 'MCC',
      placeholder: 'Select MCC (4 digits)',
      prefixIcon: Icons.category_outlined,
      helperText:
          '4-digit merchantCategoryCode · default $defaultMerchantCategoryCode',
      displayText: match == null
          ? ''
          : 'MCC · ${match.code} · ${match.description}',
      onTap: () async {
        final picked = await showMerchantFlowSelectSheet<MccOption>(
          context: context,
          accentColor: accentColor,
          mutedColor: mutedColor,
          title: 'MCC',
          subtitle:
              '4-digit merchantCategoryCode (default $defaultMerchantCategoryCode)',
          titleIcon: Icons.category_outlined,
          selectedValue: match,
          searchable: true,
          searchHint: 'Search by code or name',
          options: merchantMccOptions
              .map(
                (m) => MerchantFlowSelectOption(
                  value: m,
                  title: '${m.code} — ${m.description}',
                  subtitle: 'merchantCategoryCode',
                  icon: Icons.storefront_outlined,
                ),
              )
              .toList(),
          filter: (o, q) {
            final m = o.value;
            final hay = '${m.code} ${m.description}'.toLowerCase();
            return hay.contains(q);
          },
        );
        if (picked != null) onSelected(picked.code, picked.description);
      },
    );
  }
}

class _QrPurposePicker extends StatelessWidget {
  const _QrPurposePicker({
    required this.accentColor,
    required this.mutedColor,
    required this.selectedCode,
    required this.onSelected,
  });

  final Color accentColor;
  final Color mutedColor;
  final String selectedCode;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final match = qrPurposeByValue(selectedCode);

    return MerchantFlowPickerField(
      accentColor: accentColor,
      mutedColor: mutedColor,
      label: 'QR payment purpose',
      placeholder: 'Select purpose',
      prefixIcon: Icons.payments_outlined,
      helperText: 'Default ENTMT if unchanged',
      displayText: match == null ? '' : '${match.value} — ${match.label}',
      onTap: () async {
        final picked = await showMerchantFlowSelectSheet<QrPurposeOption>(
          context: context,
          accentColor: accentColor,
          mutedColor: mutedColor,
          title: 'QR payment purpose',
          subtitle: 'Purpose code for QR payments',
          titleIcon: Icons.payments_outlined,
          selectedValue: match,
          searchable: true,
          searchHint: 'Search by code or label',
          options: merchantQrPurposeOptions
              .map(
                (p) => MerchantFlowSelectOption(
                  value: p,
                  title: p.label,
                  subtitle: p.value,
                  icon: Icons.qr_code_2_outlined,
                ),
              )
              .toList(),
          filter: (o, q) {
            final p = o.value;
            final hay = '${p.value} ${p.label}'.toLowerCase();
            return hay.contains(q);
          },
        );
        if (picked != null) onSelected(picked.value);
      },
    );
  }
}

class _MerchantBrandHeader extends StatelessWidget {
  const _MerchantBrandHeader({
    required this.compact,
    required this.coopCyan,
    required this.coopBlue,
    required this.coopLogoAsset,
  });

  final bool compact;
  final Color coopCyan;
  final Color coopBlue;
  final String coopLogoAsset;

  @override
  Widget build(BuildContext context) {
    final logoH = compact ? 28.0 : 32.0;
    final iconSize = compact ? 36.0 : 42.0;

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
              Container(
                height: iconSize,
                width: iconSize,
                decoration: BoxDecoration(
                  color: coopCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.storefront_rounded, color: coopCyan, size: iconSize * 0.55),
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
            child: Icon(Icons.qr_code_2_rounded, color: coopBlue, size: logoH + 4),
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
        Text(
          'coop',
          style: TextStyle(
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w900,
            color: coopCyan,
            height: 1,
          ),
        ),
        Text(
          'bank oromia',
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

class _MerchantInfoBanner extends StatelessWidget {
  const _MerchantInfoBanner({
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
              'Walk through: select branch, verify account, merchant details, address, then confirmation.',
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
