import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/di/app_di.dart';
import 'package:united_mania_claude/core/routing/app_router.dart';
import 'package:united_mania_claude/core/utils/app_strings.dart';
import 'package:united_mania_claude/core/utils/routes.dart';
import 'package:united_mania_claude/features/news_feed/news_feed_screen.dart';

void main() {
  group('AppRouter.generateRoute', () {
    tearDown(() => AppDi.disposeNewsFeed());

    testWidgets('Routes.home builds a NewsFeedScreen', (
      WidgetTester tester,
    ) async {
      // The route's widget is constructed but deliberately never mounted:
      // mounting would call initState -> getNews() and start a real timer
      // via NewsFeedMockRepo, which this test has no need to wait out just
      // to prove the routing wire-up is correct.
      await tester.pumpWidget(const SizedBox());
      final BuildContext context = tester.element(find.byType(SizedBox));

      final MaterialPageRoute<void> route =
          AppRouter.generateRoute(const RouteSettings(name: Routes.home))
              as MaterialPageRoute<void>;

      expect(route.builder(context), isA<NewsFeedScreen>());
    });

    testWidgets('an unknown route shows the route-not-found screen', (
      WidgetTester tester,
    ) async {
      // Built and mounted directly, rather than via MaterialApp's
      // initialRoute: for a non-root initial route, Navigator's default
      // initial-route handling also generates the '/' route to seed the
      // back stack, which would mount a real NewsFeedScreen alongside it.
      await tester.pumpWidget(const SizedBox());
      final BuildContext context = tester.element(find.byType(SizedBox));

      final MaterialPageRoute<void> route =
          AppRouter.generateRoute(const RouteSettings(name: '/unknown-route'))
              as MaterialPageRoute<void>;

      await tester.pumpWidget(MaterialApp(home: route.builder(context)));

      expect(find.text(AppStrings.routeNotFound), findsOneWidget);
    });
  });
}
