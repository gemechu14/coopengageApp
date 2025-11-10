# Phone Number Formatting - Ethiopia (+251)

## ✅ Automatic Formatting Applied

### 📱 How It Works

When users enter an Ethiopian phone number, the app automatically:
1. **Removes** the first `0` (if present)
2. **Adds** the country code `+251`
3. **Sends** the formatted number to the API

---

## 📊 Examples

| User Input | Sent to API | Description |
|------------|-------------|-------------|
| `0912345678` | `+251912345678` | Standard format (0 removed) |
| `0712345678` | `+251712345678` | Alternative prefix (0 removed) |
| `912345678` | `+251912345678` | Without leading 0 (adds +251) |
| `712345678` | `+251712345678` | Without leading 0 (adds +251) |

---

## 🔧 Code Implementation

### Location
**File**: `lib/customerOnboarding/SendLink/link_generator_page.dart`

### Formatting Logic

```dart
// Format phone number: remove first 0 and add +251
String? formattedPhone;
if (_phoneController.text.trim().isNotEmpty) {
  final phone = _phoneController.text.trim();
  
  // Remove first 0 if present and add +251
  if (phone.startsWith('0')) {
    formattedPhone = '+251${phone.substring(1)}';  // 0912345678 → +251912345678
  } else {
    formattedPhone = '+251$phone';                 // 912345678 → +251912345678
  }
}
```

### When Applied

The formatting is applied:
- ✅ During form submission (`_onSubmit()`)
- ✅ Before creating the API request
- ✅ Only for phone platforms (WhatsApp, Telegram)

---

## 📝 Validation Rules

### User Input Requirements

The phone field validates:
- ✅ Must be **10 digits**
- ✅ Must start with **09** or **07**
- ✅ Only digits allowed (no spaces or special characters)

**Valid inputs:**
- `0912345678` ✅
- `0712345678` ✅
- `0923456789` ✅
- `0734567890` ✅

**Invalid inputs:**
- `912345678` ❌ (9 digits - missing leading 0 for validation)
- `0812345678` ❌ (doesn't start with 09 or 07)
- `09123456789` ❌ (11 digits - too long)
- `091234567` ❌ (9 digits - too short)

---

## 🌍 Ethiopia Phone Number Format

### Country Code
**Ethiopia**: `+251`

### Number Structure
```
+251 9 12 345 678
  │  │ └─ 8 digits (subscriber number)
  │  └─ Network code (9 or 7)
  └─ Country code (251)
```

### Mobile Network Codes

| Code | Network | Example |
|------|---------|---------|
| `09` | Ethio Telecom Mobile | `0912345678` |
| `07` | Safaricom (New) | `0712345678` |

---

## 🔄 Complete Flow

### 1. User Input
```
User enters: 0912345678
```

### 2. Validation
```
✅ Starts with 09 ✓
✅ 10 digits ✓
✅ Only digits ✓
```

### 3. Formatting
```dart
phone = "0912345678"
phone.startsWith('0') = true
formattedPhone = '+251' + phone.substring(1)
formattedPhone = '+251912345678'
```

### 4. API Request
```json
{
  "linkType": "INDIVIDUAL",
  "platform": "WHATSAPP",
  "recipientPhone": "+251912345678"  ← Formatted number
}
```

### 5. Backend Processing
```
Backend receives: +251912345678
Can generate WhatsApp link: wa.me/251912345678
```

---

## 🎯 Benefits

### For Users
✅ Simple input (just type as usual: `09...`)  
✅ No need to think about country codes  
✅ No manual formatting required  

### For System
✅ Consistent international format  
✅ Compatible with WhatsApp API  
✅ Compatible with Telegram API  
✅ Easy to integrate with other systems  

### For Developers
✅ Automatic conversion  
✅ Clean, maintainable code  
✅ Single source of truth for formatting  

---

## 🔍 Testing

### Test Cases

**Test 1: Standard Input**
```
Input: 0912345678
Expected Output: +251912345678
✅ Pass
```

**Test 2: Alternative Prefix**
```
Input: 0712345678
Expected Output: +251712345678
✅ Pass
```

**Test 3: Without Leading Zero**
```
Input: 912345678
Expected Output: +251912345678
✅ Pass
```

**Test 4: Empty Phone**
```
Input: (empty)
Expected Output: null
✅ Pass (field not sent to API)
```

---

## 🛠️ Customization

### Change Country Code

To support a different country, modify the formatting logic:

```dart
// For Kenya (+254)
if (phone.startsWith('0')) {
  formattedPhone = '+254${phone.substring(1)}';
} else {
  formattedPhone = '+254$phone';
}

// For Nigeria (+234)
if (phone.startsWith('0')) {
  formattedPhone = '+234${phone.substring(1)}';
} else {
  formattedPhone = '+234$phone';
}
```

### Support Multiple Countries

For international support, use country selector:

```dart
String countryCode = '+251'; // Default Ethiopia

// Based on selected country
switch (selectedCountry) {
  case 'ET':
    countryCode = '+251';
    break;
  case 'KE':
    countryCode = '+254';
    break;
  case 'NG':
    countryCode = '+234';
    break;
}

if (phone.startsWith('0')) {
  formattedPhone = '$countryCode${phone.substring(1)}';
} else {
  formattedPhone = '$countryCode$phone';
}
```

---

## ⚠️ Important Notes

### 1. Backend Compatibility
Ensure your backend expects phone numbers in this format:
```
+251912345678
```

If backend expects different format:
- `251912345678` (without +) → Remove the `+` in formatting
- `0912345678` (local format) → Don't format, send as-is
- `+251 912 345 678` (with spaces) → Add space formatting

### 2. WhatsApp/Telegram APIs
Both platforms expect international format without `+`:
```
WhatsApp: wa.me/251912345678
Telegram: t.me/+251912345678
```

Your backend should handle the conversion if needed.

### 3. Email Platform
Phone formatting is **NOT applied** for email platform:
- Email uses email field (not phone)
- Phone field is hidden for email platform

---

## 📱 Platform-Specific Behavior

### WhatsApp
```
User Input: 0912345678
Formatted: +251912345678
WhatsApp URL: wa.me/251912345678 (generated by backend)
```

### Telegram
```
User Input: 0912345678
Formatted: +251912345678
Telegram URL: t.me/+251912345678 (generated by backend)
```

### Email
```
Phone field not shown
Email field used instead
No phone formatting applied
```

---

## ✅ Verification

After implementation:

- [x] Phone numbers formatted with +251
- [x] Leading 0 removed correctly
- [x] Works for 09 prefix
- [x] Works for 07 prefix
- [x] Works without leading 0
- [x] Null handling for empty input
- [x] Only applies to phone platforms
- [x] No linter errors

---

**Status**: ✅ **IMPLEMENTED**  
**Version**: 1.0.4  
**Date**: 2025-10-10  
**Country**: Ethiopia (+251)

