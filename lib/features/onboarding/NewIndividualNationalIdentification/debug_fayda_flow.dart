// Debug widget to track the Fayda authentication flow with detailed logging
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/fayda_provider.dart';
import 'widgets/national_id_auth_widget.dart';

class DebugFaydaFlow extends ConsumerStatefulWidget {
  const DebugFaydaFlow({Key? key}) : super(key: key);

  @override
  ConsumerState<DebugFaydaFlow> createState() => _DebugFaydaFlowState();
}

class _DebugFaydaFlowState extends ConsumerState<DebugFaydaFlow> {
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    print('🐛 [DebugWidget] Debug widget initialized');
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String().split('T')[1].split('.')[0]} - $message');
    });
    print('🐛 [DebugWidget] $message');
  }

  @override
  Widget build(BuildContext context) {
    final faydaState = ref.watch(faydaProvider);
    final faydaNotifier = ref.read(faydaProvider.notifier);

    // Log state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addLog('State: loading=${faydaState.isLoading}, connected=${faydaState.isConnected}, '
          'registered=${faydaState.isRegistered}, completed=${faydaState.isCompleted}, '
          'hasAuthUrl=${faydaState.authUrl != null}, hasError=${faydaState.error != null}, '
          'hasUserData=${faydaState.userData != null}');
      
      _addLog('WebSocket: ${faydaNotifier.isWebSocketConnected ? "CONNECTED" : "DISCONNECTED"}');
      
      if (faydaState.error != null) {
        _addLog('ERROR: ${faydaState.error}');
      }
      
      if (faydaState.userData != null) {
        _addLog('USER DATA: ${faydaState.userData!.name} (${faydaState.userData!.email})');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Fayda Flow'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _addLog('=== RESET TRIGGERED ===');
              faydaNotifier.reset();
              setState(() => _logs.clear());
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() => _logs.clear());
              _addLog('Logs cleared');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Debug controls
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.purple.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Debug Controls & Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildStatusChip('Loading', faydaState.isLoading, Colors.orange),
                    _buildStatusChip('Connected', faydaState.isConnected, Colors.blue),
                    _buildStatusChip('Registered', faydaState.isRegistered, Colors.green),
                    _buildStatusChip('WebSocket', faydaNotifier.isWebSocketConnected, Colors.purple),
                    _buildStatusChip('Auth URL', faydaState.authUrl != null, Colors.indigo),
                    _buildStatusChip('Completed', faydaState.isCompleted, Colors.teal),
                    _buildStatusChip('Error', faydaState.error != null, Colors.red),
                    _buildStatusChip('User Data', faydaState.userData != null, Colors.amber),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _addLog('=== MANUAL START AUTHENTICATION ===');
                        faydaNotifier.startAuthentication('http://10.8.100.111:9062/');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Start Auth'),
                    ),
                    const SizedBox(width: 8),
                    if (faydaState.error != null && faydaNotifier.isWebSocketConnected)
                      ElevatedButton(
                        onPressed: () {
                          _addLog('=== MANUAL RETRY CALLBACK ===');
                          // For demo, use dummy values
                          faydaNotifier.processCallback('http://10.8.100.111:9062/', 'test_code', 'test_state');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text('Retry Callback'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Main widget
          const Expanded(
            flex: 2,
            child: NationalIdAuthWidget(),
          ),
          
          // Debug logs
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey.shade800,
                    child: const Text(
                      'Debug Logs (Real-time)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      reverse: true, // Show newest logs at top
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[_logs.length - 1 - index];
                        Color textColor = Colors.white;
                        
                        if (log.contains('ERROR')) {
                          textColor = Colors.red.shade300;
                        } else if (log.contains('SUCCESS') || log.contains('✅')) {
                          textColor = Colors.green.shade300;
                        } else if (log.contains('WARNING') || log.contains('⚠️')) {
                          textColor = Colors.orange.shade300;
                        } else if (log.contains('WebSocket')) {
                          textColor = Colors.purple.shade300;
                        } else if (log.contains('State:')) {
                          textColor = Colors.blue.shade300;
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              color: textColor,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade600,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      backgroundColor: isActive ? color : Colors.grey.shade200,
      side: BorderSide(
        color: isActive ? color : Colors.grey.shade400,
        width: 1,
      ),
    );
  }
}

/*
DEBUG WIDGET FEATURES:

✅ Real-time Status Indicators:
- Loading, Connected, Registered, WebSocket, Auth URL, Completed, Error, User Data

✅ Live Debug Logs:
- Timestamped logs with color coding
- Real-time state changes
- WebSocket connection status
- Error messages and user data

✅ Manual Controls:
- Start authentication manually
- Retry callback if WebSocket is connected
- Reset flow
- Clear logs

✅ Visual Flow Tracking:
- Shows current step in the authentication process
- Highlights WebSocket connection status
- Color-coded status chips

USAGE:
```dart
import 'debug_fayda_flow.dart';

// Use this for debugging instead of the normal widget
const DebugFaydaFlow()
```

COLOR CODING:
- 🔴 Red: Errors
- 🟢 Green: Success/Completed states
- 🟠 Orange: Warnings/Loading
- 🟣 Purple: WebSocket related
- 🔵 Blue: State changes
- ⚪ White: General logs

This widget will help you see EXACTLY what's happening at each step
and identify where the WebSocket is closing or the callback API is failing.
*/ 