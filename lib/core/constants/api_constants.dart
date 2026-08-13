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
}