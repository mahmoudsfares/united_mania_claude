import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/utils/routes.dart';

void main() {
  group('Routes', () {
    test('route names are non-empty', () {
      expect(Routes.home, isNotEmpty);
      expect(Routes.newsDetails, isNotEmpty);
    });

    test('route names are unique', () {
      expect(Routes.home, isNot(equals(Routes.newsDetails)));
    });
  });
}
