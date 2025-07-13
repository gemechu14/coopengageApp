// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:coopengageplus/constants/kconstant.dart';
// import '../providers/stepper_provider.dart';

// class OtpVerificationWidget extends ConsumerWidget {
//   const OtpVerificationWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final stepperState = ref.watch(stepperProvider);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'OTP Verification',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           'Enter the 6-digit OTP sent to your phone number',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey,
//           ),
//         ),
//         const SizedBox(height: 30),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 spreadRadius: 1,
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextFormField(
//             initialValue: stepperState.otpCode,
//             onChanged: (value) =>
//                 ref.read(stepperProvider.notifier).updateOtpCode(value),
//             decoration: InputDecoration(
//               labelText: 'OTP Code',
//               labelStyle: TextStyle(color: Colors.grey.shade600),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: cyanblueColor, width: 2),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: Colors.red.shade300),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//               prefixIcon: Icon(Icons.lock, color: cyanblueColor),
//               hintText: 'e.g., 123456',
//               hintStyle: TextStyle(color: Colors.grey.shade400),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               counterText: '',
//             ),
//             keyboardType: TextInputType.number,
//             maxLength: 6,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter the OTP code';
//               }
//               if (value.length != 6) {
//                 return 'Please enter a 6-digit OTP code';
//               }
//               return null;
//             },
//           ),
//         ),
//         const SizedBox(height: 20),
//         Row(
//           children: [
//             const Text(
//               "Didn't receive OTP? ",
//               style: TextStyle(color: Colors.grey),
//             ),
//             TextButton(
//               onPressed: () {
//                 // TODO: Implement resend OTP
//               },
//               child: const Text(
//                 'Resend OTP',
//                 style: TextStyle(color: cyanblueColor),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
