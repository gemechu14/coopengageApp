import 'package:flutter/material.dart';
import '../constants/dashboard_constants.dart';

/// Sync Alert Card Widget
/// Displays an alert when there are unsynced customers
class SyncAlertCard extends StatelessWidget {
  final int unsyncedCount;
  final VoidCallback onSyncPressed;

  const SyncAlertCard({
    Key? key,
    required this.unsyncedCount,
    required this.onSyncPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DashboardConstants.listTilePadding),
      child: Card(
        color: DashboardConstants.syncCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DashboardConstants.cardBorderRadius),
        ),
        elevation: DashboardConstants.cardElevation,
        child: ListTile(
          title: Text(
            'You have $unsyncedCount unsynced customers!',
            style: const TextStyle(
              color: DashboardConstants.syncCardTextColor,
              fontSize: 16,
            ),
          ),
          subtitle: const Text(
            'Please sync to avoid data loss.',
            style: TextStyle(
              color: DashboardConstants.syncCardSubtitleColor,
              fontSize: 14,
            ),
          ),
          trailing: ElevatedButton(
            onPressed: onSyncPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: DashboardConstants.syncButtonColor,
            ),
            child: const Text(
              'Sync Now',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

