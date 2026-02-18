import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxe/core/router/app_router.dart';
import 'package:luxe/core/theme/app_theme.dart';
import 'package:luxe/core/network/supa_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  await SupaService.initialize();

  runApp(const ProviderScope(child: LuxeApp()));
}

class LuxeApp extends ConsumerWidget {
  const LuxeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'LUXE',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'KE'),
    );
  }
}
