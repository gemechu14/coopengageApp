// import 'package:coopengageplus/features/auth/login/login_state.dart';
// import 'package:coopengageplus/pages/MainPage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../common_widgets/AlertDialog/dialog_helper.dart';
// import 'login_controller.dart';
// import 'widgets/login_form.dart';

// class LoginScreen extends ConsumerWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.listen<LoginState>(loginControllerProvider, (previous, next) {
//       if (next is LoginError) {
//         DialogHelper.show(
//           context,
//           title: "Coop Engage+",
//           message: next.message,
//           type: DialogType.error,
//         );
//       } else if (next is LoginSuccess) {
//         Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => const MainPage()));
//       }
//     });

//     final state = ref.watch(loginControllerProvider);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             const LoginForm(),
//             if (state is LoginLoading)
//               const Center(
//                 child: CircularProgressIndicator(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
