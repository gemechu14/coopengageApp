import 'package:coopengageplus/features/onboarding/corporate/corporateAccount.dart';
import 'package:coopengageplus/features/onboarding/jointaccount/jointAccount.dart';
import 'package:coopengageplus/features/onboarding/Indivudualaccount/CustomerRegistrationScreen.dart';
import 'package:flutter/material.dart';

class AccountOpeningHomePage extends StatefulWidget {
  @override
  State<AccountOpeningHomePage> createState() => _AccountOpeningHomePageState();
}

class _AccountOpeningHomePageState extends State<AccountOpeningHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Account Type",
          style: TextStyle(
              fontSize: 19, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50),
              _buildAccountCard(
                color: Colors.blue,
                title: 'Individual Account',
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => RegistrationScreen()),
                  );

                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => C()),
                  //   (route) => false,
                  // );
                  // Handle Individual Account tap
                },
              ),
              SizedBox(height: 16),
              _buildAccountCard(
                color: Colors.green,
                title: 'Joint Account',
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => JointAccountStepperPage()),
                    (route) => false,
                  );
                  // Handle Joint Account tap
                },
              ),
              SizedBox(height: 16),
              _buildAccountCard(
                color: Colors.orange,
                title: 'Corporate Account',
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CorporateRegistration()),
                    (route) => false,
                  );
                  // Handle Corporate Account tap
                },
              ),
              SizedBox(height: 16),
              _buildAccountCard(
                color: Colors.pink,
                title: 'Children Account',
                onTap: () {
                  // Handle Children Account tap
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(
      {required Color color,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
