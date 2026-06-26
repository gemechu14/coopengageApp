import 'package:coopengageplus/features/home/widgets/mycard_registration/mycard_user_branches_loader.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mcc_data.dart';
import '../data/merchant_api_log_interceptor.dart';
import '../data/merchant_models.dart';
import '../data/merchant_qr_purpose_codes.dart';
import '../data/merchant_remote_service.dart';

final merchantDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      validateStatus: (s) => s != null && s < 600,
    ),
  );
  dio.interceptors.add(MerchantApiLogInterceptor());
  return dio;
});

final merchantRemoteServiceProvider = Provider<MerchantRemoteService>((ref) {
  return MerchantRemoteService(ref.watch(merchantDioProvider));
});

final merchantRegistrationControllerProvider =
    NotifierProvider.autoDispose<MerchantRegistrationController, MerchantRegistrationState>(
  MerchantRegistrationController.new,
);

enum PuidMode { auto, premium }

const puidStartDigitOptions = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

class MerchantRegistrationState {
  const MerchantRegistrationState({
    this.step = 1,
    this.branchCode = '',
    this.branches = const [],
    this.isLoadingBranches = false,
    this.accountNumber = '',
    this.accountHolderName,
    this.accountVerified = false,
    this.puidMode = PuidMode.auto,
    this.puidStartDigit = '6',
    this.selectedPremiumPuid,
    this.merchantId,
    this.assignedPuid,
    this.dbaName = '',
    this.phoneNumber = '',
    this.email = '',
    this.taxId = '',
    this.tinNumber = '',
    this.merchantCategoryCode = defaultMerchantCategoryCode,
    this.businessType = defaultMerchantBusinessType,
    this.qrPurposeCode = defaultQrPurposeCode,
    this.languageCode = 'en',
    this.wantsAcrylicQr = true,
    this.wantsStickerQr = false,
    this.tradeLicense,
    this.tradeRegistration,
    this.plcEstablishment,
    this.merchantContract,
    this.region = '',
    this.city = '',
    this.streetAddress = '',
    this.postalCode = '',
    this.regions = const [],
    this.lastMerchantResponse,
    this.isVerifying = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final int step;
  final String branchCode;
  final List<BranchOption> branches;
  final bool isLoadingBranches;
  final String accountNumber;
  final String? accountHolderName;
  final bool accountVerified;
  final PuidMode puidMode;
  final String puidStartDigit;
  final String? selectedPremiumPuid;
  final String? merchantId;
  final String? assignedPuid;
  final String dbaName;
  final String phoneNumber;
  final String email;
  final String taxId;
  final String tinNumber;
  final String merchantCategoryCode;
  final String businessType;
  final String qrPurposeCode;
  final String languageCode;
  final bool wantsAcrylicQr;
  final bool wantsStickerQr;
  final MerchantDocumentFile? tradeLicense;
  final MerchantDocumentFile? tradeRegistration;
  final MerchantDocumentFile? plcEstablishment;
  final MerchantDocumentFile? merchantContract;
  final String region;
  final String city;
  final String streetAddress;
  final String postalCode;
  final List<RegionOption> regions;
  final MerchantResponse? lastMerchantResponse;
  final bool isVerifying;
  final bool isLoading;
  final String? errorMessage;

  bool get showPlcDocument => businessType.toUpperCase().contains('PLC');

  bool get canContinueFromStep1 => accountVerified;

  bool get canVerifyAccount => accountNumber.length == 13;

  bool get canProceedFromStep2 {
    if (branchCode.trim().isEmpty) return false;
    if (dbaName.trim().isEmpty) return false;
    if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber.trim())) return false;
    if (email.trim().isNotEmpty && !email.contains('@')) return false;
    if (!RegExp(r'^\d{4}$').hasMatch(merchantCategoryCode)) return false;
    if (businessType.trim().isEmpty) return false;
    if (!isValidQrPurposeCode(qrPurposeCode)) return false;
    if (!wantsAcrylicQr && !wantsStickerQr) return false;
    if (puidMode == PuidMode.premium &&
        (selectedPremiumPuid == null ||
            !RegExp(r'^\d{6}$').hasMatch(selectedPremiumPuid!))) {
      return false;
    }
    return true;
  }

  bool get canProceedFromStep3 =>
      region.isNotEmpty &&
      city.trim().isNotEmpty &&
      streetAddress.trim().isNotEmpty;

  MerchantRegistrationState copyWith({
    int? step,
    String? branchCode,
    List<BranchOption>? branches,
    bool? isLoadingBranches,
    String? accountNumber,
    String? accountHolderName,
    bool? accountVerified,
    bool clearAccountHolder = false,
    PuidMode? puidMode,
    String? puidStartDigit,
    String? selectedPremiumPuid,
    bool clearPremiumPuid = false,
    String? merchantId,
    String? assignedPuid,
    String? dbaName,
    String? phoneNumber,
    String? email,
    String? taxId,
    String? tinNumber,
    String? merchantCategoryCode,
    String? businessType,
    String? qrPurposeCode,
    String? languageCode,
    bool? wantsAcrylicQr,
    bool? wantsStickerQr,
    MerchantDocumentFile? tradeLicense,
    MerchantDocumentFile? tradeRegistration,
    MerchantDocumentFile? plcEstablishment,
    MerchantDocumentFile? merchantContract,
    bool clearTradeLicense = false,
    bool clearTradeRegistration = false,
    bool clearPlcEstablishment = false,
    bool clearMerchantContract = false,
    String? region,
    String? city,
    String? streetAddress,
    String? postalCode,
    List<RegionOption>? regions,
    MerchantResponse? lastMerchantResponse,
    bool? isVerifying,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MerchantRegistrationState(
      step: step ?? this.step,
      branchCode: branchCode ?? this.branchCode,
      branches: branches ?? this.branches,
      isLoadingBranches: isLoadingBranches ?? this.isLoadingBranches,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName:
          clearAccountHolder ? null : (accountHolderName ?? this.accountHolderName),
      accountVerified: accountVerified ?? this.accountVerified,
      puidMode: puidMode ?? this.puidMode,
      puidStartDigit: puidStartDigit ?? this.puidStartDigit,
      selectedPremiumPuid:
          clearPremiumPuid ? null : (selectedPremiumPuid ?? this.selectedPremiumPuid),
      merchantId: merchantId ?? this.merchantId,
      assignedPuid: assignedPuid ?? this.assignedPuid,
      dbaName: dbaName ?? this.dbaName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      taxId: taxId ?? this.taxId,
      tinNumber: tinNumber ?? this.tinNumber,
      merchantCategoryCode: merchantCategoryCode ?? this.merchantCategoryCode,
      businessType: businessType ?? this.businessType,
      qrPurposeCode: qrPurposeCode ?? this.qrPurposeCode,
      languageCode: languageCode ?? this.languageCode,
      wantsAcrylicQr: wantsAcrylicQr ?? this.wantsAcrylicQr,
      wantsStickerQr: wantsStickerQr ?? this.wantsStickerQr,
      tradeLicense: clearTradeLicense ? null : (tradeLicense ?? this.tradeLicense),
      tradeRegistration: clearTradeRegistration
          ? null
          : (tradeRegistration ?? this.tradeRegistration),
      plcEstablishment: clearPlcEstablishment
          ? null
          : (plcEstablishment ?? this.plcEstablishment),
      merchantContract: clearMerchantContract
          ? null
          : (merchantContract ?? this.merchantContract),
      region: region ?? this.region,
      city: city ?? this.city,
      streetAddress: streetAddress ?? this.streetAddress,
      postalCode: postalCode ?? this.postalCode,
      regions: regions ?? this.regions,
      lastMerchantResponse: lastMerchantResponse ?? this.lastMerchantResponse,
      isVerifying: isVerifying ?? this.isVerifying,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class MerchantRegistrationController extends AutoDisposeNotifier<MerchantRegistrationState> {
  MerchantRemoteService get _service => ref.read(merchantRemoteServiceProvider);

  @override
  MerchantRegistrationState build() => const MerchantRegistrationState();

  /// Load branches when entering step 2 (avoids extra eth-qr call on screen open).
  Future<void> ensureBranchesLoaded() async {
    if (state.branches.isNotEmpty || state.isLoadingBranches) return;
    await loadBranches();
  }

  Future<void> loadBranches() async {
    state = state.copyWith(isLoadingBranches: true, clearError: true);
    try {
      final branches = await _branchesFromLoggedInUser();
      var selected = state.branchCode;
      if (selected.isEmpty && branches.isNotEmpty) {
        selected = branches.first.branchCode;
      }
      state = state.copyWith(
        isLoadingBranches: false,
        branches: branches,
        branchCode: selected,
        clearError: branches.isNotEmpty,
        errorMessage: branches.isEmpty
            ? 'No branch found on your profile. Try logging in again.'
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingBranches: false,
        errorMessage: 'Could not load your branch. Try logging in again.',
      );
    }
  }

  /// Branches assigned to the logged-in user (JWT), not the full eth-qr branch list.
  Future<List<BranchOption>> _branchesFromLoggedInUser() async {
    final jwtBranches = await MycardUserBranchesLoader.load();
    return jwtBranches
        .where((b) => (b['branchCode']?.toString() ?? '').isNotEmpty)
        .map(
          (b) => BranchOption(
            id: b['id']?.toString() ?? '',
            branchCode: b['branchCode']?.toString() ?? '',
            name: b['isMain'] == true
                ? '${b['name']?.toString() ?? 'Branch'} (Main)'
                : b['name']?.toString() ?? 'Branch',
          ),
        )
        .toList();
  }

  void setBranchCode(String? value) =>
      state = state.copyWith(branchCode: value ?? '', clearError: true);

  void setAccountNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 13 ? digits.substring(0, 13) : digits;
    state = state.copyWith(
      accountNumber: trimmed,
      accountVerified: false,
      clearAccountHolder: true,
      clearError: true,
    );
  }

  void setDbaName(String value) => state = state.copyWith(dbaName: value, clearError: true);
  void setPhoneNumber(String value) =>
      state = state.copyWith(phoneNumber: value, clearError: true);
  void setEmail(String value) => state = state.copyWith(email: value, clearError: true);
  void setTaxId(String value) => state = state.copyWith(taxId: value, clearError: true);
  void setTinNumber(String value) =>
      state = state.copyWith(tinNumber: value, clearError: true);
  void setQrPurposeCode(String value) =>
      state = state.copyWith(qrPurposeCode: value, clearError: true);
  void setLanguageCode(String value) =>
      state = state.copyWith(languageCode: value, clearError: true);
  void setWantsAcrylicQr(bool value) =>
      state = state.copyWith(wantsAcrylicQr: value, clearError: true);
  void setWantsStickerQr(bool value) =>
      state = state.copyWith(wantsStickerQr: value, clearError: true);
  void setPuidStartDigit(String value) =>
      state = state.copyWith(puidStartDigit: value, clearError: true);
  void setPuidMode(PuidMode mode) => state = state.copyWith(
        puidMode: mode,
        clearPremiumPuid: mode == PuidMode.auto,
        clearError: true,
      );
  void setSelectedPremiumPuid(String? value) =>
      state = state.copyWith(selectedPremiumPuid: value, clearError: true);
  void setRegion(String value) => state = state.copyWith(region: value, clearError: true);
  void setCity(String value) => state = state.copyWith(city: value, clearError: true);
  void setStreetAddress(String value) =>
      state = state.copyWith(streetAddress: value, clearError: true);
  void setPostalCode(String value) =>
      state = state.copyWith(postalCode: value, clearError: true);

  void setMcc(String code, String description) {
    state = state.copyWith(
      merchantCategoryCode: code,
      businessType: description,
      clearError: true,
    );
  }

  void setDocument({
    MerchantDocumentFile? tradeLicense,
    MerchantDocumentFile? tradeRegistration,
    MerchantDocumentFile? plcEstablishment,
    MerchantDocumentFile? merchantContract,
  }) {
    state = state.copyWith(
      tradeLicense: tradeLicense,
      tradeRegistration: tradeRegistration,
      plcEstablishment: plcEstablishment,
      merchantContract: merchantContract,
      clearError: true,
    );
  }

  Future<void> verifyAccount() async {
    final account = state.accountNumber.trim();
    if (!RegExp(r'^[0-9]{13}$').hasMatch(account)) {
      state = state.copyWith(
        errorMessage: 'Enter a valid 13-digit account number.',
      );
      return;
    }

    state = state.copyWith(isVerifying: true, clearError: true);
    try {
      final data = await _service.verifyAccount(account);
      state = state.copyWith(
        isVerifying: false,
        accountVerified: true,
        accountHolderName: data['accountHolderName']?.toString(),
      );
    } on MerchantApiException catch (e) {
      state = state.copyWith(isVerifying: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: 'Could not verify account. Please try again.',
      );
    }
  }

  Future<void> goToStep2() async {
    if (!state.canContinueFromStep1) return;
    state = state.copyWith(step: 2, clearError: true);
    await ensureBranchesLoaded();
  }

  Future<void> saveMerchantDetails() async {
    if (!state.canProceedFromStep2) return;

    if (state.puidMode == PuidMode.premium && state.selectedPremiumPuid != null) {
      state = state.copyWith(isLoading: true, clearError: true);
      try {
        final availability =
            await _service.checkPremiumPuidAvailability(state.selectedPremiumPuid!);
        if (availability['available'] != true) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: availability['message']?.toString() ??
                'Selected premium PUID is not available.',
          );
          return;
        }
      } on MerchantApiException catch (e) {
        state = state.copyWith(isLoading: false, errorMessage: e.message);
        return;
      }
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final body = <String, dynamic>{
        'branchCode': state.branchCode.trim(),
        'accountNumber': state.accountNumber,
        'dbaName': state.dbaName.trim(),
        'merchantCategoryCode': state.merchantCategoryCode,
        'businessType': state.businessType,
        'qrPurposeCode': state.qrPurposeCode,
        'phoneNumber': state.phoneNumber.trim(),
        'languageCode': state.languageCode,
        'wantsAcrylicQr': state.wantsAcrylicQr,
        'wantsStickerQr': state.wantsStickerQr,
      };
      if (state.email.trim().isNotEmpty) body['email'] = state.email.trim();
      if (state.taxId.trim().isNotEmpty) body['taxId'] = state.taxId.trim();
      if (state.tinNumber.trim().isNotEmpty) {
        body['tinNumber'] = state.tinNumber.trim();
      }
      if (state.puidMode == PuidMode.premium && state.selectedPremiumPuid != null) {
        body['puid'] = state.selectedPremiumPuid;
      } else {
        body['puidStartDigit'] = state.puidStartDigit;
      }

      final branchCode = state.branchCode.trim();
      MerchantResponse response;
      if (state.merchantId != null) {
        body.remove('accountNumber');
        body.remove('branchCode');
        response = await _service.updateMerchant(
          state.merchantId!,
          body,
          branchCode: branchCode,
        );
      } else {
        response = await _service.createMerchant(body);
      }

      var latest = response;
      if (_hasDocuments) {
        latest = await _service.uploadRegistrationDocuments(
          merchantId: latest.id,
          branchCode: branchCode,
          tradeLicense: state.tradeLicense,
          tradeRegistration: state.tradeRegistration,
          plcEstablishment: state.showPlcDocument ? state.plcEstablishment : null,
          merchantContract: state.merchantContract,
        );
      }

      final regions = state.regions.isEmpty ? await _service.fetchRegions() : state.regions;

      state = state.copyWith(
        isLoading: false,
        merchantId: latest.id,
        assignedPuid: latest.puid ?? state.assignedPuid,
        lastMerchantResponse: latest,
        regions: regions,
        step: 3,
      );
    } on MerchantApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not save merchant details.',
      );
    }
  }

  bool get _hasDocuments =>
      state.tradeLicense != null ||
      state.tradeRegistration != null ||
      state.plcEstablishment != null ||
      state.merchantContract != null;

  Future<void> saveAddress() async {
    if (!state.canProceedFromStep3 || state.merchantId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final address = <String, dynamic>{
        'region': state.region,
        'city': state.city.trim(),
        'streetAddress': state.streetAddress.trim(),
      };
      if (state.postalCode.trim().isNotEmpty) {
        address['postalCode'] = state.postalCode.trim();
      }

      final response = await _service.addAddress(
        state.merchantId!,
        address,
        branchCode: state.branchCode.trim(),
      );
      state = state.copyWith(
        isLoading: false,
        lastMerchantResponse: response,
        step: 4,
      );
    } on MerchantApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not save address.',
      );
    }
  }

  void goBack() {
    if (state.step <= 1) return;
    state = state.copyWith(step: state.step - 1, clearError: true);
  }

  void reset() {
    state = const MerchantRegistrationState();
  }

  Future<List<String>> searchPremiumPuids(String query) async {
    try {
      return await _service.searchPremiumPuids(search: query);
    } catch (_) {
      return [];
    }
  }
}
