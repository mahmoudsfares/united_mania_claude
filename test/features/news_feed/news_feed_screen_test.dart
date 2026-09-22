import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/networking/state_resource.dart';
import 'package:united_mania_claude/core/shared_widgets/app_loader.dart';
import 'package:united_mania_claude/core/utils/app_images.dart';
import 'package:united_mania_claude/core/utils/app_strings.dart';
import 'package:united_mania_claude/core/utils/date_formatter.dart';
import 'package:united_mania_claude/features/news_feed/business_logic/news_feed_cubit.dart';
import 'package:united_mania_claude/features/news_feed/models/article.dart';
import 'package:united_mania_claude/features/news_feed/models/article_source.dart';
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

Future<void> _pumpSingleArticleCard(WidgetTester tester, Article article) async {
  final NewsFeedCubit cubit = NewsFeedCubit(
    ({int page = 1}) async =>
        StateResource<List<Article>>.success(<Article>[article]),
  );
  addTearDown(cubit.close);

  await tester.pumpWidget(MaterialApp(home: NewsFeedScreen(cubit: cubit)));
  await tester.pump();
}

Finder _placeholderImageFinder() {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == AppImages.articlePlaceholder,
  );
}

void main() {
  group('NewsFeedScreen', () {
    testWidgets('shows a loader while the first page is loading', (
      WidgetTester tester,
    ) async {
      final Completer<StateResource<List<Article>>> completer =
          Completer<StateResource<List<Article>>>();
      final NewsFeedCubit cubit = NewsFeedCubit(
        ({int page = 1}) async => completer.future,
      );

      await tester.pumpWidget(MaterialApp(home: NewsFeedScreen(cubit: cubit)));

      expect(find.byType(AppLoader), findsOneWidget);

      completer.complete(const StateResource<List<Article>>.success(<Article>[]));
      await tester.pump();
      await cubit.close();
    });

    testWidgets('shows the article list on success', (
      WidgetTester tester,
    ) async {
      final NewsFeedCubit cubit = NewsFeedCubit(
        ({int page = 1}) async =>
            const StateResource<List<Article>>.success(<Article>[_article]),
      );

      await tester.pumpWidget(MaterialApp(home: NewsFeedScreen(cubit: cubit)));
      await tester.pump();

      expect(find.text(_article.title!), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      await cubit.close();
    });

    testWidgets('shows the empty message when the list is empty', (
      WidgetTester tester,
    ) async {
      final NewsFeedCubit cubit = NewsFeedCubit(
        ({int page = 1}) async =>
            const StateResource<List<Article>>.success(<Article>[]),
      );

      await tester.pumpWidget(MaterialApp(home: NewsFeedScreen(cubit: cubit)));
      await tester.pump();

      expect(find.text(AppStrings.noArticles), findsOneWidget);

      await cubit.close();
    });

    testWidgets('pull to refresh over the empty state calls getNews() again', (
      WidgetTester tester,
    ) async {
      int pageOneRequests = 0;
      final NewsFeedCubit cubit = NewsFeedCubit(({int page = 1}) async {
        pageOneRequests++;
        return const StateResource<List<Article>>.success(<Article>[]);
      });

      await tester.pumpWidget(MaterialApp(home: NewsFeedScreen(cubit: cubit)));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noArticles), findsOneWidget);
      expect(pageOneRequests, 1);

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(pageOneRequests, 2);

      await cubit.close();
    });

    testWidgets(
      'pull to refresh over the article list calls getNews() again',
      (WidgetTester tester) async {
        int pageOneRequests = 0;
        final List<Article> manyArticles = List<Article>.generate(
          20,
          (_) => _article,
        );
        final NewsFeedCubit cubit = NewsFeedCubit(({int page = 1}) async {
          if (page == 1) {
            pageOneRequests++;
          }
          return StateResource<List<Article>>.success(manyArticles);
        });

        await tester.pumpWidget(
          MaterialApp(home: NewsFeedScreen(cubit: cubit)),
        );
        await tester.pumpAndSettle();

        expect(pageOneRequests, 1);

        await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(pageOneRequests, 2);

        await cubit.close();
      },
    );

    testWidgets('shows the error view with retry on failure', (
      WidgetTester tester,
    ) async {
      final NewsFeedCubit cubit = NewsFeedCubit(
        ({int page = 1}) async =>
            const StateResource<List<Article>>.error('Boom'),
      );

      await tester.pumpWidget(MaterialApp(home: NewsFeedScreen(cubit: cubit)));
      await tester.pump();

      expect(find.text('Boom'), findsOneWidget);
      expect(find.text(AppStrings.retry), findsOneWidget);

      await cubit.close();
    });

    testWidgets('shows a trailing loading row while the next page loads', (
      WidgetTester tester,
    ) async {
      final Completer<StateResource<List<Article>>> nextPageCompleter =
          Completer<StateResource<List<Article>>>();
      final NewsFeedCubit cubit = NewsFeedCubit(({int page = 1}) async {
        if (page == 1) {
          return const StateResource<List<Article>>.success(<Article>[
            _article,
          ]);
        }
        return nextPageCompleter.future;
      });

      await tester.pumpWidget(MaterialApp(home: NewsFeedScreen(cubit: cubit)));
      await tester.pump();

      cubit.getNextPage();
      await tester.pump();

      expect(find.byType(AppLoader), findsOneWidget);

      nextPageCompleter.complete(
        const StateResource<List<Article>>.success(<Article>[]),
      );
      await tester.pump();
      await cubit.close();
    });

    testWidgets('has no trailing loading row once every page has loaded', (
      WidgetTester tester,
    ) async {
      final NewsFeedCubit cubit = NewsFeedCubit(({int page = 1}) async {
        if (page == 1) {
          return const StateResource<List<Article>>.success(<Article>[
            _article,
          ]);
        }
        return const StateResource<List<Article>>.success(<Article>[]);
      });

      await tester.pumpWidget(MaterialApp(home: NewsFeedScreen(cubit: cubit)));
      await tester.pumpAndSettle();

      expect(find.byType(AppLoader), findsNothing);
      expect(cubit.state.hasReachedMax, isTrue);

      await cubit.close();
    });

    testWidgets(
      'automatically requests more pages while the list does not fill the '
      'screen',
      (WidgetTester tester) async {
        final List<int> requestedPages = <int>[];
        final NewsFeedCubit cubit = NewsFeedCubit(({int page = 1}) async {
          requestedPages.add(page);
          if (page >= 3) {
            return const StateResource<List<Article>>.success(<Article>[]);
          }
          return const StateResource<List<Article>>.success(<Article>[
            _article,
          ]);
        });

        await tester.pumpWidget(
          MaterialApp(home: NewsFeedScreen(cubit: cubit)),
        );
        await tester.pumpAndSettle();

        expect(requestedPages, <int>[1, 2, 3]);
        expect(cubit.state.hasReachedMax, isTrue);
        expect(cubit.state.data, hasLength(2));

        await cubit.close();
      },
    );

    testWidgets('does not chain another page after a failed next page', (
      WidgetTester tester,
    ) async {
      int nextPageRequests = 0;
      final NewsFeedCubit cubit = NewsFeedCubit(({int page = 1}) async {
        if (page == 1) {
          return const StateResource<List<Article>>.success(<Article>[
            _article,
          ]);
        }
        nextPageRequests++;
        return const StateResource<List<Article>>.error('Boom');
      });

      await tester.pumpWidget(MaterialApp(home: NewsFeedScreen(cubit: cubit)));
      await tester.pumpAndSettle();

      expect(nextPageRequests, 1);
      expect(find.byType(AppLoader), findsNothing);

      await cubit.close();
    });

    testWidgets('card renders the title, source, and formatted date', (
      WidgetTester tester,
    ) async {
      const Article article = Article(
        source: ArticleSource(id: null, name: 'BBC Sport'),
        author: null,
        title: 'United win again',
        description: null,
        url: null,
        urlToImage: null,
        publishedAt: '2026-09-15T12:06:44Z',
        content: null,
      );

      await _pumpSingleArticleCard(tester, article);

      expect(find.text(article.title!), findsOneWidget);
      expect(
        find.text(
          'BBC Sport${AppStrings.sourceDateSeparator}'
          '${DateFormatter.format(article.publishedAt)}',
        ),
        findsOneWidget,
      );
    });

    testWidgets('card shows the placeholder when the image url is null', (
      WidgetTester tester,
    ) async {
      await _pumpSingleArticleCard(tester, _article);

      expect(_placeholderImageFinder(), findsOneWidget);
    });

    testWidgets(
      'card shows just the date, with no leading separator, when the '
      'source is null',
      (WidgetTester tester) async {
        const Article article = Article(
          source: null,
          author: null,
          title: 'No source',
          description: null,
          url: null,
          urlToImage: null,
          publishedAt: '2026-09-15T12:06:44Z',
          content: null,
        );

        await _pumpSingleArticleCard(tester, article);

        expect(
          find.text(DateFormatter.format(article.publishedAt)),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'card renders no blank row when both source and date are null',
      (WidgetTester tester) async {
        await _pumpSingleArticleCard(tester, _article);

        expect(
          find.descendant(
            of: find.byType(Card),
            matching: find.byType(Text),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
