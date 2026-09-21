import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/utils/app_strings.dart';

void main() {
  group('AppStrings', () {
    test('every label is non-empty', () {
      expect(AppStrings.appTitle, isNotEmpty);
      expect(AppStrings.homeTitle, isNotEmpty);
      expect(AppStrings.retry, isNotEmpty);
      expect(AppStrings.readFullArticle, isNotEmpty);
      expect(AppStrings.noArticles, isNotEmpty);
      expect(AppStrings.routeNotFound, isNotEmpty);
      expect(AppStrings.sourceDateSeparator, isNotEmpty);
    });
  });
}
