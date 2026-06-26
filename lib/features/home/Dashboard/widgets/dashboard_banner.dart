import 'dart:async';

import 'package:coopengageplus/features/home/AccountOpeningHomePage.dart';
import 'package:coopengageplus/features/merchant/presentation/merchant_registration_page.dart';
import 'package:flutter/material.dart';
import '../constants/dashboard_constants.dart';

/// Dashboard banner carousel: account opening + merchant QR registration.
class DashboardBanner extends StatefulWidget {
  const DashboardBanner({super.key});

  @override
  State<DashboardBanner> createState() => _DashboardBannerState();
}

class _DashboardBannerState extends State<DashboardBanner> {
  static const int _slideCount = 2;
  static const int _infiniteStart = 10000;
  static const Duration _autoPlayInterval = Duration(seconds: 5);

  final PageController _pageController =
      PageController(initialPage: _infiniteStart);
  int _activeIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(_autoPlayInterval, (_) => _advanceSlide());
  }

  void _advanceSlide() {
    if (!mounted || !_pageController.hasClients) return;
    final current = _pageController.page?.round() ?? _infiniteStart;
    _pageController.animateToPage(
      current + 1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _activeIndex = index % _slideCount);
    _startAutoPlay();
  }

  Widget _slideAt(int slideIndex) {
    if (slideIndex == 0) {
      return _BannerSlide(
        onTap: _openAccountTypePage,
        child: Image.asset(
          DashboardConstants.openBannerImage,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    return _BannerSlide(
      onTap: _openMerchantRegistration,
      child: Image.asset(
        DashboardConstants.merchantQrBannerImage,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _openAccountTypePage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountOnboardingScreen(),
      ),
    );
  }

  void _openMerchantRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MerchantRegistrationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= DashboardConstants.tabletBreakpoint;
    final bannerWidth = screenWidth - (isTablet ? 26 : 20);
    final bannerHeight = bannerWidth / DashboardConstants.bannerAspectRatio;

    return Column(
      children: [
        Container(
          width: bannerWidth,
          height: bannerHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius:
                BorderRadius.circular(DashboardConstants.imageBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(DashboardConstants.imageBorderRadius),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _slideAt(index % _slideCount),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            final active = index == _activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? DashboardConstants.bannerGradientColors.first
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.expand(child: child),
      ),
    );
  }
}
