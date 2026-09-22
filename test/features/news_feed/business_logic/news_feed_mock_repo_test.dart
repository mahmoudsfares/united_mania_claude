import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/networking/state_resource.dart';
import 'package:united_mania_claude/core/utils/json_keys.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_mock_repo.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/removed_articles_filter.dart';
import 'package:united_mania_claude/features/news_feed/models/article.dart';

void main() {
  group('NewsFeedMockRepo.getNews', () {
    test(
      'page 1 returns nine articles after dropping the removed one, after a '
      'one-second delay',
      () async {
        const NewsFeedMockRepo repo = NewsFeedMockRepo();
        final Stopwatch stopwatch = Stopwatch()..start();

        final StateResource<List<Article>> result = await repo.getNews(
          page: 1,
        );

        stopwatch.stop();
        expect(
          stopwatch.elapsed,
          greaterThanOrEqualTo(const Duration(seconds: 1)),
        );
        expect(result.isSuccess, true);
        expect(result.error, isNull);
        expect(result.data?.length, 9);
        expect(
          result.data?.any(
            (Article article) =>
                article.title == RemovedArticlesFilter.removedPlaceholder,
          ),
          false,
        );
      },
    );

    test('page 2 returns four more articles', () async {
      const NewsFeedMockRepo repo = NewsFeedMockRepo();

      final StateResource<List<Article>> result = await repo.getNews(
        page: 2,
      );

      expect(result.isSuccess, true);
      expect(result.error, isNull);
      expect(result.data?.length, 4);
    });

    test('page 3 returns an empty list', () async {
      const NewsFeedMockRepo repo = NewsFeedMockRepo();

      final StateResource<List<Article>> result = await repo.getNews(
        page: 3,
      );

      expect(result.isSuccess, true);
      expect(result.data, <Article>[]);
    });

    test(
      'returns an error resource carrying the fixture message regardless of page',
      () async {
        const NewsFeedMockRepo repo = NewsFeedMockRepo(returnError: true);

        final StateResource<List<Article>> pageOneResult = await repo.getNews(
          page: 1,
        );
        final StateResource<List<Article>> pageTwoResult = await repo.getNews(
          page: 2,
        );

        for (final StateResource<List<Article>> result in <
          StateResource<List<Article>>
        >[pageOneResult, pageTwoResult]) {
          expect(result.isError, true);
          expect(result.data, isNull);
          expect(
            result.error,
            NewsFeedMockRepo.errorResponseBody[JsonKeys.message],
          );
        }
      },
    );
  });

  group('NewsFeedMockRepo.successResponseBody', () {
    final List<dynamic> articlesJson =
        NewsFeedMockRepo.successResponseBody[JsonKeys.articles]
            as List<dynamic>;
    final List<Article> articles = articlesJson
        .map(
          (dynamic articleJson) =>
              Article.fromJson(articleJson as Map<String, dynamic>),
        )
        .toList();

    test('parses through Article.fromJson without throwing', () {
      expect(articles.length, 10);
    });

    test('includes an article with a null urlToImage', () {
      expect(
        articles.any((Article article) => article.urlToImage == null),
        true,
      );
    });

    test('includes an article with a "[Removed]" title', () {
      expect(
        articles.any((Article article) => article.title == '[Removed]'),
        true,
      );
    });

    test('includes an article with a null author and a null source id', () {
      expect(
        articles.any(
          (Article article) =>
              article.author == null && article.source?.id == null,
        ),
        true,
      );
    });
  });

  group('NewsFeedMockRepo.successResponseBodyPageTwo', () {
    final List<dynamic> articlesJson =
        NewsFeedMockRepo.successResponseBodyPageTwo[JsonKeys.articles]
            as List<dynamic>;
    final List<Article> articles = articlesJson
        .map(
          (dynamic articleJson) =>
              Article.fromJson(articleJson as Map<String, dynamic>),
        )
        .toList();

    test('parses through Article.fromJson without throwing', () {
      expect(articles.length, 4);
    });
  });
}
