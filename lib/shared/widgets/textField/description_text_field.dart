import 'package:flutter/material.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/constants/text_styles.dart';

class DescriptionTextField extends StatelessWidget {
  const DescriptionTextField({
    super.key,
    required this.title,
    required this.hint,
    required this.textEditingController,
    this.widget,
    required this.textInputType,
    this.isDate,
    this.dateAction,
    this.maxLines = 1, // Default maxLines is 1 for single-line input.
  });

  final String title;
  final String hint;
  final TextEditingController textEditingController;
  final TextInputType textInputType;
  final Widget? widget;
  final String? isDate;
  final VoidCallback? dateAction;
  final int maxLines; // Added maxLines property.

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Sizes.p4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: titleStyle,
          ),
          Container(
            margin: EdgeInsets.only(top: Sizes.p4),
            padding: EdgeInsets.only(left: Sizes.p8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(Sizes.p12),
            ),
            child: Row(
              crossAxisAlignment: maxLines > 1
                  ? CrossAxisAlignment
                      .start // Align text at the top for multiline.
                  : CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    onTap: isDate == null ? dateAction : null,
                    autofocus: false,
                    keyboardType: textInputType,
                    readOnly: widget == null ? false : true,
                    cursorColor: Colors.grey[700],
                    controller: textEditingController,
                    style: titleStyle,
                    maxLines: maxLines, // Set the maxLines property here.
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: subtitleStyle,
                      border: InputBorder.none,
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryBlue, width: 0)),
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                widget == null ? Container() : Container(child: widget),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
