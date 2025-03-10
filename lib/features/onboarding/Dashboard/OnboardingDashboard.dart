import 'package:flutter/material.dart';

class OnboardingDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            _buildCard('Individual Account', Icons.person),
            _buildCard('Joint Account', Icons.group),
            _buildCard('Corporate Account', Icons.business),
            _buildCard('Children Account', Icons.child_care),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}