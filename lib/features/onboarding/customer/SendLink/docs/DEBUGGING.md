# Link Generator - Debugging Guide

## 🐛 Common Issues and Solutions

### Issue 1: Type 'Null' is not a subtype of type 'String' in type cast

**Symptom**: Getting 200 response but app crashes with null type error

**Cause**: API response contains null values for fields marked as required (non-nullable)

**Solution**: ✅ FIXED - Updated `LinkGenerationResponse.fromJson()` to handle null values gracefully

```dart
// Before (would crash on null)
shareableLink: json['shareableLink'] as String,

// After (handles null)
final shareableLink = json['shareableLink'] as String? ?? '';
```

**Debug Steps**:
1. Check the actual API response in logs
2. Verify which field is null
3. Update the model to handle null or make field nullable

---

### Issue 2: Authentication Token Missing

**Symptom**: 401 Unauthorized error

**Cause**: Token not found in secure storage

**Debug Steps**:
```dart
// Add debug logging in service
String? token = await storage.read(key: "token");
print('Token: ${token != null ? "Found" : "Missing"}');
```

**Solution**:
- Ensure user is logged in
- Verify token is saved with key "token"
- Check token expiration

---

### Issue 3: Network Connection Errors

**Symptom**: Connection timeout or no internet error

**Debug Steps**:
1. Check internet connection
2. Verify API endpoint URL
3. Check firewall/proxy settings
4. Try curl/Postman with same endpoint

**Solution**:
```dart
// Increase timeout in provider
final dio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 60), // Increase if needed
    receiveTimeout: const Duration(seconds: 60),
  ),
);
```

---

### Issue 4: Invalid Phone/Email Validation

**Symptom**: Form validation fails incorrectly

**Debug Steps**:
```dart
// Test regex patterns
final phoneRegex = RegExp(r'^(09|07)\d{8}$');
print(phoneRegex.hasMatch('0947539988')); // Should be true

final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
print(emailRegex.hasMatch('test@example.com')); // Should be true
```

**Solution**: Update regex patterns in validation methods

---

### Issue 5: QR Code Not Displaying

**Symptom**: QR code section shows error or loading indefinitely

**Possible Causes**:
- API returns null `qrCodeUrl`
- Network issue loading image
- Invalid URL format

**Debug Steps**:
```dart
if (result.qrCodeUrl != null) {
  print('QR Code URL: ${result.qrCodeUrl}');
  // Try opening in browser to verify
}
```

---

### Issue 6: Share Button Not Working

**Symptom**: Nothing happens when tapping share button

**Debug Steps**:
```dart
// Check platform-specific URL
print('Platform URL: ${result.platformSpecificUrl}');

// Check if URL can be launched
final uri = Uri.parse(result.platformSpecificUrl!);
print('Can launch: ${await canLaunchUrl(uri)}');
```

**Common Causes**:
- WhatsApp/Telegram not installed
- URL format incorrect
- Permissions not granted

**Solution for Android**: Add to `AndroidManifest.xml`:
```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
</queries>
```

---

## 🔍 Debugging Tools

### 1. Enable Dio Logging

In `providers/link_generator_provider.dart`, logging is already enabled:

```dart
dio.interceptors.add(
  LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ),
);
```

This logs:
- ✅ Request URL
- ✅ Request headers
- ✅ Request body
- ✅ Response status
- ✅ Response body
- ✅ Errors

### 2. Add Custom Logging

```dart
// In service layer
Future<LinkGenerationResponse> generateLink(request) async {
  print('🚀 Generating link...');
  print('Request: ${jsonEncode(request.toJson())}');
  
  try {
    final response = await _dio.post(url, ...);
    print('✅ Success: ${response.statusCode}');
    print('Response: ${response.data}');
    
    return LinkGenerationResponse.fromJson(data);
  } catch (e) {
    print('❌ Error: $e');
    rethrow;
  }
}
```

### 3. Debug API Response Structure

```dart
// Add temporary debug code
final data = _parseResponseData(response.data);
print('Parsed data keys: ${data.keys}');
print('shareableLink: ${data['shareableLink']}');
print('platformSpecificUrl: ${data['platformSpecificUrl']}');
print('qrCodeUrl: ${data['qrCodeUrl']}');
```

### 4. Test with Mock Data

```dart
// Create test provider for debugging
final mockLinkGeneratorProvider = 
    StateNotifierProvider<LinkGeneratorNotifier, LinkGeneratorState>((ref) {
  // Return mock service for testing
  return LinkGeneratorNotifier(MockLinkGeneratorService());
});
```

---

## 📝 API Response Debugging

### Expected Response Format

```json
{
  "shareableLink": "https://example.com/invite/abc123",
  "platformSpecificUrl": "https://wa.me/251947539988?text=...",
  "qrCodeUrl": "https://example.com/qr/abc123.png",
  "message": "Link generated successfully"
}
```

### Actual Response Checklist

- [ ] `shareableLink` is present and not null
- [ ] `shareableLink` is a valid URL string
- [ ] `platformSpecificUrl` is present for WhatsApp/Telegram
- [ ] `qrCodeUrl` is a valid image URL (if present)
- [ ] Response has 200 or 201 status code

### Common API Response Issues

**Issue**: Empty response
```json
{}
```
**Solution**: Check backend implementation

**Issue**: Wrapped response
```json
{
  "data": {
    "shareableLink": "..."
  }
}
```
**Solution**: Update parsing to handle wrapper:
```dart
final data = response.data['data'] ?? response.data;
```

**Issue**: String response instead of JSON
```json
"shareableLink=https://..."
```
**Solution**: Service already handles this with `_parseResponseData()`

---

## 🧪 Testing Checklist

### Manual Testing

- [ ] Test with INDIVIDUAL account type
- [ ] Test with JOINT account type
- [ ] Test with ORGANIZATION account type
- [ ] Test WhatsApp with valid phone (09xxxxxxxx)
- [ ] Test WhatsApp with valid phone (07xxxxxxxx)
- [ ] Test Telegram with valid phone
- [ ] Test Email with valid email
- [ ] Test with invalid phone (should fail validation)
- [ ] Test with invalid email (should fail validation)
- [ ] Test copy link functionality
- [ ] Test share button for WhatsApp
- [ ] Test share button for Telegram
- [ ] Verify email doesn't show share button
- [ ] Test with no internet (should show error)
- [ ] Test with expired token (should show auth error)

### Error Cases

- [ ] Test with invalid phone format
- [ ] Test with invalid email format
- [ ] Test without authentication
- [ ] Test with network timeout
- [ ] Test rapid button clicking (should prevent duplicate requests)

---

## 🔧 Quick Fixes

### Clear All Debug Logs

Search for `print(` statements and remove them from production code.

### Reset State

```dart
// In your widget
ref.read(linkGeneratorProvider.notifier).reset();
```

### Force Refresh

```dart
// Invalidate provider to rebuild
ref.invalidate(linkGeneratorProvider);
```

### Check Current State

```dart
final state = ref.read(linkGeneratorProvider);
print('Loading: ${state.isLoading}');
print('Error: ${state.errorMessage}');
print('Has Result: ${state.hasResult}');
```

---

## 📱 Platform-Specific Issues

### Android

**Issue**: URL not launching
**Fix**: Add queries to `AndroidManifest.xml`

**Issue**: Network security
**Fix**: Add network security config for HTTP URLs (if needed)

### iOS

**Issue**: URL schemes blocked
**Fix**: Add to `Info.plist`:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>whatsapp</string>
  <string>tg</string>
</array>
```

---

## 🆘 Getting Help

If issues persist:

1. **Check the logs**: Enable Dio logging and check console
2. **Verify API**: Test endpoint with Postman/curl
3. **Check model**: Ensure response structure matches model
4. **Review docs**: Check README.md and ARCHITECTURE.md
5. **Test isolation**: Test service layer independently

### Useful Commands

```bash
# Check Flutter version
flutter --version

# Clean and rebuild
flutter clean
flutter pub get

# Run with verbose logging
flutter run --verbose

# Check for issues
flutter analyze
```

---

## ✅ Resolution Checklist

When debugging an issue:

- [ ] Identified the error message
- [ ] Located where error occurs (UI/Provider/Service/Model)
- [ ] Added debug logging
- [ ] Reviewed API response
- [ ] Tested with different inputs
- [ ] Fixed the root cause
- [ ] Removed debug code
- [ ] Tested the fix
- [ ] Documented the solution

---

**Last Updated**: 2025-10-10  
**Status**: Active maintenance

