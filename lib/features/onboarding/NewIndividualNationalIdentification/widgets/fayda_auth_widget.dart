import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/fayda_provider.dart';

class FaydaAuthWidget extends ConsumerWidget {
  const FaydaAuthWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(faydaProvider);
    final notifier = ref.read(faydaProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Fayda Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status indicators
            _buildStatusCard('Connected', state.isConnected),
            _buildStatusCard('Registered', state.isRegistered),
            _buildStatusCard('Completed', state.isCompleted),
            
            const SizedBox(height: 20),
            
            // Action buttons
            if (!state.isConnected) ...[
              ElevatedButton(
                onPressed: state.isLoading ? null : () => _startAuth(notifier),
                child: state.isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Start Authentication'),
              ),
            ],
            
            if (state.authUrl != null && !state.isCompleted) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _openAuthUrl(state.authUrl!),
                child: const Text('Open Authentication URL'),
              ),
              const SizedBox(height: 16),
              const Text('After completing authentication, the result will appear automatically.'),
            ],
            
            const SizedBox(height: 20),
            
            // Error display
            if (state.error != null) ...[
              Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
            
            // User data display
            if (state.userData != null) ...[
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Authentication Successful!', 
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Name: ${state.userData!.name}'),
                      Text('Email: ${state.userData!.email}'),
                      if (state.userData!.phoneNumber != null)
                        Text('Phone: ${state.userData!.phoneNumber}'),
                      if (state.userData!.birthdate != null)
                        Text('Birthdate: ${state.userData!.birthdate}'),
                      if (state.userData!.gender != null)
                        Text('Gender: ${state.userData!.gender}'),
                    ],
                  ),
                ),
              ),
            ],
            
            const Spacer(),
            
            // Reset button
            ElevatedButton(
              onPressed: () => notifier.reset(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, bool isActive) {
    return Card(
      color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isActive ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
      ),
    );
  }

  void _startAuth(FaydaNotifier notifier) {
    // Replace with your actual base URL
    const baseUrl = 'http://10.8.100.210/'; // Example base URL
    notifier.startAuthentication(baseUrl);
  }

  void _openAuthUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
} 