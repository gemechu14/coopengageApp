# Dashboard Debug Guide

## Issue: Values don't update until manual refresh

### Check These Things:

1. **Check Console Logs**
   Look for these messages in your debug console:
   ```
   - "Dashboard build: New=X, Approved=Y, Loading={...}"
   - "fetchUserCounts: Starting (isOnline: true/false)"
   - "fetchUserCounts: Fetching from API" or "Fetching from local database"
   - "fetchUserCounts: Data fetched - New: X, Awaiting: Y, Approved: Z, Rejected: W"
   - "fetchUserCounts: State updated successfully"
   - "Dashboard initialization completed successfully"
   ```

2. **Common Issues & Solutions:**

   **A. Token Issues**
   - If you see "Token expired" errors → Token validation is failing
   - Solution: Check `TokenService.isTokenValid()` implementation
   - Check if token is actually stored in secure storage

   **B. User ID is Null**
   - If you see "fetchUserCounts: User ID is null!"
   - Solution: `fetchUserId()` is failing or returning null
   - Check token decoding in `DashboardRepository.fetchUserId()`

   **C. API/Network Errors**
   - If you see "Error fetching user counts: [error]"
   - Check network connectivity
   - Check API endpoint is correct
   - Check backend is running

   **D. Database Errors (Offline Mode)**
   - If offline and see database errors
   - Check `DatabaseHelper.getCustomers()` is working
   - Check database is initialized

   **E. Provider Not Rebuilding Widget**
   - If logs show "State updated successfully" but UI doesn't change
   - Check if Dashboard widget is inside a Navigator that loses Provider context
   - Try wrapping Dashboard's parent with `Consumer` widget

3. **Quick Fixes to Try:**

   **Fix 1: Ensure Provider Context**
   If Dashboard is pushed via Navigator, wrap it:
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => Consumer(
         builder: (context, ref, child) => Dashboard(onSettingsTap: () {}),
       ),
     ),
   );
   ```

   **Fix 2: Force Rebuild**
   After initialization, try invalidating the provider:
   ```dart
   // In Dashboard after initialization
   ref.invalidate(dashboardProvider);
   ```

   **Fix 3: Check Global Variables**
   The code updates global variables like `TOTALAPPROVED`, `TOTALPENDING`, etc.
   Make sure these aren't being used elsewhere in a way that causes conflicts.

4. **Test Sequence:**

   ```
   Step 1: Open Dashboard
   Expected: See "-" in all cards
   
   Step 2: Wait ~200ms
   Expected: See actual numbers appear with smooth fade
   
   Step 3: Pull to refresh
   Expected: See "-" briefly, then numbers update
   ```

5. **Debug Mode - Detailed Logging:**

   Add this to see every state change:
   ```dart
   // In DashboardNotifier
   @override
   set state(DashboardState value) {
     print("STATE CHANGE: isLoading=${value.isLoading}, "
           "New=${value.userCounts.newApplicants}, "
           "LoadingCount=${value.isLoadingCount}");
     super.state = value;
   }
   ```

6. **Check API Response:**

   In `dashboard_repository.dart`, add logging:
   ```dart
   print("API Response: ${response.body}");
   print("Status Code: ${response.statusCode}");
   ```

## Most Likely Issues:

Based on the symptom "values don't update until manual refresh":

1. **Provider is being recreated** - Check if Dashboard is in a route that recreates the provider
2. **Token is invalid** - First API call fails, but error is swallowed
3. **User ID fetch fails** - Can't query database without user ID
4. **State update happens but widget doesn't rebuild** - Provider context lost in navigation

## Quick Test:

Add this button to Dashboard to manually trigger update:
```dart
FloatingActionButton(
  onPressed: () async {
    print("Manual refresh triggered");
    await ref.read(dashboardProvider.notifier).refresh();
    print("Manual refresh completed");
  },
  child: Icon(Icons.refresh),
)
```

If clicking this button shows the values, then initialization is the problem.
If clicking this button STILL doesn't show values, then provider context is the problem.

