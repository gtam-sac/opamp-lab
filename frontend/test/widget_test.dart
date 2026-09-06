import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:opamp_lab_frontend/app.dart';
import 'package:opamp_lab_frontend/services/auth_provider.dart';

void main() {
  testWidgets('Op-Amp Lab app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const OpAmpLabApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(OpAmpLabApp), findsOneWidget);
  });
}

