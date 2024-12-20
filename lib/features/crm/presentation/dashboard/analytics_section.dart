import 'package:flutter/material.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/constants/text_styles.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/line_chart.dart';

class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: height * 0.23,
      margin: EdgeInsets.only(
          left: Sizes.p12, right: Sizes.p12, top: 0, bottom: Sizes.p8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200, // Lighter color
            offset: Offset(8, 9), // Reduced offset
            blurRadius: 20, // Reduced blur radius
            spreadRadius: 1, // Reduced spread radius
          ),
          BoxShadow(
            color: Colors.grey.shade300, // Lighter color
            offset: Offset(2, 2), // Reduced offset
            blurRadius: 15, // Reduced blur radius
            spreadRadius: -10, // Reduced spread radius
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        gapH10,
        Padding(
            padding: EdgeInsets.all(Sizes.p10),
            child: Text(
              "Client Interaction",
              style: sectionTitleStyle,
            )),
        gapH12,
        LineChartSample2()
      ]),
    );
  }
}
