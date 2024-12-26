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
        return true; // Prevent the default back action
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Help"),
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
                (route) => false,
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Interest Free Deposit Products',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Wadiah Saving Account',
                description:
                    'The term Wadiah is derived from the verb "Wadi’ah," meaning to leave, lodge, or deposit. The bank keeps the funds of depositors in its safe custody for safety and convenience.',
                ageRange: 'Any age',
                minimumBalance: 'Birr 50.00',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Wadiah Current Account',
                description:
                    'A non-profit bearing account for literate customers. A minimum balance of Birr 500 is required for individual customers, and Birr 1000 for corporate customers.',
                ageRange: 'Any age',
                minimumBalance: 'Birr 500 (individuals), Birr 1000 (corporate)',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Labbaik Wadiah Saving Account',
                description:
                    'A type of forced saving account for Hajji & Umrah pilgrimage. The account tenure ranges from 1-3 years for Umrah and 5-15 years for Hajji.',
                ageRange: 'For those who intend to perform pilgrimage',
                minimumBalance: 'Not applicable',
              ),
              SizedBox(height: 10),
              _buildSection(
                title:
                    'Ethiopian Commodity Exchange (ECX) Wadi’ah Current Accounts',
                description:
                    'These accounts are opened for the members of the Ethiopian Commodity Exchange to facilitate commodity trading.',
                ageRange: 'Any age',
                minimumBalance: 'Varies per exchange rules',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Gammee-Junior Wadiah Saving Account',
                description:
                    'A savings account for children between 0-15 years, managed by parents/guardians until the child reaches 18.',
                ageRange: '0-15 years',
                minimumBalance: 'Birr 0',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Mudarabah Saving Accounts',
                description:
                    'Mudarabah is a partnership in profit and loss sharing where one party provides capital, and the bank offers management.',
                ageRange: 'Any age',
                minimumBalance: 'Varies based on the bank\'s terms',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Sinqe – Women Mudarabah Saving Account',
                description:
                    'This account is for women aged 30 and above, with a higher profit-sharing ratio compared to ordinary Mudarabah accounts.',
                ageRange: '30+ years',
                minimumBalance: 'Varies based on the bank\'s terms',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Dargago -Youth Mudarabah Saving Account',
                description:
                    'Designed for youth aged 15-29, particularly for students, with a better profit-sharing ratio.',
                ageRange: '15-29 years',
                minimumBalance: 'Varies based on the bank\'s terms',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Gammee – Junior Mudarabah Saving Account',
                description:
                    'A savings account for children 0-15 years, managed by the parents/guardian, with a higher profit-sharing ratio.',
                ageRange: '0-15 years',
                minimumBalance: 'Birr 0',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Cooperatives Mudarabah Saving Account',
                description:
                    'This account is for cooperative associations of individuals for mutual benefits in business enterprises.',
                ageRange: 'Any age',
                minimumBalance: 'Varies based on the bank\'s terms',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Labbaik Mudarabah Saving Account',
                description:
                    'A saving account for Hajji and Umrah Pilgrimage with higher profit sharing compared to ordinary Mudarabah saving accounts.',
                ageRange: 'For those intending pilgrimage',
                minimumBalance: 'Varies based on the bank\'s terms',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Gudunfa Saving Account',
                description:
                    'A Wadi’ah saving account using a designated box for petty traders and low-income workers.',
                ageRange: 'Any age',
                minimumBalance: 'Varies based on the bank\'s terms',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Mudarabah Investment/Time Deposit Accounts',
                description:
                    'A type of investment account where funds are locked for an agreed period and profit is shared based on the bank\'s performance.',
                ageRange: 'Any age',
                minimumBalance: 'Varies based on the bank\'s terms',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'IFB Foreign Currency Deposit Products',
                description:
                    'Foreign currency accounts for customers living abroad or foreign nationals of Ethiopian origin, available in USD, Pound Sterling, or Euro.',
                ageRange: 'Any age',
                minimumBalance: 'Varies based on the bank\'s terms',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Diaspora Wadi’ah (Safe Keeping) Saving Account',
                description:
                    'A safe-keeping saving account for Diaspora Ethiopians or foreign nationals of Ethiopian origin.',
                ageRange: 'For Diaspora Ethiopians',
                minimumBalance: 'Varies based on the bank\'s terms',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Wadi’ah Retention Accounts',
                description:
                    'Retention accounts opened by exporters, with deposits from export proceeds.',
                ageRange: 'Exporters or any individual exporter',
                minimumBalance: 'Varies based on the bank\'s terms',
              ),
              SizedBox(height: 10),
              _buildSection(
                title: 'Foreign Exchange Retention Account A & B',
                description:
                    'Foreign exchange retention accounts for exporters, with specific deposit percentages to be held in foreign currency.',
                ageRange: 'Exporters or any individual exporter',
                minimumBalance: 'Varies based on the bank\'s terms',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required String ageRange,
    required String minimumBalance,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        // Text(
        //  'Description:',
        //    style: TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.bold,
        //     color: Colors.black87,
        //   ),
        // ),
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Age Range:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          ageRange,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Minimum Balance:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          minimumBalance,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
