import 'package:flutter/material.dart';

class Riverpodmodel extends ChangeNotifier {
  int counter;
  Riverpodmodel({
    required this.counter,
  });
  void addCounter() {
    counter++;
    notifyListeners();
  }

  void removeCounter() {
    counter--;
    notifyListeners();
  }
}
