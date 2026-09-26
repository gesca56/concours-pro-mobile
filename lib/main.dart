import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ConcoursProApp());
}

class ConcoursProApp extends StatelessWidget {
  const ConcoursProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Concours-Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _RacineApp(),
      ),
    );
  }
}

class _RacineApp extends StatelessWidget {
  const _RacineApp();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return auth.isAuthenticated ? const DashboardScreen() : const LoginScreen();
  }
}
