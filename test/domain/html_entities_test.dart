import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/normalize/html_entities.dart';

void main() {
  group('HtmlEntities.unescape', () {
    test('Decodes the entities Cloud Translation v2 commonly returns', () {
      expect(HtmlEntities.unescape("It&#39;s 100&amp;"), equals("It's 100&"));
      expect(
        HtmlEntities.unescape('&lt;tag&gt; &quot;x&quot;'),
        equals('<tag> "x"'),
      );
    });

    test('Leaves plain text unchanged', () {
      expect(HtmlEntities.unescape("It's 100%"), equals("It's 100%"));
      expect(HtmlEntities.unescape(''), equals(''));
    });

    test('Decodes &amp; last so compound entities resolve', () {
      expect(HtmlEntities.unescape('&amp;lt;'), equals('&lt;'));
    });

    test('Decodes hex numeric entities', () {
      expect(HtmlEntities.unescape('&#x27;'), equals("'"));
    });
  });
}
