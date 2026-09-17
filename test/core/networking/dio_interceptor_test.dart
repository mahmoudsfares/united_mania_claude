import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/networking/api_endpoints.dart';
import 'package:united_mania_claude/core/networking/dio_interceptor.dart';

void main() {
  group('DioInterceptor', () {
    test('attaches the api key to the outgoing request query parameters', () {
      final RequestOptions options = RequestOptions(path: 'everything');
      final RequestInterceptorHandler handler = RequestInterceptorHandler();

      DioInterceptor().onRequest(options, handler);

      expect(
        options.queryParameters[ApiEndpoints.apiKeyQueryParam],
        ApiEndpoints.apiKey,
      );
    });
  });
}
