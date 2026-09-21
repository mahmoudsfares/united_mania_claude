import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/shared_widgets/app_error_view.dart';
import 'package:united_mania_claude/core/utils/app_strings.dart';

void main() {
  group('AppErrorView', () {
    testWidgets('renders the given message and the retry button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorView(message: 'Something went wrong.', onRetry: () {}),
          ),
        ),
      );

      expect(find.text('Something went wrong.'), findsOneWidget);
      expect(find.text(AppStrings.retry), findsOneWidget);
    });

    testWidgets('calls onRetry when the retry button is tapped', (
      WidgetTester tester,
    ) async {
      int retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorView(
              message: 'Something went wrong.',
              onRetry: () => retryCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text(AppStrings.retry));
      await tester.pump();

      expect(retryCount, 1);
    });
  });
}
