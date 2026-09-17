import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/main.dart';

void main() {
  testWidgets('app builds a MaterialApp without throwing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UnitedManiaApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
