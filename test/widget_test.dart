import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mateapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MealMateApp boots and renders navigation structure', (WidgetTester tester) async {
    await tester.pumpWidget(const MealMateApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Mealmate'), findsAtLeastNWidgets(1));
    expect(find.text('Home'), findsAtLeastNWidgets(1));
    expect(find.text('Favorites'), findsAtLeastNWidgets(1));
    expect(find.text('Meal Planner'), findsAtLeastNWidgets(1));
    expect(find.text('Settings'), findsAtLeastNWidgets(1));
  });
}
