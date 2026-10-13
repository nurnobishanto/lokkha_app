import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/constants/app_images.dart';
import 'package:lokkha/shared/widgets/app_svg_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSvgImage Reusable Widget Tests', () {
    testWidgets('renders from asset constructor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSvgImage.asset(
              AssetVectorPaths.onboarding1,
              width: 150,
              height: 150,
            ),
          ),
        ),
      );

      expect(find.byType(AppSvgImage), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('renders from string constructor', (tester) async {
      const svg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50">
  <rect width="50" height="50" fill="#147E5E"/>
</svg>
''';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSvgImage.string(
              svg,
              width: 50,
              height: 50,
            ),
          ),
        ),
      );

      expect(find.byType(AppSvgImage), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('renders default constructor with asset path', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSvgImage(
              AssetVectorPaths.splashIcon,
              width: 80,
              height: 80,
            ),
          ),
        ),
      );

      expect(find.byType(AppSvgImage), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('renders fallback error widget when empty path is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSvgImage.asset(''),
          ),
        ),
      );

      expect(find.byType(AppSvgImage), findsOneWidget);
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    });
  });
}
