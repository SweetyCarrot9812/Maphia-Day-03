import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🌐 Hanoa Web Version - Starting without Isar database');
  
  runApp(const ProviderScope(child: HanoaWebApp()));
}

class HanoaWebApp extends ConsumerWidget {
  const HanoaWebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppInitializer(
      child: MaterialApp.router(
        title: 'Hanoa - 슈퍼앱 (Web Demo)',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}