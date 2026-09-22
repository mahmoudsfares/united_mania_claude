import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:united_mania_claude/core/networking/api_endpoints.dart';
import 'package:united_mania_claude/core/networking/app_dio_client.dart';
import 'package:united_mania_claude/core/networking/state_resource.dart';
import 'package:united_mania_claude/core/utils/app_error_messages.dart';
import 'package:united_mania_claude/core/utils/json_keys.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_mock_repo.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_repo.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/removed_articles_filter.dart';
import 'package:united_mania_claude/features/news_feed/models/article.dart';

class MockAppDioClient extends Mock implements AppDioClient {}

void main() {
  const String emptyBody = '';
  const String garbageBody = 'not json';
  const int wrongTypedValue = 42;

  final List<dynamic> fixtureArticles =
      NewsFeedMockRepo.successResponseBody[JsonKeys.articles] as List<dynamic>;
  final Map<String, dynamic> fixtureArticle =
      fixtureArticles.first as Map<String, dynamic>;

  late MockAppDioClient dioClient;
  late NewsFeedRepo repo;
  late RequestOptions requestOptions;

  setUp(() {
    dioClient = MockAppDioClient();
    repo = NewsFeedRepo(dioClient);
    requestOptions = RequestOptions(path: ApiEndpoints.everything);
  });

  void stubSuccess(Object? body) {
    when(
      () => dioClient.get(
        ApiEndpoints.everything,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 200,
        data: body,
      ),
    );
  }

  void stubThrow(DioException exception) {
    when(
      () => dioClient.get(
        ApiEndpoints.everything,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(exception);
  }

  void stubStatus(int statusCode, [Object? body]) {
    stubThrow(
      DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: statusCode,
          data: body,
        ),
      ),
    );
  }

  void stubTransportFailure(DioExceptionType type) {
    stubThrow(DioException(requestOptions: requestOptions, type: type));
  }

  Map<String, dynamic> successBodyWith(Object? articles) {
    return <String, dynamic>{
      JsonKeys.status: NewsFeedMockRepo.successResponseBody[JsonKeys.status],
      JsonKeys.articles: articles,
    };
  }

  Map<String, dynamic> successBodyWithoutArticles() {
    return Map<String, dynamic>.from(NewsFeedMockRepo.successResponseBody)
      ..remove(JsonKeys.articles);
  }

  Map<String, dynamic> errorBodyWith(String key, Object? value) {
    return Map<String, dynamic>.from(NewsFeedMockRepo.errorResponseBody)
      ..[key] = value;
  }

  Map<String, dynamic> errorBodyWithout(String key) {
    return Map<String, dynamic>.from(NewsFeedMockRepo.errorResponseBody)
      ..remove(key);
  }

  Map<String, dynamic> articleWith(String key, Object? value) {
    return Map<String, dynamic>.from(fixtureArticle)..[key] = value;
  }

  Map<String, dynamic> articleWithout(String key) {
    return Map<String, dynamic>.from(fixtureArticle)..remove(key);
  }

  Future<void> expectError(String message) async {
    final StateResource<List<Article>> result = await repo.getNews(page: 1);

    expect(result.isError, true);
    expect(result.data, isNull);
    expect(result.error, message);
  }

  group('NewsFeedRepo.getNews — transport', () {
    test('1 — no internet connection returns the no internet message', () async {
      stubTransportFailure(DioExceptionType.connectionError);

      await expectError(AppErrorMessages.noInternet);
    });

    test('2 — a connection timeout returns the timeout message', () async {
      stubTransportFailure(DioExceptionType.connectionTimeout);

      await expectError(AppErrorMessages.timeout);
    });
  });

  group('NewsFeedRepo.getNews — 200 with the contract body', () {
    test(
      '3 — parses every article in the mock repo payload, dropping the '
      'removed one',
      () async {
        stubSuccess(NewsFeedMockRepo.successResponseBody);

        final StateResource<List<Article>> result = await repo.getNews(
          page: 1,
        );

        final List<Map<String, dynamic>> expectedArticles = fixtureArticles
            .cast<Map<String, dynamic>>()
            .where(
              (Map<String, dynamic> article) =>
                  article[JsonKeys.title] !=
                  RemovedArticlesFilter.removedPlaceholder,
            )
            .toList();

        expect(result.isSuccess, true);
        expect(result.error, isNull);
        expect(result.data?.length, expectedArticles.length);
        for (int index = 0; index < expectedArticles.length; index++) {
          final Map<String, dynamic> expected = expectedArticles[index];
          final Article actual = result.data![index];
          final Map<String, dynamic>? expectedSource =
              expected[JsonKeys.source] as Map<String, dynamic>?;

          expect(actual.title, expected[JsonKeys.title]);
          expect(actual.author, expected[JsonKeys.author]);
          expect(actual.description, expected[JsonKeys.description]);
          expect(actual.url, expected[JsonKeys.url]);
          expect(actual.urlToImage, expected[JsonKeys.urlToImage]);
          expect(actual.publishedAt, expected[JsonKeys.publishedAt]);
          expect(actual.content, expected[JsonKeys.content]);
          expect(actual.source?.id, expectedSource?[JsonKeys.id]);
          expect(actual.source?.name, expectedSource?[JsonKeys.name]);
        }
      },
    );

    test('sends the feed query values from ApiEndpoints', () async {
      stubSuccess(NewsFeedMockRepo.successResponseBody);

      await repo.getNews(page: 1);

      final dynamic captured = verify(
        () => dioClient.get(
          ApiEndpoints.everything,
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured.single;
      final Map<String, dynamic> queryParameters =
          captured as Map<String, dynamic>;

      expect(queryParameters[ApiEndpoints.qQueryParam], ApiEndpoints.q);
      expect(
        queryParameters[ApiEndpoints.sortByQueryParam],
        ApiEndpoints.sortBy,
      );
      expect(
        queryParameters[ApiEndpoints.languageQueryParam],
        ApiEndpoints.language,
      );
    });

    test('sends page and pageSize query values for page 1', () async {
      stubSuccess(NewsFeedMockRepo.successResponseBody);

      await repo.getNews(page: 1);

      final dynamic captured = verify(
        () => dioClient.get(
          ApiEndpoints.everything,
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured.single;
      final Map<String, dynamic> queryParameters =
          captured as Map<String, dynamic>;

      expect(queryParameters[ApiEndpoints.pageQueryParam], 1);
      expect(
        queryParameters[ApiEndpoints.pageSizeQueryParam],
        NewsFeedRepo.pageSize,
      );
    });

    test('forwards the requested page number rather than hardcoding it', () async {
      stubSuccess(NewsFeedMockRepo.successResponseBodyPageTwo);

      await repo.getNews(page: 2);

      final dynamic captured = verify(
        () => dioClient.get(
          ApiEndpoints.everything,
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured.single;
      final Map<String, dynamic> queryParameters =
          captured as Map<String, dynamic>;

      expect(queryParameters[ApiEndpoints.pageQueryParam], 2);
    });
  });

  group('NewsFeedRepo.getNews — 400', () {
    test('4 — a good error body returns the api message as is', () async {
      stubStatus(400, NewsFeedMockRepo.errorResponseBody);

      await expectError(
        NewsFeedMockRepo.errorResponseBody[JsonKeys.message] as String,
      );
    });

    test('5 — an empty response body returns the generic message', () async {
      stubStatus(400, emptyBody);

      await expectError(AppErrorMessages.generic);
    });

    test('6 — a null response body returns the generic message', () async {
      stubStatus(400, null);

      await expectError(AppErrorMessages.generic);
    });

    test('7 — a garbage response body returns the generic message', () async {
      stubStatus(400, garbageBody);

      await expectError(AppErrorMessages.generic);
    });

    test('8 — an empty error field returns the generic message', () async {
      stubStatus(400, errorBodyWith(JsonKeys.message, emptyBody));

      await expectError(AppErrorMessages.generic);
    });

    test('9 — a null error field returns the generic message', () async {
      stubStatus(400, errorBodyWith(JsonKeys.message, null));

      await expectError(AppErrorMessages.generic);
    });

    test('10 — a missing error field returns the generic message', () async {
      stubStatus(400, errorBodyWithout(JsonKeys.message));

      await expectError(AppErrorMessages.generic);
    });

    test('11 — an error field of an unexpected type returns the generic message', () async {
      stubStatus(400, errorBodyWith(JsonKeys.message, wrongTypedValue));

      await expectError(AppErrorMessages.generic);
    });
  });

  group('NewsFeedRepo.getNews — other status codes', () {
    test('12 — 404 returns the generic message', () async {
      stubStatus(404, NewsFeedMockRepo.errorResponseBody);

      await expectError(AppErrorMessages.generic);
    });

    test('13 — 500 returns the server error message', () async {
      stubStatus(500, NewsFeedMockRepo.errorResponseBody);

      await expectError(AppErrorMessages.serverError);
    });

    test('401 returns the invalid api key message', () async {
      stubStatus(401, NewsFeedMockRepo.errorResponseBody);

      await expectError(AppErrorMessages.invalidApiKey);
    });

    test('426 returns the generic message', () async {
      stubStatus(426, NewsFeedMockRepo.errorResponseBody);

      await expectError(AppErrorMessages.generic);
    });

    test('429 returns the rate limited message', () async {
      stubStatus(429, NewsFeedMockRepo.errorResponseBody);

      await expectError(AppErrorMessages.rateLimited);
    });
  });

  // Every Article field is nullable (news_feed.md §2), so the only things the payload must
  // supply are the `articles` key and an object per entry. Scenarios 20–22 are read against
  // those; a missing or wrong-typed article field is covered by the last two tests.
  group('NewsFeedRepo.getNews — 200 with a body that breaks the contract', () {
    test('14 — an empty response body returns the generic message', () async {
      stubSuccess(emptyBody);

      await expectError(AppErrorMessages.generic);
    });

    test('15 — a null response body returns the generic message', () async {
      stubSuccess(null);

      await expectError(AppErrorMessages.generic);
    });

    test('16 — a garbage response body returns the generic message', () async {
      stubSuccess(garbageBody);

      await expectError(AppErrorMessages.generic);
    });

    test('17 — an empty articles array returns success with an empty list', () async {
      stubSuccess(successBodyWith(<dynamic>[]));

      final StateResource<List<Article>> result = await repo.getNews(page: 1);

      expect(result.isSuccess, true);
      expect(result.data, <Article>[]);
    });

    test('18 — a null articles field returns the generic message', () async {
      stubSuccess(successBodyWith(null));

      await expectError(AppErrorMessages.generic);
    });

    test('19 — an articles field of an unexpected type returns the generic message', () async {
      stubSuccess(successBodyWith(garbageBody));

      await expectError(AppErrorMessages.generic);
    });

    test('20 — a null entry inside articles returns the generic message', () async {
      stubSuccess(successBodyWith(<dynamic>[null]));

      await expectError(AppErrorMessages.generic);
    });

    test('21 — a missing articles field returns the generic message', () async {
      stubSuccess(successBodyWithoutArticles());

      await expectError(AppErrorMessages.generic);
    });

    test('22 — an article field of an unexpected type returns the generic message', () async {
      stubSuccess(
        successBodyWith(<dynamic>[articleWith(JsonKeys.title, wrongTypedValue)]),
      );

      await expectError(AppErrorMessages.generic);
    });

    test('an article missing a nullable field parses it as null', () async {
      stubSuccess(successBodyWith(<dynamic>[articleWithout(JsonKeys.title)]));

      final StateResource<List<Article>> result = await repo.getNews(page: 1);

      expect(result.isSuccess, true);
      expect(result.data?.single.title, isNull);
      expect(result.data?.single.url, fixtureArticle[JsonKeys.url]);
    });

    test('an article with a null source parses without a source', () async {
      stubSuccess(successBodyWith(<dynamic>[articleWith(JsonKeys.source, null)]));

      final StateResource<List<Article>> result = await repo.getNews(page: 1);

      expect(result.isSuccess, true);
      expect(result.data?.single.source, isNull);
    });
  });
}
