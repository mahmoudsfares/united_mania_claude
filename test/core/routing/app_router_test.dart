import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/di/app_di.dart';
import 'package:united_mania_claude/core/routing/app_router.dart';
import 'package:united_mania_claude/core/utils/app_strings.dart';
import 'package:united_mania_claude/core/utils/routes.dart';
import 'package:united_mania_claude/features/news_details/news_details_screen.dart';
import 'package:united_mania_claude/features/news_feed/models/article.dart';
import 'package:united_mania_claude/features/news_feed/news_feed_screen.dart';

const Article _article = Article(
  source: null,
  author: null,
  title: 'A United win',
  description: null,
  url: null,
  urlToImage: null,
  publishedAt: null,
  content: null,
);

void main() {
  group('AppRouter.generateRoute', () {
    tearDown(() {
      AppDi.disposeNewsFeed();
      AppDi.disposeNewsDetails();
    });

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

    testWidgets(
      'Routes.newsDetails with an Article argument builds a NewsDetailsScreen '
      'for that article',
      (WidgetTester tester) async {
        await tester.pumpWidget(const SizedBox());
        final BuildContext context = tester.element(find.byType(SizedBox));

        final MaterialPageRoute<void> route =
            AppRouter.generateRoute(
                  const RouteSettings(
                    name: Routes.newsDetails,
                    arguments: _article,
                  ),
                )
                as MaterialPageRoute<void>;

        final Widget screen = route.builder(context);

        expect(screen, isA<NewsDetailsScreen>());
        expect((screen as NewsDetailsScreen).article, same(_article));
      },
    );

    testWidgets(
      'Routes.newsDetails with a missing argument shows the '
      'route-not-found screen',
      (WidgetTester tester) async {
        await tester.pumpWidget(const SizedBox());
        final BuildContext context = tester.element(find.byType(SizedBox));

        final MaterialPageRoute<void> route =
            AppRouter.generateRoute(
                  const RouteSettings(name: Routes.newsDetails),
                )
                as MaterialPageRoute<void>;

        await tester.pumpWidget(MaterialApp(home: route.builder(context)));

        expect(find.text(AppStrings.routeNotFound), findsOneWidget);
      },
    );

    testWidgets(
      'Routes.newsDetails with a wrong-typed argument shows the '
      'route-not-found screen',
      (WidgetTester tester) async {
        await tester.pumpWidget(const SizedBox());
        final BuildContext context = tester.element(find.byType(SizedBox));

        final MaterialPageRoute<void> route =
            AppRouter.generateRoute(
                  const RouteSettings(
                    name: Routes.newsDetails,
                    arguments: 'not an article',
                  ),
                )
                as MaterialPageRoute<void>;

        await tester.pumpWidget(MaterialApp(home: route.builder(context)));

        expect(find.text(AppStrings.routeNotFound), findsOneWidget);
      },
    );

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
