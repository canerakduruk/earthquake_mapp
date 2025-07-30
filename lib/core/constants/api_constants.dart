class ApiConstants {
  static const String baseUrl = 'https://deprem.afad.gov.tr';
  static const String earthquakeFilter = '/apiv2/event/filter';

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  static const String defaultOrderBy = 'timedesc';
  static const String defaultFormat = 'json';
}
