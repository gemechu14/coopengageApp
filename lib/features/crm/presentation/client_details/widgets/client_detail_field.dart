import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/widgets/categories_row.dart';
import 'package:coopengageplus/shared/widgets/text/CustomText.dart';
import 'package:flutter/material.dart';



class ClientDetailField extends StatelessWidget {
  const ClientDetailField(
      {super.key, required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: label == "accountNumber"
              ? "Account Number"
              : label == "tinNumber"
                  ? "Tin Number"
                  : label == "accHolderName"
                      ? "Name"
                      : label.capitalize(),
          fontColor: blackColor,
          fontWeight: FontWeight.w600,
          fontSize: Sizes.p16,
        ),
        CustomText(text: value),
      ],
    );
  }
}
