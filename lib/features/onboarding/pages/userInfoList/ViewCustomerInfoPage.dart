// ignore_for_file: must_be_immutable, deprecated_member_use, use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:coopengageplus/core/network/network_handler.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/home/main_page.dart';
import 'package:coopengageplus/features/onboarding/pages/verifyCustomerInfo.dart';
import 'package:coopengageplus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewCustomerInfo extends StatefulWidget {
  final Map<String, dynamic> registrationData;
  String title;
  final String? userId;
  final String? className;

  ViewCustomerInfo({
    super.key,
    required this.registrationData,
    required this.title,
    this.userId,
    this.className,
  });

  @override
  State<ViewCustomerInfo> createState() => _ViewCustomerInfoState();
}

class _ViewCustomerInfoState extends State<ViewCustomerInfo> {
  NetworkHandler networkHandler = NetworkHandler();
  List<Map<String, dynamic>> accountTypes = [];
  bool _navigatingToHome = false;

  String _getStatusFromTitle(String title) {
    if (title.contains('Approved')) return 'APPROVED';
    if (title.contains('Rejected')) return 'REJECTED';
    if (title.contains('Awaiting')) return 'PENDING';
    return 'NEW';
  }

  /// Same rules as verify in [UserListPage] popup: New Applicants + REGISTERED + online.
  bool _shouldShowVerifyAction() {
    if (!isOnline) return false;
    if (widget.title != 'New Applicants') return false;
    final s =
        (widget.registrationData['status'] ?? '').toString().trim().toUpperCase();
    return s == 'REGISTERED';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SystemChrome.setSystemUIOverlayStyle(systemUiForCyanAppBar);
      }
    });
  }

  @override
  void dispose() {
    if (!_navigatingToHome) {
      SystemChrome.setSystemUIOverlayStyle(systemUiForCyanAppBar);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.registrationData;
    final dynamic signatureBytes = data['signature'];
    final dynamic photoData = data['photo'];
    final dynamic residenceCardData = data['residenceCard'];
    final dynamic residenceCardBackData = data['residenceCardBack'];
    final String fullName = data['fullName'] ?? 'Customer';
    final String status = data['status'] ?? _getStatusFromTitle(widget.title);
    final String initials = fullName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(fullName, initials, status),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  if (_shouldShowVerifyAction()) ...[
                    _buildVerifyAccountBanner(),
                    const SizedBox(height: 12),
                  ],
                  _buildSection(
                    'Personal Information',
                    Icons.person_outline,
                    [
                      _InfoItem('Full Name', data['fullName']),
                      _InfoItem('Surname', data['surname']),
                      _InfoItem('Mother\'s Name', data['motherName']),
                      _InfoItem('Gender', data['sex']),
                      _InfoItem('Date of Birth', _formatDate(data['dateOfBirth'])),
                      _InfoItem('Phone', _formatPhone(data['phone'])),
                      _InfoItem('Email', data['email']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    'Address Details',
                    Icons.location_on_outlined,
                    [
                      _InfoItem('Country', data['country']),
                      _InfoItem('State / Region', data['state']),
                      _InfoItem('City', data['city']),
                      _InfoItem('Zone / Sub City', data['zoneSubCity']),
                      _InfoItem('Zip Code', data['zipCode']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    'Account Information',
                    Icons.account_balance_outlined,
                    [
                      _InfoItem('Branch', data['branch']),
                      _InfoItem('Customer Type', data['customerType']),
                      _InfoItem('Account Type', data['accountType']?.toString()),
                      _InfoItem('Account Number', data['accountNumber']),
                      _InfoItem('Currency', data['currency']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    'Employment & Income',
                    Icons.work_outline,
                    [
                      _InfoItem('Occupation', data['occupation']),
                      _InfoItem('Monthly Income', data['monthlyIncome']?.toString()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    'Identification',
                    Icons.badge_outlined,
                    [
                      _InfoItem('Document Name', data['documentName']),
                      _InfoItem('Issue Date', _formatDate(data['issueDate'])),
                      _InfoItem('Expiry Date', _formatDate(data['expirayDate'] ?? data['expiryDate'])),
                    ],
                  ),
                  if (_hasAnyImage(signatureBytes, photoData,
                      residenceCardData, residenceCardBackData)) ...[
                    const SizedBox(height: 12),
                    _buildDocumentsSection(
                      signatureBytes,
                      photoData,
                      residenceCardData,
                      residenceCardBackData,
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildHomeButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(String fullName, String initials, String status) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: cyanblueColor,
      systemOverlayStyle: systemUiForCyanAppBar,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cyanblueColor, cyanblueColor.withOpacity(0.85)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.45)),
                  ),
                  child: Text(
                    status[0] + status.substring(1).toLowerCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyAccountBanner() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.verified_outlined, color: cyanblueColor, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Account verification',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Verify the customer to get the account number.',
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => Verifycustomerinfo(
                      registrationData: widget.registrationData,
                      title: widget.title,
                      userId: widget.userId,
                      className: widget.className,
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: cyanblueColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Verify',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<_InfoItem> items) {
    final validItems =
        items.where((i) => i.value != null && i.value!.isNotEmpty).toList();
    if (validItems.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cyanblueColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: cyanblueColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cyanblueColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: validItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAnyImage(dynamic sig, dynamic photo, dynamic front, dynamic back) {
    return sig != null || photo != null || front != null || back != null;
  }

  Widget _buildDocumentsSection(
    dynamic signatureBytes,
    dynamic photoData,
    dynamic residenceCardData,
    dynamic residenceCardBackData,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cyanblueColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Icon(Icons.photo_library_outlined, size: 18, color: cyanblueColor),
                ),
                const SizedBox(width: 10),
                Text(
                  'Documents & Photos',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cyanblueColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildImageTile('Photo', photoData),
                _buildImageTile('Signature', signatureBytes),
                _buildImageTile('ID Card (Front)', residenceCardData),
                _buildImageTile('ID Card (Back)', residenceCardBackData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(String title, dynamic imageData) {
    if (imageData == null) return const SizedBox.shrink();

    Widget? imageWidget;
    try {
      if (imageData is Uint8List) {
        imageWidget = Image.memory(imageData, fit: BoxFit.cover);
      } else if (imageData is String &&
          (imageData.startsWith('http') || imageData.startsWith('https'))) {
        imageWidget = Image.network(
          imageData,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.broken_image, color: Colors.grey[400]),
        );
      } else if (imageData is String &&
          (imageData.startsWith('/9j/') ||
              imageData.startsWith('data:image/'))) {
        final base64Str = imageData.startsWith('data:image/')
            ? imageData.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')
            : imageData;
        imageWidget = Image.memory(base64Decode(base64Str), fit: BoxFit.cover);
      }
    } catch (e) {
      print("Error processing image for '$title': $e");
    }

    if (imageWidget == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showFullImage(title, imageWidget!),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageWidget,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(String title, Widget imageWidget) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Container(
                constraints:
                    const BoxConstraints(maxHeight: 400, maxWidth: 350),
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageWidget,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          _navigatingToHome = true;
          SystemChrome.setSystemUIOverlayStyle(systemUiForLightBackground);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.home_outlined, size: 20),
        label: const Text(
          'Go to Home',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: cyanblueColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  String _formatPhone(String? phone) {
    if (phone == null) return '';
    return phone;
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final d = DateTime.parse(date);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }

  Future<void> _initializeGlobal() async {
    List<Map<String, dynamic>> fetchedAccountTypes =
        await networkHandler.fetchAccountTypesFromDatabase();
    setState(() {
      accountTypes = fetchedAccountTypes;
    });
  }
}

class _InfoItem {
  final String label;
  final String? value;
  _InfoItem(this.label, this.value);
}
