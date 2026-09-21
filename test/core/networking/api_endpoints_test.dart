import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/networking/api_endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    test('base url and path are correct', () {
      expect(ApiEndpoints.baseUrl, 'https://newsapi.org/v2/');
      expect(ApiEndpoints.everything, 'everything');
    });

    test('query values match the news feed api contract', () {
      expect(
        ApiEndpoints.q,
        'manchester united|man utd|man united|manchester utd',
      );
      expect(ApiEndpoints.sortBy, 'publishedAt');
      expect(ApiEndpoints.language, 'en');
    });

    test('api key query parameter name is correct', () {
      expect(ApiEndpoints.apiKeyQueryParam, 'apiKey');
    });

    test('feed query parameter names are correct', () {
      expect(ApiEndpoints.qQueryParam, 'q');
      expect(ApiEndpoints.sortByQueryParam, 'sortBy');
      expect(ApiEndpoints.languageQueryParam, 'language');
    });

    test('pagination query parameter names are correct', () {
      expect(ApiEndpoints.pageQueryParam, 'page');
      expect(ApiEndpoints.pageSizeQueryParam, 'pageSize');
    });

    test('api key is set', () {
      expect(ApiEndpoints.apiKey, isNotEmpty);
    });
  });
}
