# Dashboard Loading State Fix

## Problem
The stat cards were briefly showing values (often "0") before displaying the loading indicator ("-"), creating a jarring user experience.

## Root Cause
The provider was initializing data in its constructor, causing a race condition where:
1. Provider created and immediately started fetching data
2. UI hadn't rendered yet
3. Fast API responses would update state before first frame
4. User would see: `0` → `-` → `actual value` (incorrect order)

## Solution

### 1. **Initial State Always Shows Loading** (`dashboard_state.dart`)
```dart
const DashboardState({
  this.isLoadingCount = const {
    "New Applicants": true,    // Default to true
    "Awaiting Action": true,   // Default to true
    "Approved": true,           // Default to true
    "Rejected": true,           // Default to true
  },
  this.isLoading = true,
});
```
All loading states default to `true`, ensuring "-" shows first.

### 2. **Removed Auto-Initialization from Constructor** (`dashboard_provider.dart`)
```dart
DashboardNotifier(this._repository) : super(const DashboardState()) {
  // Don't initialize here - let the widget control initialization
  // This ensures the UI renders the loading state first
}
```
No longer calls `initialize()` in constructor.

### 3. **Widget Controls Initialization Timing** (`Dashboard.dart`)
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (!_hasInitialized) {
    _hasInitialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).initialize();
    });
  }
}
```
Initialization happens **after** the first frame renders, guaranteeing loading state is visible.

### 4. **Guaranteed Loading Duration** (`dashboard_provider.dart`)
```dart
Future<void> initialize() async {
  if (_initialized) return;
  _initialized = true;

  // 100ms delay ensures loading UI is visible
  await Future.delayed(const Duration(milliseconds: 100));
  
  await fetchUserId();
  await Future.wait([fetchUserCounts(), fetchLocalCustomers()]);
}
```
100ms minimum delay ensures users always see the loading indicator.

### 5. **Smooth Transitions** (`stat_card.dart`)
```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (Widget child, Animation<double> animation) {
    return FadeTransition(opacity: animation, child: child);
  },
  child: Text(
    isLoading ? DashboardConstants.loadingPlaceholder : count,
    key: ValueKey<String>(isLoading ? 'loading' : 'value_$count'),
    // ...
  ),
)
```
Smooth 300ms fade transition between loading and value states.

## Loading Sequence (Correct Order)

```
Time →

Frame 1:  Widget builds with initial state
          isLoadingCount = all true
          UI shows: "-" ✓

Frame 2+: User sees loading indicator for at least 100ms

After delay: initialize() called
             fetchUserId()
             fetchUserCounts() → API call

API response: State updated with real values
              isLoadingCount = all false

UI updates:   AnimatedSwitcher fades from "-" to actual value
              Smooth 300ms transition ✨

Result:      User sees: "-" → "42" (smooth fade)
```

## Benefits

✅ **Always shows loading first** - No more flickering values  
✅ **Smooth transitions** - Professional fade animation  
✅ **Predictable behavior** - Consistent loading sequence  
✅ **Better UX** - Users know data is being fetched  
✅ **No race conditions** - Initialization properly sequenced  

## Testing Checklist

- [ ] Dashboard shows "-" on first load
- [ ] After ~100ms, values fade in smoothly
- [ ] Pull-to-refresh shows "-" then values
- [ ] Fast network doesn't skip loading state
- [ ] Slow network shows "-" until data arrives
- [ ] Offline mode shows "-" then local data
- [ ] No flickering or value overlap
- [ ] Smooth 300ms fade transition visible

## Technical Details

**Key Changes:**
- Removed auto-init from provider constructor
- Added 100ms guaranteed loading delay
- Widget-controlled initialization with `postFrameCallback`
- AnimatedSwitcher with FadeTransition
- Unique ValueKey per state change
- Initialization guard flag to prevent duplicates

**Files Modified:**
1. `models/dashboard_state.dart` - Default loading states to true
2. `providers/dashboard_provider.dart` - Removed constructor init, added delay
3. `Dashboard.dart` - Widget-controlled initialization timing
4. `widgets/stat_card.dart` - AnimatedSwitcher with proper keys

**Performance Impact:**
- Minimal: 100ms intentional delay on initial load only
- Improved perceived performance due to clear loading state
- Smooth animations enhance user experience

