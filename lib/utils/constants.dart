class AppConstants {
  // API URLs
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api/v1';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';

  // Messages
  static const String networkErrorMessage =
      'Koneksi jaringan gagal. Silakan coba lagi.';
  static const String serverErrorMessage =
      'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
  static const String unauthorizedMessage =
      'Sesi Anda telah berakhir. Silakan login kembali.';
}
