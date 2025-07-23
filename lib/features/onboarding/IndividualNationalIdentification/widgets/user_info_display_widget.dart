import 'package:flutter/material.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import '../model/user_information.dart';
import '../services/user_info_service.dart';

/// Widget to display user information in a beautiful, organized layout
class UserInfoDisplayWidget extends StatelessWidget {
  final UserInformation userInfo;
  final VoidCallback? onClose;

  const UserInfoDisplayWidget({
    Key? key,
    required this.userInfo,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 24),
                  _buildContactInfoSection(),
                  const SizedBox(height: 24),
                  _buildSystemInfoSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cyanblueColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cyanblueColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person,
              color: cyanblueColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cyanblueColor,
                  ),
                ),
                Text(
                  UserInfoService.getUserSummary(userInfo),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person_outline,
      items: [
        _InfoItem(
          label: 'Full Name',
          value: userInfo.fullName ?? 'Not provided',
          icon: Icons.badge,
        ),
        _InfoItem(
          label: 'Date of Birth',
          value: UserInfoService.formatDate(userInfo.dateOfBirth),
          icon: Icons.cake,
        ),
        _InfoItem(
          label: 'Gender',
          value: userInfo.sex ?? 'Not provided',
          icon: Icons.person,
        ),
        _InfoItem(
          label: 'Legal ID',
          value: userInfo.legalId ?? 'Not provided',
          icon: Icons.credit_card,
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      title: 'Contact Information',
      icon: Icons.contact_mail_outlined,
      items: [
        _InfoItem(
          label: 'Email',
          value: userInfo.email ?? 'Not provided',
          icon: Icons.email,
          subtitle: userInfo.emailVerified != null
              ? 'Verified: ${UserInfoService.formatBoolean(userInfo.emailVerified)}'
              : null,
        ),
        _InfoItem(
          label: 'Phone',
          value: userInfo.phone ?? 'Not provided',
          icon: Icons.phone,
        ),
        _InfoItem(
          label: 'State',
          value: userInfo.state ?? 'Not provided',
          icon: Icons.location_on,
        ),
        _InfoItem(
          label: 'Country',
          value: userInfo.country ?? 'Not provided',
          icon: Icons.flag,
        ),
      ],
    );
  }

  Widget _buildSystemInfoSection() {
    return _buildSection(
      title: 'System Information',
      icon: Icons.info_outline,
      items: [
        _InfoItem(
          label: 'Auth ID',
          value: userInfo.authId?.toString() ?? 'Not available',
          icon: Icons.fingerprint,
        ),
        _InfoItem(
          label: 'Account ID',
          value: userInfo.accountId?.toString() ?? 'Not available',
          icon: Icons.account_box,
        ),
        _InfoItem(
          label: 'Customer Type',
          value: userInfo.customerType ?? 'Not specified',
          icon: Icons.category,
        ),
        _InfoItem(
          label: 'Status',
          value: userInfo.status ?? 'Not available',
          icon: Icons.check_circle_outline,
        ),
        _InfoItem(
          label: 'Profile Completion',
          value: UserInfoService.formatPercentage(userInfo.percentageComplete),
          icon: Icons.pie_chart,
        ),
        _InfoItem(
          label: 'Created',
          value: UserInfoService.formatDate(userInfo.createdAt),
          icon: Icons.schedule,
        ),
        _InfoItem(
          label: 'Last Updated',
          value: UserInfoService.formatDate(userInfo.updatedAt),
          icon: Icons.update,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: cyanblueColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cyanblueColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: items.map((item) => _buildInfoRow(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: cyanblueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              item.icon,
              size: 16,
              color: cyanblueColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
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

  /// Static method to show user info in a bottom sheet
  static Future<void> showUserInfo(
    BuildContext context,
    UserInformation userInfo,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => UserInfoDisplayWidget(
          userInfo: userInfo,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

/// Helper class for info items
class _InfoItem {
  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
  });
} 