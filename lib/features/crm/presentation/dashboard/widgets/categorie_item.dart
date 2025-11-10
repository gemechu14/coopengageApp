import 'package:flutter/material.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.green),
        ),
        gapW16,
        Text(text),
      ],
    );
  }
}
