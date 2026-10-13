import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SvgPicture renders pure vector paths without error', (tester) async {
    const svgContent = '''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">
  <circle cx="50" cy="50" r="40" fill="#147E5E" />
</svg>
''';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SvgPicture.string(svgContent),
        ),
      ),
    );

    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('SvgPicture handles embedded data URI image tag', (tester) async {
    // 1x1 transparent png
    final base64Png = base64Encode([
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
      0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196,
      137, 0, 0, 0, 11, 73, 68, 65, 84, 120, 156, 99, 96, 0, 0, 0,
      2, 0, 1, 226, 33, 188, 51, 0, 0, 0, 0, 73, 69, 78, 68,
      174, 66, 96, 130
    ]);
    final svgWithImage = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100" height="100" viewBox="0 0 100 100">
  <image width="100" height="100" href="data:image/png;base64,$base64Png"/>
</svg>
''';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SvgPicture.string(svgWithImage),
        ),
      ),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('SvgPicture renders asset svg files without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SvgPicture.asset(
            'assets/vectors/onboarding_1.svg',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
