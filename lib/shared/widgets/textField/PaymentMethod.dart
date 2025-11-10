import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentMethodWidget extends StatefulWidget {
  final TextEditingController initialDepositController;
  final TextEditingController phoneNumberController;

  PaymentMethodWidget({
    required this.initialDepositController,
    required this.phoneNumberController,
  });

  @override
  _PaymentMethodWidgetState createState() => _PaymentMethodWidgetState();
}

class _PaymentMethodWidgetState extends State<PaymentMethodWidget> {
  String? selectedPaymentMethod;
  bool isBankTransferSelected = false;
  bool isBankTransferIconClicked = false;
  String phoneNumber = '';
  String amount = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: Column(
        children: [
          // Payment Method Dropdown
          DropdownButtonFormField<String>(
            value: selectedPaymentMethod,
            hint: const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 13, color: Colors.black),
            ),
            items: ['Cash', 'Transfer'].map((String method) {
              return DropdownMenuItem<String>(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: (String? newMethod) {
              setState(() {
                selectedPaymentMethod = newMethod;
                isBankTransferSelected = newMethod == 'Transfer';
                isBankTransferIconClicked = false; // Reset icon click state
              });
            },
            validator: (String? value) {
              if (value == null) {
                return 'Please select a payment method';
              }
              return null;
            },
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.black),
              ),
              prefixIcon: Icon(Icons.payment),
            ),
          ),
          const SizedBox(height: 10),

          if (isBankTransferSelected)
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isBankTransferIconClicked =
                          !isBankTransferIconClicked; // Toggle fields visibility
                    });
                  },
                  child: Image.asset(
                    'assets/ebirr.png',
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 10),
                if (isBankTransferIconClicked) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
                    child: TextFormField(
                      controller: widget.phoneNumberController,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Only allow numbers
                        LengthLimitingTextInputFormatter(9),
                      ],
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: "Phone Number",
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 10.0), // Adjust padding as needed
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
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
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            '+251',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the phone number';
                        } else if (value.length != 9) {
                          return 'Phone number must be 9 digits';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          phoneNumber = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
                    child: TextFormField(
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      controller: widget.initialDepositController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        isDense: true,
                        hintText: "Amount",
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
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(top: 10, left: 3),
                          child: Text('ETB', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the amount';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          amount = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print("Phone Number: $phoneNumber, Amount: $amount");
                      },
                      child: Text('Send'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue, // White text
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
