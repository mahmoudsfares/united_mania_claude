import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/utils/json_keys.dart';

void main() {
  group('JsonKeys', () {
    test('every key is non-empty', () {
      expect(JsonKeys.status, isNotEmpty);
      expect(JsonKeys.articles, isNotEmpty);
      expect(JsonKeys.source, isNotEmpty);
      expect(JsonKeys.id, isNotEmpty);
      expect(JsonKeys.name, isNotEmpty);
      expect(JsonKeys.author, isNotEmpty);
      expect(JsonKeys.title, isNotEmpty);
      expect(JsonKeys.description, isNotEmpty);
      expect(JsonKeys.url, isNotEmpty);
      expect(JsonKeys.urlToImage, isNotEmpty);
      expect(JsonKeys.publishedAt, isNotEmpty);
      expect(JsonKeys.content, isNotEmpty);
      expect(JsonKeys.message, isNotEmpty);
    });
  });
}
