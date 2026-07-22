// lib/utils/constants.dart
class AppConstants {
  // API Configuration
  static const String baseUrl =
      'http://192.168.98.112:8000/api'; // jika menggunakan emulator Android, gunakan IP
  // 'http://127.0.0.1:8000/api'; // localhost
  static const String apiVersion = 'v1';

  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String userEndpoint = '/user';

  // Booking Endpoints
  static const String bookingsEndpoint = '/bookings';
  static const String hotelsEndpoint = '/hotels';
  static const String trainsEndpoint = '/trains';
  static const String busesEndpoint = '/buses';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';

  // Pagination
  static const int defaultPageSize = 10;

  // Date Format
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Currency
  static const String currencySymbol = 'Rp';
  static const String currencyLocale = 'id_ID';
}
