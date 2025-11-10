import 'package:flutter/material.dart';
import 'package:coopengageplus/shared/widgets/button/link_button.dart';
import 'package:coopengageplus/shared/widgets/text/custom_nav_heading.dart';
import 'package:coopengageplus/shared/widgets/textField/search_field.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/constants/text_styles.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/priority_client.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/recent_activities.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/segementation_section.dart';
import 'package:coopengageplus/core/utils/language_store.dart';

class CRMDashboard extends StatefulWidget {
  const CRMDashboard({super.key});

  @override
  State<CRMDashboard> createState() => _CRMDashboardState();
}

class _CRMDashboardState extends State<CRMDashboard> {
  // Data and colors for the chart
  Map<String, double> dataMap = {
    "Manufacturing": 10,
    "Agriculture": 2,
    "Service": 19,
    // "Construction": 19,
  };

  // Define colors for each business type
  final colorList = <Color>[
    Colors.green, // Small Business
    Colors.red, // Medium Business
    Colors.blue,
    // Colors.amber // Large Business
  ];

  // Total value
  // double totalValue = dataMap.values.reduce((a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: lightBG,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: EdgeInsets.all(Sizes.p10),
          child: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: CustomNavHeading(
              text: translation(context).home,
            ),
            actions: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: whiteColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.1), // Very light shadow
                        blurRadius: 6, // Controls the softness of the shadow
                        spreadRadius: 2, // Controls the size of the shadow
                        offset: const Offset(2, 2), // Position of the shadow
                      ),
                    ],
                  ),
                  height: 45,
                  width: 45,
                  child: const Icon(
                    Icons.notifications,
                    color: primaryBlue,
                    size: Sizes.p24,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: width < 600 ? double.infinity : width * 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SearchField(),
                  SegementationSection(height: height),
                  // gapH10,
                  // AnalyticsSection(),
                  gapH10,
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.p12, vertical: Sizes.p8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recommendation",
                              style: sectionTitleStyle,
                            ),
                            LinkButton(action: () {})
                          ])),
                  gapH10,
                  PriorityClient(),
                  gapH10,
                  RecentActivites(),
                ],
              ),
            ),
          ),
        ),
      ),
      // bottomNavigationBar: GoogleButtomNavBar(
      //   showBottomNavBar: true,
      // // ),
    );
  }
}
