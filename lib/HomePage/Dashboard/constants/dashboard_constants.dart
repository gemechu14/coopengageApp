import 'package:flutter/material.dart';

/// Dashboard Constants
/// Contains all constants, colors, and styles for the dashboard

class DashboardConstants {
  // Card titles
  static const String newApplicants = "New Applicants";
  static const String awaitingAction = "Awaiting Action";
  static const String approved = "Approved";
  static const String rejected = "Rejected";

  // Icon colors for each status
  static const Map<String, Color> iconColors = {
    newApplicants: Colors.blue,
    awaitingAction: Colors.orange,
    approved: Colors.green,
    rejected: Colors.red,
  };

  // Icons for each status
  static const Map<String, IconData> statusIcons = {
    newApplicants: Icons.person_add,
    awaitingAction: Icons.hourglass_bottom,
    approved: Icons.check_circle,
    rejected: Icons.cancel,
  };

  // Responsive breakpoints
  static const double tabletBreakpoint = 600.0;
  static const double smallPhoneBreakpoint = 400.0;
  static const double mediumPhoneBreakpoint = 600.0;
  static const double largePhoneBreakpoint = 800.0;

  // Grid settings
  static const int mobileGridColumns = 2;
  static const int tabletGridColumns = 4;
  static const double mobileCardAspectRatio = 1.7;
  static const double tabletCardAspectRatio = 1.4;

  // Padding
  static const double mobilePadding = 10.0;
  static const double tabletPadding = 13.0;

  // Sizes
  static const double mobileCarouselHeight = 150.0;
  static const double tabletCarouselHeight = 200.0;
  static const double mobileGridHeight = 240.0;
  static const double tabletGridHeight = 240.0;

  // Border radius
  static const double cardBorderRadius = 12.0;
  static const double imageBorderRadius = 16.0;

  // Card elevation
  static const double cardElevation = 5.0;

  // Spacing
  static const double verticalSpacing = 15.0;
  static const double cardPadding = 6.0;
  static const double listTilePadding = 8.0;

  // Sync card colors
  static const Color syncCardBackground = Color.fromARGB(255, 53, 52, 52);
  static const Color syncCardTextColor = Colors.white;
  static const Color syncCardSubtitleColor = Colors.orange;
  static const Color syncButtonColor = Colors.blue;

  // Font sizes (based on screen width)
  static double getTitleFontSize(double screenWidth) {
    if (screenWidth < smallPhoneBreakpoint) return 17;
    if (screenWidth < mediumPhoneBreakpoint) return 17;
    if (screenWidth < largePhoneBreakpoint) return 19;
    return 23;
  }

  static double getValueFontSize(double screenWidth) {
    if (screenWidth < smallPhoneBreakpoint) return 27;
    if (screenWidth < mediumPhoneBreakpoint) return 29;
    if (screenWidth < largePhoneBreakpoint) return 29;
    return 34;
  }

  static double getIconSize(double screenWidth) {
    if (screenWidth < smallPhoneBreakpoint) return 21;
    if (screenWidth < mediumPhoneBreakpoint) return 27;
    if (screenWidth < largePhoneBreakpoint) return 33;
    return 37;
  }

  // Images
  static const String bannerImage = "assets/step3.png";

  // Loading placeholder
  static const String loadingPlaceholder = "-";
}

