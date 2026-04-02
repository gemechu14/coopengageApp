import 'package:coopengageplus/core/utils/checkToken.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/model/registration_data.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/fayda_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/national_id_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/simple_national_id_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/providers/stepper_provider.dart';
import 'package:coopengageplus/features/onboarding/customer/NewIndividualNationalIdentification/services/registration_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─── Utilities ───────────────────────────────────────────────────────────────

String getValueOrDefault(
    String? primary, String? fallback, String defaultValue) {
  if (primary != null && primary.isNotEmpty) return primary;
  if (fallback != null && fallback.isNotEmpty) return fallback;
  return defaultValue;
}

String extractSurname(String fullName) {
  final parts = fullName.trim().split(' ');
  return parts.length > 1 ? parts[1] : '';
}

// ─── State ───────────────────────────────────────────────────────────────────

class RegistrationControllerState {
  final bool existingAccountChecked;
  final String? lastCheckedPhone;

  const RegistrationControllerState({
    this.existingAccountChecked = false,
    this.lastCheckedPhone,
  });

  RegistrationControllerState copyWith({
    bool? existingAccountChecked,
    String? lastCheckedPhone,
  }) =>
      RegistrationControllerState(
        existingAccountChecked:
            existingAccountChecked ?? this.existingAccountChecked,
        lastCheckedPhone: lastCheckedPhone ?? this.lastCheckedPhone,
      );
}

// ─── Controller ──────────────────────────────────────────────────────────────

class RegistrationControllerNotifier
    extends StateNotifier<RegistrationControllerState> {
  final Ref _ref;
  final RegistrationService _service = RegistrationService();

  RegistrationControllerNotifier(this._ref)
      : super(const RegistrationControllerState());

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );

  // ── Authentication helpers ──────────────────────────────────────────────

  void _persistFaydaAuthData() {
    final fayda = _ref.read(simpleNationalIdProvider);
    if (fayda.userData == null) return;

    final data = {
      'id': fayda.userData!.sub,
      'name': fayda.userData!.name,
      'email': fayda.userData!.email,
      'phone_number': fayda.userData!.phoneNumber,
      'gender': fayda.userData!.gender,
      'birthdate': fayda.userData!.birthdate,
      'address': {
        'country': fayda.userData!.address?.country ?? 'Unknown',
        'region': fayda.userData!.address?.region ?? 'Unknown',
      },
    };
    _ref.read(stepperProvider.notifier).saveAuthenticationData(data);
  }

  String? getPhoneNumber() {
    final fayda = _ref.read(simpleNationalIdProvider);
    final stepper = _ref.read(stepperProvider);
    final phone =
        (fayda.userData?.phoneNumber ?? stepper.authPhone ?? '').trim();
    return phone.isEmpty ? null : phone;
  }

  bool shouldCheckExistingAccount(String phone) =>
      !state.existingAccountChecked || state.lastCheckedPhone != phone;

  // ── Step validation ────────────────────────────────────────────────────

  /// Returns an error message or `null` when valid.
  String? validateAuthStep() {
    final nationalId = _ref.read(nationalIdProvider);
    final fayda = _ref.read(simpleNationalIdProvider);

    if (nationalId.isAuthCompleted && nationalId.authResult != null) {
      _ref
          .read(stepperProvider.notifier)
          .saveAuthenticationData(nationalId.authResult!);
    } else if (fayda.isCompleted && fayda.userData != null) {
      _persistFaydaAuthData();
    } else {
      return 'Please complete National ID authentication first';
    }

    if (getPhoneNumber() == null) {
      return 'Phone number is missing. Unable to check existing accounts.';
    }
    return null;
  }

  String? validateAdditionalInfoStep() {
    final s = _ref.read(stepperProvider);
    if (s.initialDeposit == null ||
        s.motherName == null ||
        s.motherName!.isEmpty ||
        s.selectedProductType == null ||
        s.selectedProductType!.isEmpty) {
      return 'Please fill in all required fields: Initial Deposit, Mother Name, and Product Type';
    }
    if (s.selectedBranch == null) {
      return 'Please fill in all required fields';
    }
    return null;
  }

  String? validateIdInfoStep() {
    final s = _ref.read(stepperProvider);
    if (s.legalId == null || s.legalId!.isEmpty) {
      return 'Please fill in the Legal ID field';
    }
    return null;
  }

  // ── Account existence check ────────────────────────────────────────────

  Future<Map<String, dynamic>?> checkExistingAccount(String phone) async {
    final result = await _service.checkAccountExist(phone);
    state = state.copyWith(
        existingAccountChecked: true, lastCheckedPhone: phone);
    return result;
  }

  // ── Registration data assembly ─────────────────────────────────────────

  RegistrationData buildRegistrationData() {
    final fayda = _ref.read(simpleNationalIdProvider);
    final s = _ref.read(stepperProvider);

    return RegistrationData(
      fullName: fayda.userData?.name ?? s.fullName ?? '',
      email: fayda.userData?.email ?? s.email ?? '',
      phone: fayda.userData?.phoneNumber ?? s.authPhone ?? '',
      accountType: s.selectedAccountType,
      branch: s.selectedBranch,
      motherName: s.motherName,
      initialDeposit: s.initialDeposit?.toString(),
      dateOfBirth: fayda.userData?.birthdate ?? s.dateOfBirth,
      productType: s.selectedProductType,
      documentName: 'NATIONALID',
      signature: s.signature,
      sex: fayda.userData?.gender ?? s.sex,
      country: getValueOrDefault(
          fayda.userData?.address?.country, s.country, 'ETHIOPIA'),
      state: getValueOrDefault(
          fayda.userData?.address?.region, s.state, 'Addis Ababa'),
      zoneSubCity: getValueOrDefault(
          fayda.userData?.address?.zone, null, 'Addis Ababa'),
      streetAddress: getValueOrDefault(
          fayda.userData?.address?.woreda, null, 'Addis Ababa'),
      bankShare: s.bankShare,
      customerShare: s.customerShare,
      title: s.selectedTitle,
      photo: fayda.userData?.picture,
      maritalStatus: s.selectedMaritalStatus,
      legalId: s.legalId ?? '',
      issueAuthority: s.issueAuthority ?? '',
      expirayDate: s.expireDate ?? '',
      issueDate: s.issueDate ?? '',
    );
  }

  // ── Token validation ───────────────────────────────────────────────────

  Future<String?> getValidToken() async {
    final token = await _storage.read(key: 'token');
    if (token == null || isTokenExpired(token)) return null;
    return token;
  }

  // ── Submit registration ────────────────────────────────────────────────

  Future<void> submitRegistration() async {
    final s = _ref.read(stepperProvider);
    final fayda = _ref.read(simpleNationalIdProvider);

    _resolveAuthId();

    await _service.submitRegistration(
      accountType: s.selectedAccountType ?? '1',
      initialDeposit: (s.initialDeposit ?? 1000.0).toString(),
      branch: s.selectedBranch ?? 'FINFINNE',
      motherName: s.motherName ?? 'N/A',
      state: getValueOrDefault(
          fayda.userData?.address?.region, s.state, 'Addis abeba'),
      documentName: 'NATIONALID',
      customerInfoInitialDeposit: '100',
      signature: s.signature,
      title: s.selectedTitle,
      fullName: fayda.userData?.name ?? s.fullName ?? '',
      Sex: fayda.userData?.gender ?? s.sex ?? '',
      phone: fayda.userData?.phoneNumber ?? s.phoneNumber,
      email: fayda.userData?.email ?? s.email ?? '',
      dateOfBirth: fayda.userData?.birthdate ?? s.dateOfBirth ?? '',
      country: getValueOrDefault(
          fayda.userData?.address?.country, s.country, 'ETHIOPIA'),
      zoneSubCity:
          getValueOrDefault(fayda.userData?.address?.zone, null, ''),
      streetAddress:
          getValueOrDefault(fayda.userData?.address?.woreda, null, ''),
      photo: fayda.userData?.picture ?? '',
      currency: 'ETB',
      surname:
          extractSurname(fayda.userData?.name ?? s.fullName ?? ''),
      legalId: s.legalId ?? '',
      issueAuthority: s.issueAuthority ?? 'ET',
      expirayDate: s.expireDate ?? '',
      issueDate: s.issueDate ?? '',
    );
  }

  void _resolveAuthId() {
    final s = _ref.read(stepperProvider);
    if (s.authId != null) return;

    final nationalId = _ref.read(nationalIdProvider);
    if (nationalId.authResult?['id'] != null) {
      _ref
          .read(stepperProvider.notifier)
          .saveAuthenticationData(nationalId.authResult!);
      return;
    }

    final faydaFull = _ref.read(faydaProvider);
    if (faydaFull.isCompleted &&
        faydaFull.userData?.sub.isNotEmpty == true) {
      _persistFaydaAuthData();
    }
  }

  void reset() {
    state = const RegistrationControllerState();
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final registrationControllerProvider = StateNotifierProvider<
    RegistrationControllerNotifier, RegistrationControllerState>((ref) {
  return RegistrationControllerNotifier(ref);
});
