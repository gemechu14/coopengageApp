import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/merchant/presentation/merchant_registration_page.dart';
import 'package:coopengageplus/features/onboarding/customer/CorporateAccountOpening/views/CorporateAccountOpening.dart';
import 'package:coopengageplus/features/onboarding/customer/JointNationalIdentification/views/individual_account_by_national_id.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/views/individual_account_by_national_id.dart';
import 'package:coopengageplus/features/onboarding/customer/SendLink/link_generator_page.dart';
// import 'package:coopengageplus/features/onboarding/customer/agent/AgentPage.dart';
import 'package:flutter/material.dart';

class AccountOnboardingScreen extends StatelessWidget {
  AccountOnboardingScreen({super.key});

  static const Color _muted = Color(0xFF64748B);
  static const Color _titleColor = Color(0xFF0F172A);
  static const Color _pageBg = Color(0xFFF5F7F9);

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
      description: 'Register  Merchants for QR payment code',
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
            builder: (context) => const MerchantRegistrationPage(),
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
      backgroundColor: _pageBg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _pageBg,
        foregroundColor: cyanblueColor,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Choose Account Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cyanblueColor,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select the type of account you would like to open',
                style: TextStyle(
                  fontSize: 14,
                  color: _muted.withOpacity(0.95),
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
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.22,
                ),
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  final option = _options[index];
                  return _AccountTypeCard(
                    option: option,
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

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.option,
    required this.onTap,
  });

  final _AccountTypeOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cyanblueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        option.icon,
                        size: 18,
                        color: cyanblueColor,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AccountOnboardingScreen._muted.withOpacity(0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  option.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AccountOnboardingScreen._titleColor,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    option.description,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AccountOnboardingScreen._muted.withOpacity(0.9),
                      height: 1.35,
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
    );
  }
}
