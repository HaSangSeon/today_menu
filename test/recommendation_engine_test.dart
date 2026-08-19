import 'package:flutter_test/flutter_test.dart';
import 'package:today_menu/models/filter_criteria.dart';
import 'package:today_menu/models/menu_item.dart';
import 'package:today_menu/services/recommendation_engine.dart';

void main() {
  group('RecommendationEngine Tests', () {
    late List<MenuItem> mockMenus;
    late RecommendationEngine engine;

    setUp(() {
      engine = RecommendationEngine();
      mockMenus = [
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
          tags: ['국물', '얼큰한', '매운'],
        ),
        const MenuItem(
          id: 'menu_02',
          name: '짜장면',
          category: '중식',
          subCategory: '면',
          mealType: ['혼밥', '배달'],
          priceLevel: 1,
          estimatedPrice: '6,500원',
          cookingTime: 10,
          spicy: false,
          soup: false,
          rice: false,
          noodle: true,
          meat: true,
          healthy: false,
          deliveryAvailable: true,
          tags: ['면', '달콤한'],
        ),
        const MenuItem(
          id: 'menu_03',
          name: '샐러드',
          category: '양식',
          subCategory: '샐러드',
          mealType: ['혼밥', '집밥'],
          priceLevel: 2,
          estimatedPrice: '8,500원',
          cookingTime: 8,
          spicy: false,
          soup: false,
          rice: false,
          noodle: false,
          meat: false,
          healthy: true,
          deliveryAvailable: true,
          tags: ['건강식', '다이어트'],
        ),
        const MenuItem(
          id: 'menu_04',
          name: '돈카츠',
          category: '일식',
          subCategory: '카츠',
          mealType: ['외식', '배달'],
          priceLevel: 3,
          estimatedPrice: '12,000원',
          cookingTime: 15,
          spicy: false,
          soup: false,
          rice: true,
          noodle: false,
          meat: true,
          healthy: false,
          deliveryAvailable: true,
          tags: ['바삭바삭', '고기'],
        ),
      ];
    });

    test('1차 필터링: 한식 선택 시 김치찌개만 추천', () {
      const filter = FilterCriteria(category: '한식');
      final result = engine.recommend(
        allMenus: mockMenus,
        filter: filter,
        recentExcludedIds: [],
      );

      expect(result, isNotNull);
      expect(result!.menuItem.name, '김치찌개');
      expect(result.isRelaxed, isFalse);
    });

    test('스트레스 타파 매운맛 프리셋 및 매운 음식 성향 선택 시 반드시 spicy == true인 음식만 추천', () {
      // 까다로운 가격/조리시간 조건이 겹치더라도 매운맛은 절대 타협하지 않음
      final spicyFilter = FilterCriteria.fromPreset('spicy').copyWith(
        price: '5천원 이하', // mock에는 5천원 이하 매운 음식이 없음
      );

      final result = engine.recommend(
        allMenus: mockMenus,
        filter: spicyFilter,
        recentExcludedIds: [],
      );

      expect(result, isNotNull);
      expect(result!.menuItem.spicy, isTrue);
      expect(result.menuItem.name, '김치찌개');
    });

    test('2차 필터링: 최근 5개 추천 목록에 있는 메뉴는 제외', () {
      const filter = FilterCriteria(); // 상관없음
      final result = engine.recommend(
        allMenus: mockMenus,
        filter: filter,
        recentExcludedIds: ['menu_01', 'menu_02', 'menu_03'],
      );

      expect(result, isNotNull);
      expect(result!.menuItem.id, 'menu_04');
    });

    test('3차 필터링: 까다로운 조건으로 후보가 없을 때 조건 완화 동작', () {
      // 10분 이하 + 5천원 이하 + 한식 (mockMenus에는 없음)
      const strictFilter = FilterCriteria(
        category: '한식',
        cookingTime: '10분 이하',
        price: '5천원 이하',
      );

      final result = engine.recommend(
        allMenus: mockMenus,
        filter: strictFilter,
        recentExcludedIds: [],
      );

      expect(result, isNotNull);
      // 한식 카테고리를 유지하며 조리시간/가격 조건 완화되어 김치찌개 추천됨
      expect(result!.menuItem.category, '한식');
      expect(result.isRelaxed, isTrue);
      expect(result.relaxationMessage, isNotEmpty);
    });

    test('빈 메뉴 리스트 전달 시 null 반환', () {
      const filter = FilterCriteria();
      final result = engine.recommend(
        allMenus: [],
        filter: filter,
        recentExcludedIds: [],
      );

      expect(result, isNull);
    });
  });
}
