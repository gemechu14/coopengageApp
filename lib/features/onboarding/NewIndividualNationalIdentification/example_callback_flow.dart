// Example demonstrating the improved callback flow with immediate WebView closure
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/national_id_auth_widget.dart';
import 'providers/fayda_provider.dart';

class CallbackFlowExample extends ConsumerWidget {
  const CallbackFlowExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faydaState = ref.watch(faydaProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Improved Callback Flow'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(faydaProvider.notifier).reset(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Flow indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Improved Authentication Flow:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildFlowStep('1. Connect & Register', faydaState.isConnected && faydaState.isRegistered),
                _buildFlowStep('2. Get Auth URL', faydaState.authUrl != null),
                _buildFlowStep('3. User Authentication (WebView)', faydaState.authUrl != null),
                _buildFlowStep('4. Callback Detection & Processing', faydaState.authUrl != null && faydaState.isLoading),
                _buildFlowStep('5. WebSocket Result & Next Step', faydaState.isCompleted),
              ],
            ),
          ),
          
          // Main content
          const Expanded(
            child: NationalIdAuthWidget(),
          ),
          
          // Debug info
          if (faydaState.error != null || faydaState.userData != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: faydaState.error != null ? Colors.red.shade50 : Colors.green.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faydaState.error != null ? 'Error:' : 'Success:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: faydaState.error != null ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    faydaState.error ?? 'Authentication completed for ${faydaState.userData?.name}',
                    style: TextStyle(
                      color: faydaState.error != null ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFlowStep(String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isActive ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.green : Colors.grey.shade600,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/*
IMPROVED CALLBACK FLOW SUMMARY:

✅ IMMEDIATE WEBVIEW CLOSURE:
- Multiple callback detection points (onNavigationRequest, onPageStarted, onUrlChange)
- Immediate NavigationDecision.prevent to stop further navigation
- Instant setState(() => _showWebView = false) when callback detected
- No delay in hiding the WebView

✅ AUTOMATIC STEP PROGRESSION:
1. User completes auth in WebView
2. Callback URL detected instantly → WebView closes immediately
3. "Processing authentication..." indicator shows
4. API callback processed: {{urld}}api/v1/fayda/callback?code=...&state=...
5. WebSocket waits for authentication_result
6. Success message shows briefly: "Authentication successful! Welcome [Name]"
7. Auto-advances to next stepper step

✅ VISUAL FEEDBACK:
- Status indicators show each step completion
- Loading indicator during callback processing
- Success message before step advancement
- Clear error handling with retry options

✅ TECHNICAL IMPROVEMENTS:
- Triple callback detection for reliability
- Immediate state updates
- Proper mounted checks
- Automatic resource cleanup
- Error state handling

FLOW TIMING:
User Auth → Callback Detected (instant) → WebView Closes (instant) → 
API Call → WebSocket Response → Success Message (2s) → Next Step

The WebView now closes IMMEDIATELY when code and state are detected,
and the user sees a smooth transition to the processing state and then
to the next step of the registration flow.
*/ 