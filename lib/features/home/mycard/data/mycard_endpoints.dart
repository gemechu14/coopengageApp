/// UAT hosts (swap for prod via same file or dart-define later).
abstract final class MycardEndpoints {
  /// Single OAuth2 token for Soufle + internal gateway APIs (same Bearer).
  static const oauthToken =
      'https://controlplane-apim-uat.coopbankoromiasc.com/oauth2/token';

  static const sendOtp =
      'https://externalgateway-apim-uat.coopbankoromiasc.com/soufle/1.0.0/sendOtp';

  static const verifyOtp =
      'https://externalgateway-apim-uat.coopbankoromiasc.com/soufle/1.0.0/verifyOtp';

  /// UAT internal gateway (aligned with `externalgateway-apim-uat` for Soufle).
  static Uri customerInfoUri(String accountId) => Uri(
        scheme: 'https',
        host: 'externalgateway-apim-uat.coopbankoromiasc.com',
        path: '/coopapp/1.0.0/customer/info',
        queryParameters: {'accountId': accountId},
      );

  static const requestNewCard =
      'https://externalgateway-apim-uat.coopbankoromiasc.com/prepaidcard/1.0.0/requestNewCard';
}