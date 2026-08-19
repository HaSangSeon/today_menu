import 'dart:math';
import '../models/filter_criteria.dart';
import '../models/menu_item.dart';

class RecommendationResult {
  final MenuItem menuItem;
  final bool isRelaxed;
  final String? relaxationMessage;
  final int totalCandidates;

  const RecommendationResult({
    required this.menuItem,
    this.isRelaxed = false,
    this.relaxationMessage,
    required this.totalCandidates,
  });
}

class RecommendationEngine {
  final Random _random;

  RecommendationEngine([Random? random]) : _random = random ?? Random();

  /// 4단계 추천 파이프라인
  RecommendationResult? recommend({
    required List<MenuItem> allMenus,
    required FilterCriteria filter,
    required List<String> recentExcludedIds,
  }) {
    if (allMenus.isEmpty) return null;

    // 1차 필터링: 엄격 조건 매칭
    List<MenuItem> candidates = _applyFilter(
      menus: allMenus,
      filter: filter,
      strictCookingTime: true,
      strictPrice: true,
      strictPreference: true,
      strictCategory: true,
      strictMealType: true,
    );

    bool isRelaxed = false;
    String? relaxationMessage;

    // 2차 필터링: 최근 5개 추천 제외
    List<MenuItem> nonRecentCandidates = candidates
        .where((menu) => !recentExcludedIds.contains(menu.id))
        .toList();

    if (nonRecentCandidates.isNotEmpty) {
      candidates = nonRecentCandidates;
    } else if (candidates.isNotEmpty) {
      // 최근 추천을 제외하면 후보가 없지만 원본 후보는 있는 경우, 원본 후보 유지
      candidates = candidates;
    }

    // 3차 필터링 (조건 완화): 후보가 없을 때 단계적 완화
    if (candidates.isEmpty) {
      // Step 3-1: 조리시간 완화
      candidates = _applyFilter(
        menus: allMenus,
        filter: filter,
        strictCookingTime: false,
        strictPrice: true,
        strictPreference: true,
        strictCategory: true,
        strictMealType: true,
      );
      if (candidates.isNotEmpty) {
        isRelaxed = true;
        relaxationMessage = '조리시간 조건을 완화하여 추천했습니다.';
      }

      // Step 3-2: 가격 조건 추가 완화
      if (candidates.isEmpty) {
        candidates = _applyFilter(
          menus: allMenus,
          filter: filter,
          strictCookingTime: false,
          strictPrice: false,
          strictPreference: true,
          strictCategory: true,
          strictMealType: true,
        );
        if (candidates.isNotEmpty) {
          isRelaxed = true;
          relaxationMessage = '가격 및 조리시간 조건을 유연하게 맞춰 추천했습니다.';
        }
      }

      // Step 3-3: 식사 형태 및 성향 완화 (카테고리만 유지)
      if (candidates.isEmpty) {
        candidates = _applyFilter(
          menus: allMenus,
          filter: filter,
          strictCookingTime: false,
          strictPrice: false,
          strictPreference: false,
          strictCategory: true,
          strictMealType: false,
        );
        if (candidates.isNotEmpty) {
          isRelaxed = true;
          relaxationMessage = '선택하신 카테고리의 대표 메뉴를 추천합니다.';
        }
      }

      // Step 3-4: 전체 메뉴 중 무작위 (최후의 안전장치)
      if (candidates.isEmpty) {
        candidates = allMenus;
        isRelaxed = true;
        relaxationMessage = '조건에 맞는 메뉴가 없어 전체 인기 메뉴 중에서 추천합니다.';
      }

      // 최근 추천 목록 다시 제외 시도
      final filteredNonRecent = candidates
          .where((menu) => !recentExcludedIds.contains(menu.id))
          .toList();
      if (filteredNonRecent.isNotEmpty) {
        candidates = filteredNonRecent;
      }
    }

    // 4차: 후보 중 무작위 1개 선택
    final selectedIndex = _random.nextInt(candidates.length);
    final chosenMenu = candidates[selectedIndex];

    return RecommendationResult(
      menuItem: chosenMenu,
      isRelaxed: isRelaxed,
      relaxationMessage: relaxationMessage,
      totalCandidates: candidates.length,
    );
  }

  List<MenuItem> _applyFilter({
    required List<MenuItem> menus,
    required FilterCriteria filter,
    required bool strictCookingTime,
    required bool strictPrice,
    required bool strictPreference,
    required bool strictCategory,
    required bool strictMealType,
  }) {
    return menus.where((menu) {
      // 1. 식사 형태 필터
      if (strictMealType && filter.mealType != '상관없음') {
        if (!menu.mealType.contains(filter.mealType)) {
          return false;
        }
      }

      // 2. 가격 필터
      if (strictPrice && filter.price != '상관없음') {
        if (filter.price == '5천원 이하' && menu.priceLevel > 1) {
          return false;
        } else if (filter.price == '1만원 이하' && menu.priceLevel > 2) {
          return false;
        } else if (filter.price == '1만5천원 이하' && menu.priceLevel > 3) {
          return false;
        }
      }

      // 3. 음식 종류 / 카테고리 필터
      if (strictCategory && filter.category != '상관없음') {
        final cat = filter.category;
        if (cat == '면') {
          if (!menu.noodle && !menu.subCategory.contains('면') && !menu.name.contains('면') && !menu.name.contains('국수') && !menu.name.contains('우동') && !menu.name.contains('라멘') && !menu.name.contains('파스타')) {
            return false;
          }
        } else if (cat == '밥') {
          if (!menu.rice && !menu.subCategory.contains('밥') && !menu.subCategory.contains('덮밥') && !menu.subCategory.contains('볶음밥') && !menu.subCategory.contains('비빔밥') && !menu.subCategory.contains('국밥') && !menu.subCategory.contains('초밥')) {
            return false;
          }
        } else if (cat == '국/찌개') {
          if (!menu.soup && !menu.subCategory.contains('찌개') && !menu.subCategory.contains('탕') && !menu.subCategory.contains('국') && !menu.subCategory.contains('스프')) {
            return false;
          }
        } else if (cat == '고기') {
          if (!menu.meat && !menu.tags.any((t) => t.contains('고기') || t.contains('삼겹') || t.contains('소고기') || t.contains('돼지') || t.contains('닭') || t.contains('스테이크'))) {
            return false;
          }
        } else if (cat == '샐러드') {
          if (!menu.healthy && !menu.subCategory.contains('샐러드') && !menu.name.contains('샐러드') && !menu.tags.any((t) => t.contains('샐러드') || t.contains('다이어트') || t.contains('포케') || t.contains('건강'))) {
            return false;
          }
        } else {
          // 한식, 중식, 일식, 양식, 분식, 패스트푸드, 치킨, 기타
          if (menu.category != cat) {
            return false;
          }
        }
      }

      // 4. 조리시간 필터
      if (strictCookingTime && filter.cookingTime != '상관없음') {
        if (filter.cookingTime == '10분 이하' && menu.cookingTime > 10) {
          return false;
        } else if (filter.cookingTime == '20분 이하' && menu.cookingTime > 20) {
          return false;
        } else if (filter.cookingTime == '30분 이하' && menu.cookingTime > 30) {
          return false;
        }
      }

      // 5. 추천 성향 필터
      if (strictPreference && filter.preference != '아무거나') {
        final pref = filter.preference;
        if (pref == '든든하게') {
          if (menu.priceLevel < 2 && menu.cookingTime < 10 && !menu.meat && !menu.rice) {
            return false;
          }
        } else if (pref == '가볍게') {
          if (menu.priceLevel > 2 || menu.cookingTime > 20 || menu.tags.contains('푸짐한')) {
            return false;
          }
        } else if (pref == '매운 음식') {
          if (!menu.spicy) {
            return false;
          }
        } else if (pref == '국물') {
          if (!menu.soup) {
            return false;
          }
        } else if (pref == '면') {
          if (!menu.noodle) {
            return false;
          }
        } else if (pref == '밥') {
          if (!menu.rice) {
            return false;
          }
        } else if (pref == '고기') {
          if (!menu.meat) {
            return false;
          }
        } else if (pref == '건강식') {
          if (!menu.healthy) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }
}
