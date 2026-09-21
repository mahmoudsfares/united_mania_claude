import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/shared_widgets/app_loader.dart';
import 'package:united_mania_claude/core/utils/app_colors.dart';

void main() {
  group('AppLoader', () {
    testWidgets('shows a centred progress indicator in the theme colour', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLoader())),
      );

      expect(
        find.descendant(
          of: find.byType(Center),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      final CircularProgressIndicator indicator = tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          );
      expect(indicator.color, AppColors.primary);
    });
  });
}
