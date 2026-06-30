import 'package:coopengageplus/core/network/network_handler.dart';
import 'package:coopengageplus/features/home/widgets/mycard_registration/horizontal_registration_stepper.dart';
import 'package:coopengageplus/features/home/widgets/mycard_registration/mycard_registration_step_panel.dart';
import 'package:coopengageplus/features/merchant/data/mcc_data.dart';
import 'package:coopengageplus/features/merchant/data/merchant_models.dart';
import 'package:coopengageplus/features/merchant/data/merchant_qr_purpose_codes.dart';
import 'package:coopengageplus/features/merchant/presentation/merchant_registration_controller.dart';
import 'package:coopengageplus/features/merchant/widgets/merchant_mycard_form_fields.dart';
import 'package:coopengageplus/shared/services/GlobalData.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Edit page for an Incomplete merchant — updates details and/or address
/// via PUT /merchants/{id} and POST /merchants/{id}/address.
class MerchantEditPage extends ConsumerStatefulWidget {
  const MerchantEditPage({
    super.key,
    required this.merchant,
    required this.branchCode,
    this.onSaved,
  });

  final MerchantResponse merchant;
  final String branchCode;

  /// Called after the merchant is successfully saved (details + address).
  /// The caller can use this to refresh its list.
  final VoidCallback? onSaved;

  @override
  ConsumerState<MerchantEditPage> createState() => _MerchantEditPageState();
}

class _MerchantEditPageState extends ConsumerState<MerchantEditPage> {
  static const Color _coopCyan = Color(0xFF00AEEF);
  static const Color _muted = Color(0xFF64748B);

  static const List<RegistrationStepDef> _steps = [
    RegistrationStepDef(label: 'Details'),
    RegistrationStepDef(label: 'Address'),
    RegistrationStepDef(label: 'Done'),
  ];

  // Step: 1=details, 2=address, 3=done
  int _step = 1;

  // ---- Details form state ----
  late String _dbaName;
  late String _phoneNumber;
  late String _email;
  late String _taxId;
  late String _tinNumber;
  late String _merchantCategoryCode;
  late String _businessType;
  late String _qrPurposeCode;
  late String _languageCode;
  late bool _wantsAcrylicQr;
  late bool _wantsStickerQr;

  // ---- Documents ----
  MerchantDocumentFile? _tradeLicense;
  MerchantDocumentFile? _tradeRegistration;
  MerchantDocumentFile? _plcEstablishment;
  MerchantDocumentFile? _merchantContract;

  // ---- Address form state ----
  late String _region;
  late String _city;
  late String _streetAddress;
  late String _postalCode;
  List<RegionOption> _regions = [];
  bool _regionsLoading = false;

  // ---- Page status ----
  bool _isLoading = false;
  String? _errorMessage;
  MerchantResponse? _savedMerchant;

  // ---- Validation ----
  bool get _canSaveDetails {
    if (_dbaName.trim().isEmpty) return false;
    if (!RegExp(r'^\d{10}$').hasMatch(_phoneNumber.trim())) return false;
    if (_email.trim().isNotEmpty && !_email.contains('@')) return false;
    if (!RegExp(r'^\d{4}$').hasMatch(_merchantCategoryCode)) return false;
    if (_businessType.trim().isEmpty) return false;
    if (!isValidQrPurposeCode(_qrPurposeCode)) return false;
    if (!_wantsAcrylicQr && !_wantsStickerQr) return false;
    return true;
  }

  bool get _canSaveAddress =>
      _region.isNotEmpty &&
      _city.trim().isNotEmpty &&
      _streetAddress.trim().isNotEmpty;

  bool get _showPlcDocument =>
      _businessType.toLowerCase().contains('plc');

  @override
  void initState() {
    super.initState();
    _initFromMerchant();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRegions());
  }

  void _initFromMerchant() {
    final m = widget.merchant;
    _dbaName = m.dbaName ?? '';

    // API returns 251xxxxxxxxx (12 digits) → convert to 0xxxxxxxxx (10 digits)
    var phone = m.phoneNumber ?? '';
    if (phone.startsWith('251') && phone.length == 12) {
      phone = '0${phone.substring(3)}';
    }
    _phoneNumber = phone;

    _email = m.email ?? '';
    _taxId = '';
    _tinNumber = '';
    _merchantCategoryCode = m.merchantCategoryCode ?? defaultMerchantCategoryCode;
    _businessType = m.businessType ?? defaultMerchantBusinessType;
    _qrPurposeCode = m.qrPurposeCode ?? defaultQrPurposeCode;
    _languageCode = 'en';
    _wantsAcrylicQr = m.wantsAcrylicQr;
    _wantsStickerQr = m.wantsStickerQr;

    final addr = m.address;
    _region = addr?['region']?.toString() ?? '';
    _city = addr?['city']?.toString() ?? '';
    _streetAddress = addr?['streetAddress']?.toString() ?? '';
    _postalCode = addr?['postalCode']?.toString() ?? '';
  }

  Future<void> _loadRegions() async {
    if (_regions.isNotEmpty) return;
    setState(() => _regionsLoading = true);
    try {
      final service = ref.read(merchantRemoteServiceProvider);
      final regions = await service.fetchRegions();
      if (mounted) setState(() { _regions = regions; _regionsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _regionsLoading = false);
    }
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
    setState(() {
      switch (key) {
        case 'tradeLicense':
          _tradeLicense = doc;
        case 'tradeRegistration':
          _tradeRegistration = doc;
        case 'plcEstablishment':
          _plcEstablishment = doc;
        case 'merchantContract':
          _merchantContract = doc;
      }
    });
  }

  Future<void> _saveDetails() async {
    if (!_canSaveDetails) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final service = ref.read(merchantRemoteServiceProvider);
      final operatorEmail = await _operatorEmail();

      final body = <String, dynamic>{
        'dbaName': _dbaName.trim(),
        'phoneNumber': _phoneNumber.trim(),
        'merchantCategoryCode': _merchantCategoryCode,
        'businessType': _businessType,
        'qrPurposeCode': _qrPurposeCode,
        'languageCode': _languageCode,
        'wantsAcrylicQr': _wantsAcrylicQr,
        'wantsStickerQr': _wantsStickerQr,
      };
      if (_email.trim().isNotEmpty) body['email'] = _email.trim();
      if (_taxId.trim().isNotEmpty) body['taxId'] = _taxId.trim();
      if (_tinNumber.trim().isNotEmpty) body['tinNumber'] = _tinNumber.trim();
      if (operatorEmail != null && operatorEmail.isNotEmpty) {
        body['operatorEmail'] = operatorEmail;
      }

      var updated = await service.updateMerchant(
        widget.merchant.id,
        body,
        branchCode: widget.branchCode,
      );

      // Upload any newly selected documents
      final hasDoc = _tradeLicense != null ||
          _tradeRegistration != null ||
          _plcEstablishment != null ||
          _merchantContract != null;
      if (hasDoc) {
        updated = await service.uploadRegistrationDocuments(
          merchantId: updated.id,
          branchCode: widget.branchCode,
          tradeLicense: _tradeLicense,
          tradeRegistration: _tradeRegistration,
          plcEstablishment: _showPlcDocument ? _plcEstablishment : null,
          merchantContract: _merchantContract,
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _savedMerchant = updated;
          _step = 2;
        });
      }
    } on MerchantApiException catch (e) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = e.message; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = 'Could not save details. Please try again.'; });
    }
  }

  Future<void> _saveAddress() async {
    if (!_canSaveAddress) return;
    final merchantId = (_savedMerchant ?? widget.merchant).id;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final service = ref.read(merchantRemoteServiceProvider);
      final address = <String, dynamic>{
        'region': _region,
        'city': _city.trim(),
        'streetAddress': _streetAddress.trim(),
      };
      if (_postalCode.trim().isNotEmpty) {
        address['postalCode'] = _postalCode.trim();
      }

      final updated = await service.addAddress(
        merchantId,
        address,
        branchCode: widget.branchCode,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _savedMerchant = updated;
          _step = 3;
        });
        widget.onSaved?.call();
      }
    } on MerchantApiException catch (e) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = e.message; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _errorMessage = 'Could not save address. Please try again.'; });
    }
  }

  /// Fetches the logged-in operator's email from the server or JWT claims.
  Future<String?> _operatorEmail() async {
    try {
      final handler = NetworkHandler();
      final data = await handler.get('/api/v1/users/me');
      if (data is Map) {
        final email = data['email']?.toString();
        if (email != null && email.isNotEmpty) return email;
      }
    } catch (_) {}
    try {
      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
          storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
        ),
      );
      final token = await storage.read(key: 'token');
      if (token != null && token.isNotEmpty) {
        final claims = Map<String, dynamic>.from(JwtDecoder.decode(token) as Map);
        final email = claims['email']?.toString();
        if (email != null && email.isNotEmpty) return email;
      }
    } catch (_) {}
    return GlobalData().username;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _coopCyan,
        title: const Text(
          'Edit Merchant',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: _step == 3
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () {
                  if (_step > 1) {
                    setState(() { _step--; _errorMessage = null; });
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: _coopCyan.withOpacity(0.15),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HorizontalRegistrationStepper(
              steps: _steps,
              accentColor: _coopCyan,
              mutedColor: _muted,
              currentIndex: _step - 1,
              compact: compact,
            ),
            const SizedBox(height: 16),
            // Info banner: show read-only merchant info
            _MerchantInfoBanner(
              merchantName: widget.merchant.merchantName ?? '—',
              puid: widget.merchant.puid ?? '—',
              coopCyan: _coopCyan,
              muted: _muted,
            ),
            const SizedBox(height: 14),
            if (_step == 1) _buildDetailsCard(),
            if (_step == 2) _buildAddressCard(),
            if (_step == 3) _buildDoneCard(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1 — Details
  // ---------------------------------------------------------------------------

  Widget _buildDetailsCard() {
    return MycardFlowCard(
      accentColor: _coopCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            icon: Icons.storefront_outlined,
            title: 'Merchant details',
            subtitle: 'Update business info, QR options, and documents',
            coopCyan: _coopCyan,
            muted: _muted,
          ),
          const SizedBox(height: 14),

          // ---- Business info ----
          MerchantFlowSubheading(
            accentColor: _coopCyan,
            mutedColor: _muted,
            title: 'Business info',
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: 12),
          _LabeledField(
            key: const ValueKey('dba'),
            label: 'DBA name',
            hint: 'Trading name shown on QR',
            prefixIcon: Icons.storefront_outlined,
            initialValue: _dbaName,
            onChanged: (v) => setState(() => _dbaName = v),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            key: const ValueKey('phone'),
            label: 'Phone number',
            hint: '0912345678',
            helperText: '10 digits only',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.number,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            initialValue: _phoneNumber,
            onChanged: (v) => setState(() => _phoneNumber = v),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            key: const ValueKey('email'),
            label: 'Email (optional)',
            hint: 'merchant@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            initialValue: _email,
            onChanged: (v) => setState(() => _email = v),
          ),
          const SizedBox(height: 12),
          _EditMccPicker(
            accentColor: _coopCyan,
            mutedColor: _muted,
            selectedCode: _merchantCategoryCode,
            onSelected: (code, desc) => setState(() {
              _merchantCategoryCode = code;
              _businessType = desc;
            }),
          ),
          const SizedBox(height: 12),
          _EditQrPurposePicker(
            accentColor: _coopCyan,
            mutedColor: _muted,
            selectedCode: _qrPurposeCode,
            onSelected: (v) => setState(() => _qrPurposeCode = v),
          ),
          const SizedBox(height: 12),
          MerchantFlowDropdown<String>(
            accentColor: _coopCyan,
            mutedColor: _muted,
            label: 'Language',
            sheetTitle: 'Portal language',
            value: _languageCode,
            prefixIcon: Icons.language_outlined,
            options: const [
              MerchantFlowSelectOption(value: 'en', title: 'English', icon: Icons.translate_rounded),
              MerchantFlowSelectOption(value: 'om', title: 'Afaan Oromo', icon: Icons.translate_rounded),
              MerchantFlowSelectOption(value: 'am', title: 'Amharic', icon: Icons.translate_rounded),
            ],
            onChanged: (v) { if (v != null) setState(() => _languageCode = v); },
          ),
          const SizedBox(height: 12),
          _LabeledField(
            key: const ValueKey('taxId'),
            label: 'Tax ID (optional)',
            hint: 'Tax identification',
            prefixIcon: Icons.receipt_long_outlined,
            initialValue: _taxId,
            onChanged: (v) => setState(() => _taxId = v),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            key: const ValueKey('tinNumber'),
            label: 'TIN number (optional)',
            hint: 'TIN if applicable',
            prefixIcon: Icons.numbers_outlined,
            initialValue: _tinNumber,
            onChanged: (v) => setState(() => _tinNumber = v),
          ),

          // ---- QR products ----
          const SizedBox(height: 16),
          MerchantFlowSubheading(
            accentColor: _coopCyan,
            mutedColor: _muted,
            title: 'QR products',
            subtitle: 'Select which physical QR items to request',
            icon: Icons.qr_code_2_outlined,
          ),
          const SizedBox(height: 8),
          MerchantFlowToggleRow(
            accentColor: _coopCyan,
            mutedColor: _muted,
            label: 'Acrylic QR',
            value: _wantsAcrylicQr,
            onChanged: (v) => setState(() => _wantsAcrylicQr = v),
          ),
          MerchantFlowToggleRow(
            accentColor: _coopCyan,
            mutedColor: _muted,
            label: 'Sticker QR',
            value: _wantsStickerQr,
            onChanged: (v) => setState(() => _wantsStickerQr = v),
          ),

          // ---- Documents ----
          const SizedBox(height: 16),
          MerchantFlowSubheading(
            accentColor: _coopCyan,
            mutedColor: _muted,
            title: 'Documents (optional)',
            subtitle: 'PDF, PNG, or JPG — max 10 MB each',
            icon: Icons.folder_open_outlined,
          ),
          const SizedBox(height: 8),
          MerchantFlowDocumentRow(
            accentColor: _coopCyan,
            mutedColor: _muted,
            label: 'Trade license',
            fileName: _tradeLicense?.name,
            onPick: () => _pickDocument('tradeLicense'),
          ),
          MerchantFlowDocumentRow(
            accentColor: _coopCyan,
            mutedColor: _muted,
            label: 'Trade registration',
            fileName: _tradeRegistration?.name,
            onPick: () => _pickDocument('tradeRegistration'),
          ),
          if (_showPlcDocument)
            MerchantFlowDocumentRow(
              accentColor: _coopCyan,
              mutedColor: _muted,
              label: 'PLC establishment',
              fileName: _plcEstablishment?.name,
              onPick: () => _pickDocument('plcEstablishment'),
            ),
          MerchantFlowDocumentRow(
            accentColor: _coopCyan,
            mutedColor: _muted,
            label: 'Merchant contract',
            fileName: _merchantContract?.name,
            onPick: () => _pickDocument('merchantContract'),
          ),

          // ---- Error ----
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorBanner(message: _errorMessage!),
          ],

          const SizedBox(height: 16),
          FilledButton(
            onPressed: _canSaveDetails && !_isLoading ? _saveDetails : null,
            style: FilledButton.styleFrom(
              backgroundColor: _coopCyan,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCBD5E1),
              disabledForegroundColor: const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  )
                : const Text(
                    'Update & Next',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2 — Address
  // ---------------------------------------------------------------------------

  Widget _buildAddressCard() {
    return MycardFlowCard(
      accentColor: _coopCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            icon: Icons.location_on_outlined,
            title: 'Business address',
            subtitle: 'Region, city, and street for the merchant location',
            coopCyan: _coopCyan,
            muted: _muted,
          ),
          const SizedBox(height: 14),

          if (_regionsLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Loading regions…',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            )
          else if (_regions.isEmpty)
            FilledButton.icon(
              onPressed: _loadRegions,
              style: FilledButton.styleFrom(
                backgroundColor: _coopCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text(
                'Retry loading regions',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            )
          else
            MerchantFlowDropdown<String>(
              accentColor: _coopCyan,
              mutedColor: _muted,
              label: 'Region',
              sheetTitle: 'Select region',
              value: _region.isEmpty ? null : _region,
              prefixIcon: Icons.map_outlined,
              options: _regions
                  .map((r) => MerchantFlowSelectOption(
                        value: r.code,
                        title: r.displayName,
                        icon: Icons.place_outlined,
                      ))
                  .toList(),
              onChanged: (v) { if (v != null) setState(() => _region = v); },
            ),
          const SizedBox(height: 12),
          _LabeledField(
            key: const ValueKey('city'),
            label: 'City',
            hint: 'City name',
            prefixIcon: Icons.location_city_outlined,
            initialValue: _city,
            onChanged: (v) => setState(() => _city = v),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            key: const ValueKey('street'),
            label: 'Street address',
            hint: 'Street, building, floor',
            prefixIcon: Icons.signpost_outlined,
            initialValue: _streetAddress,
            onChanged: (v) => setState(() => _streetAddress = v),
          ),
          const SizedBox(height: 12),
          _LabeledField(
            key: const ValueKey('postal'),
            label: 'Postal code (optional)',
            hint: 'P.O. box or postal code',
            prefixIcon: Icons.markunread_mailbox_outlined,
            initialValue: _postalCode,
            onChanged: (v) => setState(() => _postalCode = v),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorBanner(message: _errorMessage!),
          ],

          const SizedBox(height: 16),
          FilledButton(
            onPressed: _canSaveAddress && !_isLoading ? _saveAddress : null,
            style: FilledButton.styleFrom(
              backgroundColor: _coopCyan,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCBD5E1),
              disabledForegroundColor: const Color(0xFF94A3B8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isLoading
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

  // ---------------------------------------------------------------------------
  // Step 3 — Done
  // ---------------------------------------------------------------------------

  Widget _buildDoneCard() {
    final m = _savedMerchant ?? widget.merchant;
    final ready = m.readyForQrRequest;
    final addr = m.address;
    final addressText = addr == null
        ? '—'
        : [addr['streetAddress'], addr['city'], addr['region']]
            .where((e) => e != null && '$e'.trim().isNotEmpty)
            .join(', ');

    return MycardFlowCard(
      accentColor: _coopCyan,
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
                color: ready
                    ? const Color(0xFFC9A227)
                    : Colors.orange.shade800,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            ready ? 'Merchant updated.' : 'Updated — still incomplete',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: ready ? Colors.amber.shade800 : Colors.orange.shade800,
            ),
          ),
          if (!ready) ...[
            const SizedBox(height: 6),
            Text(
              'Some information may still be missing before QR can be requested.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: _muted, height: 1.4),
            ),
          ],
          const SizedBox(height: 16),
          MerchantFlowSubheading(
            accentColor: _coopCyan,
            mutedColor: _muted,
            title: 'Summary',
            icon: Icons.summarize_outlined,
          ),
          const SizedBox(height: 8),
          MerchantFlowSummaryTile(
            accentColor: _coopCyan,
            mutedColor: _muted,
            label: 'Legal name',
            value: m.merchantName ?? '—',
          ),
          MerchantFlowSummaryTile(
            accentColor: _coopCyan,
            mutedColor: _muted,
            label: 'DBA',
            value: m.dbaName ?? '—',
          ),
          MerchantFlowSummaryTile(
            accentColor: _coopCyan,
            mutedColor: _muted,
            label: 'PUID',
            value: m.puid ?? '—',
            monospace: true,
          ),
          MerchantFlowSummaryTile(
            accentColor: _coopCyan,
            mutedColor: _muted,
            label: 'Address',
            value: addressText,
          ),
          MerchantFlowSummaryTile(
            accentColor: _coopCyan,
            mutedColor: _muted,
            label: 'QR types',
            value: [
              if (m.wantsAcrylicQr) 'Acrylic',
              if (m.wantsStickerQr) 'Sticker',
            ].join(', ').let((v) => v.isEmpty ? '—' : v),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: _coopCyan,
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
// Private helpers
// ---------------------------------------------------------------------------

extension _LetExt<T> on T {
  R let<R>(R Function(T) block) => block(this);
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.coopCyan,
    required this.muted,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color coopCyan;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: coopCyan, size: 18),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.blueGrey.shade900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 11.5, color: muted, height: 1.3)),
      ],
    );
  }
}

class _MerchantInfoBanner extends StatelessWidget {
  const _MerchantInfoBanner({
    required this.merchantName,
    required this.puid,
    required this.coopCyan,
    required this.muted,
  });

  final String merchantName;
  final String puid;
  final Color coopCyan;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: coopCyan.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: coopCyan.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.store_rounded, color: coopCyan, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchantName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey.shade900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'PUID: $puid',
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.5, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin wrapper so callers can pass a typed key and simplified params.
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    super.key,
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.onChanged,
    this.prefixIcon,
    this.helperText,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
  });

  final String label;
  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final IconData? prefixIcon;
  final String? helperText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return MerchantFlowLabeledField(
      accentColor: const Color(0xFF00AEEF),
      mutedColor: const Color(0xFF64748B),
      label: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      helperText: helperText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      initialValue: initialValue,
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// MCC picker (mirrors _MccPicker in merchant_registration_page.dart)
// ---------------------------------------------------------------------------

class _EditMccPicker extends StatelessWidget {
  const _EditMccPicker({
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
    final match = merchantMccOptions
        .where((m) => m.code == selectedCode)
        .cast<MccOption?>()
        .firstOrNull;

    return MerchantFlowPickerField(
      accentColor: accentColor,
      mutedColor: mutedColor,
      label: 'MCC',
      placeholder: 'Select MCC (4 digits)',
      prefixIcon: Icons.category_outlined,
      helperText: '4-digit merchantCategoryCode · default $defaultMerchantCategoryCode',
      displayText: match == null ? '' : 'MCC · ${match.code} · ${match.description}',
      onTap: () async {
        final picked = await showMerchantFlowSelectSheet<MccOption>(
          context: context,
          accentColor: accentColor,
          mutedColor: mutedColor,
          title: 'MCC',
          subtitle: '4-digit merchantCategoryCode (default $defaultMerchantCategoryCode)',
          titleIcon: Icons.category_outlined,
          selectedValue: match,
          searchable: true,
          searchHint: 'Search by code or name',
          options: merchantMccOptions
              .map((m) => MerchantFlowSelectOption(
                    value: m,
                    title: '${m.code} — ${m.description}',
                    subtitle: 'merchantCategoryCode',
                    icon: Icons.storefront_outlined,
                  ))
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

// ---------------------------------------------------------------------------
// QR purpose picker (mirrors _QrPurposePicker in merchant_registration_page.dart)
// ---------------------------------------------------------------------------

class _EditQrPurposePicker extends StatelessWidget {
  const _EditQrPurposePicker({
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
              .map((p) => MerchantFlowSelectOption(
                    value: p,
                    title: p.label,
                    subtitle: p.value,
                    icon: Icons.qr_code_2_outlined,
                  ))
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
