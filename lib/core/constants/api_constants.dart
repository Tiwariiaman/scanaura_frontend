class ApiConstants {
  ApiConstants._();

  // Android emulator
  static const String androidBaseUrl = 'http://10.0.2.2:8080';

  // Chrome / Web
  static const String webBaseUrl = 'http://localhost:8080';

  // Production
  static const String productionBaseUrl = 'https://api.scanaura.in';

  // Authentication
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogin = '/api/v1/auth/login';

  static const String businessBase = '/api/v1/business';

  static const String businessMine = '/api/v1/business/me';

  static const String subscriptionMy =
      '/api/v1/subscription/my';

  static const String subscriptionRequest =
      '/api/v1/subscription/request';

  static const String subscriptionRequestHistory =
      '/api/v1/subscription/request/history';

  static const String imageUpload =
      '/api/v1/images/upload';

  static const String qrBase = '/api/v1/qr';

  static const String qrDigital = '$qrBase/digital';

  static const String qrMy = '$qrBase/my';

  // Categories
  static const String categoryBase = '/api/v1/categories';

  // Catalog / Menu
  static const String catalogBase = '/api/v1/catalog';

  static String catalogById(String id) {
    return '$catalogBase/$id';
  }

  static String categoryById(String id) {
    return '$categoryBase/$id';
  }

   static const String catalog =
      catalogBase;

  static const String categories =
      '/api/v1/categories';

  static const String aiMenuBase =
      '/api/v1/ai/menu';

  static const String aiMenuAnalyze =
      '$aiMenuBase/analyze';

  static const String aiMenuImport =
      '$aiMenuBase/import'; 

}