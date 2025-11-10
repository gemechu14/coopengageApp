# Dashboard Module

A clean, sophisticated, and well-structured dashboard implementation using Riverpod for state management.

## Architecture Overview

This dashboard follows a **clean architecture** pattern with clear separation of concerns:

```
Dashboard/
├── constants/          # Constants, colors, and styles
│   └── dashboard_constants.dart
├── models/            # Data models and state classes
│   └── dashboard_state.dart
├── providers/         # Riverpod providers and state management
│   └── dashboard_provider.dart
├── repository/        # Data access layer (API + Local DB)
│   └── dashboard_repository.dart
├── widgets/           # Reusable UI components
│   ├── dashboard_banner.dart
│   ├── stat_card.dart
│   ├── stats_grid.dart
│   └── sync_alert_card.dart
└── Dashboard.dart     # Main dashboard widget
```

## Key Features

### 🎯 Clean Code Principles
- **Single Responsibility**: Each file has one clear purpose
- **DRY (Don't Repeat Yourself)**: Reusable components and constants
- **Separation of Concerns**: UI, business logic, and data access are separated
- **Type Safety**: Strong typing with Dart models

### 🔄 State Management (Riverpod)
- **DashboardProvider**: Manages all dashboard state
- **DashboardNotifier**: Handles business logic and state updates
- **Reactive UI**: Automatically updates when state changes
- **Efficient**: Only rebuilds widgets that need updating

### 📦 Modular Components

#### Models (`models/dashboard_state.dart`)
- `DashboardState`: Main state container
- `UserCounts`: User statistics model
- Immutable data classes with `copyWith` methods

#### Repository (`repository/dashboard_repository.dart`)
Handles all data operations:
- `fetchUserId()`: Get user ID from token
- `fetchUserCountsFromAPI()`: Fetch stats from backend
- `fetchUserCountsFromDatabase()`: Fetch stats from local DB
- `fetchLocalCustomersCount()`: Get unsynced customers count

#### Providers (`providers/dashboard_provider.dart`)
State management with Riverpod:
- `dashboardRepositoryProvider`: Provides repository instance
- `dashboardProvider`: Main state provider
- `DashboardNotifier`: Business logic controller

#### Widgets (`widgets/`)
Reusable UI components:
- `StatCard`: Individual statistic card
- `StatsGrid`: Grid layout of stat cards
- `DashboardBanner`: Promotional banner
- `SyncAlertCard`: Unsynced data alert

#### Constants (`constants/dashboard_constants.dart`)
All magic numbers and styles in one place:
- Colors, icons, and sizes
- Responsive breakpoints
- Grid configurations
- Helper methods for responsive sizing

## Usage

### Basic Usage

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Dashboard/Dashboard.dart';

// Use ConsumerWidget or wrap with ProviderScope
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: Dashboard(onSettingsTap: () {}),
      ),
    );
  }
}
```

### Accessing State

```dart
// In any ConsumerWidget
final state = ref.watch(dashboardProvider);
print('New Applicants: ${state.userCounts.newApplicants}');
```

### Triggering Actions

```dart
// Refresh data
await ref.read(dashboardProvider.notifier).refresh();

// Fetch user counts
await ref.read(dashboardProvider.notifier).fetchUserCounts();
```

## Responsive Design

The dashboard automatically adapts to different screen sizes:

- **Mobile**: 2-column grid, smaller text
- **Tablet**: 4-column grid, larger text
- **Breakpoint**: 600px width

Font sizes and icon sizes scale based on screen width for optimal readability.

## Error Handling

Comprehensive error handling for:
- **Token expiration**: Automatic logout
- **Network errors**: User-friendly messages
- **Data fetch errors**: Graceful degradation

## Benefits of This Refactoring

### Before (Old Implementation)
- ❌ 603 lines in one file
- ❌ Mixed UI and business logic
- ❌ StatefulWidget with complex state
- ❌ Hard to test
- ❌ Difficult to maintain
- ❌ Magic numbers everywhere

### After (New Implementation)
- ✅ Clean separation of concerns
- ✅ ~150 lines in main widget file
- ✅ Easy to test each component
- ✅ Reusable widgets
- ✅ Type-safe state management
- ✅ Centralized constants
- ✅ Better error handling
- ✅ More maintainable

## Testing

Each component can be tested independently:

```dart
// Test repository
test('fetchUserCountsFromAPI returns valid counts', () async {
  final repo = DashboardRepository();
  final counts = await repo.fetchUserCountsFromAPI();
  expect(counts.newApplicants, isA<int>());
});

// Test notifier
test('initialize loads data', () async {
  final notifier = DashboardNotifier(mockRepo);
  await notifier.initialize();
  expect(notifier.state.isLoading, false);
});
```

## Future Enhancements

Potential improvements:
- [ ] Add unit tests for each component
- [ ] Add loading skeletons instead of "-" placeholder
- [ ] Implement caching strategy
- [ ] Add analytics tracking
- [ ] Support for dark mode
- [ ] Add animations and transitions
- [ ] Implement pull-to-refresh with custom indicator

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.6.1  # State management
  flutter_secure_storage: any  # Secure token storage
  jwt_decoder: any  # JWT token decoding
  http: any  # API calls
```

## Maintainers

Keep this dashboard clean:
- Add new stats by updating constants and models
- Add new widgets in the widgets folder
- Keep business logic in the notifier
- Keep data access in the repository
- Update this README when making significant changes

