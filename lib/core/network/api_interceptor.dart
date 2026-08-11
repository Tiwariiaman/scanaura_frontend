import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    handler.next(err);
  }
}