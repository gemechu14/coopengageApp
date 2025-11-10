import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coopengageplus/shared/widgets/text/CustomText.dart';
import 'package:coopengageplus/core/constants/app_sizes.dart';

// class AppointmentDaysCard extends StatefulWidget {
//   const AppointmentDaysCard({super.key, this.listDate});
//   final listDate;

//   @override
//   State<AppointmentDaysCard> createState() => _AppointmentDaysCardState();
// }

// class _AppointmentDaysCardState extends State<AppointmentDaysCard> {
//   static bool selectedDate = false;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedDate != selectedDate;
//         });
//       },
//       child: Container(
//         margin: EdgeInsets.only(top: Sizes.p8, right: Sizes.p8),
//         width: 60,
//         // height: 20.h,
//         decoration: BoxDecoration(
//             color: selectedDate ? primaryColor : whiteColor,
//             // border: Border.all(width: 2, color: primaryColor),
//             borderRadius: BorderRadius.all(Radius.circular(Sizes.p10))),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CustomText(
//               text: DateTime.parse(widget.listDate).day.toString(),
//               fontColor: Color(0xff606980),
//               fontSize: Sizes.p20,
//               fontWeight: FontWeight.w700,
//             ),
//             CustomText(
//               text: DateFormat('EEEE')
//                   .format(DateTime.parse(widget.listDate))
//                   .toString()
//                   .substring(0, 3)
//                   .toUpperCase(),
//               fontColor: Color(0xff606980),
//               fontSize: Sizes.p12,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AppointmentDaysCard extends StatefulWidget {
//   const AppointmentDaysCard({super.key, required this.listDate});
//   final DateTime listDate;

//   @override
//   State<AppointmentDaysCard> createState() => _AppointmentDaysCardState();
// }

// class _AppointmentDaysCardState extends State<AppointmentDaysCard> {
//    bool isSelected = false;
//   int selectedDate = DateTime.now().day;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     selectedDate == DateTime.now().day ? isSelected = true : isSelected = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           isSelected = !isSelected;
//         });
//       },
//       child: Container(
//         margin: EdgeInsets.only(top: Sizes.p8, right: Sizes.p8),
//         width: 60,
//         decoration: BoxDecoration(
//           color: isSelected ? primaryColor : whiteColor,
//           borderRadius: BorderRadius.all(Radius.circular(Sizes.p10)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CustomText(
//               text: widget.listDate.day.toString(),
//               fontColor: isSelected ? Colors.white : Color(0xff606980),
//               fontSize: Sizes.p20,
//               fontWeight: FontWeight.w700,
//             ),
//             CustomText(
//               text: DateFormat('EEEE')
//                   .format(widget.listDate)
//                   .substring(0, 3)
//                   .toUpperCase(),
//               fontColor: isSelected ? Colors.white : Color(0xff606980),
//               fontSize: Sizes.p12,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
class AppointmentDaysCard extends StatelessWidget {
  const AppointmentDaysCard({
    Key? key,
    required this.listDate,
    required this.isSelected,
    required this.onDateSelected,
  }) : super(key: key);

  final DateTime listDate;
  final bool isSelected;
  final Function(DateTime) onDateSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onDateSelected(listDate);
      },
      child: Container(
        margin: EdgeInsets.only(top: Sizes.p8, right: Sizes.p8),
        width: 60,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(Sizes.p10)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFF2196F3).withOpacity(0.5),
                    blurRadius: 15, // Increase blur for a more floating effect
                    spreadRadius: 2, // Increase spread for elevation effect
                    offset: Offset(0, 8), // Slight upward lift
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: DateFormat('MMM')
                  .format(listDate)
                  .substring(0, 3)
                  .toUpperCase(),
              fontColor: isSelected ? Colors.white : Color(0xff606980),
              fontSize: Sizes.p8,
            ),
            CustomText(
              text: listDate.day.toString(),
              fontColor: isSelected ? Colors.white : Color(0xff606980),
              fontSize: Sizes.p20,
              fontWeight: FontWeight.w700,
            ),
            CustomText(
              text: DateFormat('EEEE')
                  .format(listDate)
                  .substring(0, 3)
                  .toUpperCase(),
              fontColor: isSelected ? Colors.white : Color(0xff606980),
              fontSize: Sizes.p12,
            ),
          ],
        ),
      ),
    );
  }
}
