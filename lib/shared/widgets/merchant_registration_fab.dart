import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/merchant/presentation/merchant_qr_hub_page.dart';
import 'package:flutter/material.dart';

/// Floating action button on Home — opens the Merchant QR hub.
class MerchantRegistrationFab extends StatelessWidget {
  const MerchantRegistrationFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: primaryBlue.withOpacity(0.4),
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MerchantQrHubPage(),
            ),
          );
        },
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_2_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  'Merchant QR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
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
