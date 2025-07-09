import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../_corporate/providers/registration_providers.dart';
import '../../_corporate/models/corporate_registration_form.dart';
import '../../_corporate/services/registration_service.dart';

class SubmitButton extends ConsumerWidget {
  const SubmitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(corporateRegistrationProvider);
    final notifier = ref.read(corporateRegistrationProvider.notifier);
    final service = RegistrationService();

    return ElevatedButton(
      onPressed: () async {
        final requestData = {
          'companyName': form.companyName,
          'email': form.email,
          'phoneNumber': form.phoneNumber,
          'dateOfEstablishment': form.dateOfEstablishment,
          'residence': form.residence,
          'state': form.state,
          'zone': form.zone,
          'woreda': form.woreda,
          'branch': form.branch,
          'currency': form.currency,
          'accountType': form.accountType,
          'initialDeposit': form.initialDeposit,
          'percentageCompleted': form.percentageCompleted,
          'customers': form.customers,
          'letterOfRequest': form.letterOfRequest,
          'tradeLicense': form.tradeLicense,
          'articlesOfAssociation': form.articlesOfAssociation,
        };
        final result = await service.registerCustomers(requestData);
        if (result['statusCode'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          notifier.reset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['message']}')),
          );
        }
      },
      child: const Text('Submit Registration'),
    );
  }
} 