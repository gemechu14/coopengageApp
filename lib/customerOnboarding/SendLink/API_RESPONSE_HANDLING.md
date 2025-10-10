# API Response Handling Guide

## ✅ Fixed: Wrapped Response Issue

### Your API Response Structure

Your backend returns responses wrapped in a `"data"` field:

```json
{
  "data": {
    "invitationId": 40,
    "trackingToken": "9c023fa2-f292-4fe3-b5d3-cfefb6ff2880",
    "platform": "EMAIL",
    "shareableLink": "https://my.coopbankoromiasc.com/api/v1/invitations/track/social-click/9c023fa2-f292-4fe3-b5d3-cfefb6ff2880",
    "platformSpecificUrl": "🏦 Cooperative Bank of Oromia\n\nHello Bxbz!\n\nYou're invited...",
    "formattedMessage": "🏦 Cooperative Bank of Oromia\n\nHello Bxbz!..."
  }
}
```

## 🔧 What Was Fixed

### 1. Updated `_parseResponseData()` Method

**File**: `services/link_generator_service.dart`

**Before**:
```dart
Map<String, dynamic> _parseResponseData(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data; // ❌ Returns the whole response including 'data' wrapper
  }
  // ...
}
```

**After**:
```dart
Map<String, dynamic> _parseResponseData(dynamic data) {
  Map<String, dynamic> parsedData;
  
  if (data is Map<String, dynamic>) {
    parsedData = data;
  } else if (data is String) {
    parsedData = jsonDecode(data) as Map<String, dynamic>;
  }
  
  // ✅ Check if response is wrapped in a 'data' field
  if (parsedData.containsKey('data') && parsedData['data'] is Map<String, dynamic>) {
    return parsedData['data'] as Map<String, dynamic>;
  }
  
  return parsedData;
}
```

### 2. Updated Model to Handle `formattedMessage`

**File**: `models/link_generator_models.dart`

Your API returns `formattedMessage` instead of `message`:

```dart
factory LinkGenerationResponse.fromJson(Map<String, dynamic> json) {
  final shareableLink = json['shareableLink'] as String? ?? '';
  
  // ✅ Handle both 'message' and 'formattedMessage' from API
  final message = json['message'] as String? ?? 
                  json['formattedMessage'] as String?;
  
  return LinkGenerationResponse(
    shareableLink: shareableLink,
    platformSpecificUrl: json['platformSpecificUrl'] as String?,
    qrCodeUrl: json['qrCodeUrl'] as String?,
    message: message,
  );
}
```

## 📊 Response Flow

```
API Response (Dio)
    ↓
{"data": {...}}
    ↓
_parseResponseData() extracts "data" field
    ↓
{
  "shareableLink": "...",
  "platformSpecificUrl": "...",
  "formattedMessage": "..."
}
    ↓
LinkGenerationResponse.fromJson()
    ↓
LinkGenerationResponse object
    ↓
Display in UI
```

## 🎯 Your API Fields Mapping

| API Field | Model Field | Type | Note |
|-----------|-------------|------|------|
| `shareableLink` | `shareableLink` | String | Main link |
| `platformSpecificUrl` | `platformSpecificUrl` | String? | For WhatsApp/Telegram |
| `formattedMessage` | `message` | String? | The formatted message |
| `qrCodeUrl` | `qrCodeUrl` | String? | QR code (if provided) |

**Additional fields in API** (not used in model):
- `invitationId` - Stored on backend
- `trackingToken` - For tracking
- `platform` - Platform identifier

## 🧪 Test Cases

### Test Case 1: Email Platform
```json
{
  "data": {
    "platform": "EMAIL",
    "shareableLink": "https://...",
    "platformSpecificUrl": "Full email text...",
    "formattedMessage": "🏦 Cooperative Bank..."
  }
}
```
✅ Should display link and formatted message

### Test Case 2: WhatsApp Platform
```json
{
  "data": {
    "platform": "WHATSAPP",
    "shareableLink": "https://...",
    "platformSpecificUrl": "https://wa.me/...",
    "formattedMessage": "WhatsApp message"
  }
}
```
✅ Should display link with share button

### Test Case 3: Response Without Wrapper
If your backend changes to return unwrapped data:
```json
{
  "shareableLink": "https://...",
  "platformSpecificUrl": "..."
}
```
✅ Still works! (fallback to direct parsing)

## 💡 Understanding Your API Response

### The `platformSpecificUrl` Field

For **EMAIL** platform, this contains the **full email body**:
```
🏦 Cooperative Bank of Oromia

Hello Bxbz!

You're invited to open a Individual Savings Account with us!

Benefits:
✅ Competitive interest rates
✅ Mobile & internet banking
✅ Quick registration process
✅ Secure & trusted service

Start your registration: https://...

Sent by adb
Cooperative Bank of Oromia
```

For **WHATSAPP** platform, this contains:
```
https://wa.me/251947539988?text=<encoded_message>
```

For **TELEGRAM** platform, this contains:
```
https://t.me/share/url?url=<link>&text=<message>
```

### The `shareableLink` Field

This is the **tracking link** that redirects to your registration form:
```
https://my.coopbankoromiasc.com/api/v1/invitations/track/social-click/9c023fa2-f292-4fe3-b5d3-cfefb6ff2880
```

**Purpose**: Tracks when someone clicks the invitation link

## 🎨 UI Display

### Email Platform Result
- ✅ Shows shareable link
- ✅ Shows formatted message (in message card)
- ✅ "Copy Link" button
- ❌ No "Share" button (Email doesn't support direct sharing)

### WhatsApp/Telegram Platform Result
- ✅ Shows shareable link
- ✅ "Copy Link" button
- ✅ "Share" button (opens WhatsApp/Telegram with pre-filled message)

## 🔍 Debugging

### Check What Data is Parsed

Add debug logging (temporarily):

```dart
// In _parseResponseData method
final result = parsedData['data'] ?? parsedData;
print('📦 Parsed data keys: ${result.keys}');
print('🔗 shareableLink: ${result['shareableLink']}');
print('📱 platformSpecificUrl: ${result['platformSpecificUrl']}');
print('💬 formattedMessage: ${result['formattedMessage']}');
return result;
```

### Verify Response Structure

```dart
// In generateLink method, after getting response
print('📥 Raw response: ${response.data}');
print('📊 Response type: ${response.data.runtimeType}');
```

## ✅ Verification Checklist

After the fix, verify:

- [x] ✅ Link is displayed (not null)
- [x] ✅ No type cast errors
- [x] ✅ Formatted message appears (if provided)
- [x] ✅ Copy button works
- [x] ✅ Share button works (WhatsApp/Telegram)
- [x] ✅ Email platform shows message text
- [x] ✅ No linter errors

## 🚀 Result

Your app now correctly handles:
1. ✅ Wrapped API responses (`{"data": {...}}`)
2. ✅ Unwrapped API responses (backward compatible)
3. ✅ Both `message` and `formattedMessage` fields
4. ✅ Null values for optional fields
5. ✅ All three platforms (WhatsApp, Telegram, Email)

---

**Status**: ✅ **FIXED**  
**Version**: 1.0.2  
**Date**: 2025-10-10

