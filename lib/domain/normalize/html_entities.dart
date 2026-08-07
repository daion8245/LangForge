/// Decodes the HTML entities Cloud Translation v2 embeds in `translatedText`
/// even when the request uses `format: "text"`.
///
/// Named entities are applied before `&amp;` so that `&amp;lt;` becomes `&lt;`
/// then `<` in a single pass of this function's ordered replacements.
abstract final class HtmlEntities {
  static final RegExp _decimalEntity = RegExp(r'&#(\d+);');
  static final RegExp _hexEntity = RegExp(r'&#x([0-9A-Fa-f]+);');

  static String unescape(String input) {
    if (input.isEmpty || !input.contains('&')) return input;

    var out = input.replaceAllMapped(_decimalEntity, (match) {
      final code = int.tryParse(match.group(1)!);
      if (code == null || code < 0 || code > 0x10FFFF) return match.group(0)!;
      return String.fromCharCode(code);
    });

    out = out.replaceAllMapped(_hexEntity, (match) {
      final code = int.tryParse(match.group(1)!, radix: 16);
      if (code == null || code < 0 || code > 0x10FFFF) return match.group(0)!;
      return String.fromCharCode(code);
    });

    // Named entities — `&amp;` must be last so earlier replacements stay intact.
    out = out.replaceAll('&lt;', '<');
    out = out.replaceAll('&gt;', '>');
    out = out.replaceAll('&quot;', '"');
    out = out.replaceAll('&apos;', "'");
    out = out.replaceAll('&amp;', '&');
    return out;
  }
}
