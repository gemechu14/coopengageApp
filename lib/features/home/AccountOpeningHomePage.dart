import 'package:coopengageplus/features/merchant/presentation/merchant_qr_hub_page.dart';
import 'package:coopengageplus/features/onboarding/customer/CorporateAccountOpening/views/CorporateAccountOpening.dart';
import 'package:coopengageplus/features/onboarding/customer/JointNationalIdentification/views/individual_account_by_national_id.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/views/individual_account_by_national_id.dart';
import 'package:coopengageplus/features/onboarding/customer/SendLink/link_generator_page.dart';
// import 'package:coopengageplus/features/onboarding/customer/agent/AgentPage.dart';
import 'package:flutter/material.dart';

class AccountOnboardingScreen extends StatelessWidget {
  const AccountOnboardingScreen({super.key});

  static const List<_AccountTypeOption> _options = [
    _AccountTypeOption(
      title: 'Individual',
      description: 'Personal account for a single user',
      icon: Icons.person_outline_rounded,
      route: _AccountRoute.individual,
    ),
    _AccountTypeOption(
      title: 'Joint',
      description: 'Shared account for multiple users',
      icon: Icons.groups_outlined,
      route: _AccountRoute.joint,
    ),
    _AccountTypeOption(
      title: 'Corporate',
      description: 'Business and organizational accounts',
      icon: Icons.apartment_outlined,
      route: _AccountRoute.corporate,
    ),
    _AccountTypeOption(
      title: 'Merchant QR Registration',
      description: 'Register merchants for QR payment code',
      icon: Icons.qr_code_2_outlined,
      route: _AccountRoute.merchant,
    ),
    // _AccountTypeOption(
    //   title: 'Agent / Partner',
    //   description: 'Onboard customers on behalf of the bank',
    //   icon: Icons.support_agent_outlined,
    //   route: _AccountRoute.agent,
    // ),
    _AccountTypeOption(
      title: 'Send a Link',
      description: 'Share a self-service registration link',
      icon: Icons.link_rounded,
      route: _AccountRoute.sendLink,
    ),
  ];

  void _onOptionTap(BuildContext context, _AccountRoute route) {
    switch (route) {
      case _AccountRoute.individual:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => NationalIdentificationWebSocket(),
          ),
          (route) => false,
        );
      case _AccountRoute.joint:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => JointNationalIdentification()),
        );
      case _AccountRoute.corporate:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CorporateAccountOpening()),
        );
      case _AccountRoute.merchant:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MerchantQrHubPage(),
          ),
        );
      // case _AccountRoute.agent:
      //   Navigator.of(context).push(
      //     MaterialPageRoute(builder: (context) => const AgentPage()),
      //   );
      case _AccountRoute.agent:
        break;
      case _AccountRoute.sendLink:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LinkGeneratorPage()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: MerchantFlowColors.coopCyan,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Choose Account Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: MerchantFlowColors.coopCyan,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select the type of account you would like to open',
                style: TextStyle(
                  fontSize: 14,
                  color: MerchantFlowColors.muted.withOpacity(0.95),
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.32,
                ),
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  final option = _options[index];
                  return _AccountTypeGridCard(
                    icon: option.icon,
                    title: option.title,
                    subtitle: option.description,
                    onTap: () => _onOptionTap(context, option.route),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AccountRoute {
  individual,
  joint,
  corporate,
  merchant,
  agent,
  sendLink,
}

class _AccountTypeOption {
  const _AccountTypeOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });

  final String title;
  final String description;
  final IconData icon;
  final _AccountRoute route;
}

class _AccountTypeGridCard extends StatefulWidget {
  const _AccountTypeGridCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_AccountTypeGridCard> createState() => _AccountTypeGridCardState();
}

class _AccountTypeGridCardState extends State<_AccountTypeGridCard> {
  static const Color _muted = Color(0xFF5A7184);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: MerchantFlowColors.coopCyan.withOpacity(_pressed ? 0.5 : 0.32),
            width: 1,
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: MerchantFlowColors.coopCyan.withOpacity(0.01),
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                    spreadRadius: -2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: MerchantFlowColors.coopCyan.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(2, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (highlighted) {
              setState(() => _pressed = highlighted);
            },
            borderRadius: BorderRadius.circular(18),
            splashColor: MerchantFlowColors.coopCyan.withOpacity(0.14),
            highlightColor: MerchantFlowColors.coopCyan.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: MerchantFlowColors.bannerFill,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon,
                          color: MerchantFlowColors.coopCyan,
                          size: 18,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 30,
                        height: 30,
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
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: MerchantFlowColors.coopCyan,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Expanded(
                    child: Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: _muted.withOpacity(0.95),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
