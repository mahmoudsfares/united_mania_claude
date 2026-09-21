import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/utils/json_keys.dart';
import 'package:united_mania_claude/features/news_feed/models/article_source.dart';

void main() {
  group('ArticleSource', () {
    test('fromJson parses id and name', () {
      final Map<String, dynamic> json = <String, dynamic>{
        JsonKeys.id: 'yahoo-entertainment',
        JsonKeys.name: 'Yahoo Entertainment',
      };

      final ArticleSource source = ArticleSource.fromJson(json);

      expect(source.id, 'yahoo-entertainment');
      expect(source.name, 'Yahoo Entertainment');
    });

    test('fromJson handles a null id and name', () {
      final Map<String, dynamic> json = <String, dynamic>{
        JsonKeys.id: null,
        JsonKeys.name: null,
      };

      final ArticleSource source = ArticleSource.fromJson(json);

      expect(source.id, null);
      expect(source.name, null);
    });

    test('toJson round-trips fromJson output', () {
      final Map<String, dynamic> json = <String, dynamic>{
        JsonKeys.id: null,
        JsonKeys.name: 'Yahoo Entertainment',
      };

      final Map<String, dynamic> result = ArticleSource.fromJson(json).toJson();

      expect(result, json);
    });
  });
}
