import 'package:flutter/material.dart';
import 'package:coopengageplus/shared/widgets/text/CustomText.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({
    super.key,
    required this.type,
    required this.amount,
    this.icon,
    required this.percentage,
    this.pecentageColor,
  });

  final String type;
  final String amount;
  final icon;
  final String percentage;
  final pecentageColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(Sizes.p8)),
      height: 70, // Adjust the height here as needed
      child: ListTile(
        // contentPadding:
        //     EdgeInsets.all(Sizes.p10), // Optional padding for ListTile content
        title: Row(
          children: [
            Container(
              width: Sizes.p12,
              height: Sizes.p12,
              margin: EdgeInsets.only(right: Sizes.p10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pecentageColor,
              ),
            ),
            CustomText(
              text: type,
              fontColor: Colors.grey[500],
              fontSize: Sizes.p12,
            ),
          ],
        ),
        subtitle: CustomText(
          text: amount,
          fontColor: blackColor,
          fontSize: Sizes.p17,
          fontWeight: FontWeight.bold,
        ),
        trailing: SizedBox(
          width: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                icon,
                color: pecentageColor,
                size: Sizes.p32,
              ),
              SizedBox(width: 2),
              CustomText(
                text: percentage,
                fontColor: pecentageColor,
                fontSize: Sizes.p14,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
