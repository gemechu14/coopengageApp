import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberWidget extends StatelessWidget {
  final TextEditingController phoneNumberController;
  final String countryPrefix;
  final bool isRequired;
  final bool greyBoarder;
  final bool isEnabled;
  final bool readOnly; // New parameter for read-only mode
  final Function(String)? onChanged;
  const PhoneNumberWidget({
    Key? key,
    bool? greyBorder,
    required this.phoneNumberController,
    this.countryPrefix = '+251', // Default to Ethiopia
    this.isRequired = true, // Make it optional by default
    this.isEnabled = true,
    this.readOnly = false,
    this.onChanged,
  })  : greyBoarder = greyBorder ?? false, // Default to false if null
        super(key: key);

  String? _validatePhoneNumber(String? value) {
    if (isRequired && (value == null || value.isEmpty)) {
      return 'Phone number is required';
    }
    if (value != null && value.isNotEmpty && value.length != 9) {
      return 'Phone number must be 9 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: TextFormField(
        controller: phoneNumberController,
        enabled: isEnabled && !readOnly,
        readOnly: readOnly,
        keyboardType: TextInputType.phone,
        onChanged: onChanged,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        decoration: InputDecoration(
          filled: readOnly,
          fillColor: readOnly ? Colors.grey[100] : null,
          labelStyle: const TextStyle(fontSize: 5),
          hintStyle: TextStyle(
            fontSize: 13,
            color: readOnly ? Colors.grey[600] : Colors.black,
          ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: readOnly 
                  ? Colors.grey[300]! 
                  : (greyBoarder ? Colors.grey : Colors.black),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: readOnly 
                  ? Colors.grey[300]! 
                  : (greyBoarder ? Colors.grey : Colors.black),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              color: readOnly ? Colors.grey[300]! : Colors.blue
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.red),
          ),
          prefixIcon: Container(
            alignment: Alignment.center,
            width: 50,
            child: Text(
              countryPrefix,
              style: TextStyle(
                color: readOnly ? Colors.grey[600] : Colors.black, 
                fontSize: 14
              ),
            ),
          ),
        ),
        validator: _validatePhoneNumber,
      ),
    );
  }
}


