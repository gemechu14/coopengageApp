import 'package:flutter/material.dart';
import '../constants/dashboard_constants.dart';

/// Stat Card Widget
/// Displays a statistic with title, icon, and count
class StatCard extends StatelessWidget {
  final String title;
  final String count;
  final bool isLoading;
  final double titleFontSize;
  final double valueFontSize;
  final double iconSize;
  final VoidCallback onTap;

  const StatCard({
    Key? key,
    required this.title,
    required this.count,
    required this.isLoading,
    required this.titleFontSize,
    required this.valueFontSize,
    required this.iconSize,
    required this.onTap,
    // required Widget countWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconData = DashboardConstants.statusIcons[title] ?? Icons.error;
    final iconColor = DashboardConstants.iconColors[title] ?? Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: DashboardConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(DashboardConstants.cardBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DashboardConstants.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(iconData, iconColor),
              const Spacer(),
              _buildCount(iconColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(IconData iconData, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: Icon(
            iconData,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCount(Color iconColor) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Text(
          isLoading ? DashboardConstants.loadingPlaceholder : count,
          key: ValueKey<String>(isLoading ? 'loading' : 'value_$count'),
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
