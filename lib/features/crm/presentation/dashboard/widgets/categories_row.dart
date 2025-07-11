// import 'package:crm/common_widgets/text/CustomText.dart';
// import 'package:crm/constants/app_sizes.dart';
// import 'package:crm/features/CRM/widgets/pie_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/features/crm/presentation/widgets/pie_chart.dart';

class SegementationCategory extends ConsumerWidget {
  const SegementationCategory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      flex: 3,
      child: Column(
        children: [
          // CategoryItem(
          //   text: "Small Bussiness",
          // )
          gapH12,
          for (var category in kCategories)
            ExpenseCategory(
                text: category.name, index: kCategories.indexOf(category))
        ],
      ),
    );
  }
}

// class ExpenseCategory extends StatelessWidget {
//   const ExpenseCategory({
//     Key? key,
//     required this.index,
//     required this.text,
//   }) : super(key: key);

//   final int index;
//   final String text;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 10),
//       child: Row(
//         children: <Widget>[
//           Container(
//             width: 7,
//             height: 7,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color:
//                   kNeumorphicColors.elementAt(index % kNeumorphicColors.length),
//             ),
//           ),
//           SizedBox(width: 20),
//           FittedBox(
//             child: CustomText(
//               text: text.capitalize(),
//               fontWeight: FontWeight.w400,
//               fontSize: Sizes.p14,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

class ExpenseCategory extends StatelessWidget {
  const ExpenseCategory({
    Key? key,
    required this.index,
    required this.text,
  }) : super(key: key);

  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kNeumorphicColors.elementAt(index %
                  kNeumorphicColors
                      .length), // Set a default color or define a list if needed
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text.capitalize(),
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: Sizes.p14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1, // Ensures the text doesn't exceed a single line
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
