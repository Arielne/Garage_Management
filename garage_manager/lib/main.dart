import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'core/app_routes.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://nywdepmmllfeyfuidtyi.supabase.co',
    anonKey: 'sb_publishable_fHoiSua2No-R0uhkB6RXUA_VqmX20Em',
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
