import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'dio_interceptor.dart';

class AppDioClient {
  AppDioClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = ApiEndpoints.baseUrl;
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;
    _dio.interceptors.add(DioInterceptor());
  }

  static const Duration _timeout = Duration(seconds: 30);

  final Dio _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<dynamic>(path, queryParameters: queryParameters);
  }
}
