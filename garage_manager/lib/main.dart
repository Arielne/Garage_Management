import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/app_theme.dart';
import 'core/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nywdepmmllfeyfuidtyi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im55d2RlcG1tbGxmZXlmdWlkdHlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI5OTYxNDEsImV4cCI6MjA5ODU3MjE0MX0.mfD3TWuhjiuDlG5sUXF91mYssi7T9FgLTfUD0uXh5Yc',
  );

  runApp(
    const ProviderScope(
      child: GarageManagerApp(),
    ),
  );
}

class GarageManagerApp extends StatelessWidget {
  const GarageManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
