import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:united_mania_claude/core/networking/api_endpoints.dart';
import 'package:united_mania_claude/core/networking/app_dio_client.dart';

// `http_mock_adapter`'s `MockServer` callback parameter type is not exported
// from its public API, so it cannot be named explicitly without importing an
// internal `src/` path. The callbacks below are left for inference and the
// lint silenced line by line (matches the package's own tests).

void main() {
  late Dio dio;
  late AppDioClient client;
  late DioAdapter dioAdapter;

  setUp(() {
    dio = Dio();
    client = AppDioClient(dio: dio);
    dioAdapter = DioAdapter(dio: dio);
  });

  group('AppDioClient', () {
    test('a 200 response returns the decoded body', () async {
      final Map<String, dynamic> body = <String, dynamic>{
        'status': 'ok',
        'articles': <dynamic>[],
      };

      dioAdapter.onGet(
        ApiEndpoints.everything,
        // ignore: always_specify_types
        (server) => server.reply(200, body),
      );

      final Response<dynamic> response = await client.get(
        ApiEndpoints.everything,
      );

      expect(response.statusCode, 200);
      expect(response.data, body);
    });

    test('attaches the api key to every outgoing request', () async {
      dioAdapter.onGet(
        ApiEndpoints.everything,
        // ignore: always_specify_types
        (server) => server.reply(200, <String, dynamic>{'status': 'ok'}),
        queryParameters: <String, dynamic>{
          ApiEndpoints.apiKeyQueryParam: ApiEndpoints.apiKey,
        },
      );

      final Response<dynamic> response = await client.get(
        ApiEndpoints.everything,
      );

      expect(response.statusCode, 200);
    });

    test('a 401 response propagates as a DioException', () async {
      dioAdapter.onGet(
        ApiEndpoints.everything,
        // ignore: always_specify_types
        (server) => server.throws(
          401,
          DioException(
            requestOptions: RequestOptions(path: ApiEndpoints.everything),
            type: DioExceptionType.badResponse,
            response: Response<dynamic>(
              requestOptions: RequestOptions(path: ApiEndpoints.everything),
              statusCode: 401,
            ),
          ),
        ),
      );

      expect(
        () async => client.get(ApiEndpoints.everything),
        throwsA(isA<DioException>()),
      );
    });

    test('a timeout propagates as a DioException', () async {
      dioAdapter.onGet(
        ApiEndpoints.everything,
        // ignore: always_specify_types
        (server) => server.throws(
          408,
          DioException(
            requestOptions: RequestOptions(path: ApiEndpoints.everything),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
      );

      expect(
        () async => client.get(ApiEndpoints.everything),
        throwsA(isA<DioException>()),
      );
    });
  });
}
