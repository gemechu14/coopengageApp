// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:coopengageplus/constants/config/config.dart';
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Verifycustomerinfo extends StatefulWidget {
  final Map<String, dynamic> registrationData;
  final String title;
  final String? userId;
  final String? className;

  const Verifycustomerinfo({
    super.key,
    required this.registrationData,
    required this.title,
    this.userId,
    this.className,
  });

  @override
  State<Verifycustomerinfo> createState() => _VerifycustomerinfoState();
}

class _VerifycustomerinfoState extends State<Verifycustomerinfo> {
  String? accountNumber;
  bool isLoading = false;
  bool _obscureAccount = true;

  String get currentAccountNumber {
    return widget.registrationData['accountNumber'] ?? accountNumber ?? '';
  }

  String get displayAccount {
    final fullAccount = currentAccountNumber;
    if (fullAccount.isEmpty) return '';
    if (_obscureAccount) {
      return fullAccount.replaceRange(
          2, fullAccount.length, '*' * (fullAccount.length - 2));
    } else {
      return fullAccount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAccountNumber = currentAccountNumber.isNotEmpty;

    return Scaffold(
      // backgroundColor: Color(colors.white),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 25,
              color: Colors.blue,
            ),
            onPressed: () {
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => MainPage()),
              //   (route) => false,
              // );
              Navigator.pop(context);
            },
          ),
        ),
        title: const Text(
          'Verify Customer Info',
          style: TextStyle(
              color: Colors.blue, fontSize: 19, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          isLoading
              ? Expanded(
                  child: const Center(
                      child: Center(child: CircularProgressIndicator())))
              : hasAccountNumber
                  ? Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.blue,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 28.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name: ${widget.registrationData['fullName'].toString().toUpperCase()}",
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'arial',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    displayAccount,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: Icon(
                                      _obscureAccount
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureAccount = !_obscureAccount;
                                      });
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search_off,
                                size: 80, color: Colors.blue),
                            SizedBox(height: 16),
                            Text(
                              'No account number yet',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
        ],
      ),
      bottomNavigationBar: hasAccountNumber
          ? const SizedBox.shrink()
          : BottomAppBar(
              elevation: 10,
              color: Colors.transparent,
              shape: const CircularNotchedRectangle(),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : fetchAccountNumber,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text(
                      'Get Account Number',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> fetchAccountNumber() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: "token");

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authorization token is missing.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final accountId = widget.registrationData['accountId'];
      final url = Uri.parse(
          '${AppConstants.baseURL}/api/v1/accounts/$accountId/verify-account');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              token.startsWith('Bearer ') ? token : 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetchedAccountNumber = data['accountNumber'];

        setState(() {
          accountNumber = fetchedAccountNumber;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to verify account',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
