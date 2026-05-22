import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/utils/language_store.dart';
import 'package:coopengageplus/features/merchant/presentation/merchant_registration_page.dart';
import 'package:flutter/material.dart';

/// Floating action button on Home — opens branch-user merchant registration.
class MerchantRegistrationFab extends StatelessWidget {
  const MerchantRegistrationFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${translation(context).merchant} registration',
      child: Material(
        elevation: 6,
        shadowColor: primaryBlue.withOpacity(0.4),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MerchantRegistrationPage(),
              ),
            );
          },
          child: Ink(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
