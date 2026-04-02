import 'package:coopengageplus/features/home/Dashboard/models/dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/shared/widgets/text/custom_nav_heading.dart';
import 'package:coopengageplus/shared/services/GlobalData.dart';
// import 'package:coopengageplus/shared/services/token_service.dart';

import 'constants/dashboard_constants.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/dashboard_banner.dart';
import 'widgets/dashboard_mycard_share_card.dart';
import 'widgets/stats_grid.dart';
import 'widgets/sync_alert_card.dart';

/// Dashboard Page
/// Main dashboard view displaying user statistics and sync status
class Dashboard extends ConsumerStatefulWidget {
  final VoidCallback onSettingsTap;

  const Dashboard({Key? key, required this.onSettingsTap}) : super(key: key);

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    print("Dashboard initState called");

    // Force loading state immediately before any data fetch
    Future.microtask(() {
      if (mounted) {
        print("Dashboard: Resetting to loading state");
        ref.read(dashboardProvider.notifier).resetToLoadingState();
      }
    });

    // Initialize dashboard data after first frame is rendered
    // This ensures the loading state is visible first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print("Dashboard: Calling initialize()");
        ref.read(dashboardProvider.notifier).initialize().catchError((error) {
          print("Dashboard initialization error caught in widget: $error");
          _handleError(error);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    print(
        "Dashboard build: New=${state.userCounts.newApplicants}, Approved=${state.userCounts.approved}, Loading=${state.isLoadingCount}");

    // If this is the first build and we have old data, show loading immediately
    final displayState = _isFirstBuild &&
            !state.isLoadingCount.values.every((loading) => loading)
        ? state.copyWith(
            isLoadingCount: {
              "New Applicants": true,
              "Awaiting Action": true,
              "Approved": true,
              "Rejected": true,
            },
            userCounts: const UserCounts(),
          )
        : state;

    _isFirstBuild = false;

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= DashboardConstants.tabletBreakpoint;
    final padding = isTablet
        ? DashboardConstants.tabletPadding
        : DashboardConstants.mobilePadding;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                StatsGrid(
                  state: displayState,
                  screenWidth: screenWidth,
                ),
                const SizedBox(height: DashboardConstants.verticalSpacing),
                // const DashboardMycardShareCard(),
                // const SizedBox(height: DashboardConstants.verticalSpacing),
                const DashboardBanner(),
                // if (state.localCustomers > 0) _buildSyncAlert(state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: AppBar(
        title: CustomNavHeading(text: "Home"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  Widget _buildSyncAlert(state) {
    return SyncAlertCard(
      unsyncedCount: state.localCustomers,
      onSyncPressed: _handleSyncPressed,
    );
  }

  Future<void> _handleRefresh() async {
    try {
      await ref.read(dashboardProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
        _handleError(e);
      }
    }
  }

  Future<void> _handleSyncPressed() async {
    try {
      await GlobalData.syncUnsyncedCustomers(context);
      // Refresh dashboard after sync
      await ref.read(dashboardProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
        _handleError(e);
      }
    }
  }

  void _handleError(dynamic error) {
    final errorString = error.toString();
    print("Dashboard error: $errorString");
  }

  void _showTokenErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                  'Your session has been invalidated. Please login again.'),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showGenericErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Error: $error'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
