/// OAuth **Basic** (Base64 of `clientId:clientSecret` — the part after `Basic ` only).
///
/// Token URL (all MyCard APIs use the same Bearer from this):
/// `POST https://controlplane-apim-uat.coopbankoromiasc.com/oauth2/token`
/// `-d "grant_type=client_credentials"` `-H "Authorization: Basic <BASE64>"`
///
/// Override at build time: `--dart-define=MYCARD_OAUTH_BASIC_AUTH=...`
/// (legacy: `MYCARD_SOUFLE_BASIC_AUTH` still accepted).
abstract final class MycardSecrets {
  static const _kOAuthBasicDefault =
      'VG5QckFUbHI4cDZyc09NaVNDaUx5eGZvc184YTpyNkNKYW9JN3YweUNFczhHWTdDM0ZpdjFkbzBh';

  static String get oauthBasicAuth {
    const fromOauth = String.fromEnvironment(
      'MYCARD_OAUTH_BASIC_AUTH',
      defaultValue: '',
    );
    const fromLegacy = String.fromEnvironment(
      'MYCARD_SOUFLE_BASIC_AUTH',
      defaultValue: '',
    );
    if (fromOauth.isNotEmpty) return fromOauth;
    if (fromLegacy.isNotEmpty) return fromLegacy;
    return _kOAuthBasicDefault;
  }

  /// Kept for call sites that still say "soufle"; same value as [oauthBasicAuth].
  static String get soufleBasicAuth => oauthBasicAuth;

  static const missingOAuthMessage =
      'MyCard OAuth: set _kOAuthBasicDefault in mycard_secrets.dart or '
      'MYCARD_OAUTH_BASIC_AUTH at build time.';
}
