// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:coopengageplus/core/database/database_helper.dart';
import 'package:coopengageplus/core/network/network_handler.dart';
import 'package:coopengageplus/features/home/main_page.dart';
import 'package:coopengageplus/features/merchant/widgets/merchant_mycard_form_fields.dart';
import 'package:coopengageplus/features/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

class AgentPage extends StatefulWidget {
  const AgentPage({super.key});

  @override
  State<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  static const Color _coopCyan = Color(0xFF00AEEF);
  static const Color _muted = Color(0xFF64748B);

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );

  final _formKey = GlobalKey<FormState>();
  final _networkHandler = NetworkHandler();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _tinController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _resetForm();
  }

  void _resetForm() {
    _fullNameController.clear();
    _phoneController.clear();
    _businessNameController.clear();
    _tinController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _hidePassword = true;
    _hideConfirmPassword = true;
    _isSubmitting = false;
    _errorMessage = null;
    _formKey.currentState?.reset();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _tinController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 360 || size.height < 700;
    final fieldGap = compact ? 8.0 : 10.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _coopCyan,
        toolbarHeight: compact ? 44 : kToolbarHeight,
        title: Text(
          'Agent Registration',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: compact ? 16 : 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          compact ? 12 : 16,
          10,
          compact ? 12 : 16,
          14 + bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null) ...[
                _ErrorBanner(message: _errorMessage!, compact: compact),
                SizedBox(height: fieldGap),
              ],
              _AgentFlowCard(
                accentColor: _coopCyan,
                compact: compact,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.support_agent_outlined,
                            color: _coopCyan, size: compact ? 16 : 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            compact
                                ? 'Register new agent'
                                : 'New agent — fill in details below',
                            style: TextStyle(
                              fontSize: compact ? 13 : 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: fieldGap),
                    _AgentFormField(
                      accentColor: _coopCyan,
                      mutedColor: _muted,
                      compact: compact,
                      label: 'Full name',
                      hintText: 'Agent full name',
                      prefixIcon: Icons.badge_outlined,
                      controller: _fullNameController,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Full name is required' : null,
                    ),
                    SizedBox(height: fieldGap),
                    _AgentFormField(
                      accentColor: _coopCyan,
                      mutedColor: _muted,
                      compact: compact,
                      label: 'Phone or email',
                      hintText: '0912345678 or email',
                      prefixIcon: Icons.phone_outlined,
                      controller: _phoneController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z@._-]')),
                        LengthLimitingTextInputFormatter(50),
                      ],
                      validator: _validatePhoneOrEmail,
                    ),
                    SizedBox(height: fieldGap),
                    _AgentFormField(
                      accentColor: _coopCyan,
                      mutedColor: _muted,
                      compact: compact,
                      label: 'Business name (optional)',
                      hintText: 'Business name',
                      prefixIcon: Icons.storefront_outlined,
                      controller: _businessNameController,
                    ),
                    SizedBox(height: fieldGap),
                    _AgentFormField(
                      accentColor: _coopCyan,
                      mutedColor: _muted,
                      compact: compact,
                      label: 'TIN',
                      hintText: '10-digit TIN',
                      prefixIcon: Icons.numbers_outlined,
                      controller: _tinController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'TIN is required';
                        if (v.length != 10) return 'TIN must be exactly 10 digits';
                        return null;
                      },
                    ),
                    SizedBox(height: fieldGap),
                    _AgentPasswordField(
                      accentColor: _coopCyan,
                      mutedColor: _muted,
                      compact: compact,
                      label: 'Password',
                      controller: _passwordController,
                      hidePassword: _hidePassword,
                      onToggleVisibility: () =>
                          setState(() => _hidePassword = !_hidePassword),
                    ),
                    SizedBox(height: fieldGap),
                    _AgentPasswordField(
                      accentColor: _coopCyan,
                      mutedColor: _muted,
                      compact: compact,
                      label: 'Confirm password',
                      controller: _confirmPasswordController,
                      hidePassword: _hideConfirmPassword,
                      onToggleVisibility: () => setState(
                        () => _hideConfirmPassword = !_hideConfirmPassword,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (v != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: compact ? 12 : 14),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: _coopCyan,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFCBD5E1),
                        disabledForegroundColor: const Color(0xFF94A3B8),
                        padding: EdgeInsets.symmetric(vertical: compact ? 12 : 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            )
                          : const Text(
                              'Register agent',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validatePhoneOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number or email is required';
    }
    final trimmed = value.trim();
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!phoneRegex.hasMatch(trimmed) && !emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid 10-digit phone number or email';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final mainBranchId = await _loggedInUserMainBranchId();
      final branchIds = mainBranchId != null ? <int>[mainBranchId] : <int>[];

      final data = <String, dynamic>{
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'business_name': _businessNameController.text.trim(),
        'tin_number': _tinController.text.trim(),
        'branchIds': branchIds,
        'password': _passwordController.text.trim(),
      };
      if (mainBranchId != null) {
        data['mainBranchId'] = mainBranchId;
      }

      final response = await _networkHandler
          .postAgentRegistration('/api/v1/agents', data)
          .timeout(const Duration(seconds: 50));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered successfully')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
          (_) => false,
        );
        return;
      }

      final body = jsonDecode(response.body);
      _showError(body['message']?.toString() ??
          'Unable to register. Please try again later.');
    } on TimeoutException {
      _showError('Request timed out. Please try again.');
    } catch (e) {
      if (_isSessionExpired(e)) {
        _navigateToLogin();
      } else {
        _showError('An error occurred. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    FormHelper.showSimpleAlertDialog(
      context,
      'Coop Engage +',
      message,
      'OK',
      () => Navigator.of(context).pop(),
    );
  }

  bool _isSessionExpired(Object error) {
    final msg = error.toString();
    return msg.contains('Token expired') ||
        msg.contains('Invalid token') ||
        msg.contains('please login again');
  }

  void _navigateToLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expired. Please login again.'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Loginscreen()),
      (_) => false,
    );
  }

  int? _coerceStoredBranchId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  Future<int?> _loggedInUserMainBranchId() async {
    final token = await _storage.read(key: 'token');
    final dbHelper = DatabaseHelper();

    if (token != null && token.isNotEmpty) {
      final user = await dbHelper.getUserByToken(token);
      if (user != null) {
        return _coerceStoredBranchId(user['mainBranchId']);
      }
    }

    final users = await dbHelper.getUsers();
    if (users.isEmpty) return null;
    return _coerceStoredBranchId(users.first['mainBranchId']);
  }
}

class _AgentFlowCard extends StatelessWidget {
  const _AgentFlowCard({
    required this.accentColor,
    required this.compact,
    required this.child,
  });

  final Color accentColor;
  final bool compact;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.28)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, this.compact = false});

  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 8 : 10),
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

InputDecoration _agentInputDecoration({
  required Color accentColor,
  required Color mutedColor,
  required bool compact,
  String? hintText,
  IconData? prefixIcon,
}) {
  final base = merchantFlowInputDecoration(
    accentColor: accentColor,
    mutedColor: mutedColor,
    hintText: hintText,
    prefixIcon: prefixIcon,
    counterText: '',
  );
  return base.copyWith(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 10,
      vertical: compact ? 9 : 11,
    ),
    prefixIconConstraints: BoxConstraints(
      minWidth: compact ? 36 : 40,
      minHeight: compact ? 32 : 40,
    ),
  );
}

class _AgentFormField extends StatelessWidget {
  const _AgentFormField({
    required this.accentColor,
    required this.mutedColor,
    required this.compact,
    required this.label,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.validator,
  });

  final Color accentColor;
  final Color mutedColor;
  final bool compact;
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey.shade800,
          ),
        ),
        SizedBox(height: compact ? 4 : 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: compact ? 13 : 14),
          decoration: _agentInputDecoration(
            accentColor: accentColor,
            mutedColor: mutedColor,
            compact: compact,
            hintText: hintText ?? label,
            prefixIcon: prefixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
}

class _AgentPasswordField extends StatelessWidget {
  const _AgentPasswordField({
    required this.accentColor,
    required this.mutedColor,
    required this.compact,
    required this.label,
    required this.controller,
    required this.hidePassword,
    required this.onToggleVisibility,
    this.validator,
  });

  final Color accentColor;
  final Color mutedColor;
  final bool compact;
  final String label;
  final TextEditingController controller;
  final bool hidePassword;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey.shade800,
          ),
        ),
        SizedBox(height: compact ? 4 : 6),
        TextFormField(
          controller: controller,
          obscureText: hidePassword,
          style: TextStyle(fontSize: compact ? 13 : 14),
          decoration: _agentInputDecoration(
            accentColor: accentColor,
            mutedColor: mutedColor,
            compact: compact,
            hintText: label,
            prefixIcon: Icons.lock_outline_rounded,
          ).copyWith(
            suffixIcon: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(
                hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: mutedColor,
                size: compact ? 18 : 20,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
          validator: validator ??
              (v) => v == null || v.isEmpty ? 'Password is required' : null,
        ),
      ],
    );
  }
}
