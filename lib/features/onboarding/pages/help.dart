
import 'package:coopengageplus/pages/MainPage.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
          (route) => false,
        );
        return true; 
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Help & Products"),
          backgroundColor: Colors.blue.shade700,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
                (route) => false,
              );
            
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Interest Free Deposit Products',
              // style: Theme.of(context).textTheme.bodyMedium.(
              //       fontWeight: FontWeight.bold,
              //       color: Colors.blue.shade800,
              //     ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.savings,
              title: 'Wadiah Saving Account',
              description:
                  'The term Wadiah is derived from the verb "Wadi’ah," meaning to leave, lodge, or deposit. The bank keeps the funds of depositors in its safe custody for safety and convenience.',
              ageRange: 'Any age',
              minimumBalance: 'Birr 50.00',
            ),
            _buildSection(
              icon: Icons.account_balance,
              title: 'Wadiah Current Account',
              description:
                  'A non-profit bearing account for literate customers. A minimum balance of Birr 500 is required for individual customers, and Birr 1000 for corporate customers.',
              ageRange: 'Any age',
              minimumBalance: 'Birr 500 (individuals), Birr 1000 (corporate)',
            ),
            _buildSection(
              icon: Icons.mosque,
              title: 'Labbaik Wadiah Saving Account',
              description:
                  'A type of forced saving account for Hajji & Umrah pilgrimage. The account tenure ranges from 1-3 years for Umrah and 5-15 years for Hajji.',
              ageRange: 'For those who intend to perform pilgrimage',
              minimumBalance: 'Not applicable',
            ),
            _buildSection(
              icon: Icons.groups,
              title: 'Gammee-Junior Wadiah Saving Account',
              description:
                  'A savings account for children between 0-15 years, managed by parents/guardians until the child reaches 18.',
              ageRange: '0-15 years',
              minimumBalance: 'Birr 0',
            ),
            // 👉 You can continue adding all other accounts here
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String description,
    required String ageRange,
    required String minimumBalance,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(icon, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.cake, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Age Range: $ageRange",
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Minimum Balance: $minimumBalance",
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
