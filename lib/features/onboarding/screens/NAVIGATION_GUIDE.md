# Navigation Guide - Statistics Feature

## 🗺️ Complete Navigation Map

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP STRUCTURE                            │
└─────────────────────────────────────────────────────────────────┘

                         Profile Screen
                    ┌──────────────────────┐
                    │  👤 Profile Card     │
                    ├──────────────────────┤
                    │  🏢 Branch Info      │
                    ├──────────────────────┤
                    │  🎯 Quick Actions    │
                    │  ┌────────────────┐  │
                    │  │ 📊 Overall     │  │─────┐
                    │  │    Statistics  │  │     │
                    │  └────────────────┘  │     │
                    │  ┌────────────────┐  │     │
                    │  │ 📜 Recent      │  │─────┼─┐
                    │  │    Invitations │  │     │ │
                    │  └────────────────┘  │     │ │
                    ├──────────────────────┤     │ │
                    │  ⚙️ Settings         │     │ │
                    └──────────────────────┘     │ │
                                                 │ │
                    ┌────────────────────────────┘ │
                    │                              │
                    ↓                              ↓
                                                   
        Overall Stats Page          Recent Invitations Page
    ┌────────────────────┐         ┌────────────────────────┐
    │ ← Back to Profile  │         │ ← Back to Profile      │
    ├────────────────────┤         ├────────────────────────┤
    │                    │         │                        │
    │  📊 Statistics     │         │  📜 Invitation #1      │
    │  ┌──────────────┐ │         │  📜 Invitation #2      │
    │  │ Total: 42    │ │         │  📜 Invitation #3      │
    │  │ Opened: 1    │ │         │  ...                   │
    │  │ Clicked: 6   │ │         │  📜 Invitation #10     │
    │  │ Register: 0  │ │         │  ⭕ Loading...         │
    │  └──────────────┘ │         │  📜 Invitation #11     │
    │                    │         │  ...                   │
    │  📈 Rates          │         │  📜 Invitation #20     │
    │  Open: 2.4%       │         │  ⭕ Loading...         │
    │  Click: 14.3%     │         │  📜 Invitation #21     │
    │  Convert: 0.0%    │         │  ...                   │
    │                    │         │  (Keeps loading)       │
    │  📅 This Month     │         │                        │
    │  Sent: 42         │         └────────────────────────┘
    │  Target: 50       │
    │  Progress: 84%    │
    │  ████████░░       │
    │                    │
    └────────────────────┘
```

---

## 🔄 User Flow Diagrams

### Flow 1: View Statistics

```
User                     System
 │                         │
 │  Opens Profile         │
 │─────────────────────────>
 │                         │
 │  Sees Quick Actions    │
 │<─────────────────────────
 │                         │
 │  Taps "Overall         │
 │      Statistics"        │
 │─────────────────────────>
 │                         │
 │                        Fetches Stats
 │                        GET /stats
 │                         │
 │  Shows Loading...      │
 │<─────────────────────────
 │                         │
 │  Displays Stats        │
 │<─────────────────────────
 │                         │
 │  Taps Back Button      │
 │─────────────────────────>
 │                         │
 │  Returns to Profile    │
 │<─────────────────────────
```

### Flow 2: View Invitations with Pagination

```
User                     System
 │                         │
 │  Opens Profile         │
 │─────────────────────────>
 │                         │
 │  Taps "Recent          │
 │      Invitations"       │
 │─────────────────────────>
 │                         │
 │                        Fetches Page 0
 │                        GET /invitations?page=0
 │                         │
 │  Shows Loading...      │
 │<─────────────────────────
 │                         │
 │  Displays 10 items     │
 │<─────────────────────────
 │                         │
 │  Scrolls Down          │
 │─────────────────────────>
 │                         │
 │                        Detects near bottom
 │                        Fetches Page 1
 │                        GET /invitations?page=1
 │                         │
 │  Shows Loading         │
 │  at bottom...          │
 │<─────────────────────────
 │                         │
 │  Appends 10 more       │
 │  (Total: 20)           │
 │<─────────────────────────
 │                         │
 │  Scrolls Down More     │
 │─────────────────────────>
 │                         │
 │                        Fetches Page 2
 │                         │
 │  Appends 10 more       │
 │  (Total: 30)           │
 │<─────────────────────────
 │                         │
 │  ... (continues)       │
 │                         │
 │  Taps Back Button      │
 │─────────────────────────>
 │                         │
 │  Returns to Profile    │
 │<─────────────────────────
```

### Flow 3: Refresh Data

```
User                     System
 │                         │
 │  Opens Invitations     │
 │─────────────────────────>
 │                         │
 │  Sees 30 items         │
 │  (from pagination)      │
 │<─────────────────────────
 │                         │
 │  Pulls Down            │
 │  (Pull to Refresh)      │
 │─────────────────────────>
 │                         │
 │                        Resets to Page 0
 │                        Clears list
 │                        GET /invitations?page=0
 │                         │
 │  Shows Loading...      │
 │<─────────────────────────
 │                         │
 │  Displays fresh        │
 │  10 items              │
 │<─────────────────────────
```

---

## 📱 Screen States

### Profile Screen States

```
┌─────────────────────────────┐
│ State: Normal               │
│ ┌─────────────────────────┐ │
│ │ Quick Actions           │ │
│ │ • Overall Statistics    │ │
│ │ • Recent Invitations    │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

### Overall Stats Page States

```
┌─────────────────────────────┐
│ State: Loading              │
│ ┌─────────────────────────┐ │
│ │   ⭕ Loading...         │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘

┌─────────────────────────────┐
│ State: Data Loaded          │
│ ┌─────────────────────────┐ │
│ │ Total: 42               │ │
│ │ Opened: 1               │ │
│ │ Clicked: 6              │ │
│ │ Registered: 0           │ │
│ │ Rates, Progress, etc.   │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘

┌─────────────────────────────┐
│ State: Error                │
│ ┌─────────────────────────┐ │
│ │   ⚠️ Error loading      │ │
│ │   [Retry Button]        │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

### Recent Invitations Page States

```
┌─────────────────────────────┐
│ State: Initial Loading      │
│ ┌─────────────────────────┐ │
│ │   ⭕ Loading...         │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘

┌─────────────────────────────┐
│ State: Data Loaded          │
│ ┌─────────────────────────┐ │
│ │ Invitation #1           │ │
│ │ Invitation #2           │ │
│ │ ...                     │ │
│ │ Invitation #10          │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘

┌─────────────────────────────┐
│ State: Loading More         │
│ ┌─────────────────────────┐ │
│ │ Invitation #1-10        │ │
│ │ ⭕ Loading more...      │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘

┌─────────────────────────────┐
│ State: All Loaded           │
│ ┌─────────────────────────┐ │
│ │ Invitation #1-42        │ │
│ │ (No more items)         │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘

┌─────────────────────────────┐
│ State: Empty                │
│ ┌─────────────────────────┐ │
│ │   📥                    │ │
│ │   No invitations yet    │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘

┌─────────────────────────────┐
│ State: Error                │
│ ┌─────────────────────────┐ │
│ │   ⚠️ Error loading      │ │
│ │   [Retry Button]        │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

---

## 🎯 Interaction Points

### Profile Screen

| Element | Action | Result |
|---------|--------|--------|
| Overall Statistics button | Tap | Navigate to Overall Stats Page |
| Recent Invitations button | Tap | Navigate to Recent Invitations Page |
| Pull down | Refresh | Reload profile data |

### Overall Stats Page

| Element | Action | Result |
|---------|--------|--------|
| Back button | Tap | Return to Profile Screen |
| Pull down | Refresh | Reload statistics |
| Retry button (on error) | Tap | Retry loading stats |

### Recent Invitations Page

| Element | Action | Result |
|---------|--------|--------|
| Back button | Tap | Return to Profile Screen |
| Scroll down | Near bottom | Load next 10 items |
| Pull down | Refresh | Reset to page 0, reload |
| Retry button (on error) | Tap | Retry loading invitations |

---

## 📊 Data Loading Timeline

### Overall Stats Page:

```
Time    Event
──────────────────────────────────
0ms     User taps button
        ↓
50ms    Page opens
        ↓
100ms   Shows loading spinner
        ↓
150ms   API call starts
        ↓
500ms   API responds
        ↓
550ms   Data parsed
        ↓
600ms   UI updated with stats
        ↓
Done    User sees statistics
```

### Recent Invitations Page (with pagination):

```
Time    Event
──────────────────────────────────
0ms     User taps button
        ↓
50ms    Page opens
        ↓
100ms   Shows loading spinner
        ↓
150ms   API call starts (page=0)
        ↓
500ms   API responds (10 items)
        ↓
550ms   UI updated with 10 items
        ↓
        User scrolls down...
        ↓
2000ms  Near bottom detected
        ↓
2050ms  Shows bottom loading
        ↓
2100ms  API call starts (page=1)
        ↓
2450ms  API responds (10 more)
        ↓
2500ms  UI updated (20 total)
        ↓
        User scrolls down...
        ↓
4000ms  Near bottom detected
        ↓
4050ms  API call starts (page=2)
        ↓
4400ms  API responds (10 more)
        ↓
4450ms  UI updated (30 total)
        ↓
        ... continues ...
```

---

## 🔄 State Transitions

### Overall Stats Page:

```
   [Initial]
      ↓
   Loading ─────Error────→ Error State
      ↓                        ↓
   Success                  [Retry]
      ↓                        ↓
   Display Stats ←────────────┘
      ↓
   [Refresh] ────────→ Loading
      ↓                   ↓
   Back ────────→ Profile Screen
```

### Recent Invitations Page:

```
   [Initial]
      ↓
   Loading Page 0 ──Error──→ Error State
      ↓                          ↓
   Display 10 Items           [Retry]
      ↓                          ↓
   [Scroll Down] ←──────────────┘
      ↓
   Loading Page 1
      ↓
   Display 20 Items
      ↓
   [Scroll Down]
      ↓
   Loading Page 2
      ↓
   Display 30 Items
      ↓
   ... (continues until hasMore = false)
      ↓
   [Refresh] ────→ Reset to Page 0
      ↓
   [Back] ───────→ Profile Screen
```

---

## 🎨 Visual Navigation

```
┌─────────────────┐
│  Profile Screen │
│                 │
│  ┌───────────┐  │
│  │Quick      │  │
│  │Actions    │  │
│  │           │  │
│  │[Stats]  ───┼─────────┐
│  │[Invites]───┼────┐    │
│  └───────────┘  │    │    │
└─────────────────┘    │    │
                       │    │
        ┌──────────────┘    │
        │                   │
        ↓                   ↓
┌───────────────┐   ┌───────────────┐
│Overall Stats  │   │Recent         │
│               │   │Invitations    │
│[←Back]        │   │[←Back]        │
│               │   │               │
│Stats Display  │   │Item 1-10      │
│               │   │⭕ Loading...  │
│               │   │Item 11-20     │
│               │   │⭕ Loading...  │
│               │   │Item 21-30     │
└───────────────┘   └───────────────┘
        │                   │
        └──────┬────────────┘
               │
               ↓
        ┌─────────────┐
        │Profile      │
        │Screen       │
        └─────────────┘
```

---

## 🧭 Quick Reference

### To View Statistics:
1. Open Profile
2. Tap "Overall Statistics"
3. View stats
4. Tap back

### To View Invitations:
1. Open Profile
2. Tap "Recent Invitations"
3. View first 10
4. Scroll for more
5. Tap back

### To Refresh:
- Pull down on any page

### To Go Back:
- Tap back button (top-left)
- Or swipe from left edge

---

**This guide covers all navigation flows in the statistics feature!** 🗺️

