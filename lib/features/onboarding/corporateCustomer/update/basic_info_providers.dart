import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final selectedProductTypeProvider = StateProvider<String?>((ref) => null);
final companyNameControllerProvider = Provider((ref) => TextEditingController());
final phoneNumberControllerProvider = Provider((ref) => TextEditingController());
final emailControllerProvider = Provider((ref) => TextEditingController());
final tinNumberControllerProvider = Provider((ref) => TextEditingController());
final dateOfEstablishmentControllerProvider = Provider((ref) => TextEditingController()); 