import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders placeholder', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: HomeScreen(),
    ));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Home placeholder'), findsOneWidget);
  });
}
