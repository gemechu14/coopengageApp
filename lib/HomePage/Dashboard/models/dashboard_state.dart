/// Dashboard State Model
/// Holds all the state data for the dashboard
class DashboardState {
  final int? userId;
  final int localCustomers;
  final int databaseCustomers;
  final UserCounts userCounts;
  final Map<String, bool> isLoadingCount;
  final bool isLoading;

  const DashboardState({
    this.userId,
    this.localCustomers = 0,
    this.databaseCustomers = 0,
    this.userCounts = const UserCounts(),
    this.isLoadingCount = const {
      "New Applicants": true,
      "Awaiting Action": true,
      "Approved": true,
      "Rejected": true,
    },
    this.isLoading = true,
  });

  DashboardState copyWith({
    int? userId,
    int? localCustomers,
    int? databaseCustomers,
    UserCounts? userCounts,
    Map<String, bool>? isLoadingCount,
    bool? isLoading,
  }) {
    return DashboardState(
      userId: userId ?? this.userId,
      localCustomers: localCustomers ?? this.localCustomers,
      databaseCustomers: databaseCustomers ?? this.databaseCustomers,
      userCounts: userCounts ?? this.userCounts,
      isLoadingCount: isLoadingCount ?? this.isLoadingCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// User Counts Model
/// Represents the different user status counts
class UserCounts {
  final int newApplicants;
  final int awaitingAction;
  final int approved;
  final int rejected;

  const UserCounts({
    this.newApplicants = 0,
    this.awaitingAction = 0,
    this.approved = 0,
    this.rejected = 0,
  });

  UserCounts copyWith({
    int? newApplicants,
    int? awaitingAction,
    int? approved,
    int? rejected,
  }) {
    return UserCounts(
      newApplicants: newApplicants ?? this.newApplicants,
      awaitingAction: awaitingAction ?? this.awaitingAction,
      approved: approved ?? this.approved,
      rejected: rejected ?? this.rejected,
    );
  }

  int getCountByTitle(String title) {
    switch (title) {
      case "New Applicants":
        return newApplicants;
      case "Awaiting Action":
        return awaitingAction;
      case "Approved":
        return approved;
      case "Rejected":
        return rejected;
      default:
        return 0;
    }
  }
}

