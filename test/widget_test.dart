import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:today_menu/models/menu_item.dart';
import 'package:today_menu/providers/filter_provider.dart';
import 'package:today_menu/providers/menu_provider.dart';
import 'package:today_menu/providers/theme_provider.dart';
import 'package:today_menu/repositories/local_storage_repository.dart';
import 'package:today_menu/repositories/menu_repository.dart';
import 'package:today_menu/screens/home_screen.dart';

void main() {
  testWidgets('App starts with HomeScreen and renders Today Menu button', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final mockPrefs = await SharedPreferences.getInstance();

    final menuRepo = LocalJsonMenuRepository.withMenus([
      const MenuItem(
        id: 'menu_01',
        name: '김치찌개',
        category: '한식',
        subCategory: '찌개',
        mealType: ['혼밥', '집밥'],
        priceLevel: 2,
        estimatedPrice: '8,000원',
        cookingTime: 20,
        spicy: true,
        soup: true,
        rice: true,
        noodle: false,
        meat: true,
        healthy: false,
        deliveryAvailable: true,
        tags: ['국물'],
      ),
    ]);

    final storageRepo = SharedPreferencesLocalStorageRepository(mockPrefs);
    final filterProvider = FilterProvider(storageRepo);
    final menuProvider = MenuProvider(
      menuRepository: menuRepo,
      storageRepository: storageRepo,
    );
    final themeProvider = ThemeProvider(mockPrefs);

    await filterProvider.initialize();
    await menuProvider.initialize();
    await themeProvider.initialize();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: filterProvider),
          ChangeNotifierProvider.value(value: menuProvider),
          ChangeNotifierProvider.value(value: themeProvider),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title, Subtitle and Buttons exist
    expect(find.text('오늘 뭐 먹지?'), findsWidgets);
    expect(find.text('1초 만에 딱 골라드려요 🍽️'), findsOneWidget);
    expect(find.text('메뉴 룰렛'), findsOneWidget);
    expect(find.text('메뉴 골라줘!'), findsOneWidget);
  });
}
