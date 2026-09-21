import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/utils/app_images.dart';

void main() {
  group('AppImages', () {
    test('articlePlaceholder is non-empty', () {
      expect(AppImages.articlePlaceholder, isNotEmpty);
    });

    test('articlePlaceholder points into the registered assets/images folder', () {
      expect(AppImages.articlePlaceholder, startsWith('assets/images/'));
    });
  });
}
