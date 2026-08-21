import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'providers/filter_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/local_storage_repository.dart';
import 'repositories/menu_repository.dart';
import 'screens/home_screen.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize repositories
  final menuRepository = LocalJsonMenuRepository();
  final storageRepository = SharedPreferencesLocalStorageRepository();

  // Initialize providers
  final filterProvider = FilterProvider(storageRepository);
  final menuProvider = MenuProvider(
    menuRepository: menuRepository,
    storageRepository: storageRepository,
  );
  final themeProvider = ThemeProvider();

  // Load initial data defensively
  try {
    await Future.wait([
      filterProvider.initialize(),
      menuProvider.initialize(),
      themeProvider.initialize(),
    ]);
  } catch (e) {
    debugPrint('Init error: $e');
  }

  // Initialize NotificationService in background
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('NotificationService error: $e');
  }

  // Initialize AdMob in background (safe non-blocking)
  try {
    AdService().initialize();
  } catch (e) {
    debugPrint('AdService error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: filterProvider),
        ChangeNotifierProvider.value(value: menuProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const TodayMenuApp(),
    ),
  );
}

class TodayMenuApp extends StatelessWidget {
  const TodayMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const HomeScreen(),
    );
  }
}
