import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/utils/app_colors.dart';
import 'package:united_mania_claude/core/utils/app_theme.dart';

void main() {
  group('AppTheme.theme', () {
    test('colorScheme.primary is the red constant', () {
      expect(AppTheme.theme.colorScheme.primary, AppColors.primary);
    });

    test('body text style is white', () {
      expect(AppTheme.theme.textTheme.bodyMedium?.color, AppColors.white);
    });
  });

  group('AppTheme.theme widget', () {
    testWidgets('renders white text on the red surface', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const Scaffold(body: Center(child: Text('United Mania'))),
        ),
      );

      final BuildContext context = tester.element(find.byType(Scaffold));
      final Color surfaceColor = Theme.of(context).scaffoldBackgroundColor;
      expect(surfaceColor, AppColors.surface);

      final RichText richText = tester.widget<RichText>(
        find.descendant(
          of: find.text('United Mania'),
          matching: find.byType(RichText),
        ),
      );
      expect(richText.text.style?.color, AppColors.white);
    });
  });
}
