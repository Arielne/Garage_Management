import 'package:flutter_test/flutter_test.dart';

import 'package:garage_manager/main.dart';

void main() {
  testWidgets('Garage Manager test', (WidgetTester tester) async {
    await tester.pumpWidget(const GarageManagerApp());

    expect(find.text('Garage Manager'), findsOneWidget);
    expect(find.text('Khung app chung cho team'), findsOneWidget);
  });
}
