import 'package:flutter/material.dart';

import 'merchant_list_page.dart';
import 'merchant_registration_page.dart';

/// Shared eth-qr brand colors (matches merchant registration flow).
abstract final class MerchantFlowColors {
  static const Color coopCyan = Color(0xFF00AEEF);
  static const Color coopBlue = Color(0xFF0D47A1);
  static const Color pageBg = Color(0xFFF4F7FB);
  static const Color bannerFill = Color(0xFFE8F7FD);
  static const Color muted = Color(0xFF64748B);
  static const Color cardBorder = Color(0xFFD1E9F6);
}

/// Landing hub shown when the user taps "Merchant QR".
class MerchantQrHubPage extends StatelessWidget {
  const MerchantQrHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MerchantFlowColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: MerchantFlowColors.coopCyan,
        title: const Text(
          'Merchant QR',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: MerchantFlowColors.coopCyan,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // const _HubHeaderCard(),
              const SizedBox(height: 24),
              // const _QuickActionsHeader(),
              const SizedBox(height: 14),
              _HubActionCard(
                icon: Icons.person_add_alt_1_rounded,
                title: 'New Merchant Registration',
                subtitle:
                    'Register a merchant with full account details and verified address.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MerchantRegistrationPage(),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _HubActionCard(
                icon: Icons.qr_code_2_rounded,
                title: 'Registered Merchants',
                subtitle:
                    'Request QR codes and view printable posters for branch merchants.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MerchantListPage(),
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

// ---------------------------------------------------------------------------
// Header card
// ---------------------------------------------------------------------------

class _HubHeaderCard extends StatelessWidget {
  const _HubHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MerchantFlowColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: MerchantFlowColors.coopCyan.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: MerchantFlowColors.bannerFill,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: MerchantFlowColors.coopCyan,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EthQR Merchant Portal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: MerchantFlowColors.coopCyan,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coop Bank Oromia — Branch Operations',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: MerchantFlowColors.muted.withOpacity(0.9),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: MerchantFlowColors.bannerFill,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: MerchantFlowColors.coopCyan,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'SESSION SECURE · BRANCH STAFF',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: MerchantFlowColors.muted.withOpacity(0.85),
                    letterSpacing: 0.6,
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

// ---------------------------------------------------------------------------
// Quick actions section label
// ---------------------------------------------------------------------------

class _QuickActionsHeader extends StatelessWidget {
  const _QuickActionsHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          'QUICK ACTIONS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: MerchantFlowColors.coopCyan,
            letterSpacing: 0.8,
          ),
        ),
        Spacer(),
        Text(
          '2 available',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: MerchantFlowColors.muted,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action card
// ---------------------------------------------------------------------------

class _HubActionCard extends StatelessWidget {
  const _HubActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const Color _muted = Color(0xFF5A7184);

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: MerchantFlowColors.coopCyan.withOpacity(0.32),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MerchantFlowColors.coopCyan.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(3, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: MerchantFlowColors.coopCyan.withOpacity(0.1),
          highlightColor: MerchantFlowColors.coopCyan.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: MerchantFlowColors.bannerFill,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: MerchantFlowColors.coopCyan, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: MerchantFlowColors.coopCyan,
                          // color: Colors.black12,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: _muted.withOpacity(0.95),
                          height: 1.4,
                        ),
                      ),
                      // Badge hidden — STEP 1 / MANAGE pills not shown per design.
                      // const SizedBox(height: 10),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 10,
                      //     vertical: 4,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: _iconCircleBg,
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: Text(
                      //     badge,
                      //     style: const TextStyle(
                      //       fontSize: 10.5,
                      //       fontWeight: FontWeight.w700,
                      //       color: _coopCyan,
                      //       letterSpacing: 0.4,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: MerchantFlowColors.coopCyan,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: MerchantFlowColors.coopCyan.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
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
