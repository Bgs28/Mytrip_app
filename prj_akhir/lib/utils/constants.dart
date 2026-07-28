// lib/utils/constants.dart
class AppConstants {
  // API Configuration
  static const String baseUrl =
      'http://10.31.8.45:8000/api'; // Ganti dengan URL API Anda
  // 'http://192.168.126.112:8000/api'; // jika menggunakan emulator Android, gunakan IP
  // 'http://127.0.0.1:8000/api'; // localhost

  /// Base URL server tanpa /api — dipakai untuk storage
  static const String serverUrl = 'http://10.31.8.45:8000';

  /// Prefix storage Laravel (public disk)
  static const String storageUrl = '$serverUrl/storage';

  /// Bangun URL lengkap untuk file di storage Laravel.
  /// [path] adalah nilai yang disimpan di database, misalnya
  /// "hotels/foto.jpg" atau hanya "foto.jpg".
  /// [folder] adalah subfolder default jika path tidak mengandung '/'.
  static String buildStorageUrl(String? path, {String folder = ''}) {
    if (path == null || path.trim().isEmpty) return '';
    // Jika sudah berupa URL lengkap, kembalikan langsung
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    // Jika path sudah mengandung folder, gunakan langsung
    if (path.contains('/')) return '$storageUrl/$path';
    // Tambahkan folder default
    if (folder.isNotEmpty) return '$storageUrl/$folder/$path';
    return '$storageUrl/$path';
  }

  static const String apiVersion = 'v1';

  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String paymentsEndpoint = '/payments';
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
