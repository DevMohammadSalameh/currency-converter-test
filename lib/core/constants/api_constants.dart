class ApiConstants {
  static const String baseUrl =
      'https://v6.exchangerate-api.com/v6/2b9dc826ba9b9924526b58a8';
  static const String flagBaseUrl = 'https://flagcdn.com';
  static const String flagCodesUrl = 'https://flagcdn.com/en/codes.json';

  // Endpoints
  static const String latestEndpoint = '/latest/USD';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Flag URL helper
  static String getFlagUrl(String countryCode) {
    return '$flagBaseUrl/$countryCode.svg';
  }
}
