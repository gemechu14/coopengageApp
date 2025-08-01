# WebSocket-Based Fayda Authentication Implementation

## Overview

This implementation provides a seamless OAuth flow with Fayda National ID authentication using WebSockets for real-time communication between frontend and backend.

## Architecture

```
Frontend (Flutter) ←→ WebSocket Connection ←→ Backend
     ↓
   WebSocket Service → Fayda OAuth → Callback to Backend
                                      ↓
                              WebSocket sends result to Frontend
```

## Implementation Details

### 1. WebSocket Service (`websocket_service.dart`)

The `WebSocketService` class handles:
- **Client ID Generation**: Creates unique client IDs for session tracking
- **WebSocket Connection**: Establishes and manages WebSocket connections
- **Message Handling**: Processes incoming WebSocket messages
- **Authentication Flow**: Coordinates the complete authentication process

#### Key Methods:
- `authenticate()`: Main method to start WebSocket authentication
- `generateClientId()`: Creates unique client identifiers
- `_connectWebSocket()`: Establishes WebSocket connection
- `_handleWebSocketMessage()`: Processes incoming messages

### 2. Updated National ID Provider (`national_id_provider.dart`)

Enhanced to support both WebSocket and traditional API authentication:

#### New State Properties:
- `useWebSocket`: Toggle between WebSocket and traditional mode
- `clientId`: Tracks the current client ID
- `isWebSocketConnected`: Connection status

#### New Methods:
- `_callWebSocketAuth()`: WebSocket-based authentication
- `_callTraditionalAuth()`: Traditional API authentication
- `toggleWebSocketMode()`: Switch between modes
- `setWebSocketMode()`: Set authentication mode explicitly

### 3. Updated Widget (`national_id_auth_widget.dart`)

Enhanced UI to support WebSocket authentication:

#### New Features:
- **Mode Selection**: Toggle between WebSocket and traditional authentication
- **WebSocket Loading State**: Shows connection progress and client ID
- **Test Buttons**: Test both API and WebSocket connectivity
- **Real-time Status**: Display current authentication mode

#### New Methods:
- `_startWebSocketAuth()`: Initiates WebSocket authentication
- `_buildWebSocketLoadingState()`: Shows WebSocket connection progress
- `_buildAuthenticationModeSelection()`: Mode selection UI

### 4. Enhanced API Service (`api_service.dart`)

Added WebSocket testing capabilities:

#### New Methods:
- `testWebSocketAuthEndpoint()`: Test the WebSocket authentication endpoint
- `testWebSocketConnection()`: Test WebSocket connectivity

### 5. Enhanced Dialog Service (`dialog_service.dart`)

Added WebSocket test result dialogs:

#### New Methods:
- `showWebSocketTestResultDialog()`: Display WebSocket test results

## Usage

### Basic WebSocket Authentication

```dart
// Start WebSocket authentication
final result = await WebSocketService.authenticate();

if (result != null) {
  // Handle successful authentication
  print('Authentication successful: $result');
} else {
  // Handle authentication failure
  print('Authentication failed');
}
```

### Toggle Authentication Modes

```dart
// Switch to WebSocket mode
ref.read(nationalIdProvider.notifier).setWebSocketMode(true);

// Switch to traditional API mode
ref.read(nationalIdProvider.notifier).setWebSocketMode(false);

// Start authentication
ref.read(nationalIdProvider.notifier).callEsignetApi();
```

### Test Connectivity

```dart
// Test API endpoint
final apiResult = await ApiService.testApiEndpoint();

// Test WebSocket connection
final wsResult = await ApiService.testWebSocketConnection();
```

## WebSocket Message Types

### Client Registration:
```json
{
  "type": "register_client",
  "clientId": "your-unique-client-id"
}
```

### Authentication Result:
```json
{
  "type": "authentication_result",
  "clientId": "your-unique-client-id", 
  "data": {
    // User information from Fayda
  }
}
```

### Error Message:
```json
{
  "type": "error",
  "clientId": "your-unique-client-id",
  "message": "Error description"
}
```

## Configuration

### Backend Requirements

1. **WebSocket Endpoint**: `/ws/fayda`
2. **API Endpoint**: `/api/v1/fayda/authenticate-url-ws?clientId={clientId}`
3. **Callback Endpoint**: `/api/v1/fayda/callback`

### Frontend Configuration

The implementation automatically:
- Converts HTTP URLs to WebSocket URLs
- Generates unique client IDs
- Handles connection timeouts
- Manages authentication state

## Benefits

1. **Real-time Communication**: No polling required
2. **Multiple Sessions**: Client ID ensures correct user mapping
3. **Error Handling**: Comprehensive error reporting
4. **Automatic Cleanup**: Backend handles connection closure
5. **Fallback Support**: Traditional API mode available
6. **Testing Tools**: Built-in connectivity testing

## Security Considerations

1. **Client ID Generation**: Uses cryptographically secure random IDs
2. **Connection Timeouts**: Prevents hanging connections
3. **Error Handling**: Doesn't expose sensitive information
4. **State Management**: Proper cleanup of resources

## Troubleshooting

### Common Issues:

1. **WebSocket Connection Failed**
   - Check backend WebSocket endpoint availability
   - Verify URL conversion (HTTP to WS/WSS)
   - Check network connectivity

2. **Authentication Timeout**
   - Verify backend callback handling
   - Check client ID mapping
   - Review authentication flow

3. **Message Parsing Errors**
   - Verify JSON message format
   - Check message type handling
   - Review error handling logic

### Debug Tools:

- Use the "Test WebSocket" button in the UI
- Check console logs for connection status
- Monitor WebSocket message flow
- Verify client ID generation

## Migration from Traditional API

The implementation maintains backward compatibility:
- Traditional API mode still works
- Existing code continues to function
- Gradual migration possible
- Both modes can be tested simultaneously 