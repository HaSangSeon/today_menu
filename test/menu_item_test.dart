import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:today_menu/models/filter_criteria.dart';
import 'package:today_menu/models/menu_item.dart';
import 'package:today_menu/services/recommendation_engine.dart';

void main() {
  group('MenuItem Model & menus.json Verification', () {
    test('menus.json file contains over 300 items with valid properties', () {
      final file = File('assets/data/menus.json');
      expect(file.existsSync(), isTrue, reason: 'assets/data/menus.json must exist');

      final jsonString = file.readAsStringSync();
      final dynamic decoded = json.decode(jsonString);

      expect(decoded, isA<List>());
      final list = decoded as List;

      // Requirement: At least 300 items
      expect(list.length, greaterThanOrEqualTo(300));

      for (var item in list) {
        final map = item as Map<String, dynamic>;
        final menuItem = MenuItem.fromJson(map);

        expect(menuItem.id, isNotEmpty);
        expect(menuItem.name, isNotEmpty);
        expect(menuItem.category, isNotEmpty);
        expect(menuItem.mealType, isNotEmpty);
        expect(menuItem.priceLevel, inInclusiveRange(1, 4));
        expect(menuItem.cookingTime, greaterThan(0));
        expect(menuItem.tags, isNotEmpty);
        expect(menuItem.emoji, isNotEmpty);
      }
    });

    test('MenuItem serialization roundtrip and accurate emoji matching', () {
      const item = MenuItem(
        id: 'test_01',
        name: '테스트김치찌개',
        category: '한식',
        subCategory: '찌개',
        mealType: ['집밥', '혼밥'],
        priceLevel: 2,
        estimatedPrice: '8,000~10,000원',
        cookingTime: 20,
        spicy: true,
        soup: true,
        rice: true,
        noodle: false,
        meat: true,
        healthy: false,
        deliveryAvailable: true,
        tags: ['국물', '매운맛'],
      );

      final jsonMap = item.toJson();
      final fromJsonItem = MenuItem.fromJson(jsonMap);

      expect(fromJsonItem.id, item.id);
      expect(fromJsonItem.name, item.name);
      expect(fromJsonItem.category, item.category);
      expect(fromJsonItem.subCategory, item.subCategory);
      expect(fromJsonItem.mealType, item.mealType);
      expect(fromJsonItem.priceLevel, item.priceLevel);
      expect(fromJsonItem.cookingTime, item.cookingTime);
      expect(fromJsonItem.spicy, item.spicy);
      expect(fromJsonItem.soup, item.soup);
      expect(fromJsonItem.rice, item.rice);
      expect(fromJsonItem.meat, item.meat);
      expect(fromJsonItem.emoji, '🍲');
    });

    test('Granular food emoji matching verification across various dishes', () {
      MenuItem createItem(String name, {String cat = '한식', String sub = ''}) {
        return MenuItem(
          id: 'test',
          name: name,
          category: cat,
          subCategory: sub,
          mealType: ['외식'],
          priceLevel: 2,
          estimatedPrice: '10,000원',
          cookingTime: 15,
          spicy: false,
          soup: false,
          rice: false,
          noodle: false,
          meat: false,
          healthy: false,
          deliveryAvailable: true,
          tags: [],
        );
      }

      expect(createItem('포테이토피자').emoji, '🍕');
      expect(createItem('치즈버거세트').emoji, '🍔');
      expect(createItem('베이컨토마토파스타').emoji, '🍝');
      expect(createItem('양념치킨').emoji, '🍗');
      expect(createItem('삼겹살구이').emoji, '🥓');
      expect(createItem('한우안심스테이크').emoji, '🥩');
      expect(createItem('연어초밥').emoji, '🍣');
      expect(createItem('해물라면').emoji, '🍜');
      expect(createItem('로제떡볶이').emoji, '🍢');
      expect(createItem('바삭등심돈까스').emoji, '🍱');
      expect(createItem('일본식카레라이스').emoji, '🍛');
      expect(createItem('닭가슴살샐러드').emoji, '🥗');
      expect(createItem('소고기미역국').emoji, '🍲');
      expect(createItem('간장게장정식').emoji, '🦀');
      expect(createItem('칠리새우').emoji, '🦐');
      expect(createItem('낙지볶음덮밥').emoji, '🐙');
      expect(createItem('군만두').emoji, '🥟');
    });

    test('355개 전체 메뉴 대상 룰렛 및 추천의 100% 조건 일치 정밀 검증', () {
      final file = File('assets/data/menus.json');
      final jsonString = file.readAsStringSync();
      final List<dynamic> decoded = json.decode(jsonString);
      final allMenus = decoded.map((e) => MenuItem.fromJson(e as Map<String, dynamic>)).toList();
      final engine = RecommendationEngine();

      // 1. 매운맛 프리셋 선택 시 -> 추천 & 룰렛 후보 100% spicy == true
      final spicyFilter = FilterCriteria.fromPreset('spicy');
      for (int i = 0; i < 20; i++) {
        final rec = engine.recommend(allMenus: allMenus, filter: spicyFilter, recentExcludedIds: []);
        expect(rec, isNotNull);
        expect(rec!.menuItem.spicy, isTrue, reason: '${rec.menuItem.name} must be spicy');

        final candidates = engine.getRouletteCandidates(allMenus: allMenus, filter: spicyFilter, recentExcludedIds: [], count: 6);
        expect(candidates.length, 6);
        for (final m in candidates) {
          expect(m.spicy, isTrue, reason: 'Roulette item ${m.name} must be spicy');
        }
      }

      // 2. 분식 + 매운맛 선택 시 -> 100% 분식 카테고리 & spicy == true
      const spicyBunsik = FilterCriteria(category: '분식', preference: '매운 음식');
      for (int i = 0; i < 20; i++) {
        final rec = engine.recommend(allMenus: allMenus, filter: spicyBunsik, recentExcludedIds: []);
        expect(rec, isNotNull);
        expect(rec!.menuItem.category, '분식');
        expect(rec.menuItem.spicy, isTrue, reason: '${rec.menuItem.name} must be spicy bunsik');

        final candidates = engine.getRouletteCandidates(allMenus: allMenus, filter: spicyBunsik, recentExcludedIds: [], count: 6);
        for (final m in candidates) {
          expect(m.category, '분식');
          expect(m.spicy, isTrue, reason: 'Roulette item ${m.name} must be spicy bunsik');
        }
      }

      // 3. 다이어트/클린식단 프리셋 선택 시 -> 100% healthy == true
      final dietFilter = FilterCriteria.fromPreset('diet');
      for (int i = 0; i < 10; i++) {
        final rec = engine.recommend(allMenus: allMenus, filter: dietFilter, recentExcludedIds: []);
        expect(rec, isNotNull);
        expect(rec!.menuItem.healthy, isTrue, reason: '${rec.menuItem.name} must be diet/healthy');

        final candidates = engine.getRouletteCandidates(allMenus: allMenus, filter: dietFilter, recentExcludedIds: [], count: 6);
        for (final m in candidates) {
          expect(m.healthy, isTrue, reason: '${m.name} must be diet/healthy');
        }
      }

      // 4. 국물/해장 프리셋 선택 시 -> 100% soup/국물 요리
      final hangoverFilter = FilterCriteria.fromPreset('hangover');
      for (int i = 0; i < 10; i++) {
        final rec = engine.recommend(allMenus: allMenus, filter: hangoverFilter, recentExcludedIds: []);
        expect(rec, isNotNull);
        expect(rec!.menuItem.soup, isTrue, reason: '${rec.menuItem.name} must be soup/stew');

        final candidates = engine.getRouletteCandidates(allMenus: allMenus, filter: hangoverFilter, recentExcludedIds: [], count: 6);
        for (final m in candidates) {
          expect(m.soup, isTrue, reason: '${m.name} must be soup/stew');
        }
      }
    });
  });
}
