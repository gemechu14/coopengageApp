import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/constants/text_styles.dart';
import 'package:coopengageplus/features/crm/presentation/client_details/client_details.dart';

class PriorityClientCard extends StatelessWidget {
  const PriorityClientCard({super.key, this.content});
  final content;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          // Get.to(() => ClientDetails());
        },
        child: Container(
          width: 150,
          margin: EdgeInsets.all(Sizes.p8),
          padding: EdgeInsets.all(Sizes.p8), // Adjust card width
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              // BoxShadow(
              //   color: Colors.grey.shade200,
              //   offset: Offset(4, 4),
              //   blurRadius: 8,
              //   spreadRadius: 2,
              // ),
            ],
            color: Colors.white,
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/user.jpg",
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 5,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: content["priority"] == "High"
                        ? Colors.redAccent
                        : content["priority"] == "Medium"
                            ? Colors.amber
                            : Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "${content["priority"]}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 5,
                right: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${content["name"]}", style: nameStyle),
                    SizedBox(height: 2),
                    Text(
                      "${content["reason"]}",
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(
                        fontSize: Sizes.p12,
                        color: Colors.grey,
                      )),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
