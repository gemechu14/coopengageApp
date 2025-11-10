import 'package:flutter/material.dart';
import 'package:coopengageplus/features/onboarding/pages/userInfoList/userListView.dart';
import '../constants/dashboard_constants.dart';
import '../models/dashboard_state.dart';
import 'stat_card.dart';

/// Stats Grid Widget
/// Displays a grid of stat cards
class StatsGrid extends StatelessWidget {
  final DashboardState state;
  final double screenWidth;

  const StatsGrid({
    Key? key,
    required this.state,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = screenWidth >= DashboardConstants.tabletBreakpoint;

    final titleFontSize = DashboardConstants.getTitleFontSize(screenWidth);
    final valueFontSize = DashboardConstants.getValueFontSize(screenWidth);
    final iconSize = DashboardConstants.getIconSize(screenWidth);

    final gridCrossAxisCount = isTablet
        ? DashboardConstants.tabletGridColumns
        : DashboardConstants.mobileGridColumns;
    final cardAspectRatio = isTablet
        ? DashboardConstants.tabletCardAspectRatio
        : DashboardConstants.mobileCardAspectRatio;
    final gridHeight = isTablet
        ? DashboardConstants.tabletGridHeight
        : DashboardConstants.mobileGridHeight;

    final statTitles = [
      DashboardConstants.newApplicants,
      DashboardConstants.awaitingAction,
      DashboardConstants.approved,
      DashboardConstants.rejected,
    ];

    return SizedBox(
      height: gridHeight,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCrossAxisCount,
          childAspectRatio: cardAspectRatio,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemCount: statTitles.length,
        itemBuilder: (context, index) {
          // final title = statTitles[index];
          // final count = state.userCounts.getCountByTitle(title).toString();
          // final isLoading = state.isLoadingCount[title] ?? true;

          final title = statTitles[index];
          final isLoading = state.isLoadingCount[title] ?? true;

          // Show loading first until the provider sets isLoading to false
          final count = isLoading
              ? DashboardConstants.loadingPlaceholder // could be '...' or '⏳'
              : state.userCounts.getCountByTitle(title).toString();

          return StatCard(
            title: title,
            count: count,
            isLoading: isLoading,
            titleFontSize: titleFontSize,
            valueFontSize: valueFontSize,
            iconSize: iconSize,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserListPage(title: title),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
