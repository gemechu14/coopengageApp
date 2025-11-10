import 'package:flutter/material.dart';
import '../constants/dashboard_constants.dart';

/// Dashboard Banner Widget
/// Displays a promotional or informational banner
class DashboardBanner extends StatelessWidget {
  const DashboardBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(DashboardConstants.imageBorderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DashboardConstants.imageBorderRadius),
        child: Image.asset(
          DashboardConstants.bannerImage,
          width: screenWidth * 0.9,
          height: 150,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

