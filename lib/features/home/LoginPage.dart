// ignore_for_file: sized_box_for_whitespace, use_build_context_synchronously, unused_local_variable

import 'dart:async';
import 'package:coopengageplus/core/network/network_handler.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../NetworkHandler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// Import your database helper here

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isApiCallProcess = false;
  bool hidePassword = true;
  late String errorText;
  bool validate = false;
  bool circular = false;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          colors: [Color.fromARGB(255, 20, 169, 75), Colors.red],
        )),
        child: Scaffold(
          body: ProgressHUD(
            key: UniqueKey(),
            inAsyncCall: isApiCallProcess,
            child: Form(
              key: globalFormKey,
              child: _loginUI(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginUI(BuildContext context) {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      ),
    );
    double width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 70),
          Column(
            children: [
              Image.asset(
                "assets/engage.png",
                width: MediaQuery.of(context).size.width * 0.5,
                height: 150,
                fit: BoxFit.fill,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 30, right: 20),
            child: Text(
              "Coop Engage +",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: Color.fromARGB(255, 2, 107, 142)),
            ),
          ),
          const SizedBox(height: 10),

          // Username Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: SizedBox(
              width: width < 600
                  ? double.infinity
                  : width * 0.5, // Adjust width for tablet
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: "Username",
                  labelText: "Username",
                  labelStyle: TextStyle(fontSize: 20),
                  contentPadding: EdgeInsets.fromLTRB(20, 2, 2, 4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  prefixIcon: Icon(Icons.person), // Leading icon
                ),
                controller: _username,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null;
                },
              ),
            ),
          ),

          // Password Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Container(
              width: width < 600
                  ? double.infinity
                  : width * 0.5, // Adjust width for tablet
              child: TextFormField(
                obscureText: hidePassword,
                decoration: InputDecoration(
                  hintText: "Password",
                  labelText: "Password",
                  // fillColor: Colors.grey,
                  // filled: true,

                  suffixIcon: IconButton(
                    icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                  labelStyle: const TextStyle(fontSize: 20),
                  contentPadding: const EdgeInsets.fromLTRB(20, 2, 2, 4),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  prefixIcon: const Icon(Icons.lock), // Leading icon
                ),
                controller: _password,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty';
                  }
                  return null;
                },
              ),
            ),
          ),


     
        ],
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print("Connectivity Result: $connectivityResult"); // Debugging line

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      print("Hello from: $connectivityResult");
      return true; // The device is online
    }

    return false; // The device is offline
  }
}
