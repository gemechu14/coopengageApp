import 'package:flutter/material.dart';

class EmailWidget extends StatelessWidget {
  final TextEditingController emailController;

  const EmailWidget({Key? key, required this.emailController})
      : super(key: key);

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    // Regular expression for email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid email address.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: "Enter Email",
          labelStyle: TextStyle(fontSize: 5),
          hintStyle: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.blue),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
          prefixIcon: Icon(Icons.email),
        ),
        controller: emailController,
        validator: _validateEmail,
      ),
    );
  }
}
