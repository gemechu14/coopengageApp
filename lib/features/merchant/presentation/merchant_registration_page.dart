import 'package:coopengageplus/features/home/widgets/mycard_registration/mycard_registration_step_panel.dart';
import 'package:coopengageplus/features/home/widgets/mycard_registration/horizontal_registration_stepper.dart';
import 'package:coopengageplus/features/merchant/data/mcc_data.dart';
import 'package:coopengageplus/features/merchant/data/merchant_qr_purpose_codes.dart';
// import 'package:coopengageplus/features/merchant/data/merchant_direct_api.dart';
import 'package:coopengageplus/features/merchant/data/merchant_models.dart';
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
        const SizedBox(height: 16),
        FilledButton(
          onPressed: state.canContinueFromStep1 && !state.isVerifying
              ? notifier.goToStep2
              : null,
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

  Future<void> _searchPremium(String query) async {
    setState(() => _loadingPremium = true);
    final results = await widget.notifier.searchPremiumPuids(query);
    if (!mounted) return;
    setState(() {
      _premiumResults = results;
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
              label: 'Select branch',
              sheetTitle: 'Pickup branch',
              sheetSubtitle: 'Branch for this merchant registration',
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
              subtitle: 'Auto-assign from a block or pick a premium number',
              icon: Icons.tag_outlined,
            ),
            const SizedBox(height: 10),
            MerchantFlowSegmentedToggle<PuidMode>(
              accentColor: coopCyan,
              mutedColor: muted,
              selected: state.puidMode,
              onChanged: notifier.setPuidMode,
              segments: const [
                (value: PuidMode.auto, label: 'Auto PUID'),
                (value: PuidMode.premium, label: 'Premium'),
              ],
            ),
            if (state.puidMode == PuidMode.premium) ...[
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
              TextField(
                controller: widget.premiumSearchController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(fontSize: 14, letterSpacing: 1),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: merchantFlowInputDecoration(
                  accentColor: coopCyan,
                  mutedColor: muted,
                  hintText: '000000',
                  prefixIcon: Icons.search_rounded,
                  counterText: '',
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: _loadingPremium
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: coopCyan,
                            ),
                          )
                        : Icon(Icons.search_rounded, color: coopCyan, size: 22),
                    onPressed: () =>
                        _searchPremium(widget.premiumSearchController.text),
                  ),
                ),
                onSubmitted: _searchPremium,
              ),
              const SizedBox(height: 6),
              Text(
                'Enter 6 digits, then search and tap a result',
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
            ] else ...[
              const SizedBox(height: 12),
              MerchantFlowDropdown<String>(
                accentColor: coopCyan,
                mutedColor: muted,
                label: 'PUID block (leading digit)',
                sheetTitle: 'PUID number block',
                sheetSubtitle: 'Default 6 → 600000–699999',
                value: state.puidStartDigit,
                helperText: 'Default 6 → 600000–699999',
                prefixIcon: Icons.numbers_rounded,
                options: puidStartDigitOptions
                    .map(
                      (d) => MerchantFlowSelectOption(
                        value: d,
                        title: 'Block $d',
                        subtitle: '${d}00000 – ${d}99999',
                        icon: Icons.tag_outlined,
                      ),
                    )
                    .toList(),
                onChanged: notifier.setPuidStartDigit,
              ),
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
            label: 'Email (portal login)',
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

class _StepSuccess extends StatelessWidget {
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

  String _maskAccount(String? account) {
    if (account == null || account.length < 4) return '****';
    return '****${account.substring(account.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final m = state.lastMerchantResponse;
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
          const SizedBox(height: 10),
          Text(
            ready
                ? 'Thank you for registering this merchant. The profile is ready for QR request. '
                    'Share portal login details with the merchant when applicable.'
                : 'The merchant was saved but some requirements may still be pending before a QR request.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: muted, height: 1.45),
          ),
          const SizedBox(height: 8),
          Text(
            'Account ${_maskAccount(m.primaryAccountNumber)}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: muted.withOpacity(0.85)),
          ),
          const SizedBox(height: 16),
          MerchantFlowSubheading(
            accentColor: coopCyan,
            mutedColor: muted,
            title: 'Registration summary',
            icon: Icons.summarize_outlined,
          ),
          const SizedBox(height: 10),
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
          MerchantFlowSummaryTile(
            accentColor: coopCyan,
            mutedColor: muted,
            label: 'QR purpose',
            value: qrPurposeByValue(m.qrPurposeCode)?.label ??
                m.qrPurposeCode ??
                '—',
          ),
          const SizedBox(height: 8),
          Text(
            'Need assistance? Call 609.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: coopCyan,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onDone,
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
      label: 'Business type / MCC',
      placeholder: 'Select category',
      prefixIcon: Icons.category_outlined,
      displayText: match == null ? '' : '${match.code} — ${match.description}',
      onTap: () async {
        final picked = await showMerchantFlowSelectSheet<MccOption>(
          context: context,
          accentColor: accentColor,
          mutedColor: mutedColor,
          title: 'Business type / MCC',
          subtitle: 'Merchant category code',
          titleIcon: Icons.category_outlined,
          selectedValue: match,
          searchable: true,
          searchHint: 'Search by name or code',
          options: merchantMccOptions
              .map(
                (m) => MerchantFlowSelectOption(
                  value: m,
                  title: m.description,
                  subtitle: m.code,
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
