class ApiConstants {
  ApiConstants._();

  // Android emulator:
  // http://10.0.2.2:8080
  //
  // Chrome/Web:
  // http://localhost:8080
  //
  // Production:
  // https://api.scanaura.in

  static const String androidBaseUrl = 'http://10.0.2.2:8080';

  static const String webBaseUrl = 'http://localhost:8080';

  static const String productionBaseUrl = 'https://api.scanaura.in';

  static const String authRegister = '/api/v1/auth/register';

  static const String authLogin = '/api/v1/auth/login';
}