# 🐛 Comprehensive Debug Guide - WebSocket & Callback Issues

## 🎯 Current Issue

You're getting **"Callback API failed"** errors, indicating the WebSocket may be closing too early. With the comprehensive logging now in place, we can track EXACTLY what's happening.

## 📊 Debug Tools Available

### 1. **Debug Widget with Live Monitoring**
```dart
import 'debug_fayda_flow.dart';

// Use this instead of normal widget for debugging
const DebugFaydaFlow()
```

### 2. **Comprehensive Console Logging**
Every step now prints detailed logs with emojis for easy identification:

- 🔌 **WebSocket operations**
- 🌐 **API calls** 
- 📞 **Callback processing**
- 🎯 **Widget interactions**
- 🚀 **Provider state changes**
- 📨 **WebSocket messages**

## 🔍 What to Look For

### **Step-by-Step Expected Flow:**

```
1. 🚀 [Widget] Starting authentication...
2. 🏗️ [FaydaProvider] Provider initialized
3. 🔌 [FaydaService] STEP 1: Starting WebSocket connection...
4. 🔌 [FaydaService] WebSocket connected: true
5. 🔌 [FaydaService] STEP 2: Sending registration message
6. ✅ [FaydaService] Registration success message received
7. 🌐 [FaydaService] STEP 3: Getting authentication URL...
8. 🌐 [FaydaService] WebSocket status before API call: true
9. ✅ [FaydaService] Auth URL retrieved
10. 🎯 [Widget] CALLBACK DETECTED IMMEDIATELY!
11. 📞 [FaydaProvider] STEP 4: Processing callback...
12. 📞 [FaydaService] WebSocket status BEFORE callback API: true ⚠️ CRITICAL
13. 📞 [FaydaService] Making HTTP POST request...
14. ✅ [FaydaService] Callback API successful
15. 🎉 [FaydaService] Authentication result received
16. 🔴 [FaydaProvider] NOW disposing service and closing WebSocket
```

### **🚨 Critical Points to Monitor:**

#### **Point A: WebSocket Status Before Callback**
```
📞 [FaydaService] WebSocket status BEFORE callback API: true
```
**This MUST be `true`**. If it's `false`, the WebSocket closed too early.

#### **Point B: Callback API Response**
```
📞 [FaydaService] Callback API Response status: 200
📞 [FaydaService] Callback API Response body: {...}
```
**Status MUST be 200**. If it's 400, this tells us WHY.

#### **Point C: WebSocket Status After Callback**
```
📞 [FaydaService] WebSocket status AFTER callback API: true
```
**This should still be `true`** until authentication_result is received.

## 🔧 Debugging Steps

### **Step 1: Run Debug Widget**
```dart
// Replace your current widget with:
const DebugFaydaFlow()
```

### **Step 2: Watch Console Logs**
Start the authentication and watch for these specific logs in order:

1. **WebSocket Connection:**
   ```
   🔌 [FaydaService] WebSocket connected: true
   ```

2. **Registration Success:**
   ```
   ✅ [FaydaService] Registration success message received
   ✅ [FaydaService] Client ID matches: 12344
   ```

3. **Auth URL Retrieved:**
   ```
   🌐 [FaydaService] WebSocket status after API call: true
   ✅ [FaydaService] Auth URL retrieved: [URL]
   ```

4. **Callback Detection:**
   ```
   🎯 [Widget] CALLBACK DETECTED IMMEDIATELY!
   🎯 [Widget] WebSocket status before callback: true
   ```

5. **Callback Processing:**
   ```
   📞 [FaydaProvider] WebSocket status BEFORE processing callback: true
   📞 [FaydaService] WebSocket status BEFORE callback API: true
   📞 [FaydaService] Making HTTP POST request...
   ```

6. **THE CRITICAL MOMENT:**
   ```
   📞 [FaydaService] Callback API Response status: ???
   📞 [FaydaService] Callback API Response body: ???
   ```

### **Step 3: Identify the Problem**

#### **Scenario A: WebSocket Closes Early**
If you see:
```
📞 [FaydaService] WebSocket status BEFORE callback API: false
```
**Problem**: WebSocket is closing before the callback API call.

#### **Scenario B: API Returns 400**
If you see:
```
📞 [FaydaService] Callback API Response status: 400
📞 [FaydaService] Callback API Response body: {...error details...}
```
**Problem**: Server is rejecting the callback request.

#### **Scenario C: WebSocket Disconnects During Call**
If you see the request start but then:
```
❌ [FaydaService] Exception in callback API: [error]
📞 [FaydaService] WebSocket status during exception: false
```
**Problem**: WebSocket disconnected during the API call.

## 🎮 Debug Widget Features

### **Real-time Status Chips:**
- 🟣 **WebSocket**: Shows if WebSocket is connected
- 🔵 **Connected**: WebSocket initial connection
- 🟢 **Registered**: Client registration success
- 🟠 **Loading**: Currently processing
- 🔴 **Error**: Any errors occurred

### **Manual Controls:**
- **Start Auth**: Manually trigger authentication
- **Retry Callback**: Retry callback if WebSocket is still open
- **Reset**: Clear everything and start over
- **Clear Logs**: Clear the debug log display

### **Live Logs Panel:**
- Color-coded logs with timestamps
- Real-time state updates
- WebSocket connection monitoring
- Error highlighting

## 📝 What to Send Me

When you run the debug widget, send me:

1. **The complete console log** from start to the error
2. **Screenshot of the debug widget** showing the status chips
3. **The specific error message** from the callback API response

Look for these specific lines:
```
📞 [FaydaService] WebSocket status BEFORE callback API: ???
📞 [FaydaService] Callback API Response status: ???
📞 [FaydaService] Callback API Response body: ???
```

## 🚀 Quick Test

Run this and send me the complete log output:

```dart
// Use the debug widget
const DebugFaydaFlow()

// 1. Tap "Start Auth"
// 2. Complete authentication in WebView
// 3. Copy ALL console logs from start to error
// 4. Send me the logs
```

This will show us **EXACTLY** where the WebSocket is closing and why the callback API is failing!

## 💡 Expected Findings

Based on the comprehensive logging, we should be able to identify:

1. **When** the WebSocket closes (if it closes early)
2. **Why** the callback API returns 400 (server error details)
3. **Where** in the flow the problem occurs
4. **What** the actual WebSocket and API responses are

The logging is now so detailed that we'll know exactly what's happening at every millisecond of the authentication flow! 🎯 