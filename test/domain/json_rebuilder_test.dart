import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/validation/json_rebuilder.dart';

void main() {
  group('JsonRebuilder Tests', () {
    test(
      'Rebuilds JSON preserving keyOrder, 2-space indent, UTF-8 Korean literals, and trailing newline',
      () {
        final entries = {
          'block.quark.oak_hedge': '참나무 산울타리',
          'item.quark.tome': '고대의 마도서',
        };
        final keyOrder = ['block.quark.oak_hedge', 'item.quark.tome'];

        final rebuilt = JsonRebuilder.rebuild(
          entries: entries,
          keyOrder: keyOrder,
        );

        const expected = '''
{
  "block.quark.oak_hedge": "참나무 산울타리",
  "item.quark.tome": "고대의 마도서"
}
''';

        expect(rebuilt, equals(expected));
        expect(rebuilt.endsWith('\n'), isTrue);
        expect(rebuilt, contains('참나무 산울타리'));
      },
    );
  });
}
