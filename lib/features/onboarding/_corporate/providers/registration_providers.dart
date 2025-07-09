import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/corporate_registration_form.dart';

class CorporateRegistrationNotifier extends StateNotifier<CorporateRegistrationForm> {
  CorporateRegistrationNotifier() : super(CorporateRegistrationForm());

  void updateField(String key, dynamic value) {
    state = state.copyWith(
      companyName: key == 'companyName' ? value : state.companyName,
      email: key == 'email' ? value : state.email,
      phoneNumber: key == 'phoneNumber' ? value : state.phoneNumber,
      dateOfEstablishment: key == 'dateOfEstablishment' ? value : state.dateOfEstablishment,
      residence: key == 'residence' ? value : state.residence,
      state: key == 'state' ? value : state.state,
      zone: key == 'zone' ? value : state.zone,
      woreda: key == 'woreda' ? value : state.woreda,
      branch: key == 'branch' ? value : state.branch,
      currency: key == 'currency' ? value : state.currency,
      accountType: key == 'accountType' ? value : state.accountType,
      initialDeposit: key == 'initialDeposit' ? value : state.initialDeposit,
      percentageCompleted: key == 'percentageCompleted' ? value : state.percentageCompleted,
      customers: key == 'customers' ? value : state.customers,
      letterOfRequest: key == 'letterOfRequest' ? value : state.letterOfRequest,
      tradeLicense: key == 'tradeLicense' ? value : state.tradeLicense,
      articlesOfAssociation: key == 'articlesOfAssociation' ? value : state.articlesOfAssociation,
      tin: key == 'tin' ? value : state.tin,
    );
  }

  void updateCustomer(int index, Map<String, dynamic> customer) {
    final updatedCustomers = List<Map<String, dynamic>>.from(state.customers);
    if (index < updatedCustomers.length) {
      updatedCustomers[index] = customer;
    } else {
      updatedCustomers.add(customer);
    }
    state = state.copyWith(customers: updatedCustomers);
  }

  void reset() {
    state = CorporateRegistrationForm();
  }
}

final corporateRegistrationProvider = StateNotifierProvider<CorporateRegistrationNotifier, CorporateRegistrationForm>((ref) {
  return CorporateRegistrationNotifier();
});

final companyInfoValidationProvider = StateProvider<Map<String, String?>>((ref) => {}); 