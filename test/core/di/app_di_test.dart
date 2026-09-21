import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/di/app_di.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_cubit.dart';

void main() {
  group('AppDi.newsFeedCubit', () {
    tearDown(() => AppDi.disposeNewsFeed());

    test('returns the same instance on repeated access', () {
      final NewsFeedCubit first = AppDi.newsFeedCubit;
      final NewsFeedCubit second = AppDi.newsFeedCubit;

      expect(identical(first, second), isTrue);
    });

    test('disposeNewsFeed closes the cubit and clears the singleton', () {
      final NewsFeedCubit cubit = AppDi.newsFeedCubit;

      AppDi.disposeNewsFeed();

      expect(cubit.isClosed, isTrue);
      expect(identical(AppDi.newsFeedCubit, cubit), isFalse);
    });
  });
}
