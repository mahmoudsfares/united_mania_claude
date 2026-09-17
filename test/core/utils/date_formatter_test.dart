import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:united_mania_claude/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('formats a valid ISO-8601 timestamp', () {
      const String input = '2026-09-15T12:06:44Z';
      final String expected = DateFormat(
        'd MMM yyyy',
      ).format(DateTime.parse(input).toLocal());

      expect(DateFormatter.format(input), expected);
    });

    test('returns an empty string for null', () {
      expect(DateFormatter.format(null), '');
    });

    test('returns an empty string for an empty string', () {
      expect(DateFormatter.format(''), '');
    });

    test('returns an empty string for unparseable input', () {
      expect(DateFormatter.format('not a date'), '');
    });
  });
}
