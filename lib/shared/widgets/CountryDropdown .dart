import 'package:flutter/material.dart';

class CountryDropdown extends StatelessWidget {
  final String selectedCountry;
  final List<String> countries;
  final Function(String?)? onChanged;

  const CountryDropdown({
    Key? key,
    required this.selectedCountry,
    required this.countries,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 3, right: 3),
      child: DropdownButtonFormField<String>(
        value: selectedCountry,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
        items: countries.map((String country) {
          return DropdownMenuItem<String>(
            value: country,
            child: Text(country),
          );
        }).toList(),
        onChanged: onChanged,
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
