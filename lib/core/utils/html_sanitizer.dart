/// Utility to convert MathML to readable HTML tags (<sup>, <sub>, etc.)
/// and format HTML strings for presentation in [HtmlWidget].
class HtmlSanitizer {
  HtmlSanitizer._();

  /// Converts MathML elements into readable HTML (<sup>, <sub>, fractions, roots, etc.)
  static String convertMathMlToHtml(String input) {
    if (!input.contains('<math') &&
        !input.contains('<msup') &&
        !input.contains('<msub') &&
        !input.contains('<mfrac') &&
        !input.contains('<msqrt')) {
      return input;
    }
    var s = input;

    // 1. <msup> (base and exponent)
    // Case A: both base and exponent have wrapper tags, e.g. <msup><mi>m</mi><mn>2</mn></msup>
    s = s.replaceAllMapped(
      RegExp(
        r'<msup>\s*<([a-z0-9]+)[^>]*>(.*?)</\1>\s*<([a-z0-9]+)[^>]*>(.*?)</\3>\s*</msup>',
        caseSensitive: false,
      ),
      (m) => '${m[2]}<sup>${m[4]}</sup>',
    );
    // Case B: base has tag, exponent is raw text/number, e.g. <msup><mi>m</mi>2</msup>
    s = s.replaceAllMapped(
      RegExp(
        r'<msup>\s*<([a-z0-9]+)[^>]*>(.*?)</\1>\s*([^<]+?)\s*</msup>',
        caseSensitive: false,
      ),
      (m) => '${m[2]}<sup>${m[3]}</sup>',
    );
    // Case C: base is raw text, exponent has tag, e.g. <msup>m<mn>2</mn></msup>
    s = s.replaceAllMapped(
      RegExp(
        r'<msup>\s*([^<]+?)\s*<([a-z0-9]+)[^>]*>(.*?)</\2>\s*</msup>',
        caseSensitive: false,
      ),
      (m) => '${m[1]}<sup>${m[3]}</sup>',
    );
    // Case D: both are raw text, e.g. <msup>m 2</msup>
    s = s.replaceAllMapped(
      RegExp(
        r'<msup>\s*([a-zA-Z0-9]+)\s+([a-zA-Z0-9]+)\s*</msup>',
        caseSensitive: false,
      ),
      (m) => '${m[1]}<sup>${m[2]}</sup>',
    );

    // 2. <msub> (base and subscript)
    s = s.replaceAllMapped(
      RegExp(
        r'<msub>\s*<([a-z0-9]+)[^>]*>(.*?)</\1>\s*<([a-z0-9]+)[^>]*>(.*?)</\3>\s*</msub>',
        caseSensitive: false,
      ),
      (m) => '${m[2]}<sub>${m[4]}</sub>',
    );
    s = s.replaceAllMapped(
      RegExp(
        r'<msub>\s*<([a-z0-9]+)[^>]*>(.*?)</\1>\s*([^<]+?)\s*</msub>',
        caseSensitive: false,
      ),
      (m) => '${m[2]}<sub>${m[3]}</sub>',
    );
    s = s.replaceAllMapped(
      RegExp(
        r'<msub>\s*([^<]+?)\s*<([a-z0-9]+)[^>]*>(.*?)</\2>\s*</msub>',
        caseSensitive: false,
      ),
      (m) => '${m[1]}<sub>${m[3]}</sub>',
    );

    // 3. <mfrac>
    s = s.replaceAllMapped(
      RegExp(
        r'<mfrac>\s*<([a-z0-9]+)[^>]*>(.*?)</\1>\s*<([a-z0-9]+)[^>]*>(.*?)</\3>\s*</mfrac>',
        caseSensitive: false,
      ),
      (m) => '(${m[2]})/(${m[4]})',
    );

    // 4. <msqrt>
    s = s.replaceAllMapped(
      RegExp(
        r'<msqrt>\s*([\s\S]*?)\s*</msqrt>',
        caseSensitive: false,
      ),
      (m) => '√(${m[1]})',
    );

    // 5. Strip individual MathML inline tags, preserving inner text
    s = s.replaceAll(
      RegExp(
        r'</?(?:mi|mn|mo|mtext|mrow|mspace|semantics|annotation)\b[^>]*>',
        caseSensitive: false,
      ),
      '',
    );

    // 6. Strip outer <math> tags
    s = s.replaceAll(
      RegExp(r'</?math\b[^>]*>', caseSensitive: false),
      '',
    );

    return s;
  }

  /// Converts inline LaTeX math expressions (e.g. `$\frac{\sqrt{3}}{4}a^2$`) into clean HTML.
  static String convertLatexToHtml(String input) {
    if (!input.contains(r'\') && !input.contains(r'$') && !input.contains('^')) {
      return input;
    }
    var s = input;

    // 1. Convert \sqrt{...} -> √... or √(...)
    s = s.replaceAllMapped(
      RegExp(r'\\sqrt\{([^{}]+)\}'),
      (m) {
        final inner = m[1]!.trim();
        return inner.length <= 2 ? '√$inner' : '√($inner)';
      },
    );

    // 2. Convert \frac{num}{den} (supports nested \sqrt already converted)
    for (int i = 0; i < 2; i++) {
      s = s.replaceAllMapped(
        RegExp(r'\\frac\{([^{}]+)\}\{([^{}]+)\}'),
        (m) => '(${m[1]!.trim()}/${m[2]!.trim()})',
      );
    }

    // 3. Common LaTeX symbols
    s = s
        .replaceAll(r'\times', '×')
        .replaceAll(r'\div', '÷')
        .replaceAll(r'\pm', '±')
        .replaceAll(r'\leq', '≤')
        .replaceAll(r'\geq', '≥')
        .replaceAll(r'\neq', '≠')
        .replaceAll(r'\approx', '≈')
        .replaceAll(r'\pi', 'π')
        .replaceAll(r'\theta', 'θ')
        .replaceAll(r'\alpha', 'α')
        .replaceAll(r'\beta', 'β')
        .replaceAll(r'\gamma', 'γ')
        .replaceAll(r'\degree', '°')
        .replaceAll(r'\circ', '°');

    // 4. Superscripts: ^{...} or ^x
    s = s.replaceAllMapped(
      RegExp(r'\^\{([^{}]+)\}'),
      (m) => '<sup>${m[1]}</sup>',
    );
    s = s.replaceAllMapped(
      RegExp(r'\^([0-9a-zA-Z+\-]+)'),
      (m) => '<sup>${m[1]}</sup>',
    );

    // 5. Subscripts: _{...} or _x
    s = s.replaceAllMapped(
      RegExp(r'_\{([^{}]+)\}'),
      (m) => '<sub>${m[1]}</sub>',
    );
    s = s.replaceAllMapped(
      RegExp(r'_([0-9]+)'),
      (m) => '<sub>${m[1]}</sub>',
    );

    // 6. Strip inline math $...$ delimiters
    s = s.replaceAllMapped(
      RegExp(r'\$([^$]+)\$'),
      (m) => m[1]!,
    );

    return s;
  }

  /// Sanitizes and prepares HTML content for [HtmlWidget].
  /// Translates MathML & LaTeX, removes hardcoded background styles, and adapts inline colors for dark mode.
  static String formatForDisplay(String? raw, {bool isDark = false}) {
    if (raw == null || raw.trim().isEmpty) return '';

    var s = raw.trim();

    // 1. Convert MathML elements (like <msup>, <msub>, etc.) and LaTeX math
    s = convertMathMlToHtml(s);
    s = convertLatexToHtml(s);

    // 2. Remove inline background-color so container backgrounds aren't overwritten
    s = s.replaceAll(
      RegExp(r'background-color\s*:\s*[^;"]+;?', caseSensitive: false),
      '',
    );

    // 3. Remove hardcoded inline colors in dark mode to avoid dark text on dark background
    if (isDark) {
      s = s.replaceAll(
        RegExp(r'color\s*:\s*[^;"]+;?', caseSensitive: false),
        '',
      );
    }

    // 4. Collapse consecutive empty line breaks
    s = s.replaceAll(RegExp(r'(?:<br\s*/?>\s*){3,}', caseSensitive: false), '<br/><br/>');

    return s.trim();
  }
}
