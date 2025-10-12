import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/main.dart';
import '../models/dashboard_state.dart';
import '../repository/dashboard_repository.dart';

/// Dashboard Repository Provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

/// Dashboard State Provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(repository);
});

/// Dashboard State Notifier
/// Manages all dashboard state and business logic
///
/// Loading Sequence:
/// 1. Widget builds with initial state (isLoadingCount all true, showing "-")
/// 2. After first frame, initialize() is called
/// 3. 100ms delay ensures loading UI is visible
/// 4. Data is fetched from API/DB
/// 5. State updates with real values
/// 6. AnimatedSwitcher smoothly transitions from "-" to values
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;
  bool _initialized = false;

  DashboardNotifier(this._repository) : super(const DashboardState()) {
    // Don't initialize here - let the widget control initialization
    // This ensures the UI renders the loading state first
  }

  /// Reset to loading state (clears any cached values)
  void resetToLoadingState() {
    print("DashboardNotifier: Resetting to loading state");
    state = const DashboardState(); // Reset to initial state with all loading=true and counts=0
    _initialized = false; // Allow re-initialization
  }

  /// Initialize dashboard data
  Future<void> initialize() async {
    // Prevent multiple initializations
    if (_initialized) {
      print("DashboardNotifier: Already initialized, skipping");
      return;
    }
    _initialized = true;

    try {
      print("DashboardNotifier: Starting initialization");
      // The initial state already has loading=true and isLoadingCount all true
      // Wait a bit to ensure UI renders the loading state first
      await Future.delayed(const Duration(milliseconds: 200));

      // Fetch user ID first
      await fetchUserId();

      // Then fetch other data in parallel
      await Future.wait([
        fetchUserCounts(),
        fetchLocalCustomers(),
      ]);
      
      print("Dashboard initialization completed successfully");
    } catch (e) {
      print("Error initializing dashboard: $e");
      state = state.copyWith(
        isLoading: false,
        isLoadingCount: {
          "New Applicants": false,
          "Awaiting Action": false,
          "Approved": false,
          "Rejected": false,
        },
      );
    }
  }

  /// Fetch user ID from token
  Future<void> fetchUserId() async {
    try {
      final userId = await _repository.fetchUserId();
      state = state.copyWith(
        userId: userId,
        isLoading: false,
      );
    } catch (e) {
      print("Error fetching user ID: $e");
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Fetch user counts based on online/offline mode
  Future<void> fetchUserCounts() async {
    print("fetchUserCounts: Starting (isOnline: $isOnline)");
    
    // Set loading state for all counts
    state = state.copyWith(
      isLoadingCount: {
        "New Applicants": true,
        "Awaiting Action": true,
        "Approved": true,
        "Rejected": true,
      },
    );

    try {
      UserCounts counts;

      if (isOnline) {
        print("fetchUserCounts: Fetching from API");
        // Fetch from API
        counts = await _repository.fetchUserCountsFromAPI();
      } else {
        print("fetchUserCounts: Fetching from local database");
        // Fetch from local database
        if (state.userId == null) {
          print("fetchUserCounts: User ID is null!");
          throw Exception("User ID not available");
        }
        counts = await _repository.fetchUserCountsFromDatabase(state.userId!);
      }

      print("fetchUserCounts: Data fetched - New: ${counts.newApplicants}, Awaiting: ${counts.awaitingAction}, Approved: ${counts.approved}, Rejected: ${counts.rejected}");

      // Update state with fetched counts
      state = state.copyWith(
        userCounts: counts,
        isLoadingCount: {
          "New Applicants": false,
          "Awaiting Action": false,
          "Approved": false,
          "Rejected": false,
        },
      );
      
      print("fetchUserCounts: State updated successfully");
    } catch (e) {
      print("Error fetching user counts: $e");
      // Set loading to false on error
      state = state.copyWith(
        isLoadingCount: {
          "New Applicants": false,
          "Awaiting Action": false,
          "Approved": false,
          "Rejected": false,
        },
      );
      rethrow;
    }
  }

  /// Fetch local unsynced customers
  Future<void> fetchLocalCustomers() async {
    try {
      if (state.userId == null) return;

      final count = await _repository.fetchLocalCustomersCount(state.userId!);
      state = state.copyWith(localCustomers: count);
    } catch (e) {
      print("Error fetching local customers: $e");
      rethrow;
    }
  }

  /// Refresh all dashboard data
  Future<void> refresh() async {
    // fetchUserCounts already sets loading state
    await Future.wait([
      fetchUserCounts(),
      fetchLocalCustomers(),
    ]);
  }

  /// Toggle online status and refresh data
  Future<void> toggleOnlineStatus() async {
    // The global isOnline variable is toggled at the UI level
    // Then we refresh the data
    await fetchUserCounts();
  }
}

