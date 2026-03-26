import 'package:coopengageplus/features/home/pages/mycard_apply_flow_page.dart';
import 'package:flutter/material.dart';

/// MyCard promo for **branch staff** registering **customers**; opens [MycardApplyFlowPage].
class DashboardMycardShareCard extends StatelessWidget {
  const DashboardMycardShareCard({super.key});

  static const Color _c1 = Color(0xFF1E88E5);
  static const Color _c2 = Color.fromARGB(255, 44, 111, 186);
  static const Color _c3 = Color.fromARGB(255, 77, 136, 224);
  static const Color _ctaBlue = Color(0xFF1565C0);

  /// Soft blue-white on the gradient (not pure white).
  static const Color _logoTintOnBlue = Color(0xFFD6E8F8);

  static const String _coopLogoAsset = 'assets/logo.png';
  static const String _visaLogoAsset = 'assets/visa.png';
  static const String _worldCupAsset = 'assets/world_cup.png';

  void _openApplyFlow(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const MycardApplyFlowPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 360;
    final logoH = compact ? 22.0 : 26.0;
    final cupSize = compact ? 26.0 : 30.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openApplyFlow(context),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_c1, _c2, _c3],
            ),
            boxShadow: [
              BoxShadow(
                color: _c2.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 10 : 12,
              10,
              compact ? 10 : 12,
              10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _BrandImage(
                      asset: _coopLogoAsset,
                      height: logoH,
                      maxWidth: compact ? 100 : 120,
                      fallback: Icons.account_balance,
                    ),
                    SizedBox(width: compact ? 6 : 8),
                    _WorldCupThumb(size: cupSize),
                    SizedBox(width: compact ? 6 : 8),
                    _BrandImage(
                      asset: _visaLogoAsset,
                      height: logoH * 0.85,
                      maxWidth: compact ? 52 : 58,
                      fallback: Icons.credit_card,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.add_card_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: compact ? 20 : 22,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Register customers',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: compact ? 10 : 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'From Card to World Cup!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 14.5 : 15,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Apply for a debit card for customers using their account number.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: compact ? 11 : 11.5,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app_rounded, size: 16, color: _ctaBlue),
                      const SizedBox(width: 6),
                      Text(
                        'Apply',
                        style: TextStyle(
                          color: _ctaBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: compact ? 13 : 14,
                        ),
                      ),
                    ],
                  ),
                ),const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandImage extends StatelessWidget {
  const _BrandImage({
    required this.asset,
    required this.height,
    required this.maxWidth,
    required this.fallback,
  });

  final String asset;
  final double height;
  final double maxWidth;
  final IconData fallback;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height, maxWidth: maxWidth),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          DashboardMycardShareCard._logoTintOnBlue,
          BlendMode.srcIn,
        ),
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          errorBuilder: (_, __, ___) => Icon(
            fallback,
            size: height * 0.85,
            color: DashboardMycardShareCard._logoTintOnBlue,
          ),
        ),
      ),
    );
  }
}

class _WorldCupThumb extends StatelessWidget {
  const _WorldCupThumb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          DashboardMycardShareCard._worldCupAsset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.emoji_events_rounded,
            size: size * 0.65,
            color: Colors.amber.shade200,
          ),
        ),
      ),
    );
  }
}
