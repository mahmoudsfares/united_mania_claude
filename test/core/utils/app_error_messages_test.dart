import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/utils/app_error_messages.dart';

void main() {
  group('AppErrorMessages', () {
    test('every message is non-empty', () {
      expect(AppErrorMessages.noInternet, isNotEmpty);
      expect(AppErrorMessages.timeout, isNotEmpty);
      expect(AppErrorMessages.invalidApiKey, isNotEmpty);
      expect(AppErrorMessages.rateLimited, isNotEmpty);
      expect(AppErrorMessages.serverError, isNotEmpty);
      expect(AppErrorMessages.generic, isNotEmpty);
      expect(AppErrorMessages.noArticleLink, isNotEmpty);
      expect(AppErrorMessages.couldNotOpenLink, isNotEmpty);
    });
  });
}
