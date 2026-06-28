// ignore_for_file: use_build_context_synchronously

import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JointAccountDetailPage extends StatelessWidget {
  final Map jointAccount;
  final BuildContext parentContext;

  const JointAccountDetailPage(
      {Key? key, required this.jointAccount, required this.parentContext})
      : super(key: key);

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List customers = (jointAccount['customersInfo'] != null &&
            jointAccount['customersInfo'] is List)
        ? List<Map<String, dynamic>>.from(jointAccount['customersInfo'])
        : [];
    final String accountId = jointAccount['id']?.toString() ?? '';
    final String status = jointAccount['status'] ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.93,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (context, scrollController) => Column(
          children: [
            _buildSheetHeader(accountId, status, customers.length),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSection(
                      'Account Information',
                      Icons.account_balance_outlined,
                      [
                        _InfoItem('Account Type', jointAccount['accountType']),
                        _InfoItem('Joint Account Type',
                            jointAccount['jointAccountType']),
                        _InfoItem('Branch', jointAccount['branch']),
                        _InfoItem('Currency', jointAccount['currency']),
                        _InfoItem(
                          'Initial Deposit',
                          jointAccount['initialDeposit'] != null
                              ? 'ETB ${jointAccount['initialDeposit']}'
                              : null,
                        ),
                        _InfoItem('Status', jointAccount['status']),
                        _InfoItem(
                            'Added By', jointAccount['addedByFullName']),
                        _InfoItem(
                            'Added By Role', jointAccount['addedByRole']),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildHoldersSection(customers),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader(
      String accountId, String status, int holderCount) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cyanblueColor, cyanblueColor.withOpacity(0.85)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: const Center(
                  child: Icon(Icons.people, color: Colors.white, size: 26),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Joint Account #$accountId',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (status.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(8),
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$holderCount ${holderCount == 1 ? 'holder' : 'holders'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<_InfoItem> items) {
    final validItems = items
        .where((i) => i.value != null && i.value!.toString().isNotEmpty)
        .toList();
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: cyanblueColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: cyanblueColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cyanblueColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              children: validItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
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
                        child: item.label == 'Status' && item.value != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cyanblueColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.value.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: cyanblueColor,
                                  ),
                                ),
                              )
                            : Text(
                                item.value.toString(),
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

  Widget _buildHoldersSection(List customers) {
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: cyanblueColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people_outline,
                      size: 16, color: cyanblueColor),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Account Holders',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cyanblueColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cyanblueColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${customers.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cyanblueColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          if (customers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No account holders found',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            )
          else
            ...customers.asMap().entries.map((entry) {
              return _buildHolderCard(entry.value, entry.key + 1);
            }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHolderCard(Map customer, int number) {
    final String name = customer['fullName'] ?? 'Holder $number';
    final String initials = name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    final items = <_InfoItem>[
      _InfoItem('Full Name', customer['fullName']),
      _InfoItem('Surname', customer['surname']),
      _InfoItem('Mother\'s Name', customer['motherName']),
      _InfoItem('Email', customer['email']),
      _InfoItem('Phone', customer['phone']),
      _InfoItem('Date of Birth', customer['dateOfBirth']),
      _InfoItem('Gender', customer['sex']),
      _InfoItem('Title', customer['title']),
      _InfoItem('Country', customer['country']),
      _InfoItem('State', customer['state']),
      _InfoItem('City', customer['city']),
      _InfoItem('Zone / Sub City', customer['zoneSubCity']),
      _InfoItem('House No', customer['houseNo']),
      _InfoItem('Zip Code', customer['zipCode']),
      _InfoItem('Occupation', customer['occupation']),
      _InfoItem('Issue Authority', customer['issueAuthority']),
      _InfoItem('Sector', customer['sector']),
      _InfoItem('Industry', customer['industry']),
      _InfoItem('Employer', customer['employerName']),
      _InfoItem('Legal ID', customer['legalId']),
    ];

    final validItems = items
        .where((i) => i.value != null && i.value!.toString().isNotEmpty)
        .toList();

    final hasFiles = _hasDocuments(customer);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cyanblueColor,
                  cyanblueColor.withOpacity(0.7)
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          subtitle: Text(
            'Holder $number${customer['email'] != null ? ' \u2022 ${customer['email']}' : ''}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Column(
                children: validItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.value.toString(),
                            style: const TextStyle(
                              fontSize: 13,
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
            if (hasFiles) ...[
              const Divider(indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attachments',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFileAttachment(
                        'Signature', customer['signature']),
                    _buildFileAttachment(
                        'ID Card (Front)', customer['residenceCard']),
                    _buildFileAttachment(
                        'ID Card (Back)', customer['residenceCardBack']),
                    _buildFileAttachment('ID Card (Front)',
                        customer['residenceCardFront']),
                    _buildFileAttachment(
                        'ID Card', customer['idCard']),
                    _buildFileAttachment(
                        'ID Card (Back)', customer['idCardBack']),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasDocuments(Map customer) {
    return (customer['signature'] != null &&
            customer['signature'].toString().isNotEmpty) ||
        (customer['residenceCard'] != null &&
            customer['residenceCard'].toString().isNotEmpty) ||
        (customer['residenceCardBack'] != null &&
            customer['residenceCardBack'].toString().isNotEmpty) ||
        (customer['residenceCardFront'] != null &&
            customer['residenceCardFront'].toString().isNotEmpty) ||
        (customer['idCard'] != null &&
            customer['idCard'].toString().isNotEmpty) ||
        (customer['idCardBack'] != null &&
            customer['idCardBack'].toString().isNotEmpty);
  }

  Widget _buildFileAttachment(String label, dynamic fileUrl) {
    if (fileUrl == null || fileUrl.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    final url = fileUrl.toString();
    final bool isImage = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.gif');

    if (isImage) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _showImageDialog(url, label),
              child: Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image,
                              size: 32, color: Colors.grey[400]),
                          const SizedBox(height: 4),
                          Text('Image not available',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cyanblueColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: cyanblueColor.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.attach_file,
                  size: 16, color: cyanblueColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: cyanblueColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(Icons.open_in_new,
                  size: 14, color: cyanblueColor),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl, String label) {
    showDialog(
      context: parentContext,
      builder: (context) => Dialog(
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
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Container(
                constraints:
                    const BoxConstraints(maxHeight: 400, maxWidth: 300),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text('Image not available',
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _InfoItem {
  final String label;
  final dynamic value;
  _InfoItem(this.label, this.value);
}
