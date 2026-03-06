import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/shared/widgets/text/custom_nav_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/invitation_model.dart';
import '../providers/invitation_provider.dart';

class RecentInvitationsPage extends ConsumerStatefulWidget {
  const RecentInvitationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RecentInvitationsPage> createState() =>
      _RecentInvitationsPageState();
}

class _RecentInvitationsPageState extends ConsumerState<RecentInvitationsPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoadingMore = false;
  List<Invitation> _allInvitations = [];
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    // Initial load happens automatically via provider
    Future.microtask(() {
      final invitationsAsync = ref.read(myInvitationsProvider);
      invitationsAsync.whenData((invitations) {
        if (mounted) {
          setState(() {
            _allInvitations = invitations;
            _hasMore = invitations.length >= _pageSize;
          });
        }
      });
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final service = ref.read(invitationServiceProvider);
      final newInvitations = await service.fetchMyInvitations(
        page: _currentPage + 1,
        size: _pageSize,
      );

      if (mounted) {
        setState(() {
          _currentPage++;
          _allInvitations.addAll(newInvitations);
          _hasMore = newInvitations.length >= _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 0;
      _allInvitations.clear();
      _hasMore = true;
    });
    ref.refresh(myInvitationsProvider);
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final invitationsAsync = ref.watch(myInvitationsProvider);

    return Scaffold(
      backgroundColor: graybackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: graybackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, 
                color: cyanblueColor, 
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: CustomNavHeading(text: 'Recent Invitations'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey[200]!,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: cyanblueColor,
        child: invitationsAsync.when(
          data: (initialInvitations) {
            // Use _allInvitations if we have loaded more, otherwise use initial
            final displayInvitations = _allInvitations.isNotEmpty
                ? _allInvitations
                : initialInvitations;

            if (displayInvitations.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              itemCount: displayInvitations.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == displayInvitations.length) {
                  // Loading indicator at the bottom
                  return _buildLoadingIndicator();
                }

                final invitation = displayInvitations[index];
                return _buildInvitationTile(invitation);
              },
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error),
        ),
      ),
    );
  }

  Widget _buildInvitationTile(Invitation invitation) {
    final statusColor = _getStatusColor(invitation.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Add tap functionality if needed
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: statusColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Avatar and Status
                Row(
                  children: [
                    // Avatar Circle
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor,
                            statusColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          invitation.recipientName.isNotEmpty
                              ? invitation.recipientName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: whiteColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Recipient Name and Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invitation.recipientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: blackColor,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor.withOpacity(0.12),
                                  statusColor.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    invitation.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                      letterSpacing: 0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Details Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Platform
                    _buildInfoChip(
                      icon: _getPlatformIcon(invitation.platform),
                      label: invitation.platform,
                      color: primaryBlue,
                    ),
                    // Account Type
                    _buildInfoChip(
                      icon: Icons.account_circle_outlined,
                      label: invitation.linkType,
                      color: secondaryBlue,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Engagement Stats Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        graybackgroundColor,
                        graybackgroundColor.withOpacity(0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey[200]!.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Opened Stat
                      Expanded(
                        child: _buildCompactStatChip(
                          icon: Icons.visibility_outlined,
                          label: 'Opened',
                          value: invitation.emailOpened,
                          color: tertiaryBlue,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.grey[300]!,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Clicked Stat
                      Expanded(
                        child: _buildCompactStatChip(
                          icon: Icons.touch_app_outlined,
                          label: 'Clicked',
                          value: invitation.linkClicked,
                          color: cyanblueColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.grey[300]!,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Time
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                invitation.formattedSentAt,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                  letterSpacing: 0.1,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required bool value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: value
                ? color.withOpacity(0.12)
                : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            value ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: value ? color : Colors.grey[400],
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: value ? color : Colors.grey[600],
              fontWeight: value ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 0.1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStatChip({
    required IconData icon,
    required String label,
    required bool value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            gradient: value
                ? LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: value ? null : Colors.grey[200],
            shape: BoxShape.circle,
            boxShadow: value
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            value ? Icons.check_rounded : Icons.close_rounded,
            size: 12,
            color: value ? whiteColor : Colors.grey[500],
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: value ? color : Colors.grey[600],
              fontWeight: value ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 0.1,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: whiteColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: cyanblueColor.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const CircularProgressIndicator(
            color: cyanblueColor,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: whiteColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cyanblueColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: cyanblueColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading invitations...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: whiteColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[200]!,
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  color: Colors.grey[300],
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No invitations yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start sending invitations to see them here',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red[100]!,
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red[300],
                  size: 35,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Failed to load invitations',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),
              // const SizedBox(height: 12),
              // Container(
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: Colors.grey[50],
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(
              //       color: Colors.grey[200]!,
              //     ),
              //   ),
              //   child: Text(
              //     error.toString(),
              //     style: TextStyle(
              //       fontSize: 13,
              //       color: Colors.grey[600],
              //       height: 1.4,
              //     ),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(myInvitationsProvider),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyanblueColor,
                  foregroundColor: whiteColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: cyanblueColor.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SENT':
        return primaryBlue;
      case 'CLICKED':
        return Colors.orange;
      case 'OPENED':
        return tertiaryBlue;
      case 'REGISTERED':
        return cyanblueColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toUpperCase()) {
      case 'WHATSAPP':
        return Icons.chat;
      case 'TELEGRAM':
        return Icons.telegram;
      case 'EMAIL':
        return Icons.email_outlined;
      default:
        return Icons.send;
    }
  }
}
