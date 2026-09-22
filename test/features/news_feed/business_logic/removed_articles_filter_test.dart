import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/utils/json_keys.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_mock_repo.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/removed_articles_filter.dart';
import 'package:united_mania_claude/features/news_feed/models/article.dart';

void main() {
  final List<dynamic> fixtureArticlesJson =
      NewsFeedMockRepo.successResponseBody[JsonKeys.articles] as List<dynamic>;

  List<Article> articlesFrom(Iterable<dynamic> articlesJson) {
    return articlesJson
        .map(
          (dynamic articleJson) =>
              Article.fromJson(articleJson as Map<String, dynamic>),
        )
        .toList();
  }

  group('RemovedArticlesFilter.dropRemoved', () {
    test('drops the "[Removed]" article, leaving the other two', () {
      final List<Article> threeArticles = articlesFrom(
        fixtureArticlesJson.sublist(0, 3),
      );
      expect(
        threeArticles.any(
          (Article article) =>
              article.title == RemovedArticlesFilter.removedPlaceholder,
        ),
        true,
      );

      final List<Article> result = RemovedArticlesFilter.dropRemoved(
        threeArticles,
      );

      expect(result.length, 2);
      expect(
        result.any(
          (Article article) =>
              article.title == RemovedArticlesFilter.removedPlaceholder,
        ),
        false,
      );
    });

    test('returns an empty list when every article is removed', () {
      final Article removedArticle = articlesFrom(<dynamic>[
        fixtureArticlesJson[2],
      ]).single;
      expect(removedArticle.title, RemovedArticlesFilter.removedPlaceholder);

      final List<Article> result = RemovedArticlesFilter.dropRemoved(
        <Article>[removedArticle, removedArticle],
      );

      expect(result, <Article>[]);
    });

    test('returns every article unchanged when none are removed', () {
      final List<Article> articles = articlesFrom(
        fixtureArticlesJson.sublist(3, 5),
      );

      final List<Article> result = RemovedArticlesFilter.dropRemoved(
        articles,
      );

      expect(result, articles);
    });
  });
}
