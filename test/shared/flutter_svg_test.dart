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
