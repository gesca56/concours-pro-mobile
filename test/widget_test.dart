import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:concours_pro_app/providers/auth_provider.dart';
import 'package:concours_pro_app/screens/login_screen.dart';
import 'package:concours_pro_app/theme/app_theme.dart';

void main() {
  testWidgets("L'écran de connexion affiche les champs attendus", (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: MaterialApp(theme: AppTheme.light(), home: const LoginScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Se connecter'), findsOneWidget);
    expect(find.text('Créer un compte candidat'), findsOneWidget);
  });
}
