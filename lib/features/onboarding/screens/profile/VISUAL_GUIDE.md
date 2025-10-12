# Visual Guide - Profile Statistics Feature

## 📱 Screen Layout

```
╔════════════════════════════════════════╗
║  Profile Screen                    [⏻] ║
╠════════════════════════════════════════╣
║                                        ║
║  ┌──────────────────────────────────┐ ║
║  │ 👤  Username                     │ ║
║  │     Role Badge                   │ ║
║  └──────────────────────────────────┘ ║
║                                        ║
║  ┌──────────────────────────────────┐ ║
║  │ 🏢 Branch Information            │ ║
║  │  • Main Branch                   │ ║
║  │  • Other Branches                │ ║
║  └──────────────────────────────────┘ ║
║                                        ║
║  ┌──────────────────────────────────┐ ║
║  │ 📊 Statistics           ← NEW!   │ ║
║  │                                  │ ║
║  │  ┌────────┐  ┌────────┐         │ ║
║  │  │   42   │  │   1    │         │ ║
║  │  │ Total  │  │ Opened │         │ ║
║  │  │ Sent   │  │        │         │ ║
║  │  └────────┘  └────────┘         │ ║
║  │                                  │ ║
║  │  ┌────────┐  ┌────────┐         │ ║
║  │  │   6    │  │   0    │         │ ║
║  │  │Clicked │  │Register│         │ ║
║  │  └────────┘  └────────┘         │ ║
║  │                                  │ ║
║  │  ┌──────────────────────────┐   │ ║
║  │  │ 👁 Open Rate:      2.4%  │   │ ║
║  │  │ 👆 Click Rate:    14.3%  │   │ ║
║  │  │ 📈 Conversion:     0.0%  │   │ ║
║  │  └──────────────────────────┘   │ ║
║  └──────────────────────────────────┘ ║
║                                        ║
║  ┌──────────────────────────────────┐ ║
║  │ 📜 Recent Invitations   ← NEW!  │ ║
║  │                                  │ ║
║  │ ┌────────────────────────────┐  │ ║
║  │ │ Gemechu      [CLICKED] 🟧  │  │ ║
║  │ │ 📧 EMAIL  👤 INDIVIDUAL    │  │ ║
║  │ │ ✓ Opened  ✓ Clicked  2h ago│  │ ║
║  │ └────────────────────────────┘  │ ║
║  │                                  │ ║
║  │ ┌────────────────────────────┐  │ ║
║  │ │ Abdiisaa       [SENT] 🟦   │  │ ║
║  │ │ 💬 WHATSAPP 👤 INDIVIDUAL  │  │ ║
║  │ │ ✗ Opened  ✗ Clicked  5h ago│  │ ║
║  │ └────────────────────────────┘  │ ║
║  │                                  │ ║
║  │ ┌────────────────────────────┐  │ ║
║  │ │ John         [OPENED] 🟩   │  │ ║
║  │ │ ✈️ TELEGRAM 👤 JOINT       │  │ ║
║  │ │ ✓ Opened  ✗ Clicked  1d ago│  │ ║
║  │ └────────────────────────────┘  │ ║
║  └──────────────────────────────────┘ ║
║                                        ║
║  ┌──────────────────────────────────┐ ║
║  │ ⚙️ Settings                      │ ║
║  │  • About                         │ ║
║  │  • Help                          │ ║
║  └──────────────────────────────────┘ ║
║                                        ║
╚════════════════════════════════════════╝
```

---

## 🎨 Color Scheme

### Status Colors
```
🟦 SENT      - Blue (#2196F3)
🟧 CLICKED   - Orange
🟩 OPENED    - Green (#75E6DA)
🟦 REGISTERED - Cyan (#189AB4)
```

### Platform Icons
```
💬 WHATSAPP  - Icons.chat
✈️ TELEGRAM  - Icons.telegram
📧 EMAIL     - Icons.email_outlined
```

---

## 📊 Statistics Card Breakdown

```
┌─────────────────────────────────────┐
│ 📊 Statistics                       │
├─────────────────────────────────────┤
│                                     │
│  Grid Layout (2x2)                  │
│                                     │
│  ┌──────────────┐ ┌──────────────┐ │
│  │ 📤 Icon      │ │ 📬 Icon      │ │
│  │ 42           │ │ 1            │ │
│  │ Total Sent   │ │ Opened       │ │
│  └──────────────┘ └──────────────┘ │
│                                     │
│  ┌──────────────┐ ┌──────────────┐ │
│  │ 👆 Icon      │ │ ✅ Icon      │ │
│  │ 6            │ │ 0            │ │
│  │ Clicked      │ │ Registered   │ │
│  └──────────────┘ └──────────────┘ │
│                                     │
│  Rates Section (Gray Background)    │
│  ┌─────────────────────────────┐   │
│  │ 👁 Open Rate:        2.4%   │   │
│  │ 👆 Click Rate:      14.3%   │   │
│  │ 📈 Conversion Rate:  0.0%   │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## 📜 Invitation Tile Structure

```
┌────────────────────────────────────┐
│  Row 1: Name + Status Badge        │
│  Gemechu              [CLICKED] 🟧 │
│                                    │
│  Row 2: Platform + Account Type    │
│  💬 WHATSAPP  👤 INDIVIDUAL        │
│                                    │
│  Row 3: Engagement + Time          │
│  ✓ Opened  ✓ Clicked      2h ago  │
└────────────────────────────────────┘
```

---

## 🔄 Loading States

### Statistics Loading
```
┌─────────────────────────────┐
│ 📊 Statistics               │
├─────────────────────────────┤
│                             │
│         ⭕ Loading...       │
│                             │
└─────────────────────────────┘
```

### Invitations Loading
```
┌─────────────────────────────┐
│ 📜 Recent Invitations       │
├─────────────────────────────┤
│                             │
│         ⭕ Loading...       │
│                             │
└─────────────────────────────┘
```

---

## ❌ Error States

### With Retry Button
```
┌─────────────────────────────┐
│ 📊 Statistics               │
├─────────────────────────────┤
│                             │
│     ⚠️                      │
│  Failed to load statistics  │
│                             │
│     [ Retry Button ]        │
│                             │
└─────────────────────────────┘
```

---

## 📭 Empty State

### No Invitations
```
┌─────────────────────────────────┐
│ 📜 Recent Invitations           │
├─────────────────────────────────┤
│                                 │
│           📥                    │
│      No invitations yet         │
│                                 │
│  Start sending invitations to   │
│       see them here             │
│                                 │
└─────────────────────────────────┘
```

---

## 🎯 Interactive Elements

### Engagement Indicators

**Email Opened**
```
✓ Opened   ← Green checkmark (true)
✗ Opened   ← Gray X (false)
```

**Link Clicked**
```
✓ Clicked  ← Cyan checkmark (true)
✗ Clicked  ← Gray X (false)
```

---

## 📱 Responsive Design

### Padding & Spacing
```
Container Padding:    20px
Card Border Radius:   16px
Stat Card Padding:    16px
Stat Border Radius:   12px
Gap between cards:    12px
Vertical spacing:     20px
```

### Typography
```
Section Title:        18px, Bold
Stat Value:          24px, Bold
Stat Label:          12px
Invitation Name:     16px, Bold
Status Badge:        11px, SemiBold
Detail Text:         12px
Time Text:           12px, Gray
```

---

## 🎨 Design System

### Shadows
```
Box Shadow:
  - Color: Black 5% opacity
  - Blur: 10px
  - Offset: (0, 2)
```

### Borders
```
Stat Cards:
  - Width: 1px
  - Color: Main color with 30% opacity
  - Radius: 12px
```

### Background Colors
```
White Cards:     #FFFFFF
Gray Section:    Gray[50]
Stat Cards:      Color with 10% opacity
```

---

## 📊 Data Flow Visualization

```
User Opens Profile
       ↓
   ┌───────────────────────┐
   │  ProfileScreen        │
   │  (ConsumerWidget)     │
   └───────────────────────┘
           ↓
   ┌───────────────────────┐
   │  Riverpod Providers   │
   │  - statsProvider      │
   │  - invitationsProvider│
   └───────────────────────┘
           ↓
   ┌───────────────────────┐
   │  InvitationService    │
   │  - fetchStats()       │
   │  - fetchInvitations() │
   └───────────────────────┘
           ↓
   ┌───────────────────────┐
   │  API Endpoints        │
   │  GET /stats           │
   │  GET /my-invitations  │
   └───────────────────────┘
           ↓
   ┌───────────────────────┐
   │  JSON Response        │
   └───────────────────────┘
           ↓
   ┌───────────────────────┐
   │  Models               │
   │  - fromJson()         │
   └───────────────────────┘
           ↓
   ┌───────────────────────┐
   │  UI Updates           │
   │  - StatisticsCard     │
   │  - InvitationsCard    │
   └───────────────────────┘
```

---

## 🔄 Refresh Flow

```
User Pulls Down
       ↓
RefreshIndicator Triggered
       ↓
ref.refresh(statsProvider)
ref.refresh(invitationsProvider)
       ↓
Providers Rebuild
       ↓
Services Fetch New Data
       ↓
UI Updates with Fresh Data
```

---

## 🎯 Time Formatting

```
< 1 hour    → "45m ago"
< 24 hours  → "2h ago"
< 7 days    → "5d ago"
> 7 days    → "10/10/2025"
```

---

## ✅ Success Indicators

```
Data Loaded Successfully:
  ✓ Shows all statistics
  ✓ Shows all invitations
  ✓ Colors applied correctly
  ✓ Time formatted properly
  ✓ Icons displayed
```

---

**This visual guide helps understand the UI structure and behavior!** 🎨

