// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:coopengageplus/core/config/config.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class Verifycustomerinfo extends StatefulWidget {
  final Map<String, dynamic> registrationData;
  final String title;
  final String? userId;
  final String? className;

  const Verifycustomerinfo({
    super.key,
    required this.registrationData,
    required this.title,
    this.userId,
    this.className,
  });

  @override
  State<Verifycustomerinfo> createState() => _VerifycustomerinfoState();
}

class _VerifycustomerinfoState extends State<Verifycustomerinfo>
    with SingleTickerProviderStateMixin {
  String? accountNumber;
  bool isLoading = false;
  bool _obscureAccount = true;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  String get _fullName =>
      widget.registrationData['fullName']?.toString() ?? 'N/A';

  String get _phone => widget.registrationData['phone']?.toString() ?? '';

  String get _email => widget.registrationData['email']?.toString() ?? '';

  String get _branch => widget.registrationData['branch']?.toString() ?? '';

  String get _status => widget.registrationData['status']?.toString() ?? '';

  String get _initials => _fullName.isNotEmpty
      ? _fullName
          .split(' ')
          .map((w) => w.isNotEmpty ? w[0] : '')
          .take(2)
          .join()
          .toUpperCase()
      : '?';

  String get currentAccountNumber {
    return widget.registrationData['accountNumber']?.toString() ??
        accountNumber ??
        '';
  }

  String get displayAccount {
    final full = currentAccountNumber;
    if (full.isEmpty) return '';
    if (_obscureAccount && full.length > 4) {
      return '${'*' * (full.length - 4)}${full.substring(full.length - 4)}';
    }
    return full;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAccount = currentAccountNumber.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeIn,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasAccount)
              _buildAccountResult()
            else
              _buildPreVerify(),
            if (!hasAccount && isLoading)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.white.withOpacity(0.55),
                  child: const Center(
                    child: CircularProgressIndicator(color: cyanblueColor),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: hasAccount ? null : _buildVerifyButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: cyanblueColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Verify Customer',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: cyanblueColor,
        ),
      ),
    );
  }

  // ── Pre-verify: shows customer info and a verify button ─────────────

  Widget _buildPreVerify() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildCustomerHeader(),
          const SizedBox(height: 20),
          _buildInfoCard(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cyanblueColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cyanblueColor.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cyanblueColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.info_outline, color: cyanblueColor, size: 20),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Tap the button below to verify this customer and generate their account number.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), cyanblueColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: cyanblueColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fullName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.3,
                  ),
                ),
                if (_status.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cyanblueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _status[0].toUpperCase() +
                          _status.substring(1).toLowerCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cyanblueColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (_phone.isNotEmpty)
            _infoRow(Icons.phone_outlined, 'Phone', _phone),
          if (_email.isNotEmpty)
            _infoRow(Icons.email_outlined, 'Email', _email),
          if (_branch.isNotEmpty)
            _infoRow(Icons.location_on_outlined, 'Branch', _branch),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: cyanblueColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Account result: shows the account card + share options ───────────

  Widget _buildAccountResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSuccessBanner(),
          const SizedBox(height: 20),
          _buildAccountCard(),
          const SizedBox(height: 28),
          _buildShareSection(),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF10B981).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Verified',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF065F46),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'The account has been successfully verified.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF047857),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -28,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            left: -18,
            bottom: -32,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Account Holder',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.72),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fullName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Account Number',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.72),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayAccount,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'monospace',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    _iconBtn(
                      icon: _obscureAccount
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      onTap: () =>
                          setState(() => _obscureAccount = !_obscureAccount),
                      tooltip: _obscureAccount ? 'Show' : 'Hide',
                    ),
                    const SizedBox(width: 4),
                    _iconBtn(
                      icon: Icons.copy_rounded,
                      onTap: _copyAccountNumber,
                      tooltip: 'Copy',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }

  // ── Share section ───────────────────────────────────────────────────

  Widget _buildShareSection() {
    return Row(
      children: [
        Expanded(
          child: _SharePill(
            label: 'Share',
            color: cyanblueColor,
            icon: Icons.share_rounded,
            onTap: _systemShare,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SharePill(
            label: 'Copy Info',
            color: darkBlue,
            icon: Icons.copy_rounded,
            onTap: _copyFullDetails,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : fetchAccountNumber,
            icon: const Icon(Icons.verified_rounded, size: 20),
            label: Text(
              isLoading ? 'Verifying...' : 'Verify & Get Account Number',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: cyanblueColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: cyanblueColor.withOpacity(0.45),
              disabledForegroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: isLoading ? 0 : 2,
              shadowColor: cyanblueColor.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  // ── Share / Copy actions ────────────────────────────────────────────

  String get _shareMessage {
    final buf = StringBuffer();
    buf.writeln('Account Details');
    buf.writeln('────────────────');
    buf.writeln('Name: ${_fullName.toUpperCase()}');
    buf.writeln('Account No: $currentAccountNumber');
    if (_phone.isNotEmpty) buf.writeln('Phone: $_phone');
    if (_branch.isNotEmpty) buf.writeln('Branch: $_branch');
    buf.writeln('────────────────');
    buf.writeln('Cooperative Bank of Oromia');
    return buf.toString();
  }

  void _showCopySnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: cyanblueColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _copyAccountNumber() async {
    await Clipboard.setData(ClipboardData(text: currentAccountNumber));
    if (mounted) _showCopySnackBar('Account number copied');
  }

  Future<void> _copyFullDetails() async {
    await Clipboard.setData(ClipboardData(text: _shareMessage));
    if (mounted) _showCopySnackBar('Account details copied');
  }

  Future<void> _systemShare() async {
    await SharePlus.instance.share(
      ShareParams(
        text: _shareMessage,
        subject: 'Account Details - ${_fullName.toUpperCase()}',
      ),
    );
  }

  // ── API call ────────────────────────────────────────────────────────

  Future<void> fetchAccountNumber() async {
    final storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
    );
    String? token = await storage.read(key: "token");

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authorization token is missing.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final accountId = widget.registrationData['accountId'];
      final url = Uri.parse(
          '${AppConstants.baseURL}/api/v1/accounts/$accountId/verify-account');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              token.startsWith('Bearer ') ? token : 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          accountNumber = data['accountNumber'];
          _animController.reset();
          _animController.forward();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to verify account'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $e'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}

// ── Share pill button ──────────────────────────────────────────────────

class _SharePill extends StatelessWidget {
  const _SharePill({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: color.withOpacity(0.08),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
