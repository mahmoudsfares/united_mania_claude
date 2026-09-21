import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/utils/json_keys.dart';
import 'package:united_mania_claude/features/news_feed/models/article.dart';

void main() {
  group('Article', () {
    final Map<String, dynamic> samplePayload = <String, dynamic>{
      JsonKeys.source: <String, dynamic>{
        JsonKeys.id: null,
        JsonKeys.name: 'Yahoo Entertainment',
      },
      JsonKeys.author: 'Jane Doe',
      JsonKeys.title: 'Manchester United beat rivals in derby thriller',
      JsonKeys.description:
          'A dramatic derby ends in a last minute winner for United.',
      JsonKeys.url: 'https://sports.yahoo.com/manchester-united-derby-thriller',
      JsonKeys.urlToImage:
          'https://sports.yahoo.com/images/derby-thriller.jpg',
      JsonKeys.publishedAt: '2026-09-15T12:06:44Z',
      JsonKeys.content:
          'Manchester United secured a dramatic derby win on Sunday… [+13602 chars]',
    };

    test('fromJson parses the real sample payload recorded in the spec', () {
      final Article article = Article.fromJson(samplePayload);

      expect(article.source?.id, null);
      expect(article.source?.name, 'Yahoo Entertainment');
      expect(article.author, 'Jane Doe');
      expect(article.title, 'Manchester United beat rivals in derby thriller');
      expect(
        article.description,
        'A dramatic derby ends in a last minute winner for United.',
      );
      expect(
        article.url,
        'https://sports.yahoo.com/manchester-united-derby-thriller',
      );
      expect(
        article.urlToImage,
        'https://sports.yahoo.com/images/derby-thriller.jpg',
      );
      expect(article.publishedAt, '2026-09-15T12:06:44Z');
      expect(
        article.content,
        'Manchester United secured a dramatic derby win on Sunday… [+13602 chars]',
      );
    });

    test('toJson round-trips the sample payload', () {
      final Map<String, dynamic> result = Article.fromJson(
        samplePayload,
      ).toJson();

      expect(result, samplePayload);
    });

    test('fromJson parses an all-null payload without throwing', () {
      final Map<String, dynamic> allNullPayload = <String, dynamic>{
        JsonKeys.source: null,
        JsonKeys.author: null,
        JsonKeys.title: null,
        JsonKeys.description: null,
        JsonKeys.url: null,
        JsonKeys.urlToImage: null,
        JsonKeys.publishedAt: null,
        JsonKeys.content: null,
      };

      final Article article = Article.fromJson(allNullPayload);

      expect(article.source, null);
      expect(article.author, null);
      expect(article.title, null);
      expect(article.description, null);
      expect(article.url, null);
      expect(article.urlToImage, null);
      expect(article.publishedAt, null);
      expect(article.content, null);
    });

    test('toJson round-trips an all-null payload', () {
      final Map<String, dynamic> allNullPayload = <String, dynamic>{
        JsonKeys.source: null,
        JsonKeys.author: null,
        JsonKeys.title: null,
        JsonKeys.description: null,
        JsonKeys.url: null,
        JsonKeys.urlToImage: null,
        JsonKeys.publishedAt: null,
        JsonKeys.content: null,
      };

      final Map<String, dynamic> result = Article.fromJson(
        allNullPayload,
      ).toJson();

      expect(result, allNullPayload);
    });

    test('fromJson does not crash when the source object is missing', () {
      final Map<String, dynamic> json = <String, dynamic>{
        JsonKeys.author: 'Jane Doe',
        JsonKeys.title: 'A title',
        JsonKeys.description: 'A description',
        JsonKeys.url: 'https://example.com',
        JsonKeys.urlToImage: 'https://example.com/image.jpg',
        JsonKeys.publishedAt: '2026-09-15T12:06:44Z',
        JsonKeys.content: 'Some content',
      };

      final Article article = Article.fromJson(json);

      expect(article.source, null);
    });
  });
}
