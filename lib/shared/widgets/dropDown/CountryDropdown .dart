import 'package:flutter/material.dart';

class CountryDropdown extends StatefulWidget {
  final String selectedCountry;
  final Function(String) onCountryChanged;

  const CountryDropdown({
    Key? key,
    required this.selectedCountry,
    required this.onCountryChanged,
  }) : super(key: key);

  @override
  _CountryDropdownState createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: DropdownButtonFormField<String>(
        value: widget.selectedCountry,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
        items: ['Ethiopia'].map((String country) {
          return DropdownMenuItem<String>(
            value: country,
            child: Text(country),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            widget.onCountryChanged(newValue); // Call the parent function
          }
        },
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black),
          ),
          prefixIcon: Icon(Icons.public),
        ),
      ),
    );
  }
}
