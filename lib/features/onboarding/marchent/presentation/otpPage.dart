// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class OtpForm extends StatefulWidget {
//   const OtpForm({Key? key}) : super(key: key);

//   @override
//   State<OtpForm> createState() => _OtpFormState();
// }

// class _OtpFormState extends State<OtpForm> {
//   final List<TextEditingController> _controllers =
//       List.generate(5, (index) => TextEditingController());
//   final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());

//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }

//   Widget _buildOtpBox(int index) {
//     return SizedBox(
//       height: 56,
//       width: 50,
//       child: TextFormField(
//         controller: _controllers[index],
//         focusNode: _focusNodes[index],
//         onChanged: (value) {
//           if (value.isNotEmpty) {
//             if (index < _focusNodes.length - 1) {
//               FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
//             }
//           } else if (value.isEmpty && index > 0) {
//             FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
//           }
//         },
//         onTap: () {
//           // Prevent editing of fields if previous fields are empty
//           for (int i = 0; i < index; i++) {
//             if (_controllers[i].text.isEmpty) {
//               FocusScope.of(context).requestFocus(_focusNodes[i]);
//               break;
//             }
//           }
//         },
//         decoration: const InputDecoration(
//           border: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.black),
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//           ),
//         ),
//         style: Theme.of(context).textTheme.headlineLarge,
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         cursorErrorColor: Colors.red,
//         inputFormatters: [
//           LengthLimitingTextInputFormatter(1),
//           FilteringTextInputFormatter.digitsOnly
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Form(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.only(left: 20, right: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(5, (index) => _buildOtpBox(index)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

// const Color primaryColor = Color(0xFF121212);
// const Color accentPurpleColor = Color(0xFF6A53A1);
// const Color accentPinkColor = Color(0xFFF99BBD);
// const Color accentDarkGreenColor = Color(0xFF115C49);
// const Color accentYellowColor = Color(0xFFFFB612);
// const Color accentOrangeColor = Color(0xFFEA7A3B);

// class VerificationScreen1 extends StatefulWidget {
//   @override
//   _VerificationScreen1State createState() => _VerificationScreen1State();
// }

// class _VerificationScreen1State extends State<VerificationScreen1> {
//   late List<TextStyle?> otpTextStyles;
//   late List<TextEditingController?> controls;
//   int numberOfFields = 5;
//   bool clearText = false;

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//       ),
//       body: Container(
//         padding: const EdgeInsets.only(left: 24, right: 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Verification Code",
//               style: theme.textTheme.titleSmall,
//             ),
//             Text(
//               "We texted you a code",
//               style: theme.textTheme.bodyLarge,
//             ),
//             Text("Please enter it below", style: theme.textTheme.titleSmall),
//             OtpTextField(
//               numberOfFields: numberOfFields,
//               borderColor: Color(0xFF512DA8),
//               focusedBorderColor: primaryColor,
//               clearText: clearText,
//               showFieldAsBox: true,
//               textStyle: theme.textTheme.titleMedium,
//               onCodeChanged: (String value) {
//                 //Handle each value
//               },
//               handleControllers: (controllers) {
//                 //get all textFields controller, if needed
//                 controls = controllers;
//               },
//               onSubmit: (String verificationCode) {}, // end onSubmit
//             ),
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   "This helps us verify every user in our market place",
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.bodyMedium,
//                 ),
//               ),
//             ),
//             Center(
//               child: Text(
//                 "Didn't get code?",
//                 style: theme.textTheme.bodyMedium,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class VerificationScreen2 extends StatefulWidget {
//   @override
//   _VerificationScreen2State createState() => _VerificationScreen2State();
// }

// class _VerificationScreen2State extends State<VerificationScreen2> {
//   late List<TextStyle?> otpTextStyles;

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     otpTextStyles = [
//       createStyle(accentPurpleColor),
//       createStyle(accentYellowColor),
//       createStyle(accentDarkGreenColor),
//       createStyle(accentOrangeColor),
//       createStyle(accentPinkColor),
//       createStyle(accentPurpleColor),
//     ];
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//       ),
//       body: Container(
//         padding: const EdgeInsets.only(left: 24, right: 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Verification Code",
//               style: theme.textTheme.titleSmall,
//             ),
//             SizedBox(height: 16),
//             Text(
//               "We texted you a code",
//               style: theme.textTheme.bodyLarge,
//             ),
//             Text("Please enter it below", style: theme.textTheme.bodyLarge),
//             Spacer(flex: 2),
//             OtpTextField(
//               numberOfFields: 6,
//               borderColor: Colors.black,
//               focusedBorderColor: Colors.black,
//               styles: otpTextStyles,
//               showFieldAsBox: false,
//               borderWidth: 20.0,

//               onCodeChanged: (String code) {},
//               onSubmit: (String verificationCode) {}, // end onSubmit
//             ),
//             Spacer(),
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   "This helps us verify every user in our market place",
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.bodyMedium,
//                 ),
//               ),
//             ),
//             Center(
//               child: Text(
//                 "Didn't get code?",
//                 style: theme.textTheme.bodyMedium,
//               ),
//             ),
//             Spacer(flex: 3),
//             Spacer(flex: 3),
//           ],
//         ),
//       ),
//     );
//   }

//   TextStyle? createStyle(Color color) {
//     ThemeData theme = Theme.of(context);
//     return theme.textTheme.titleSmall?.copyWith(color: color);
//   }
// }
