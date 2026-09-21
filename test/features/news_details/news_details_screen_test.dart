import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/utils/app_images.dart';
import 'package:united_mania_claude/core/utils/app_strings.dart';
import 'package:united_mania_claude/core/utils/date_formatter.dart';
import 'package:united_mania_claude/features/news_details/business_logic/news_details_cubit.dart';
import 'package:united_mania_claude/features/news_details/news_details_screen.dart';
import 'package:united_mania_claude/features/news_feed/models/article.dart';
import 'package:united_mania_claude/features/news_feed/models/article_source.dart';
import 'package:url_launcher/url_launcher.dart';

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

const String _rawContent =
    'Manchester United have confirmed a new principal partnership that '
    'will run until the end of the 2029-30 season... [+2114 chars]';
const String _strippedContent =
    'Manchester United have confirmed a new principal partnership that '
    'will run until the end of the 2029-30 season';

const Article _fullArticle = Article(
  source: ArticleSource(id: 'bbc-sport', name: 'BBC Sport'),
  author: 'Simon Stone',
  title: 'Manchester United confirm shirt sponsor extension through 2030',
  description:
      'Manchester United have extended their principal partnership deal.',
  url: 'https://www.bbc.co.uk/sport/football/man-utd-shirt-sponsor-extension',
  urlToImage:
      'https://ichef.bbci.co.uk/live-experience/cps/624/manutd-shirt.jpg',
  publishedAt: '2026-09-19T08:30:00Z',
  content: _rawContent,
);

const Article _articleWithoutBody = Article(
  source: ArticleSource(id: 'bbc-sport', name: 'BBC Sport'),
  author: 'Simon Stone',
  title: 'Manchester United confirm shirt sponsor extension through 2030',
  description: null,
  url: null,
  urlToImage:
      'https://ichef.bbci.co.uk/live-experience/cps/624/manutd-shirt.jpg',
  publishedAt: '2026-09-19T08:30:00Z',
  content: null,
);

Finder _placeholderImageFinder() {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == AppImages.articlePlaceholder,
  );
}

Future<void> _pumpScreen(WidgetTester tester, Article article) async {
  final NewsDetailsCubit cubit = NewsDetailsCubit(
    (String url, {required LaunchMode mode}) async => true,
  );
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(home: NewsDetailsScreen(article: article, cubit: cubit)),
  );
}

void main() {
  group('NewsDetailsScreen', () {
    testWidgets('renders the title of the article it is given', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, _article);

      expect(find.text(_article.title!), findsOneWidget);
    });

    testWidgets('renders all six sections for a full article', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, _fullArticle);

      final Image networkImage = tester.widget<Image>(
        find.byWidgetPredicate(
          (Widget widget) => widget is Image && widget.image is NetworkImage,
        ),
      );
      expect(
        (networkImage.image as NetworkImage).url,
        _fullArticle.urlToImage,
      );
      expect(find.text(_fullArticle.title!), findsOneWidget);
      expect(
        find.text(
          '${_fullArticle.author}${AppStrings.sourceDateSeparator}'
          '${_fullArticle.source!.name}',
        ),
        findsOneWidget,
      );
      expect(
        find.text(DateFormatter.format(_fullArticle.publishedAt)),
        findsOneWidget,
      );
      expect(find.text(_fullArticle.description!), findsOneWidget);
      expect(find.text(_strippedContent), findsOneWidget);
      expect(find.text(AppStrings.readFullArticle), findsOneWidget);
    });

    testWidgets(
      'omits description and content, without overflowing, when both are '
      'null',
      (WidgetTester tester) async {
        await _pumpScreen(tester, _articleWithoutBody);

        expect(find.text(_articleWithoutBody.title!), findsOneWidget);
        expect(
          find.text(
            '${_articleWithoutBody.author}${AppStrings.sourceDateSeparator}'
            '${_articleWithoutBody.source!.name}',
          ),
          findsOneWidget,
        );
        expect(find.byType(Text), findsNWidgets(4));
      },
    );

    testWidgets('strips the truncation counter from the content', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, _fullArticle);

      expect(find.text(_strippedContent), findsOneWidget);
      expect(find.textContaining('chars]'), findsNothing);
    });

    testWidgets('shows the placeholder when the image url is null', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, _article);

      expect(_placeholderImageFinder(), findsOneWidget);
    });

    testWidgets('byline shows the source alone when the author is null', (
      WidgetTester tester,
    ) async {
      const Article article = Article(
        source: ArticleSource(id: null, name: 'BBC Sport'),
        author: null,
        title: 'No author',
        description: null,
        url: null,
        urlToImage: null,
        publishedAt: null,
        content: null,
      );

      await _pumpScreen(tester, article);

      expect(find.text('BBC Sport'), findsOneWidget);
    });

    testWidgets(
      'omits the byline entirely, with no blank row, when author and '
      'source are both null',
      (WidgetTester tester) async {
        await _pumpScreen(tester, _article);

        expect(find.byType(Text), findsNWidgets(2));
      },
    );

    testWidgets('renders the hyperlink and calls the cubit with the url', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
          home: NewsDetailsScreen(article: _fullArticle, cubit: cubit),
        ),
      );

      expect(find.text(AppStrings.readFullArticle), findsOneWidget);

      await tester.tap(find.text(AppStrings.readFullArticle));
      await tester.pumpAndSettle();

      expect(openedUrl, _fullArticle.url);
    });
  });
}
