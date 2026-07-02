import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:garage_manager/features/auth/login_screen.dart';
import 'package:garage_manager/main.dart';

void main() {
  testWidgets('shows splash then opens login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GarageManagerApp(),
      ),
    );

    expect(find.text('GARAGE MANAGER'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
