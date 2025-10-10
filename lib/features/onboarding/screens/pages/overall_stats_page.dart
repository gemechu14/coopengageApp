import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/kconstant.dart';
import '../../../../common_widgets/text/custom_nav_heading.dart';
import '../providers/invitation_provider.dart';

class OverallStatsPage extends ConsumerWidget {
  const OverallStatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(invitationStatsProvider);

    return Scaffold(
      backgroundColor: graybackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: blackColor),
            onPressed: () => Navigator.pop(context),
          ),
          title:  CustomNavHeading(text: 'Overall Statistics'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(invitationStatsProvider);
        },
        color: cyanblueColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: statsAsync.when(
            data: (stats) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Sent',
                        value: stats.totalInvitationsSent.toString(),
                        icon: Icons.send_outlined,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Opened',
                        value: stats.totalEmailsOpened.toString(),
                        icon: Icons.mail_outline,
                        color: secondaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Clicked',
                        value: stats.totalLinksClicked.toString(),
                        icon: Icons.touch_app_outlined,
                        color: tertiaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Registered',
                        value: stats.totalRegistrations.toString(),
                        icon: Icons.check_circle_outline,
                        color: cyanblueColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Rates Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cyanblueColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.analytics_outlined,
                              color: cyanblueColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Performance Rates',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: blackColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildRateRow(
                        'Open Rate',
                        stats.openRate,
                        Icons.visibility_outlined,
                        secondaryBlue,
                      ),
                      const SizedBox(height: 16),
                      _buildRateRow(
                        'Click Rate',
                        stats.clickRate,
                        Icons.ads_click_outlined,
                        tertiaryBlue,
                      ),
                      const SizedBox(height: 16),
                      _buildRateRow(
                        'Conversion Rate',
                        stats.conversionRate,
                        Icons.trending_up_outlined,
                        cyanblueColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Monthly Progress Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: yellowColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calendar_month_outlined,
                              color: yellowColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'This Month',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: blackColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildMonthlyRow(
                        'Invitations Sent',
                        stats.currentMonthSent.toString(),
                        Icons.send_outlined,
                        primaryBlue,
                      ),
                      const SizedBox(height: 12),
                      _buildMonthlyRow(
                        'Monthly Target',
                        stats.currentMonthTarget.toString(),
                        Icons.flag_outlined,
                        secondaryBlue,
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: blackColor,
                                ),
                              ),
                              Text(
                                '${stats.targetProgress.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: cyanblueColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: stats.targetProgress / 100,
                              minHeight: 12,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                stats.targetProgress >= 100
                                    ? cyanblueColor
                                    : stats.targetProgress >= 75
                                        ? tertiaryBlue
                                        : stats.targetProgress >= 50
                                            ? secondaryBlue
                                            : primaryBlue,
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
            loading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(height: 100),
                  CircularProgressIndicator(color: cyanblueColor),
                  SizedBox(height: 16),
                  Text('Loading statistics...'),
                ],
              ),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.error_outline, color: Colors.red[300], size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load statistics',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.refresh(invitationStatsProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cyanblueColor,
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow(String label, double rate, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '${rate.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

