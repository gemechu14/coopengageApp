import 'package:flutter/material.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:coopengageplus/core/constants/text_styles.dart';

class LinkButton extends StatelessWidget {
  const LinkButton({super.key, required this.action});
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action,
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: Sizes.p8, horizontal: Sizes.p10),
        decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(Sizes.p10)),
        child: Text(
          "View All",
          style: linkStyle,
        ),
      ),
    );
  }
}
