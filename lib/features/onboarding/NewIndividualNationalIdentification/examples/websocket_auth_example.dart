import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/national_id_provider.dart';
import '../services/websocket_service.dart';
import '../services/api_service.dart';

/// Example demonstrating WebSocket-based Fayda authentication
class WebSocketAuthExample extends ConsumerStatefulWidget {
  const WebSocketAuthExample({Key? key}) : super(key: key);

  @override
  ConsumerState<WebSocketAuthExample> createState() => _WebSocketAuthExampleState();
}

class _WebSocketAuthExampleState extends ConsumerState<WebSocketAuthExample> {
  String _status = 'Ready';
  Map<String, dynamic>? _authResult;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Auth Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        fontSize: 16,
                        color: _status.contains('Error') ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Authentication buttons
            Row(
              children: [
                                 Expanded(
                   child: ElevatedButton.icon(
                     onPressed: _startWebSocketAuth,
                     icon: const Icon(Icons.wifi),
                     label: const Text('Primary Auth'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.blue,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 12),
                     ),
                   ),
                 ),
                 const SizedBox(width: 8),
                 Expanded(
                   child: ElevatedButton.icon(
                     onPressed: _startTraditionalAuth,
                     icon: const Icon(Icons.web),
                     label: const Text('Alternative Auth'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.green,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 12),
                     ),
                   ),
                 ),
              ],
            ),
            const SizedBox(height: 16),

            // Test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testApiEndpoint,
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Test API'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testWebSocket,
                    icon: const Icon(Icons.wifi_find),
                    label: const Text('Test WebSocket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mode toggle
                         ElevatedButton.icon(
               onPressed: _toggleMode,
               icon: const Icon(Icons.swap_horiz),
               label: Text('Switch to ${ref.watch(nationalIdProvider).useWebSocket ? 'Alternative' : 'Primary'} Mode'),
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.grey,
                 foregroundColor: Colors.white,
                 padding: const EdgeInsets.symmetric(vertical: 12),
               ),
             ),
            const SizedBox(height: 24),

            // Results display
            if (_authResult != null) ...[
              const Text(
                'Authentication Result:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _authResult.toString(),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

     /// Start primary authentication
   Future<void> _startWebSocketAuth() async {
     setState(() {
       _status = 'Starting primary authentication...';
       _error = null;
       _authResult = null;
     });

     try {
       // Set primary mode
       ref.read(nationalIdProvider.notifier).setWebSocketMode(true);
       
       // Start authentication
       ref.read(nationalIdProvider.notifier).callEsignetApi();
       
       setState(() {
         _status = 'Primary authentication initiated';
       });
     } catch (e) {
       setState(() {
         _status = 'Error starting primary auth';
         _error = e.toString();
       });
     }
   }

   /// Start alternative authentication
   Future<void> _startTraditionalAuth() async {
     setState(() {
       _status = 'Starting alternative authentication...';
       _error = null;
       _authResult = null;
     });

     try {
       // Set alternative mode
       ref.read(nationalIdProvider.notifier).setWebSocketMode(false);
       
       // Start authentication
       ref.read(nationalIdProvider.notifier).callEsignetApi();
       
       setState(() {
         _status = 'Alternative authentication initiated';
       });
     } catch (e) {
       setState(() {
         _status = 'Error starting alternative auth';
         _error = e.toString();
       });
     }
   }

  /// Test API endpoint
  Future<void> _testApiEndpoint() async {
    setState(() {
      _status = 'Testing API endpoint...';
      _error = null;
    });

    try {
      final result = await ApiService.testApiEndpoint();
      
      setState(() {
        _status = result.isSuccess 
          ? 'API test successful (${result.statusCode})'
          : 'API test failed (${result.statusCode})';
        _authResult = {
          'statusCode': result.statusCode,
          'responseBody': result.responseBody,
        };
      });
    } catch (e) {
      setState(() {
        _status = 'API test error';
        _error = e.toString();
      });
    }
  }

  /// Test WebSocket connection
  Future<void> _testWebSocket() async {
    setState(() {
      _status = 'Testing WebSocket connection...';
      _error = null;
    });

    try {
      final result = await ApiService.testWebSocketConnection();
      
      setState(() {
        _status = result.isSuccess 
          ? 'WebSocket test successful'
          : 'WebSocket test failed';
        _authResult = {
          'url': result.url,
          'message': result.message,
        };
      });
    } catch (e) {
      setState(() {
        _status = 'WebSocket test error';
        _error = e.toString();
      });
    }
  }

  /// Toggle between WebSocket and traditional mode
     void _toggleMode() {
     ref.read(nationalIdProvider.notifier).toggleWebSocketMode();
     
     setState(() {
       _status = 'Switched to ${ref.read(nationalIdProvider).useWebSocket ? 'Primary' : 'Alternative'} mode';
     });
   }
}

/// Example of direct WebSocket service usage
class DirectWebSocketExample extends StatefulWidget {
  const DirectWebSocketExample({Key? key}) : super(key: key);

  @override
  State<DirectWebSocketExample> createState() => _DirectWebSocketExampleState();
}

class _DirectWebSocketExampleState extends State<DirectWebSocketExample> {
  String _status = 'Ready';
  Map<String, dynamic>? _result;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct WebSocket Example'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Status: $_status',
              style: TextStyle(
                fontSize: 18,
                color: _status.contains('Error') ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startDirectAuth,
              child: const Text('Start Direct WebSocket Auth'),
            ),
            const SizedBox(height: 16),
            if (_result != null) ...[
              const Text('Result:', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(_result.toString()),
                  ),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Start direct WebSocket authentication
  Future<void> _startDirectAuth() async {
    setState(() {
      _status = 'Starting direct WebSocket authentication...';
      _error = null;
      _result = null;
    });

    try {
      final result = await WebSocketService.authenticate();
      
      setState(() {
        _status = 'Authentication completed successfully';
        _result = result;
      });
    } catch (e) {
      setState(() {
        _status = 'Authentication failed';
        _error = e.toString();
      });
    }
  }
} 