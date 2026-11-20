import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_mateapp/main.dart';
import 'package:meal_mateapp/ui/features/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'major screens lay out without render exceptions at phone, tablet, and landscape sizes',
    (tester) async {
      const viewports = [
        Size(320, 568),
        Size(360, 800),
        Size(375, 812),
        Size(393, 873),
        Size(412, 915),
        Size(432, 960),
        Size(600, 960),
        Size(768, 1024),
        Size(568, 320),
        Size(1024, 768),
      ];
      const routes = [
        '/home',
        '/recipes',
        '/recipes/qm_01',
        '/favorites',
        '/planner',
        '/settings',
        '/groceries',
        '/profile',
      ];
      GoRouter? router;

      for (final size in viewports) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(const MealMateApp());
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 250)),
        );
        router?.go('/home');
        await tester.pumpAndSettle(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull, reason: 'home at $size');

        router ??= GoRouter.of(tester.element(find.byType(HomeScreen)));
        for (final route in routes.skip(1)) {
          router.go(route);
          await tester.pumpAndSettle(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull, reason: '$route at $size');
        }
      }

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    },
  );
}
