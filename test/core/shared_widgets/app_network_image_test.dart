import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/shared_widgets/app_loader.dart';
import 'package:united_mania_claude/core/shared_widgets/app_network_image.dart';
import 'package:united_mania_claude/core/utils/app_images.dart';

Finder _placeholderFinder() {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName ==
            AppImages.articlePlaceholder,
  );
}

void main() {
  tearDown(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });

  group('AppNetworkImage', () {
    testWidgets('shows the placeholder for a null url', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppNetworkImage(url: null))),
      );

      expect(_placeholderFinder(), findsOneWidget);
    });

    testWidgets('shows the placeholder for an empty url', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppNetworkImage(url: ''))),
      );

      expect(_placeholderFinder(), findsOneWidget);
    });

    testWidgets('falls back to the placeholder when the fetch fails', (
      WidgetTester tester,
    ) async {
      // A lone "%" is invalid percent-encoding, so Uri parsing fails inside
      // the image loader — a real failure, exercised with no network access.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppNetworkImage(url: 'https://example.com/%')),
        ),
      );
      await tester.pumpAndSettle();

      expect(_placeholderFinder(), findsOneWidget);
    });

    testWidgets('fetches the image for a good url, with a loading indicator first', (
      WidgetTester tester,
    ) async {
      const String goodUrl = 'https://example.com/good.png';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppNetworkImage(url: goodUrl)),
        ),
      );

      final Image networkImage = tester.widget<Image>(
        find.byWidgetPredicate(
          (Widget widget) => widget is Image && widget.image is NetworkImage,
        ),
      );
      expect((networkImage.image as NetworkImage).url, goodUrl);

      final Widget whileLoading = networkImage.loadingBuilder!(
        tester.element(find.byType(AppNetworkImage)),
        const SizedBox.shrink(),
        const ImageChunkEvent(cumulativeBytesLoaded: 1, expectedTotalBytes: 2),
      );
      expect(whileLoading, isA<AppLoader>());

      const Widget loadedChild = SizedBox.shrink();
      final Widget whenDone = networkImage.loadingBuilder!(
        tester.element(find.byType(AppNetworkImage)),
        loadedChild,
        null,
      );
      expect(whenDone, same(loadedChild));
    });
  });
}
