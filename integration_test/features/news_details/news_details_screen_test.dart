import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:united_mania_claude/core/utils/app_error_messages.dart';
import 'package:united_mania_claude/core/utils/app_strings.dart';
import 'package:united_mania_claude/core/utils/json_keys.dart';
import 'package:united_mania_claude/features/news_details/business_logic/news_details_cubit.dart';
import 'package:united_mania_claude/features/news_details/news_details_screen.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_mock_repo.dart';
import 'package:united_mania_claude/features/news_feed/models/article.dart';
import 'package:united_mania_claude/features/news_feed/news_feed_screen.dart';
import 'package:united_mania_claude/main.dart' as app;
import 'package:url_launcher/url_launcher.dart';

Article _firstMockArticle() {
  final List<dynamic> articlesJson =
      NewsFeedMockRepo.successResponseBody[JsonKeys.articles] as List<dynamic>;
  return Article.fromJson(articlesJson.first as Map<String, dynamic>);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'tapping a card opens details for that article, and back returns to '
    'the feed',
    (WidgetTester tester) async {
      final Article firstArticle = _firstMockArticle();

      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(NewsDetailsScreen),
          matching: find.text(firstArticle.title!),
        ),
        findsOneWidget,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(NewsDetailsScreen), findsNothing);
      expect(find.byType(NewsFeedScreen), findsOneWidget);
    },
  );

  testWidgets(
    "tapping the hyperlink passes that article's url to the launcher",
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final Article firstArticle = _firstMockArticle();

      String? openedUrl;
      final NewsDetailsCubit cubit = NewsDetailsCubit(
        (String url, {required LaunchMode mode}) async {
          openedUrl = url;
          return true;
        },
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(
        MaterialApp(
          home: NewsDetailsScreen(article: firstArticle, cubit: cubit),
        ),
      );

      await tester.tap(find.text(AppStrings.readFullArticle));
      await tester.pumpAndSettle();

      expect(openedUrl, firstArticle.url);
    },
  );

  testWidgets('a failing launcher shows the snackbar', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final Article firstArticle = _firstMockArticle();

    final NewsDetailsCubit cubit = NewsDetailsCubit(
      (String url, {required LaunchMode mode}) async => false,
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: NewsDetailsScreen(article: firstArticle, cubit: cubit),
      ),
    );

    await tester.tap(find.text(AppStrings.readFullArticle));
    await tester.pumpAndSettle();

    expect(find.text(AppErrorMessages.couldNotOpenLink), findsOneWidget);
  });
}
