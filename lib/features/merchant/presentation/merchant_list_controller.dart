import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/merchant_models.dart';
import '../data/merchant_remote_service.dart';
import 'merchant_registration_controller.dart';

// ---------------------------------------------------------------------------
// Filter tab enum
// ---------------------------------------------------------------------------

enum MerchantQrFilter { all, readyToRequest, alreadyRequested }

extension MerchantQrFilterX on MerchantQrFilter {
  String get label {
    switch (this) {
      case MerchantQrFilter.all:
        return 'All';
      case MerchantQrFilter.readyToRequest:
        return 'Ready';
      case MerchantQrFilter.alreadyRequested:
        return 'Requested';
    }
  }

  bool? get apiParam {
    switch (this) {
      case MerchantQrFilter.all:
        return null;
      case MerchantQrFilter.readyToRequest:
        return false;
      case MerchantQrFilter.alreadyRequested:
        return true;
    }
  }
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class MerchantListState {
  const MerchantListState({
    this.branchCode = '',
    this.filter = MerchantQrFilter.all,
    this.merchants = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.currentPage = 0,
    this.totalPages = 1,
    this.totalElements = 0,
    this.errorMessage,
    this.requestingIds = const {},
    this.posterLoadingId,
    this.successMessage,
  });

  final String branchCode;
  final MerchantQrFilter filter;
  final List<MerchantResponse> merchants;
  final bool isLoading;
  final bool isLoadingMore;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final String? errorMessage;
  final Set<String> requestingIds;
  final String? posterLoadingId;
  final String? successMessage;

  bool get hasMore => currentPage < totalPages - 1;

  MerchantListState copyWith({
    String? branchCode,
    MerchantQrFilter? filter,
    List<MerchantResponse>? merchants,
    bool? isLoading,
    bool? isLoadingMore,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    String? errorMessage,
    bool clearError = false,
    Set<String>? requestingIds,
    String? posterLoadingId,
    bool clearPosterLoading = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return MerchantListState(
      branchCode: branchCode ?? this.branchCode,
      filter: filter ?? this.filter,
      merchants: merchants ?? this.merchants,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      requestingIds: requestingIds ?? this.requestingIds,
      posterLoadingId:
          clearPosterLoading ? null : (posterLoadingId ?? this.posterLoadingId),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final merchantListControllerProvider = NotifierProvider.autoDispose<
    MerchantListController, MerchantListState>(
  MerchantListController.new,
);

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class MerchantListController extends AutoDisposeNotifier<MerchantListState> {
  MerchantRemoteService get _service => ref.read(merchantRemoteServiceProvider);

  @override
  MerchantListState build() => const MerchantListState();

  void setBranchCode(String code) {
    state = state.copyWith(branchCode: code, clearError: true);
  }

  Future<void> loadMerchants({required String branchCode}) async {
    state = state.copyWith(
      branchCode: branchCode,
      isLoading: true,
      currentPage: 0,
      merchants: const [],
      clearError: true,
      clearSuccess: true,
    );
    try {
      final result = await _service.listMerchantsByBranch(
        branchCode: branchCode,
        qrRequested: state.filter.apiParam,
        page: 0,
      );
      state = state.copyWith(
        isLoading: false,
        merchants: result.merchants,
        totalPages: result.totalPages,
        totalElements: result.totalElements,
        currentPage: 0,
      );
    } on MerchantApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load merchants. Please try again.',
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.branchCode.isEmpty) return;
    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final result = await _service.listMerchantsByBranch(
        branchCode: state.branchCode,
        qrRequested: state.filter.apiParam,
        page: nextPage,
      );
      state = state.copyWith(
        isLoadingMore: false,
        merchants: [...state.merchants, ...result.merchants],
        totalPages: result.totalPages,
        totalElements: result.totalElements,
        currentPage: nextPage,
      );
    } on MerchantApiException catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Could not load more merchants.',
      );
    }
  }

  Future<void> setFilter(MerchantQrFilter filter) async {
    if (state.branchCode.isEmpty) return;
    state = state.copyWith(filter: filter);
    await loadMerchants(branchCode: state.branchCode);
  }

  Future<void> refresh() async {
    if (state.branchCode.isEmpty) return;
    await loadMerchants(branchCode: state.branchCode);
  }

  Future<void> requestQrCode({
    required String merchantId,
    required int acrylicQuantity,
    required int stickerQuantity,
  }) async {
    if (state.branchCode.isEmpty) return;
    final newRequesting = {...state.requestingIds, merchantId};
    state = state.copyWith(requestingIds: newRequesting, clearError: true, clearSuccess: true);
    try {
      final msg = await _service.requestQrCodes(
        branchCode: state.branchCode,
        requests: [(
          merchantId: merchantId,
          acrylicQuantity: acrylicQuantity,
          stickerQuantity: stickerQuantity,
        )],
      );
      final updated = state.requestingIds.difference({merchantId});
      state = state.copyWith(requestingIds: updated, successMessage: msg);
      await refresh();
    } on MerchantApiException catch (e) {
      final updated = state.requestingIds.difference({merchantId});
      state = state.copyWith(requestingIds: updated, errorMessage: e.message);
    } catch (e) {
      final updated = state.requestingIds.difference({merchantId});
      state = state.copyWith(
        requestingIds: updated,
        errorMessage: 'QR request failed. Please try again.',
      );
    }
  }

  Future<Uint8List?> fetchQrPoster({
    required String merchantId,
    required String branchCode,
    String templateType = 'acrylic',
    String fileType = 'png',
  }) async {
    state = state.copyWith(
      posterLoadingId: '$merchantId|$templateType',
      clearError: true,
    );
    try {
      final bytes = await _service.getQrPosterBytes(
        merchantId: merchantId,
        branchCode: branchCode,
        templateType: templateType,
        fileType: fileType,
      );
      state = state.copyWith(clearPosterLoading: true);
      return bytes;
    } on MerchantApiException catch (e) {
      state = state.copyWith(clearPosterLoading: true, errorMessage: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(
        clearPosterLoading: true,
        errorMessage: 'Could not load QR poster.',
      );
      return null;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
