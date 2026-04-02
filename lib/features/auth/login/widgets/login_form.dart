import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/shared/widgets/app_button.dart';
import 'package:coopengageplus/shared/widgets/app_text_field.dart';

import '../login_controller.dart';
import '../login_state.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  static const _muted = Color(0xFF78909C);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _hidePassword = !_hidePassword;
    });
  }

  void _onSubmit() async {
    final loginState = ref.read(loginControllerProvider);
    if (loginState is LoginLoading) return;

    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      // Pass the model to the controller
      await ref
          .read(loginControllerProvider.notifier)
          .login(username, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final isLoading = loginState is LoginLoading;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;
    final isWide = width >= 600;
    final verticalPadding = height < 700 ? 16.0 : 24.0;
    final maxCardWidth = isWide ? 520.0 : double.infinity;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEFF6FF),
            whiteColor,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? width * 0.12 : 20,
              vertical: verticalPadding,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxCardWidth),
                child: Material(
                  color: whiteColor,
                  elevation: 10,
                  shadowColor: Colors.black.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/coop_engage.png',
                              width: 220,
                              height: 96,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sign in to continue',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: _muted,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Username
                          const _FieldLabel(
                            icon: Icons.person_outline,
                            label: 'Username',
                          ),
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _usernameController,
                            hintText: 'Enter your username',
                            enabled: !isLoading,
                            prefixIcon: Icon(
                              Icons.badge_outlined,
                              color: _muted,
                              size: 20,
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Username cannot be empty'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          const _FieldLabel(
                            icon: Icons.lock_outline,
                            label: 'Password',
                          ),
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _passwordController,
                            hintText: 'Enter your password',
                            enabled: !isLoading,
                            obscureText: _hidePassword,
                            prefixIcon: Icon(
                              Icons.key_outlined,
                              color: _muted,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 19,
                                color: _muted,
                              ),
                              splashRadius: 18,
                              onPressed:
                                  isLoading ? null : _togglePasswordVisibility,
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Password cannot be empty'
                                : null,
                          ),
                          const SizedBox(height: 18),

                          AppButton(
                            label: 'Sign In',
                            isLoading: isLoading,
                            icon: Icons.login_rounded,
                            accentColor: cyanblueColor,
                            onPressed: _onSubmit,
                          ),

                          // Agent registration entry (temporarily disabled)
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     const Text(
                          //       "Want to register as an agent? ",
                          //       style: TextStyle(color: Colors.black, fontSize: 16),
                          //     ),
                          //     TextButton(
                          //       onPressed: () {
                          //         Navigator.pushNamed(context, '/agent-registration');
                          //       },
                          //       child: const Text(
                          //         "Register",
                          //         style: TextStyle(
                          //           color: Colors.blue,
                          //           fontSize: 16,
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: cyanblueColor, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.blueGrey.shade900,
          ),
        ),
      ],
    );
  }
}
