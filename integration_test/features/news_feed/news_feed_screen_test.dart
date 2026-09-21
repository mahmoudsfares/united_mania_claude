import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:united_mania_claude/core/networking/state_resource.dart';
import 'package:united_mania_claude/core/shared_widgets/app_loader.dart';
import 'package:united_mania_claude/core/shared_widgets/app_network_image.dart';
import 'package:united_mania_claude/core/utils/app_strings.dart';
import 'package:united_mania_claude/core/utils/json_keys.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_cubit.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_mock_repo.dart';
import 'package:united_mania_claude/features/news_feed/models/article.dart';
import 'package:united_mania_claude/features/news_feed/news_feed_screen.dart';
import 'package:united_mania_claude/main.dart' as app;

// Row height depends on how the title text wraps and on the card's own
// layout — not something this test can predict. So the surface rests at a
// short size for almost the whole test: short is guaranteed to overflow no
// matter how tall a row turns out to be, which both makes the list
// draggable and keeps news_feed.md §4's "load another page automatically
// while the screen isn't full" behaviour from firing on its own — only the
// explicit drags below should trigger pagination. Counting rows is the one
// moment that needs the opposite: a brief swing to a tall size guaranteed
// not to overflow, so every row sits inside ListView.builder's viewport
// instead of some being dropped past its cache window, then straight back
// down to short before anything else happens. The drag offset is likewise
// oversized on purpose — far more than any plausible list height — so it
// always lands the scroll position at the true end regardless of actual
// card height.
const Size _scrollableSurface = Size(400, 300);
const Size _fullyVisibleSurface = Size(400, 2600);
const Offset _dragToEndOffset = Offset(0, -3000);

Future<void> _expectCardCount(WidgetTester tester, int count) async {
  await tester.binding.setSurfaceSize(_fullyVisibleSurface);
  await tester.pumpAndSettle();

  expect(find.byType(Card), findsNWidgets(count));
  expect(find.byType(AppNetworkImage), findsNWidgets(count));

  await tester.binding.setSurfaceSize(_scrollableSurface);
  await tester.pump();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launches on the feed, shows the loader, then the pages', (
    WidgetTester tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(_scrollableSurface);

    app.main();
    await tester.pump();

    expect(find.byType(AppLoader), findsOneWidget);

    await tester.pumpAndSettle();

    await _expectCardCount(tester, 10);

    await tester.drag(find.byType(ListView), _dragToEndOffset);
    await tester.pumpAndSettle();

    await _expectCardCount(tester, 14);

    await tester.drag(find.byType(ListView), _dragToEndOffset);
    await tester.pumpAndSettle();

    await _expectCardCount(tester, 14);
  });

  testWidgets('shows an error message and recovers on retry', (
    WidgetTester tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(_scrollableSurface);

    int callCount = 0;
    Future<StateResource<List<Article>>> flakyThenRecovers({
      int page = 1,
    }) async {
      callCount++;
      if (callCount == 1) {
        return const NewsFeedMockRepo(returnError: true).getNews(page: page);
      }
      return const NewsFeedMockRepo().getNews(page: page);
    }

    await tester.pumpWidget(
      MaterialApp(
        home: NewsFeedScreen(cubit: NewsFeedCubit(flakyThenRecovers)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(NewsFeedMockRepo.errorResponseBody[JsonKeys.message] as String),
      findsOneWidget,
    );

    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();

    await _expectCardCount(tester, 10);
  });
}
