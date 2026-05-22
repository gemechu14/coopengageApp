/// eth-qr mobile integration API key for merchant onboarding.
///
/// Override at build time: `--dart-define=ETHQR_MOBILE_API_KEY=...`
abstract final class MerchantSecrets {
  static const _kDefaultApiKey =
      '2565609759cad56599ec78db92198ec650f9cf56e2d5401e013c8c7339c9fa8d';

  static String get mobileIntegrationApiKey {
    const fromEnv = String.fromEnvironment(
      'ETHQR_MOBILE_API_KEY',
      defaultValue: '',
    );
    if (fromEnv.isNotEmpty) return fromEnv;
    return _kDefaultApiKey;
  }
}
