// Example usage of the clean Fayda authentication implementation
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/fayda_auth_widget.dart';
import 'widgets/national_id_auth_widget.dart';

class FaydaAuthExample extends StatelessWidget {
  const FaydaAuthExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Fayda Auth Demo',
        home: const FaydaAuthWidget(),
      ),
    );
  }
}

// Usage in existing stepper flow
class ExistingStepperExample extends ConsumerWidget {
  const ExistingStepperExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('National ID Registration')),
      body: const Column(
        children: [
          // Your existing stepper or other widgets
          Text('Step 1: National ID Authentication'),
          
          // Use the updated national_id_auth_widget
          Expanded(child: NationalIdAuthWidget()),
          
          // Your next/back buttons or other widgets
        ],
      ),
    );
  }
}

/*
SUMMARY OF THE CLEAN IMPLEMENTATION:

Files created/updated:
1. model/national_id_models.dart - Clean data models
2. services/fayda_service.dart - Minimal service handling the exact flow you specified
3. providers/fayda_provider.dart - Clean Riverpod provider
4. widgets/fayda_auth_widget.dart - Standalone widget for testing
5. widgets/national_id_auth_widget.dart - Updated to use the new clean implementation

Flow implemented exactly as requested:
1. Connect to ws://10.8.100.111:9062/ws/fayda
2. Send {"type": "register_client", "clientId": "12344"}
3. Wait for registration_success response
4. Call {{urld}}api/v1/fayda/authenticate-url-ws?clientId=12344
5. Open the returned URL for user authentication
6. Process callback with code and state
7. Listen for authentication_result on WebSocket
8. Complete when type = authentication_result

Usage:
- Use FaydaAuthWidget for standalone testing
- Use updated NationalIdAuthWidget in your existing stepper flow
- Both use the same clean faydaProvider
- Minimal lines of code with proper error handling
- Automatic state management with Riverpod

Configuration:
- Update the baseUrl in the widgets to match your API endpoint
- The WebSocket URL and clientId are already set as per your requirements
*/ 