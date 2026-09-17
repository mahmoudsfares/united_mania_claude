import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/networking/network_error_handler.dart';
import 'package:united_mania_claude/core/networking/state_resource.dart';
import 'package:united_mania_claude/core/utils/app_error_messages.dart';

void main() {
  final RequestOptions requestOptions = RequestOptions(path: '/everything');

  DioException buildException(
    DioExceptionType type, {
    int? statusCode,
    Object? data,
  }) {
    return DioException(
      requestOptions: requestOptions,
      type: type,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: requestOptions,
              statusCode: statusCode,
              data: data,
            ),
    );
  }

  group('networkErrorHandler', () {
    test('connectionTimeout maps to the timeout message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(DioExceptionType.connectionTimeout),
      );

      expect(result.isError, true);
      expect(result.error, AppErrorMessages.timeout);
    });

    test('sendTimeout maps to the timeout message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(DioExceptionType.sendTimeout),
      );

      expect(result.error, AppErrorMessages.timeout);
    });

    test('receiveTimeout maps to the timeout message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(DioExceptionType.receiveTimeout),
      );

      expect(result.error, AppErrorMessages.timeout);
    });

    test('connectionError maps to the no-internet message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(DioExceptionType.connectionError),
      );

      expect(result.error, AppErrorMessages.noInternet);
    });

    test('cancel maps to the generic message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(DioExceptionType.cancel),
      );

      expect(result.error, AppErrorMessages.generic);
    });

    test('badResponse 400 with an api message shows that message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(
          DioExceptionType.badResponse,
          statusCode: 400,
          data: <String, String>{
            'status': 'error',
            'code': 'parametersMissing',
            'message': "Required parameter 'q' is missing.",
          },
        ),
      );

      expect(result.error, "Required parameter 'q' is missing.");
    });

    test('badResponse 400 without a message falls back to generic', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(
          DioExceptionType.badResponse,
          statusCode: 400,
          data: <String, String>{'status': 'error', 'code': 'parametersMissing'},
        ),
      );

      expect(result.error, AppErrorMessages.generic);
    });

    test('badResponse 400 with an empty message falls back to generic', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(
          DioExceptionType.badResponse,
          statusCode: 400,
          data: <String, String>{'status': 'error', 'message': ''},
        ),
      );

      expect(result.error, AppErrorMessages.generic);
    });

    test('badResponse 400 with a non-map body falls back to generic', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(
          DioExceptionType.badResponse,
          statusCode: 400,
          data: 'not json',
        ),
      );

      expect(result.error, AppErrorMessages.generic);
    });

    test('badResponse 401 maps to the invalid-api-key message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(DioExceptionType.badResponse, statusCode: 401),
      );

      expect(result.error, AppErrorMessages.invalidApiKey);
    });

    test('badResponse 426 maps to the generic message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(DioExceptionType.badResponse, statusCode: 426),
      );

      expect(result.error, AppErrorMessages.generic);
    });

    test('badResponse 429 maps to the rate-limited message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(DioExceptionType.badResponse, statusCode: 429),
      );

      expect(result.error, AppErrorMessages.rateLimited);
    });

    test('badResponse 500 maps to the server-error message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(DioExceptionType.badResponse, statusCode: 500),
      );

      expect(result.error, AppErrorMessages.serverError);
    });

    test('badResponse 503 maps to the server-error message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(DioExceptionType.badResponse, statusCode: 503),
      );

      expect(result.error, AppErrorMessages.serverError);
    });

    test('badResponse with an unmapped status code falls back to generic', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(DioExceptionType.badResponse, statusCode: 404),
      );

      expect(result.error, AppErrorMessages.generic);
    });

    test('unknown DioExceptionType maps to the generic message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        buildException(DioExceptionType.unknown),
      );

      expect(result.error, AppErrorMessages.generic);
    });

    test('a non-DioException object maps to the generic message', () {
      final StateResource<String> result = networkErrorHandler<String>(
        Exception('boom'),
      );

      expect(result.isError, true);
      expect(result.error, AppErrorMessages.generic);
      expect(result.data, null);
    });

    test('badResponse 401 never shows the api raw message', () {
      final DioException exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 401,
          data: <String, String>{
            'status': 'error',
            'code': 'apiKeyInvalid',
            'message': 'Your API key is invalid or incorrect.',
          },
        ),
        message: 'Your API key is invalid or incorrect.',
      );

      final StateResource<String> result = networkErrorHandler<String>(
        exception,
      );

      expect(result.error, AppErrorMessages.invalidApiKey);
      expect(result.error, isNot(contains('Your API key is invalid')));
    });
  });
}
