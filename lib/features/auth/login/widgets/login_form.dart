import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../login_controller.dart';

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
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/coop_engage.png',
              width: 210,
              height: 100,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    child: SizedBox(
                      width: width < 600 ? double.infinity : width * 0.5,
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: "Username",
                          contentPadding: EdgeInsets.fromLTRB(20, 2, 2, 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Username cannot be empty'
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    child: SizedBox(
                      width: width < 600 ? double.infinity : width * 0.5,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                          hintText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(_hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: _togglePasswordVisibility,
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 2, 2, 4),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Password cannot be empty'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: SizedBox(
                      width: width < 600 ? double.infinity : width * 0.5,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _onSubmit,
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Want to register as an agent? ",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/agent-registration');
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
