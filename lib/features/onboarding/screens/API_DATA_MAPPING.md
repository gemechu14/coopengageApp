# API Data Mapping Reference

## 📊 Statistics API

### Endpoint
```
GET {{url}}/api/v1/invitations/stats
Authorization: Bearer {token}
```

### Response Structure
```json
{
  "success": true,
  "data": {
    "totalInvitationsSent": 42,
    "totalEmailsOpened": 1,
    "totalLinksClicked": 6,
    "totalRegistrations": 0,
    "openRate": 2.380952380952381,
    "clickRate": 14.285714285714286,
    "conversionRate": 0.0,
    "currentMonthSent": 42,
    "currentMonthTarget": 0,
    "targetProgress": 0.0
  }
}
```

### Fields Used in UI

| API Field | Display Name | Format | Location in UI |
|-----------|-------------|--------|----------------|
| `totalInvitationsSent` | Total Sent | Integer | Top-left stat card |
| `totalEmailsOpened` | Opened | Integer | Top-right stat card |
| `totalLinksClicked` | Clicked | Integer | Bottom-left stat card |
| `totalRegistrations` | Registered | Integer | Bottom-right stat card |
| `openRate` | Open Rate | 2.4% | Rates section, line 1 |
| `clickRate` | Click Rate | 14.3% | Rates section, line 2 |
| `conversionRate` | Conversion Rate | 0.0% | Rates section, line 3 |

### Fields NOT Currently Used

| API Field | Reason |
|-----------|--------|
| `currentMonthSent` | Not displayed (can be added) |
| `currentMonthTarget` | Not displayed (can be added) |
| `targetProgress` | Not displayed (can be added) |

---

## 📜 Invitations API

### Endpoint
```
GET {{url}}/api/v1/invitations/my-invitations?page=0&size=10&sortBy=sentAt&sortDirection=DESC
Authorization: Bearer {token}
```

### Response Structure
```json
[
  {
    "id": 76,
    "recipientEmail": "gemechubulti11@gmail.com",
    "recipientName": "Gemechu",
    "trackingToken": "fb1eb328-5287-468e-ada2-657fbde7387a",
    "linkType": "INDIVIDUAL",
    "registrationUrl": "https://my.coopbankoromiasc.com/individualaccount?ref=...",
    "status": "CLICKED",
    "platform": "EMAIL",
    "sharedViaSocialMedia": false,
    "emailOpened": true,
    "emailOpenedAt": "2025-10-10T15:07:26.552887",
    "linkClicked": true,
    "linkClickedAt": "2025-10-10T15:09:23.112714",
    "registered": false,
    "registeredAt": null,
    "clickCount": 1,
    "openCount": 1,
    "notes": null,
    "sentAt": "2025-10-10T15:07:22.342545",
    "sentByName": "adb",
    "sentByUserId": 453
  }
]
```

### Fields Used in UI (As Requested)

| API Field | Display Name | Format | Location in Tile |
|-----------|-------------|--------|------------------|
| `recipientName` | Recipient Name | String | Header, left side |
| `linkType` | Account Type | Badge | Row 2, right side |
| `status` | Status | Badge | Header, right side |
| `platform` | Platform | Icon+Text | Row 2, left side |
| `emailOpened` | Opened | ✓/✗ | Row 3, left |
| `emailOpenedAt` | Opened Time | Hidden | Not displayed |
| `linkClicked` | Clicked | ✓/✗ | Row 3, middle |
| `linkClickedAt` | Clicked Time | Hidden | Not displayed |
| `sentAt` | Time Ago | "2h ago" | Row 3, right |

### Fields NOT Currently Used

| API Field | Type | Reason |
|-----------|------|--------|
| `id` | Integer | Internal ID, not needed in UI |
| `recipientEmail` | String | Privacy/space concerns |
| `trackingToken` | String | Internal tracking |
| `registrationUrl` | String | Not needed in summary |
| `sharedViaSocialMedia` | Boolean | Not requested |
| `registered` | Boolean | Not requested |
| `registeredAt` | DateTime | Not requested |
| `clickCount` | Integer | Not requested |
| `openCount` | Integer | Not requested |
| `notes` | String | Not requested |
| `sentByName` | String | Redundant (current user) |
| `sentByUserId` | Integer | Redundant (current user) |

---

## 🎨 Field Display Formatting

### Status Field
Maps to color-coded badges:

| Value | Color | Display |
|-------|-------|---------|
| `SENT` | Blue (#2196F3) | `[SENT]` |
| `CLICKED` | Orange | `[CLICKED]` |
| `OPENED` | Green (#75E6DA) | `[OPENED]` |
| `REGISTERED` | Cyan (#189AB4) | `[REGISTERED]` |

### Platform Field
Maps to icons and text:

| Value | Icon | Color | Display |
|-------|------|-------|---------|
| `WHATSAPP` | 💬 Icons.chat | Blue | 💬 WHATSAPP |
| `TELEGRAM` | ✈️ Icons.telegram | Blue | ✈️ TELEGRAM |
| `EMAIL` | 📧 Icons.email_outlined | Blue | 📧 EMAIL |

### LinkType Field
Maps to account type badges:

| Value | Icon | Display |
|-------|------|---------|
| `INDIVIDUAL` | 👤 Icons.account_circle_outlined | 👤 INDIVIDUAL |
| `JOINT` | 👥 Icons.account_circle_outlined | 👥 JOINT |
| `ORGANIZATION` | 🏢 Icons.account_circle_outlined | 🏢 ORGANIZATION |

### EmailOpened Field
Boolean indicator:

| Value | Icon | Color | Display |
|-------|------|-------|---------|
| `true` | ✓ Icons.check_circle | Cyan | ✓ Opened |
| `false` | ✗ Icons.cancel | Gray | ✗ Opened |

### LinkClicked Field
Boolean indicator:

| Value | Icon | Color | Display |
|-------|------|-------|---------|
| `true` | ✓ Icons.check_circle | Cyan | ✓ Clicked |
| `false` | ✗ Icons.cancel | Gray | ✗ Clicked |

### SentAt Field
Relative time formatting:

| Time Difference | Format | Example |
|----------------|--------|---------|
| < 1 hour | `{minutes}m ago` | `45m ago` |
| < 24 hours | `{hours}h ago` | `2h ago` |
| < 7 days | `{days}d ago` | `5d ago` |
| > 7 days | `DD/MM/YYYY` | `10/10/2025` |

---

## 📊 Data Processing Flow

### Statistics
```
API Response (JSON)
      ↓
Extract 'data' field
      ↓
InvitationStats.fromJson()
      ↓
Statistics Model
      ↓
Display in StatisticsCard
```

### Invitations
```
API Response (JSON Array)
      ↓
Check if wrapped in 'content' or 'data'
      ↓
Iterate through array
      ↓
Invitation.fromJson() for each item
      ↓
List<Invitation>
      ↓
Display in InvitationsListCard
```

---

## 🔄 Type Conversions

### Numbers to Strings
```dart
// Statistics
totalInvitationsSent: 42 → "42"
totalEmailsOpened: 1 → "1"
```

### Numbers to Percentages
```dart
// Rates
openRate: 2.380952380952381 → "2.4%"
clickRate: 14.285714285714286 → "14.3%"
conversionRate: 0.0 → "0.0%"
```

### DateTime to Relative Time
```dart
// Time formatting
"2025-10-10T15:07:22.342545" → "2h ago"
"2025-10-05T10:00:00.000000" → "5d ago"
"2025-09-01T10:00:00.000000" → "01/09/2025"
```

### Boolean to Icon
```dart
// Engagement indicators
emailOpened: true → ✓ (green check)
emailOpened: false → ✗ (gray X)
linkClicked: true → ✓ (cyan check)
linkClicked: false → ✗ (gray X)
```

---

## 🎯 Model Classes

### InvitationStats Model
```dart
class InvitationStats {
  final int totalInvitationsSent;    // Used ✓
  final int totalEmailsOpened;       // Used ✓
  final int totalLinksClicked;       // Used ✓
  final int totalRegistrations;      // Used ✓
  final double openRate;             // Used ✓
  final double clickRate;            // Used ✓
  final double conversionRate;       // Used ✓
  final int currentMonthSent;        // Stored, not displayed
  final int currentMonthTarget;      // Stored, not displayed
  final double targetProgress;       // Stored, not displayed
}
```

### Invitation Model
```dart
class Invitation {
  final int id;                      // Stored only
  final String recipientName;        // Used ✓
  final String linkType;             // Used ✓
  final String status;               // Used ✓
  final String platform;             // Used ✓
  final bool emailOpened;            // Used ✓
  final String? emailOpenedAt;       // Stored only
  final bool linkClicked;            // Used ✓
  final String? linkClickedAt;       // Stored only
  final String sentAt;               // Used ✓ (formatted)
}
```

---

## 🔍 Data Validation

### API Response Checks

**Statistics Response:**
```dart
// Check if response has 'data' field
if (response.data['data'] != null) {
  return InvitationStats.fromJson(response.data['data']);
}
```

**Invitations Response:**
```dart
// Check if array or wrapped
final List<dynamic> invitationsJson = 
  data is List ? data : (data['content'] ?? data['data'] ?? []);
```

### Null Safety
All fields have default values:
```dart
totalInvitationsSent: json['totalInvitationsSent'] ?? 0
recipientName: json['recipientName'] ?? ''
emailOpened: json['emailOpened'] ?? false
emailOpenedAt: json['emailOpenedAt']  // nullable
```

---

## 📋 Quick Reference

### What's Displayed

**Statistics Card:**
- ✅ Total Sent
- ✅ Opened Count
- ✅ Clicked Count
- ✅ Registered Count
- ✅ Open Rate %
- ✅ Click Rate %
- ✅ Conversion Rate %

**Invitation Tile:**
- ✅ Recipient Name
- ✅ Status Badge
- ✅ Platform Icon + Name
- ✅ Account Type
- ✅ Email Opened (✓/✗)
- ✅ Link Clicked (✓/✗)
- ✅ Time Ago

### What's NOT Displayed

**Statistics:**
- ❌ Current Month Sent
- ❌ Current Month Target
- ❌ Target Progress

**Invitations:**
- ❌ ID
- ❌ Email Address
- ❌ Tracking Token
- ❌ Registration URL
- ❌ Shared Via Social Media
- ❌ Email Opened At (timestamp)
- ❌ Link Clicked At (timestamp)
- ❌ Registered Flag
- ❌ Registered At
- ❌ Click Count
- ❌ Open Count
- ❌ Notes
- ❌ Sent By Name
- ❌ Sent By User ID

---

## 💡 Future Enhancement Ideas

### Could Add to Statistics Card:
- Monthly target progress bar
- Comparison with previous month
- Best performing platform

### Could Add to Invitations:
- Filter by status
- Filter by platform
- Search by recipient name
- Show recipient email on tap
- Show full timestamp on tap
- Click/open counts

---

**This document serves as a complete reference for understanding how API data maps to the UI!** 📊

