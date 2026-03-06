
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/shared/widgets/text/custom_nav_heading.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: graybackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            backgroundColor: whiteColor,
            elevation: 0,
            shadowColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: graybackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: cyanblueColor,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            title: CustomNavHeading(text: 'Help & Products'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.grey[200]!,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          color: cyanblueColor,
          onRefresh: () async {
            // Refresh logic if needed
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Interest-Free Deposit Products Section
                _buildSectionHeader(
                  title: 'Interest-Free Deposit Products',
                  subtitle: 'Wadiah-Based (Safekeeping) Deposit Accounts',
                  description: 'Safe. Flexible. Sharia-Compliant.',
                ),
                const SizedBox(height: 16),
                _buildProductCard(
                  icon: Icons.savings_rounded,
                  title: 'Wadiah Saving Account',
                  features: [
                    '100% capital guarantee',
                    'Free deposits and withdrawals',
                    'Ideal for everyday savers',
                  ],
                  color: primaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.account_balance_rounded,
                  title: 'Wadiah Current Account',
                  features: [
                    'Cheque book and full transaction access',
                    'Flexible and secure for daily use',
                  ],
                  color: secondaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.mosque_rounded,
                  title: 'Labbaik Wadiah Saving Account',
                  features: [
                    'Structured, long-term savings',
                    'Fully Sharia-compliant',
                    'Peace of mind while preparing for your spiritual goal',
                  ],
                  color: tertiaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.child_care_rounded,
                  title: 'Gaammee Junior Wadiah Account',
                  features: [
                    'For children aged 0–15',
                    'Managed by parents or guardians',
                    'Converts to an adult account at age 18',
                  ],
                  color: cyanblueColor,
                ),
                _buildProductCard(
                  icon: Icons.business_rounded,
                  title: 'ECX Wadiah Current Account',
                  features: [
                    'Easy settlement and trading',
                    'Opened in collaboration with ECX',
                  ],
                  color: primaryBlue,
                ),
                const SizedBox(height: 24),

                // Mudarabah-Based Accounts Section
                _buildSectionHeader(
                  title: 'Mudarabah-Based (Profit-Sharing) Accounts',
                  subtitle: 'Earn halal returns while Coopbank grows your savings responsibly.',
                  description: 'Your money works for you — ethically.',
                ),
                const SizedBox(height: 16),
                _buildProductCard(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Ordinary Mudarabah Saving Account',
                  features: [
                    'Periodic returns based on performance',
                    'Minimum balance required to earn returns',
                  ],
                  color: primaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.woman_rounded,
                  title: 'Siinqee – Women\'s Mudarabah Account',
                  features: [
                    'For women aged 30+',
                    'Enhanced profit-sharing',
                    'A tool for financial independence',
                  ],
                  color: secondaryColor,
                ),
                _buildProductCard(
                  icon: Icons.school_rounded,
                  title: 'Dargaggoo – Youth Mudarabah Account',
                  features: [
                    'For youths aged 15–29',
                    'Start smart saving early',
                    'Earn profit while studying or working',
                  ],
                  color: cyanblueColor,
                ),
                _buildProductCard(
                  icon: Icons.child_friendly_rounded,
                  title: 'Gaammee – Junior Mudarabah Account',
                  features: [
                    'For children under 15',
                    'Grows alongside your child',
                    'Earns halal returns over time',
                  ],
                  color: tertiaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.mosque_rounded,
                  title: 'Labbaik Mudarabah Saving Account',
                  features: [
                    'Save for Hajj (5–15 years) or Umrah (1–3 years)',
                    'Earn returns while fulfilling your religious obligations',
                  ],
                  color: primaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.groups_rounded,
                  title: 'Cooperatives Mudarabah Account',
                  features: [
                    'Designed for cooperatives and unions',
                    'Joint savings and investments',
                    'Ethical return-sharing for community growth',
                  ],
                  color: secondaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.savings_rounded,
                  title: 'Gudunfaa Mudarabah Saving',
                  features: [
                    'Save small amounts daily, earn more tomorrow',
                    'Ideal for low-income or informal earners',
                    'Daily collection via Gudunfa box',
                    'Earn disciplined, Sharia-compliant returns',
                  ],
                  color: yellowColor,
                ),
                const SizedBox(height: 24),

                // Mudarabah Investment Section
                _buildSectionHeader(
                  title: 'Mudarabah Investment (Time Deposit)',
                  subtitle: 'Lock in your savings. Grow with confidence.',
                  description: '',
                ),
                const SizedBox(height: 16),
                _buildProductCard(
                  icon: Icons.trending_up_rounded,
                  title: 'Mudarabah Investment / Time Deposit',
                  features: [
                    'Fixed tenure: 3 to 24+ months',
                    'Higher returns for longer investment periods',
                    'Ethical investment, peace of mind guaranteed',
                  ],
                  color: primaryBlue,
                ),
                const SizedBox(height: 24),

                // IFB Foreign Currency Deposit Accounts Section
                _buildSectionHeader(
                  title: 'IFB Foreign Currency Deposit Accounts',
                  subtitle: 'Earn or save in foreign currencies — the Islamic way.',
                  description: '',
                ),
                const SizedBox(height: 16),
                _buildProductCard(
                  icon: Icons.language_rounded,
                  title: 'Diaspora Wadiah Saving Account',
                  features: [
                    'For Ethiopians living abroad',
                    'Secure, Sharia-compliant FCY savings',
                    'Full capital guarantee',
                  ],
                  color: primaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.account_balance_rounded,
                  title: 'Diaspora Wadiah Current Account',
                  features: [
                    'Convenient FCY transactions',
                    'Cheque privileges',
                    'No interest — full control',
                  ],
                  color: secondaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Diaspora Mudarabah Saving Account',
                  features: [
                    'Ethical FCY profit-sharing',
                    'Available in USD, EUR, GBP',
                    'Trusted by the diaspora community',
                  ],
                  color: cyanblueColor,
                ),
                _buildProductCard(
                  icon: Icons.trending_up_rounded,
                  title: 'Diaspora Mudarabah Time Deposit',
                  features: [
                    'Long-term, high-return FCY investments',
                    'Available in multiple currencies',
                    'Fixed tenure with halal earnings',
                  ],
                  color: primaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.public_rounded,
                  title: 'Non-Resident Transferable & Non-Transferable Accounts',
                  features: [
                    'For all non-resident Ethiopians',
                    'Supports personal and business needs',
                    'Convertible to Birr or maintained in FCY',
                  ],
                  color: tertiaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.flight_rounded,
                  title: 'Wadiah ECOLFL Account',
                  features: [
                    'Special savings account for Ethiopians living overseas',
                    'Hassle-free, interest-free, and secure',
                  ],
                  color: secondaryBlue,
                ),
                const SizedBox(height: 24),

                // Wadi'ah Retention Accounts Section
                _buildSectionHeader(
                  title: 'Wadi\'ah Retention Accounts',
                  subtitle: 'Exclusive to exporters — control and flexibility over your foreign currency earnings.',
                  description: '',
                ),
                const SizedBox(height: 16),
                _buildProductCard(
                  icon: Icons.attach_money_rounded,
                  title: 'Foreign Exchange Retention Account A',
                  features: [
                    'Deposit 10% of export earnings (as per NBE directive)',
                    'Use funds to settle obligations in FCY',
                    'Convertible to local currency upon request',
                  ],
                  color: primaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.currency_exchange_rounded,
                  title: 'Foreign Exchange Retention Account B',
                  features: [
                    'Deposit 90% of export proceeds',
                    'Retain for up to 28 days',
                    'Automatically converted to local currency after 28 days',
                  ],
                  color: secondaryBlue,
                ),
                const SizedBox(height: 24),

                // Deposit Products Section
                _buildSectionHeader(
                  title: 'Deposit Products',
                  subtitle: 'Traditional banking products',
                  description: '',
                ),
                const SizedBox(height: 16),
                _buildProductCard(
                  icon: Icons.account_balance_rounded,
                  title: 'Ordinary Demand Deposit',
                  features: [
                    'Non-interest-bearing checking account',
                    'Minimum: Birr 500 (individuals), Birr 1,000 (organizations)',
                    'Cheque book and full transaction access',
                  ],
                  color: primaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Special Demand Deposit',
                  features: [
                    'Interest-bearing checking account',
                    'Lower interest rate than savings',
                    'Very liquid and flexible',
                  ],
                  color: secondaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.savings_rounded,
                  title: 'Regular Savings Account',
                  features: [
                    'Interest-bearing account',
                    'Minimum: Birr 50 (can open with zero)',
                    'ATM card and passbook access',
                  ],
                  color: cyanblueColor,
                ),
                _buildProductCard(
                  icon: Icons.woman_rounded,
                  title: 'Sinqe Women Savings Account',
                  features: [
                    'For women aged 30+',
                    'Better interest rates than regular savings',
                    'No transaction fees',
                  ],
                  color: secondaryColor,
                ),
                _buildProductCard(
                  icon: Icons.school_rounded,
                  title: 'Youth Savings Account',
                  features: [
                    'For youths',
                    'Start saving early',
                    'Earn interest on deposits',
                  ],
                  color: tertiaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.child_care_rounded,
                  title: 'Gamme-Junior Account',
                  features: [
                    'For children',
                    'Managed by parents/guardians',
                    'Builds saving habits',
                  ],
                  color: yellowColor,
                ),
                _buildProductCard(
                  icon: Icons.savings_rounded,
                  title: 'Gudunfa Savings Accounts',
                  features: [
                    'Daily collection via Gudunfa box',
                    'Ideal for small savers',
                    'Disciplined saving approach',
                  ],
                  color: primaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.agriculture_rounded,
                  title: 'Farmers\' Savings Account',
                  features: [
                    'Designed for farmers',
                    'Flexible deposit options',
                    'Accessible banking services',
                  ],
                  color: secondaryBlue,
                ),
                _buildProductCard(
                  icon: Icons.timer_rounded,
                  title: 'Fixed Time Deposit',
                  features: [
                    'Fixed tenure deposits',
                    'Higher returns for longer periods',
                    'Secure investment option',
                  ],
                  color: cyanblueColor,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryBlue.withOpacity(0.1),
            primaryBlue.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: blackColor,
              letterSpacing: 0.3,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.2,
              ),
            ),
          ],
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
Widget _buildProductCard({
  required IconData icon,
  required String title,
  required List<String> features,
  required Color color,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white, // assuming whiteColor = Colors.white
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 1),
        ),
      ],
      border: Border.all(
        color: color.withOpacity(0.15),
        width: 1,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Add tap functionality if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon + Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white, // assuming whiteColor = Colors.white
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // assuming blackColor = Colors.black
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Features list
              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
  // Widget _buildProductCard({
  //   required IconData icon,
  //   required String title,
  //   required List<String> features,
  //   required Color color,
  // }) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     decoration: BoxDecoration(
  //       color: whiteColor,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: color.withOpacity(0.1),
  //           blurRadius: 12,
  //           offset: const Offset(0, 2),
  //           spreadRadius: 0,
  //         ),
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.03),
  //           blurRadius: 8,
  //           offset: const Offset(0, 1),
  //         ),
  //       ],
  //       border: Border.all(
  //         color: color.withOpacity(0.15),
  //         width: 1,
  //       ),
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         borderRadius: BorderRadius.circular(16),
  //         onTap: () {
  //           // Add tap functionality if needed
  //         },
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 children: [
  //                   Container(
  //                     padding: const EdgeInsets.all(10),
  //                     decoration: BoxDecoration(
  //                       gradient: LinearGradient(
  //                         colors: [
  //                           color,
  //                           color.withOpacity(0.7),
  //                         ],
  //                         begin: Alignment.topLeft,
  //                         end: Alignment.bottomRight,
  //                       ],
  //                       borderRadius: BorderRadius.circular(12),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: color.withOpacity(0.3),
  //                           blurRadius: 8,
  //                           offset: const Offset(0, 2),
  //                         ),
  //                       ],
  //                     ),
  //                     child: Icon(
  //                       icon,
  //                       color: whiteColor,
  //                       size: 24,
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: Text(
  //                       title,
  //                       style: const TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.bold,
  //                         color: blackColor,
  //                         letterSpacing: 0.2,
  //                       ),
  //                     ),
  //                   ),
                  
  //               ),
  //               const SizedBox(height: 12),
  //               ...features.map((feature) => Padding(
  //                     padding: const EdgeInsets.only(bottom: 6),
  //                     child: Row(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Container(
  //                           margin: const EdgeInsets.only(top: 6, right: 8),
  //                           width: 5,
  //                           height: 5,
  //                           decoration: BoxDecoration(
  //                             color: color,
  //                             shape: BoxShape.circle,
  //                           ),
  //                         ),
  //                         Expanded(
  //                           child: Text(
  //                             feature,
  //                             style: TextStyle(
  //                               fontSize: 13,
  //                               color: Colors.grey[700],
  //                               height: 1.4,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //               ),
              
  //           ),
  //         );
        
  // }


}
