# 🔍 WebSocket Debugging Guide

## 🎯 Current Issue

**PROBLEM**: Callback is detected correctly, WebView closes, but WebSocket `authentication_result` message is not being received after waiting for hours.

**WHAT WE KNOW**:
✅ Callback detection works perfectly:
```
🎯 [Widget] CALLBACK DETECTED IMMEDIATELY!
🎯 [Widget] URL: https://fayidaonboarding.coopbankoromiasc.com/api/v1/esignet/callback?state=c0c6af6a&code=qkjRn6AE1IjkZvBro5QLRbr1HfM0BznqlYDS9wBuslY
✅ [Widget] Code and state found - closing WebView and waiting for WebSocket
⏳ [Widget] WebView closed, waiting for WebSocket authentication result...
🚫 [Widget] WebView restart prevented - callback detected
```

**WHAT WE DON'T KNOW**:
❓ Is the WebSocket still connected?
❓ Is the server processing the callback?
❓ Is the server sending the `authentication_result` message?
❓ Are there client ID mismatches?

---

## 🔧 Enhanced Debugging (Added)

### **1. Callback Detection Debugging**
Now shows:
- ✅ Extracted code and state parameters
- ✅ Current WebSocket connection status
- ✅ Periodic waiting timer (every 5 seconds)
- ✅ Timeout warning after 60 seconds

### **2. WebSocket Message Debugging**
Enhanced to show:
- ✅ All raw WebSocket messages received
- ✅ Message type and client ID comparison
- ✅ Detailed authentication_result processing
- ✅ Unknown message type logging

### **3. Waiting Status Debugging**
Added periodic logging:
- ✅ Shows waiting duration every 5 seconds
- ✅ Shows current connection status
- ✅ Shows completion/error status
- ✅ Warns if waiting too long (60+ seconds)

---

## 🔍 What to Check Next

### **Step 1: Run the App and Check Logs**

After callback detection, you should see:

```
🔍 [Widget] Extracted code: qkjRn6AE1IjkZvBro5QLRbr1HfM0BznqlYDS9wBuslY
🔍 [Widget] Extracted state: c0c6af6a
🔍 [Widget] Current Fayda provider state: isConnected=true, isCompleted=false
🔍 [Widget] WebSocket connection status: true
⏳ [Widget] Now waiting for server to process callback and send authentication_result via WebSocket...

⏰ [Widget] Still waiting for WebSocket result... 5s elapsed
🔍 [Widget] Current state: isCompleted=false, error=null
🔍 [Widget] WebSocket connected: true

⏰ [Widget] Still waiting for WebSocket result... 10s elapsed
...
```

### **Step 2: Check WebSocket Connection Status**

**✅ GOOD**: If you see `WebSocket connected: true`
**❌ BAD**: If you see `WebSocket connected: false`

If WebSocket is disconnected:
- The server may have closed the connection
- Network issues may have occurred
- The connection may have timed out

### **Step 3: Check for WebSocket Messages**

**✅ GOOD**: If you see any of these:
```
📨 [FaydaService] ===== WebSocket message received =====
📨 [FaydaService] Raw message: {...}
📨 [FaydaService] Message type: authentication_result
```

**❌ BAD**: If you see NO WebSocket messages at all
- Server is not sending any messages
- WebSocket connection may be broken
- Server-side callback processing may be failing

### **Step 4: Check for Authentication Result Message**

**✅ GOOD**: If you see:
```
🎉 [FaydaService] ===== AUTHENTICATION RESULT MESSAGE RECEIVED =====
🎉 [FaydaService] Client ID matches for auth result: 12344
🎉 [FaydaService] Completing auth completer with user data
```

**❌ BAD**: If you see:
```
⚠️ [FaydaService] Client ID mismatch for auth result: expected 12344, got 67890
```

---

## 🚨 Common Issues & Solutions

### **Issue 1: WebSocket Disconnected**
```
🔍 [Widget] WebSocket connected: false
```

**SOLUTION**: 
- Server may have closed the connection after callback
- Need to implement WebSocket reconnection
- Check server-side WebSocket timeout settings

### **Issue 2: No WebSocket Messages**
```
⏰ [Widget] Still waiting... 30s elapsed
(No WebSocket messages in logs)
```

**SOLUTION**:
- Server is not processing the callback URL
- Check server logs for callback API processing
- Verify callback URL format is correct
- Check if server is sending WebSocket messages

### **Issue 3: Client ID Mismatch**
```
⚠️ [FaydaService] Client ID mismatch: expected 12344, got 67890
```

**SOLUTION**:
- Server is sending messages for different client ID
- Check if multiple sessions are interfering
- Verify client ID consistency across the flow

### **Issue 4: Authentication Result Never Comes**
```
⏰ [Widget] Still waiting... 60s elapsed
⚠️ [Widget] Waited 60 seconds - this seems too long
```

**SOLUTION**:
- Server-side callback processing is failing
- Check server logs for errors
- Verify the callback API endpoint is working
- Check if server is configured to send WebSocket messages

---

## 🔧 Next Steps for Debugging

### **1. Check Server Logs**
Look for:
- Callback API requests: `GET /api/v1/fayda/callback?code=...&state=...`
- WebSocket message sending: `Sending authentication_result to client 12344`
- Any errors during callback processing

### **2. Test WebSocket Connection**
Add a manual test message:
```dart
// Send a test message to verify WebSocket is working
_channel?.sink.add(jsonEncode({
  "type": "ping",
  "clientId": _clientId,
  "message": "test connection"
}));
```

### **3. Verify Callback URL Processing**
The callback URL should trigger server-side processing that:
1. Validates the code and state parameters
2. Exchanges the code for user data
3. Sends `authentication_result` via WebSocket to the correct client ID

### **4. Check Network/Firewall Issues**
- WebSocket connections may be blocked by firewalls
- Long-running connections may be terminated by network policies
- Mobile networks may have different timeout behaviors

---

## 🎯 Expected Working Flow

```
1. Callback detected ✅
2. WebSocket stays connected ✅
3. Server processes callback URL ❓
4. Server sends authentication_result via WebSocket ❓
5. Client receives message and shows user data ❓
```

**Run the app with the enhanced debugging and check which step is failing!** 🔍 