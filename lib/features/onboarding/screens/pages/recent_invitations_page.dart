import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/kconstant.dart';
import '../../../../common_widgets/text/custom_nav_heading.dart';
import '../models/invitation_model.dart';
import '../providers/invitation_provider.dart';

class RecentInvitationsPage extends ConsumerStatefulWidget {
  const RecentInvitationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RecentInvitationsPage> createState() =>
      _RecentInvitationsPageState();
}

class _RecentInvitationsPageState
    extends ConsumerState<RecentInvitationsPage> {
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
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: whiteColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: blackColor),
            onPressed: () => Navigator.pop(context),
          ),
          title:  CustomNavHeading(text: 'Recent Invitations'),
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
              padding: const EdgeInsets.all(16.0),
              itemCount: displayInvitations.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == displayInvitations.length) {
                  // Loading indicator at the bottom
                  return _buildLoadingIndicator();
                }

                final invitation = displayInvitations[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildInvitationTile(invitation),
                );
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(invitation.status).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Recipient Name
              Expanded(
                child: Text(
                  invitation.recipientName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: blackColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(invitation.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(invitation.status).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  invitation.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(invitation.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Details Row
          Row(
            children: [
              // Platform
              _buildInfoChip(
                icon: _getPlatformIcon(invitation.platform),
                label: invitation.platform,
                color: primaryBlue,
              ),
              const SizedBox(width: 8),
              // Account Type
              _buildInfoChip(
                icon: Icons.account_circle_outlined,
                label: invitation.linkType,
                color: secondaryBlue,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Engagement Stats
          Row(
            children: [
              _buildStatChip(
                icon: Icons.visibility_outlined,
                label: 'Opened',
                value: invitation.emailOpened,
                color: tertiaryBlue,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.touch_app_outlined,
                label: 'Clicked',
                value: invitation.linkClicked,
                color: cyanblueColor,
              ),
              const Spacer(),
              // Time
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      invitation.formattedSentAt,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
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
        Icon(
          value ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: value ? color : Colors.grey[400],
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: value ? color : Colors.grey[600],
            fontWeight: value ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularProgressIndicator(color: cyanblueColor),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: cyanblueColor),
          SizedBox(height: 16),
          Text('Loading invitations...'),
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
              Icon(Icons.inbox_outlined, color: Colors.grey[300], size: 80),
              const SizedBox(height: 24),
              Text(
                'No invitations yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start sending invitations to see them here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[300], size: 80),
              const SizedBox(height: 24),
              Text(
                'Failed to load invitations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(myInvitationsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyanblueColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

