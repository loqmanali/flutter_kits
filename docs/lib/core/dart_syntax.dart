import 'package:flutter/material.dart';

/// Minimal Dart syntax highlighting for the docs' code blocks.
///
/// A single-pass regex tokenizer — comments, strings, annotations, keywords,
/// numbers and type names. That covers everything a snippet actually shows;
/// anything unmatched falls through as plain foreground text, so a construct
/// this doesn't know about is uncoloured rather than mangled.
///
/// Colours are the GitHub light/dark palettes, which are already verified at
/// WCAG AA against the muted surface the code block sits on.
class DartSyntax {
  const DartSyntax._();

  static const _keywords = <String>{
    'abstract', 'as', 'assert', 'async', 'await', 'base', 'break', 'case',
    'catch', 'class', 'const', 'continue', 'covariant', 'default', 'deferred',
    'do', 'dynamic', 'else', 'enum', 'export', 'extends', 'extension',
    'external', 'factory', 'false', 'final', 'finally', 'for', 'get', 'hide',
    'if', 'implements', 'import', 'in', 'interface', 'is', 'late', 'library',
    'mixin', 'new', 'null', 'on', 'operator', 'part', 'required', 'rethrow',
    'return', 'sealed', 'set', 'show', 'static', 'super', 'switch', 'sync',
    'this', 'throw', 'true', 'try', 'typedef', 'var', 'void', 'when', 'while',
    'with', 'yield',
  };

  /// Order matters: comments and strings win over everything inside them.
  static final _token = RegExp(
    r'''(\/\/[^\n]*|\/\*[\s\S]*?\*\/)'''      // 1 comment
    r'''|('(?:\\.|[^'\\\n])*'|"(?:\\.|[^"\\\n])*")''' // 2 string
    r'''|(@[A-Za-z_]\w*)'''                    // 3 annotation
    r'''|(\b\d[\w.]*\b)'''                     // 4 number
    r'''|(\b[A-Za-z_]\w*\b)''',                // 5 word (keyword or type)
  );

  /// Splits [code] into styled spans for a [SelectableText.rich].
  static TextSpan highlight(String code, ThemeData theme) {
    final palette = _Palette.of(theme);
    final base = TextStyle(
      fontFamily: 'monospace',
      fontSize: 12.5,
      height: 1.55,
      color: palette.plain,
    );

    final spans = <TextSpan>[];
    var cursor = 0;

    void plain(int end) {
      if (end > cursor) spans.add(TextSpan(text: code.substring(cursor, end)));
    }

    for (final m in _token.allMatches(code)) {
      plain(m.start);
      final text = m[0]!;

      final color = switch (m) {
        _ when m[1] != null => palette.comment,
        _ when m[2] != null => palette.string,
        _ when m[3] != null => palette.annotation,
        _ when m[4] != null => palette.number,
        // A bare word: a reserved word, or a type/constructor by convention.
        _ when _keywords.contains(text) => palette.keyword,
        _ when text.startsWith(RegExp('[A-Z]')) => palette.type,
        _ => null,
      };

      spans.add(
        color == null
            ? TextSpan(text: text)
            : TextSpan(text: text, style: TextStyle(color: color)),
      );
      cursor = m.end;
    }
    plain(code.length);

    return TextSpan(style: base, children: spans);
  }
}

/// The six colours a snippet needs, per brightness.
class _Palette {
  const _Palette({
    required this.plain,
    required this.comment,
    required this.string,
    required this.keyword,
    required this.number,
    required this.type,
    required this.annotation,
  });

  final Color plain;
  final Color comment;
  final Color string;
  final Color keyword;
  final Color number;
  final Color type;
  final Color annotation;

  static _Palette of(ThemeData theme) =>
      theme.brightness == Brightness.dark ? _dark : _light;

  static const _light = _Palette(
    plain: Color(0xFF1F2328),
    comment: Color(0xFF6E7781),
    string: Color(0xFF0A3069),
    keyword: Color(0xFFCF222E),
    number: Color(0xFF0550AE),
    type: Color(0xFF953800),
    annotation: Color(0xFF8250DF),
  );

  static const _dark = _Palette(
    plain: Color(0xFFE6EDF3),
    comment: Color(0xFF9198A1),
    string: Color(0xFFA5D6FF),
    keyword: Color(0xFFFF7B72),
    number: Color(0xFF79C0FF),
    type: Color(0xFFFFA657),
    annotation: Color(0xFFD2A8FF),
  );
}
