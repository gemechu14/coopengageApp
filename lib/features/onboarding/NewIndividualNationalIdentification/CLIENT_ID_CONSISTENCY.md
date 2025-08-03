# Client ID Consistency Documentation

## Overview
This document tracks all places where `clientId` is used in the Fayda authentication flow to ensure consistency.

## Fixed Client ID: "12344"

### 1. WebSocket Service (`websocket_service.dart`)
- **Line 83**: `_clientId = "12344"` in `initializeAuthentication()`
- **Line 47**: `_clientId = "12344"` in `authenticate()`
- **Line 211**: Used in WebSocket registration message
- **Line 258**: Used in API URL: `$baseUrl/fayda/authenticate-url-ws?clientId=$_clientId`

### 2. National ID Provider (`national_id_provider.dart`)
- **Line 96**: `final clientId = "12344"` in `_callWebSocketAuth()`
- **Line 99**: Used in state update

### 3. API Service (`api_service.dart`)
- **Line 37**: Used in test endpoint: `$baseUrl/api/v1/fayda/authenticate-url-ws?clientId=12344`

### 4. Widget Display (`national_id_auth_widget.dart`)
- **Line 529**: Displays clientId in UI for debugging

## Flow Consistency

### Step 1: WebSocket Registration
```json
{
    "type": "register_client",
    "clientId": "12344"
}
```

### Step 2: Get Authentication URL
```
GET /api/v1/fayda/authenticate-url-ws?clientId=12344
```

### Step 3: Process Callback
```
GET /api/v1/fayda/callback?code={code}&state={state}
```
*Note: The state parameter should match the registered clientId*

### Step 4: WebSocket Result
```json
{
    "clientId": "12344",
    "data": { ... },
    "type": "authentication_result"
}
```

## Verification
All clientId references now use the consistent value "12344" throughout the entire authentication flow. 