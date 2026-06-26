import 'dart:typed_data';

import 'package:coopengageplus/features/home/widgets/mycard_registration/mycard_user_branches_loader.dart';
import 'package:coopengageplus/features/merchant/data/merchant_models.dart';
import 'package:coopengageplus/features/merchant/data/merchant_qr_poster_actions.dart';
import 'package:coopengageplus/features/merchant/data/merchant_qr_purpose_codes.dart';
import 'package:coopengageplus/features/merchant/presentation/merchant_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const Color _cyan = Color(0xFF00AEEF);
const Color _blue = Color(0xFF0D47A1);
const Color _muted = Color(0xFF64748B);
const Color _surface = Color(0xFFF4F7FB);
const Color _cardBg = Colors.white;

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class MerchantListPage extends ConsumerStatefulWidget {
  const MerchantListPage({super.key});

  @override
  ConsumerState<MerchantListPage> createState() => _MerchantListPageState();
}

class _MerchantListPageState extends ConsumerState<MerchantListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<_BranchItem> _branches = [];
  bool _branchesLoading = true;
  bool _branchesReady = false;
  String _selectedBranchCode = '';
  String? _branchError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadBranches();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(merchantListControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _loadBranches() async {
    setState(() {
      _branchesLoading = true;
      _branchesReady = false;
      _branchError = null;
    });

    try {
      final raw = await MycardUserBranchesLoader.load();
      final items = raw
          .where((b) => (b['branchCode']?.toString() ?? '').isNotEmpty)
          .map((b) => _BranchItem(
                code: b['branchCode'] as String,
                name: b['isMain'] == true
                    ? '${b['name'] ?? 'Branch'} (Main)'
                    : b['name']?.toString() ?? 'Branch',
              ))
          .toList();

      if (!mounted) return;

      final firstCode = items.isNotEmpty ? items.first.code : '';
      setState(() {
        _branches = items;
        _branchesLoading = false;
        _selectedBranchCode = firstCode;
        _branchError = items.isEmpty ? 'No branch found on your profile.' : null;
      });

      if (items.isEmpty) {
        setState(() => _branchesReady = true);
        return;
      }

      // Paint branch dropdown first, then fetch merchants on the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _branchesReady = true);
        ref
            .read(merchantListControllerProvider.notifier)
            .loadMerchants(branchCode: firstCode);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _branchesLoading = false;
        _branchesReady = true;
        _branchError = 'Could not load branches.';
      });
    }
  }

  Future<void> _onBranchChanged(String code) async {
    setState(() => _selectedBranchCode = code);
    await ref
        .read(merchantListControllerProvider.notifier)
        .loadMerchants(branchCode: code);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantListControllerProvider);
    final notifier = ref.read(merchantListControllerProvider.notifier);

    // Show feedback snackbars
    ref.listen(merchantListControllerProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        notifier.clearMessages();
      } else if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        notifier.clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _cyan,
        title: const Text(
          'Registered Merchants',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          if (!state.isLoading)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: state.branchCode.isNotEmpty ? notifier.refresh : null,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Column(
        children: [
          _BranchBar(
            branches: _branches,
            loading: _branchesLoading,
            error: _branchError,
            selectedCode: _selectedBranchCode,
            onChanged: _onBranchChanged,
          ),
          if (_branchesReady) ...[
            _SearchBar(
              controller: _searchController,
              onChanged: (q) =>
                  setState(() => _searchQuery = q.trim().toLowerCase()),
            ),
            _FilterTabs(
              selected: state.filter,
              onSelected: (f) => notifier.setFilter(f),
            ),
          ],
          Expanded(
            child: _buildBody(state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(MerchantListState state, MerchantListController notifier) {
    // Phase 1: branch still loading — spinner only in branch bar, not here.
    if (_branchesLoading) {
      return Center(
        child: Text(
          'Loading your branch…',
          style: TextStyle(fontSize: 13, color: _muted.withOpacity(0.8)),
        ),
      );
    }
    if (_branchError != null && _branches.isEmpty) {
      return _EmptyState(
        icon: Icons.location_off_outlined,
        message: _branchError!,
        actionLabel: 'Retry',
        onAction: _loadBranches,
      );
    }
    // Phase 2: branch ready, merchants loading.
    if (!_branchesReady || (state.isLoading && state.merchants.isEmpty)) {
      return const Center(child: CircularProgressIndicator(color: _cyan));
    }
    if (state.errorMessage != null && state.merchants.isEmpty) {
      return _EmptyState(
        icon: Icons.cloud_off_rounded,
        message: state.errorMessage!,
        actionLabel: 'Retry',
        onAction: notifier.refresh,
      );
    }
    if (state.merchants.isEmpty) {
      return _EmptyState(
        icon: Icons.storefront_outlined,
        message: state.filter == MerchantQrFilter.readyToRequest
            ? 'No merchants ready to request QR yet.'
            : state.filter == MerchantQrFilter.alreadyRequested
                ? 'No merchants have requested QR codes yet.'
                : 'No merchants registered under this branch.',
        actionLabel: 'Refresh',
        onAction: notifier.refresh,
      );
    }

    final filtered = _searchQuery.isEmpty
        ? state.merchants
        : state.merchants.where((m) {
            final haystack = [
              m.dbaName ?? '',
              m.merchantName ?? '',
              m.puid ?? '',
              m.phoneNumber ?? '',
            ].join(' ').toLowerCase();
            return haystack.contains(_searchQuery);
          }).toList();

    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      return _EmptyState(
        icon: Icons.search_off_rounded,
        message: 'No merchants match "$_searchQuery".',
      );
    }

    return RefreshIndicator(
      color: _cyan,
      onRefresh: notifier.refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: filtered.length + (state.hasMore && _searchQuery.isEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filtered.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: _cyan, strokeWidth: 2),
              ),
            );
          }
          final merchant = filtered[index];
          return _MerchantCard(
            merchant: merchant,
            branchCode: state.branchCode,
            isRequesting: state.requestingIds.contains(merchant.id),
            isPosterLoading: state.posterLoadingId == merchant.id,
            onRequestQr: () => _showQrRequestSheet(context, merchant, notifier),
            onViewPoster: (templateType) =>
                _viewPoster(context, merchant, state.branchCode, notifier, templateType),
          );
        },
      ),
    );
  }

  void _showQrRequestSheet(
    BuildContext context,
    MerchantResponse merchant,
    MerchantListController notifier,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QrRequestSheet(
        merchant: merchant,
        onSubmit: ({required int acrylic, required int sticker}) async {
          Navigator.of(context).pop();
          await notifier.requestQrCode(
            merchantId: merchant.id,
            acrylicQuantity: acrylic,
            stickerQuantity: sticker,
          );
        },
      ),
    );
  }

  Future<void> _viewPoster(
    BuildContext context,
    MerchantResponse merchant,
    String branchCode,
    MerchantListController notifier,
    String templateType,
  ) async {
    final bytes = await notifier.fetchQrPoster(
      merchantId: merchant.id,
      branchCode: branchCode,
      templateType: templateType,
    );
    if (bytes == null || !mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QrPosterSheet(
        bytes: bytes,
        merchantName: merchant.dbaName ?? merchant.merchantName ?? 'Merchant',
        puid: merchant.puid ?? '',
        templateType: templateType,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Branch item helper
// ---------------------------------------------------------------------------

class _BranchItem {
  const _BranchItem({required this.code, required this.name});
  final String code;
  final String name;
}

// ---------------------------------------------------------------------------
// Branch bar
// ---------------------------------------------------------------------------

class _BranchBar extends StatelessWidget {
  const _BranchBar({
    required this.branches,
    required this.loading,
    required this.error,
    required this.selectedCode,
    required this.onChanged,
  });

  final List<_BranchItem> branches;
  final bool loading;
  final String? error;
  final String selectedCode;
  final Future<void> Function(String code) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: loading
          ? const SizedBox(
              height: 44,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: _cyan, strokeWidth: 2),
                ),
              ),
            )
          : error != null && branches.isEmpty
              ? SizedBox(
                  height: 44,
                  child: Center(
                    child: Text(error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                )
              : DropdownButtonFormField<String>(
                  value: selectedCode.isEmpty && branches.isNotEmpty
                      ? branches.first.code
                      : (selectedCode.isEmpty ? null : selectedCode),
                  decoration: InputDecoration(
                    labelText: 'Branch',
                    labelStyle: const TextStyle(color: _muted, fontSize: 13),
                    prefixIcon:
                        const Icon(Icons.account_balance_outlined, color: _cyan, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _cyan, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: branches
                      .map((b) => DropdownMenuItem(
                            value: b.code,
                            child: Text(b.name,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onChanged(v);
                  },
                ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search by name, DBA, PUID or phone…',
          hintStyle: TextStyle(color: _muted.withOpacity(0.7), fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: _cyan, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: _muted),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _cyan, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter tabs
// ---------------------------------------------------------------------------

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onSelected});

  final MerchantQrFilter selected;
  final void Function(MerchantQrFilter) onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: MerchantQrFilter.values
            .map((f) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _FilterChip(
                      label: f.label,
                      selected: f == selected,
                      onTap: () => onSelected(f),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _cyan : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : _muted,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Merchant card
// ---------------------------------------------------------------------------

class _MerchantCard extends StatelessWidget {
  const _MerchantCard({
    required this.merchant,
    required this.branchCode,
    required this.isRequesting,
    required this.isPosterLoading,
    required this.onRequestQr,
    required this.onViewPoster,
  });

  final MerchantResponse merchant;
  final String branchCode;
  final bool isRequesting;
  final bool isPosterLoading;
  final VoidCallback onRequestQr;
  final void Function(String templateType) onViewPoster;

  @override
  Widget build(BuildContext context) {
    final m = merchant;
    final ready = m.readyForQrRequest;
    final requested = m.qrRequested;

    final statusColor = requested
        ? Colors.green.shade600
        : ready
            ? _cyan
            : Colors.orange.shade700;
    final statusLabel =
        requested ? 'QR Requested' : ready ? 'Ready' : 'Incomplete';
    final statusIcon = requested
        ? Icons.check_circle_rounded
        : ready
            ? Icons.pending_rounded
            : Icons.warning_amber_rounded;

    final address = m.address;
    final city = address?['city']?.toString() ?? '';
    final qrTypes = [
      if (m.wantsAcrylicQr) 'Acrylic',
      if (m.wantsStickerQr) 'Sticker',
    ].join(', ');
    final purposeLabel = qrPurposeByValue(m.qrPurposeCode)?.label ?? m.qrPurposeCode ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00AEEF), Color(0xFF0D47A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.store_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.dbaName ?? m.merchantName ?? '—',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (m.merchantName != null && m.dbaName != null)
                        Text(
                          m.merchantName!,
                          style: TextStyle(fontSize: 12, color: _muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              children: [
                if ((m.puid ?? '').isNotEmpty)
                  _DetailRow(
                    icon: Icons.tag_rounded,
                    label: 'PUID',
                    value: m.puid!,
                    mono: true,
                  ),
                if (city.isNotEmpty)
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'City',
                    value: city,
                  ),
                if (qrTypes.isNotEmpty)
                  _DetailRow(
                    icon: Icons.qr_code_2_rounded,
                    label: 'QR Types',
                    value: qrTypes,
                  ),
                if (purposeLabel.isNotEmpty)
                  _DetailRow(
                    icon: Icons.payments_outlined,
                    label: 'Purpose',
                    value: purposeLabel,
                  ),
              ],
            ),
          ),
          // Divider
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              children: [
                if (!requested && ready)
                  _ActionButton(
                    label: 'Request QR Code',
                    icon: Icons.send_rounded,
                    color: _blue,
                    loading: isRequesting,
                    onTap: isRequesting ? null : onRequestQr,
                  ),
                if (!requested && ready) const SizedBox(height: 8),
                Row(
                  children: [
                    if (m.wantsAcrylicQr)
                      Expanded(
                        child: _ActionButton(
                          label: 'View Acrylic Poster',
                          icon: Icons.image_rounded,
                          color: _cyan,
                          loading: isPosterLoading,
                          onTap: isPosterLoading
                              ? null
                              : () => onViewPoster('acrylic'),
                        ),
                      ),
                    if (m.wantsAcrylicQr && m.wantsStickerQr)
                      const SizedBox(width: 8),
                    if (m.wantsStickerQr)
                      Expanded(
                        child: _ActionButton(
                          label: 'View Sticker Poster',
                          icon: Icons.image_outlined,
                          color: const Color(0xFF6366F1),
                          loading: isPosterLoading,
                          onTap: isPosterLoading
                              ? null
                              : () => onViewPoster('sticker'),
                        ),
                      ),
                    if (!m.wantsAcrylicQr && !m.wantsStickerQr)
                      Expanded(
                        child: _ActionButton(
                          label: 'View QR Poster',
                          icon: Icons.image_rounded,
                          color: _cyan,
                          loading: isPosterLoading,
                          onTap: isPosterLoading
                              ? null
                              : () => onViewPoster('acrylic'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _cyan),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12.5, color: _muted),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
                fontFamily: mono ? 'monospace' : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: color),
              )
            else
              Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _cyan.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: _cyan),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: _muted, height: 1.45),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAction,
                style: FilledButton.styleFrom(backgroundColor: _cyan),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QR Request Bottom Sheet
// ---------------------------------------------------------------------------

class _QrRequestSheet extends StatefulWidget {
  const _QrRequestSheet({required this.merchant, required this.onSubmit});

  final MerchantResponse merchant;
  final Future<void> Function({required int acrylic, required int sticker}) onSubmit;

  @override
  State<_QrRequestSheet> createState() => _QrRequestSheetState();
}

class _QrRequestSheetState extends State<_QrRequestSheet> {
  int _acrylic = 0;
  int _sticker = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.merchant.wantsAcrylicQr) _acrylic = 1;
    if (widget.merchant.wantsStickerQr) _sticker = 1;
  }

  bool get _canSubmit =>
      !_submitting && (_acrylic > 0 || _sticker > 0);

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(acrylic: _acrylic, sticker: _sticker);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final m = widget.merchant;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.send_rounded, color: _blue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request QR Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      m.dbaName ?? m.merchantName ?? '',
                      style: const TextStyle(fontSize: 12.5, color: _muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Select quantities to request. At least one must be greater than 0.',
            style: TextStyle(fontSize: 13, color: _muted, height: 1.4),
          ),
          const SizedBox(height: 20),
          if (m.wantsAcrylicQr) ...[
            _QuantityRow(
              label: 'Acrylic Stand',
              icon: Icons.qr_code_2_rounded,
              color: _cyan,
              value: _acrylic,
              onChanged: (v) => setState(() => _acrylic = v),
            ),
            const SizedBox(height: 12),
          ],
          if (m.wantsStickerQr) ...[
            _QuantityRow(
              label: 'Sticker',
              icon: Icons.qr_code_rounded,
              color: const Color(0xFF6366F1),
              value: _sticker,
              onChanged: (v) => setState(() => _sticker = v),
            ),
            const SizedBox(height: 12),
          ],
          if (!m.wantsAcrylicQr && !m.wantsStickerQr) ...[
            _QuantityRow(
              label: 'Acrylic Stand',
              icon: Icons.qr_code_2_rounded,
              color: _cyan,
              value: _acrylic,
              onChanged: (v) => setState(() => _acrylic = v),
            ),
            const SizedBox(height: 12),
            _QuantityRow(
              label: 'Sticker',
              icon: Icons.qr_code_rounded,
              color: const Color(0xFF6366F1),
              value: _sticker,
              onChanged: (v) => setState(() => _sticker = v),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          FilledButton.icon(
            onPressed: _canSubmit ? _submit : null,
            style: FilledButton.styleFrom(
              backgroundColor: _blue,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded, size: 18),
            label: Text(
              _submitting ? 'Submitting…' : 'Submit QR Request',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final Color color;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: color),
            ),
          ),
          _CounterButton(
            icon: Icons.remove_rounded,
            color: color,
            onTap: value > 0 ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.add_rounded,
            color: color,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap != null ? color : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QR Poster Bottom Sheet
// ---------------------------------------------------------------------------

class _QrPosterSheet extends StatefulWidget {
  const _QrPosterSheet({
    required this.bytes,
    required this.merchantName,
    required this.puid,
    required this.templateType,
  });

  final Uint8List bytes;
  final String merchantName;
  final String puid;
  final String templateType;

  @override
  State<_QrPosterSheet> createState() => _QrPosterSheetState();
}

class _QrPosterSheetState extends State<_QrPosterSheet> {
  bool _downloading = false;
  bool _sharing = false;

  String get _fileName =>
      '${widget.templateType}-${widget.puid.isNotEmpty ? widget.puid : 'poster'}.png';

  bool get _busy => _downloading || _sharing;

  Future<void> _download() async {
    if (_busy) return;
    setState(() => _downloading = true);
    try {
      final result = await MerchantQrPosterActions.downloadToDevice(
        bytes: widget.bytes,
        fileName: _fileName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Download finished.'),
          backgroundColor:
              result.success ? Colors.green.shade700 : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not download: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _sharing = true);
    try {
      await MerchantQrPosterActions.sharePoster(
        bytes: widget.bytes,
        fileName: _fileName,
        subject: '${widget.merchantName} QR Poster',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Widget _busyIcon() {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final label = widget.templateType == 'acrylic' ? 'Acrylic Poster' : 'Sticker Poster';

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.qr_code_2_rounded,
                          color: _cyan, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.merchantName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              label,
                              style: const TextStyle(
                                  fontSize: 12, color: _cyan),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: _sharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: _cyan),
                              )
                            : const Icon(Icons.share_rounded,
                                color: Colors.white),
                        onPressed: _busy ? null : _share,
                        tooltip: 'Share',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Image
            Expanded(
              child: ListView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      child: Image.memory(
                        widget.bytes,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _download,
                          style: FilledButton.styleFrom(
                            backgroundColor: _cyan,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: _downloading
                              ? _busyIcon()
                              : const Icon(Icons.download_rounded, size: 18),
                          label: Text(
                            _downloading ? 'Saving…' : 'Download Poster',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _share,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: _cyan, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: _sharing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _cyan,
                                  ),
                                )
                              : const Icon(Icons.share_rounded, size: 18),
                          label: Text(
                            _sharing ? 'Sharing…' : 'Share',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
