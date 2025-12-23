class ApiConstants {
  static const String replicateBaseUrl = 'https://api.replicate.com/v1';
  static const String predictionsEndpoint = '/predictions';

  static const String fluxSchnellModel = 'black-forest-labs/flux-schnell';
  static const String idmVtonModel = 'cuuupid/idm-vton';

  static const int pollIntervalMilliseconds = 1500;
  static const int maxPollAttempts = 60;
  static const int apiTimeoutSeconds = 30;

  static const String authHeaderKey = 'Authorization';
  static const String contentTypeHeaderKey = 'Content-Type';
  static const String contentTypeJson = 'application/json';

  static String getAuthHeaderValue(String apiToken) => 'Token $apiToken';

  static String getPredictionUrl(String predictionId) =>
      '$replicateBaseUrl$predictionsEndpoint/$predictionId';
}
