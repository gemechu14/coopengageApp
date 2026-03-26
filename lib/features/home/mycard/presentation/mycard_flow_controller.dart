import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mycard_phone_utils.dart';
import '../data/mycard_remote_service.dart';
import '../data/mycard_request_card_mapper.dart';
import '../data/oauth_client.dart';

final mycardDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
      validateStatus: (s) => s != null && s < 600,
    ),
  );
});

final oauthClientProvider = Provider<OAuthClient>((ref) {
  return OAuthClient(ref.watch(mycardDioProvider));
});

final mycardRemoteServiceProvider = Provider<MycardRemoteService>((ref) {
  return MycardRemoteService(
    ref.watch(mycardDioProvider),
    ref.watch(oauthClientProvider),
  );
});

/// Disposes when leaving the MyCard screen so a return visit starts at step 1.
final mycardFlowControllerProvider =
    NotifierProvider.autoDispose<MycardFlowController, MycardFlowState>(
  MycardFlowController.new,
);

class MycardFlowState {
  const MycardFlowState({
    this.step = 0,
    this.accountNumber,
    this.otpPhone,
    this.customerDetails,
    this.selectedBranch,
    this.sendingOtp = false,
    this.verifyingOtp = false,
    this.submittingCard = false,
    this.errorMessage,
  });

  final int step;
  /// Account number entered on step 1 (used as fallback for customer IDs in request card).
  final String? accountNumber;
  final String? otpPhone;
  final Map<String, dynamic>? customerDetails;
  final Map<String, dynamic>? selectedBranch;
  final bool sendingOtp;
  final bool verifyingOtp;
  final bool submittingCard;
  final String? errorMessage;

  MycardFlowState copyWith({
    int? step,
    String? accountNumber,
    String? otpPhone,
    Map<String, dynamic>? customerDetails,
    Map<String, dynamic>? selectedBranch,
    bool? sendingOtp,
    bool? verifyingOtp,
    bool? submittingCard,
    String? errorMessage,
    bool clearError = false,
    bool clearCustomer = false,
    bool clearOtpPhone = false,
    bool clearBranch = false,
    bool clearAccountNumber = false,
  }) {
    return MycardFlowState(
      step: step ?? this.step,
      accountNumber: clearAccountNumber
          ? null
          : (accountNumber ?? this.accountNumber),
      otpPhone: clearOtpPhone ? null : (otpPhone ?? this.otpPhone),
      customerDetails:
          clearCustomer ? null : (customerDetails ?? this.customerDetails),
      selectedBranch:
          clearBranch ? null : (selectedBranch ?? this.selectedBranch),
      sendingOtp: sendingOtp ?? this.sendingOtp,
      verifyingOtp: verifyingOtp ?? this.verifyingOtp,
      submittingCard: submittingCard ?? this.submittingCard,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class MycardFlowController extends AutoDisposeNotifier<MycardFlowState> {
  @override
  MycardFlowState build() {
    ref.onDispose(() {
      ref.read(oauthClientProvider).clearCache();
    });
    return const MycardFlowState();
  }

  Future<void> sendOtp(String accountNumber) async {
    state = state.copyWith(sendingOtp: true, clearError: true);
    try {
      final svc = ref.read(mycardRemoteServiceProvider);
      final r = await svc.sendOtp(accountNumber.trim());
      final raw = r.phoneNumber.trim();
      final normalized = normalizeMycardPhone(raw);
      final otpPhone = normalized.isNotEmpty ? normalized : raw;
      if (otpPhone.isEmpty) {
        throw StateError(
          'sendOtp did not return a phone number. Check the API response.',
        );
      }
      state = state.copyWith(
        sendingOtp: false,
        step: 1,
        otpPhone: otpPhone,
        accountNumber: accountNumber.trim(),
      );
    } catch (e) {
      state = state.copyWith(
        sendingOtp: false,
        errorMessage: _msg(e),
      );
      rethrow;
    }
  }

  Future<void> verifyOtpAndLoadCustomer({
    required String accountNumber,
    required String otp,
  }) async {
    final phone = state.otpPhone;
    if (phone == null || phone.isEmpty) {
      throw StateError('Missing phone from send OTP step');
    }
    final account = accountNumber.trim();
    final phoneForApi = normalizeMycardPhone(phone);
    state = state.copyWith(verifyingOtp: true, clearError: true);
    try {
      final svc = ref.read(mycardRemoteServiceProvider);
      final code = otp.replaceAll(RegExp(r'\D'), '');
      await svc.verifyOtp(
        phoneNumber: phoneForApi.isNotEmpty ? phoneForApi : phone,
        otpCode: code,
        accountNumber: account,
      );
      final info = await svc.getCustomerInfo(account);
      state = state.copyWith(
        verifyingOtp: false,
        step: 2,
        accountNumber: account,
        customerDetails: info.customerDetails,
        clearBranch: true,
      );
    } catch (e) {
      state = state.copyWith(verifyingOtp: false, errorMessage: _msg(e));
      rethrow;
    }
  }

  Future<void> submitRequestForBranch(Map<String, dynamic> branch) async {
    final details = state.customerDetails;
    if (details == null || details.isEmpty) {
      throw StateError('Missing customer details');
    }
    if (branchCodeFromBranch(branch).isEmpty) {
      throw StateError(
        'This branch has no branch code. Log in again to refresh branches, or pick another branch.',
      );
    }
    state = state.copyWith(submittingCard: true, clearError: true);
    try {
      final svc = ref.read(mycardRemoteServiceProvider);
      final body = buildRequestNewCardBody(
        customerDetails: details,
        branch: branch,
        otpPhoneFallback: state.otpPhone,
        accountNumberFallback: state.accountNumber,
      );
      if ('${body['CustomerCode'] ?? ''}'.trim().isEmpty) {
        throw StateError(
          'Customer profile is missing an account/customer id. Check customer/info response.',
        );
      }
      await svc.requestNewCard(body);
      state = state.copyWith(
        submittingCard: false,
        step: 3,
        selectedBranch: branch,
      );
    } catch (e) {
      state = state.copyWith(submittingCard: false, errorMessage: _msg(e));
      rethrow;
    }
  }

  void reset() {
    ref.read(oauthClientProvider).clearCache();
    state = const MycardFlowState();
  }

  String _msg(Object e) {
    if (e is DioException) {
      final direct = e.message;
      if (direct != null &&
          direct.trim().isNotEmpty &&
          direct.trim() != 'null') {
        return direct.trim();
      }
      final d = e.response?.data;
      if (d is Map) {
        final m = d['message'] ?? d['error'] ?? d['errorMessage'] ?? d['detail'];
        if (m != null && '$m'.isNotEmpty) {
          return '$m';
        }
        return '${e.message}: $d';
      }
      if (d != null) return '$e: $d';
      return e.message ?? e.toString();
    }
    if (e is StateError) return e.message;
    return e.toString();
  }
}
