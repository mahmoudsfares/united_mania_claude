import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_endpoints.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.queryParameters[ApiEndpoints.apiKeyQueryParam] =
        ApiEndpoints.apiKey;
    if (kDebugMode) {
      debugPrint('REQUEST[${options.method}] => PATH: ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }
}
