import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/constants/text_styles.dart';
import 'package:coopengageplus/features/crm/ListOfCustomers.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/widgets/categories_row.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/widgets/chart.dart';

class CustomerSegementation extends ConsumerStatefulWidget {
  const CustomerSegementation({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomerSegementationState();
}

class _CustomerSegementationState extends ConsumerState<CustomerSegementation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Sizes.p16),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // gapH12,
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              "Customer Segementation",
              style: sectionTitleStyle,
            ),
            IconButton(
                onPressed: () {
                  Get.to(() => Listofcustomers());
                },
                icon: const Icon(Icons.chevron_right, color: primaryBlue))
          ]),
          // gapH12,
          const Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [SegementationCategory(), SegementationChart()],
          )),
          gapH10
        ],
      ),
    );
  }
}
