import 'package:flutter_test/flutter_test.dart';
import 'package:united_mania_claude/core/networking/state_resource.dart';

void main() {
  group('StateResource', () {
    test('init sets only isInit to true', () {
      const StateResource<int> resource = StateResource<int>.init();

      expect(resource.isInit, true);
      expect(resource.isLoading, false);
      expect(resource.isSuccess, false);
      expect(resource.isError, false);
    });

    test('loading sets only isLoading to true', () {
      const StateResource<int> resource = StateResource<int>.loading();

      expect(resource.isInit, false);
      expect(resource.isLoading, true);
      expect(resource.isSuccess, false);
      expect(resource.isError, false);
    });

    test('success sets only isSuccess to true', () {
      const StateResource<int> resource = StateResource<int>.success(1);

      expect(resource.isInit, false);
      expect(resource.isLoading, false);
      expect(resource.isSuccess, true);
      expect(resource.isError, false);
    });

    test('error sets only isError to true', () {
      const StateResource<int> resource = StateResource<int>.error('failed');

      expect(resource.isInit, false);
      expect(resource.isLoading, false);
      expect(resource.isSuccess, false);
      expect(resource.isError, true);
    });

    test('success carries its data and a null error', () {
      const StateResource<int> resource = StateResource<int>.success(42);

      expect(resource.data, 42);
      expect(resource.error, null);
    });

    test('error carries its message and null data', () {
      const StateResource<int> resource = StateResource<int>.error('failed');

      expect(resource.error, 'failed');
      expect(resource.data, null);
    });

    test('two instances built the same way are equal', () {
      expect(const StateResource<int>.init(), const StateResource<int>.init());
      expect(
        const StateResource<int>.loading(),
        const StateResource<int>.loading(),
      );
      expect(
        const StateResource<int>.success(42),
        const StateResource<int>.success(42),
      );
      expect(
        const StateResource<int>.error('failed'),
        const StateResource<int>.error('failed'),
      );
    });

    test('instances built differently are not equal', () {
      expect(
        const StateResource<int>.success(1) ==
            const StateResource<int>.success(2),
        false,
      );
      expect(
        const StateResource<int>.error('a') == const StateResource<int>.error('b'),
        false,
      );
      expect(
        const StateResource<int>.init() == const StateResource<int>.loading(),
        false,
      );
    });
  });
}
