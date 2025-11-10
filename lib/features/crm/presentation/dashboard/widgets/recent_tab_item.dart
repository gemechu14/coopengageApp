import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:coopengageplus/shared/widgets/text/CustomText.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';

class RecentTabItem extends StatefulWidget {
  const RecentTabItem(
      {super.key, required this.showFutureActivities, required this.title});
  final bool showFutureActivities;
  final String title;
  @override
  State<RecentTabItem> createState() => _RecentTabItemState();
}

class _RecentTabItemState extends State<RecentTabItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          CustomText(
            text: widget.title,
            fontSize: Sizes.p14,
            fontWeight: FontWeight.w600,
            fontColor: widget.showFutureActivities ? blackColor : textColor,
          ),
          Container(
            width: 10.w,
            height: 10.h,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    widget.showFutureActivities ? backgroundColor : blackColor),
          )
        ],
      ),
      onTap: () {
        setState(() {
          widget.showFutureActivities != widget.showFutureActivities;
        });
      },
    );
  }
}
