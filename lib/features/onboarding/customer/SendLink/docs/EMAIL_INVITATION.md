# Email Invitation Feature

## 📧 Overview

The Email platform uses a **different API endpoint and request format** compared to WhatsApp/Telegram. When email is selected, the invitation is sent directly by the backend - no link or QR code is returned.

---

## 🎯 Key Differences

### WhatsApp/Telegram
- **Endpoint**: `POST /api/v1/invitations/social/generate-link`
- **Purpose**: Generate a shareable link
- **Result**: Returns link, platform URL, and QR code
- **User Action**: Copy/Share the generated link

### Email
- **Endpoint**: `POST /api/v1/invitations/send`
- **Purpose**: Send invitation email directly
- **Result**: Email sent by backend (no link returned)
- **User Action**: Just send - backend handles everything

---

## 📋 Request Format

### Email Invitation Request

```json
{
  "recipientEmail": "hundaolnk2000@gmail.com",
  "recipientName": "Hundaol Doe",
  "linkType": "INDIVIDUAL",
  "notes": "High potential customer"
}
```

**Required Fields:**
- ✅ `recipientEmail` - Must be valid email
- ✅ `recipientName` - Must not be empty
- ✅ `linkType` - Account type (INDIVIDUAL, JOINT, ORGANIZATION)

**Optional Fields:**
- 📝 `notes` - Additional notes about the recipient

---

## 🎨 UI for Email Platform

### Form Fields

When **Email** is selected as platform:

```
┌──────────────────────────────────────┐
│  Account Type: [INDIVIDUAL  ▼]      │ Required
│  Platform: [EMAIL  ▼]               │ Required
│  Recipient Name: [___________] *    │ Required (Name changed to required!)
│  Email Address: [___________] *     │ Required
│  Notes: [__________________]        │ Optional (3 lines)
│                                      │
│  [📧 Send Invitation]               │ Button text changes
└──────────────────────────────────────┘
```

### Success Display

After sending, shows **Email Success Card** (not link card):

```
┌──────────────────────────────────────┐
│  ✅ Email Sent Successfully          │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ 📧 Invitation Email Sent       │ │
│  │                                │ │
│  │ An invitation email has been   │ │
│  │ sent to user@example.com       │ │
│  │                                │ │
│  │ The recipient will receive the │ │
│  │ invitation link directly in    │ │
│  │ their inbox.                   │ │
│  └────────────────────────────────┘ │
│                                      │
│  Recipient Details:                  │
│  Recipient:    John Doe              │
│  Email:        user@example.com      │
│  Account Type: INDIVIDUAL            │
│  Notes:        High potential...    │
└──────────────────────────────────────┘
```

---

## 🔧 Implementation Details

### Model Classes

**`EmailInvitationRequest`** - New model for email invitations:

```dart
class EmailInvitationRequest {
  final String recipientEmail;
  final String recipientName;
  final AccountType accountType;
  final String? notes;

  const EmailInvitationRequest({
    required this.recipientEmail,
    required this.recipientName,
    required this.accountType,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'recipientEmail': recipientEmail.trim(),
      'recipientName': recipientName.trim(),
      'linkType': accountType.apiValue,
    };

    if (notes != null && notes!.trim().isNotEmpty) {
      json['notes'] = notes!.trim();
    }

    return json;
  }
}
```

### Service Method

**`sendEmailInvitation()`** - New service method:

```dart
Future<void> sendEmailInvitation(EmailInvitationRequest request) async {
  try {
    final url = '$baseUrl/api/v1/invitations/send';
    
    String? token = await storage.read(key: "token");

    final response = await _dio.post(
      url,
      data: jsonEncode(request.toJson()),
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Email sent successfully
      return;
    } else {
      // Handle errors...
    }
  } catch (e) {
    // Error handling...
  }
}
```

### Provider Method

**`sendEmailInvitation()`** - New provider method:

```dart
Future<void> sendEmailInvitation(EmailInvitationRequest request) async {
  state = state.copyWith(
    isLoading: true,
    clearError: true,
    clearResult: true,
  );

  try {
    await _service.sendEmailInvitation(request);
    
    state = state.copyWith(
      isLoading: false,
      clearError: true,
    );
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: e.toString(),
      clearResult: true,
    );
  }
}
```

---

## 🔄 Flow Comparison

### WhatsApp/Telegram Flow

```
1. User fills form (name optional, phone required)
   ↓
2. Click "Generate Link"
   ↓
3. API: POST /api/v1/invitations/social/generate-link
   ↓
4. Response: { shareableLink, platformSpecificUrl, qrCodeUrl }
   ↓
5. Show Result Card with link, copy, share buttons
   ↓
6. User copies/shares the link manually
```

### Email Flow

```
1. User fills form (name required, email required, notes optional)
   ↓
2. Click "Send Invitation"
   ↓
3. API: POST /api/v1/invitations/send
   ↓
4. Backend sends email directly
   ↓
5. Response: 200 OK (no data returned)
   ↓
6. Show Email Success Card with confirmation
   ↓
7. Done! User doesn't need to do anything else
```

---

## 📱 UI State Management

### State Variables

```dart
bool _isLinkGenerated = false;  // For WhatsApp/Telegram
bool _isEmailSent = false;      // For Email
```

### Conditional Rendering

```dart
// Show link result card ONLY for WhatsApp/Telegram
if (_isLinkGenerated && !_isEmailSent)
  if (state.hasResult) _buildResultCard(state.result!),

// Show email success card ONLY for Email
if (_isEmailSent) _buildEmailSuccessCard(),
```

---

## ✅ Validation Rules

### WhatsApp/Telegram

| Field | Required | Validation |
|-------|----------|------------|
| Account Type | ✅ Yes | Any value |
| Platform | ✅ Yes | WhatsApp/Telegram |
| Recipient Name | ❌ No (Optional) | Any text |
| Phone Number | ✅ Yes | 09/07 + 8 digits |

### Email

| Field | Required | Validation |
|-------|----------|------------|
| Account Type | ✅ Yes | Any value |
| Platform | ✅ Yes | Email |
| Recipient Name | ✅ Yes | Not empty |
| Email Address | ✅ Yes | Valid email format |
| Notes | ❌ No (Optional) | Any text (max 3 lines) |

---

## 🎯 Button States

### WhatsApp/Telegram
- **Ready**: 🔗 Generate Link
- **Loading**: ⏳ Generating...
- **Success**: ✓ Link Generated

### Email
- **Ready**: 📧 Send Invitation
- **Loading**: ⏳ Sending Email...
- **Success**: ✓ Email Sent

---

## 🧪 Testing

### Test Case 1: Send Email Invitation

**Steps:**
1. Select platform: Email
2. Enter recipient name: "John Doe"
3. Enter email: "john@example.com"
4. Enter notes (optional): "High potential customer"
5. Click "Send Invitation"

**Expected:**
- Loading state shows "Sending Email..."
- Success shows "Email Sent Successfully"
- Email success card displays with recipient details
- Fields lock after sending
- Button shows "Email Sent" with checkmark

### Test Case 2: Email Validation

**Test Invalid Email:**
```
Input: john.example.com
Expected: "Enter a valid email address"
```

**Test Empty Name:**
```
Input: (empty)
Expected: "Recipient name is required for EMAIL"
```

**Test Empty Email:**
```
Input: (empty)
Expected: "Email is required for EMAIL platform"
```

### Test Case 3: Platform Switch

**Steps:**
1. Select Email platform
2. Fill email fields
3. Switch to WhatsApp
4. All email fields should clear
5. Phone field should appear

---

## 📊 API Response Examples

### Success Response

```json
HTTP 200 OK

{
  // Empty or success message
}
```

### Error Response

```json
HTTP 400 Bad Request

{
  "message": "Invalid email address",
  "error": "VALIDATION_ERROR"
}
```

---

## 🎨 Success Card Sections

### 1. Header
- ✅ Checkmark icon
- Title: "Email Sent Successfully"

### 2. Main Message Box
- 📧 Email icon
- "Invitation Email Sent"
- Confirmation text with recipient email
- Info text about inbox delivery

### 3. Recipient Details
- Recipient name
- Email address
- Account type
- Notes (if provided)

---

## 🔍 Backend Requirements

The backend must:

1. **Accept POST request** to `/api/v1/invitations/send`
2. **Expect JSON body**:
   ```json
   {
     "recipientEmail": "string",
     "recipientName": "string",
     "linkType": "INDIVIDUAL|JOINT|ORGANIZATION",
     "notes": "string (optional)"
   }
   ```
3. **Send the invitation email** to the recipient
4. **Return 200/201** on success
5. **Include the invitation link** in the email body
6. **No need to return** link/QR code to the app

---

## 💡 Use Cases

### Use Case 1: Direct Email Invitation
**Scenario**: Customer service wants to send invitation directly

**Steps:**
1. Select Email platform
2. Enter customer details
3. Add notes about customer
4. Send invitation
5. Customer receives email with link

### Use Case 2: High-Value Customer
**Scenario**: Special handling for VIP customer

**Steps:**
1. Select Email platform
2. Enter customer info
3. Notes: "VIP customer - priority processing"
4. Send invitation
5. Backend can flag for special treatment

### Use Case 3: Bulk Email Campaign
**Scenario**: Multiple customers need invitations

**Steps:**
1. For each customer:
   - Select Email
   - Enter details
   - Add notes
   - Send
2. Each gets personalized email

---

## ⚠️ Important Notes

### 1. No Link Generation
- Email platform does NOT generate shareable link in the app
- Backend generates and includes link in the email
- App just triggers the email sending

### 2. Required Name Field
- For Email: Name is **REQUIRED**
- For WhatsApp/Telegram: Name is **OPTIONAL**
- Validation changes based on platform

### 3. Notes Field
- Only visible for Email platform
- Hidden for WhatsApp/Telegram
- Completely optional
- Supports multi-line text (3 lines)

### 4. Success Handling
- No "Copy" or "Share" buttons
- Just shows confirmation
- User knows email was sent
- Cannot retry (fields locked)

---

## 🔄 Future Enhancements

### Potential Improvements

1. **Email Preview**: Show email content before sending
2. **Send History**: Track sent invitations
3. **Resend Option**: Allow resending to same email
4. **Attachment**: Add documents to invitation email
5. **Template Selection**: Choose email template
6. **Scheduled Send**: Schedule invitation for later

---

## ✅ Checklist

Implementation:
- [x] Created `EmailInvitationRequest` model
- [x] Added `sendEmailInvitation()` service method
- [x] Added `sendEmailInvitation()` provider method
- [x] Added notes field to UI
- [x] Made name required for email
- [x] Created email success card
- [x] Updated button text for email
- [x] Added `_isEmailSent` state
- [x] Conditional rendering for email success

Testing:
- [ ] Test email validation
- [ ] Test required name for email
- [ ] Test notes field
- [ ] Test email sending
- [ ] Test success card display
- [ ] Test field locking
- [ ] Test platform switching

---

**Status**: ✅ **IMPLEMENTED**  
**Version**: 1.0.5  
**Date**: 2025-10-10  
**API Endpoint**: `/api/v1/invitations/send`

