import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/main.dart';

void main() {
  testWidgets('app builds a MaterialApp without throwing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UnitedManiaApp());
    // A deterministic jump past the mock repo's one-second delay, rather
    // than pumpAndSettle: the indeterminate loader's animation keeps
    // scheduling frames, which makes "settled" unreliable to wait for here.
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
