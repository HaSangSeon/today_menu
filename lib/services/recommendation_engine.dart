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

  /// 4단계 추천 파이프라인 (사용자 선택 옵션 100% 보장)
  RecommendationResult? recommend({
    required List<MenuItem> allMenus,
    required FilterCriteria filter,
    required List<String> recentExcludedIds,
  }) {
    if (allMenus.isEmpty) return null;

    // 1차: 사용자 필터 조건 엄격 적용
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

    // 2차: 최근 추천 목록 제외 (후보가 충분할 때만)
    List<MenuItem> nonRecentCandidates = candidates
        .where((menu) => !recentExcludedIds.contains(menu.id))
        .toList();

    if (nonRecentCandidates.isNotEmpty) {
      candidates = nonRecentCandidates;
    }

    // 3차: 조건 완화 단계
    // 핵심 원칙: 카테고리(분식/한식 등)와 핵심 성향(매운맛/국물/다이어트 등)은 어떠한 경우에도 절대 훼손하지 않음!
    if (candidates.isEmpty) {
      // Step 3-1: 조리시간만 완화 (카테고리/성향/가격/식사방식 100% 유지)
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
        relaxationMessage = '조리시간 조건을 유연하게 맞춰 추천했습니다.';
      }

      // Step 3-2: 가격 및 조리시간 완화 (카테고리/성향/식사방식 100% 유지)
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

      // Step 3-3: 식사 방식 완화 (카테고리 및 핵심 성향 100% 유지)
      if (candidates.isEmpty) {
        candidates = _applyFilter(
          menus: allMenus,
          filter: filter,
          strictCookingTime: false,
          strictPrice: false,
          strictPreference: true,
          strictCategory: true,
          strictMealType: false,
        );
        if (candidates.isNotEmpty) {
          isRelaxed = true;
          relaxationMessage = '선택하신 카테고리와 취향에 꼭 맞는 메뉴를 엄선했습니다.';
        }
      }

      // Step 3-4: 만약 카테고리가 '상관없음'인 경우에만 성향 중심 전체 카테고리 추출
      if (candidates.isEmpty && filter.category == '상관없음') {
        candidates = _applyFilter(
          menus: allMenus,
          filter: filter,
          strictCookingTime: false,
          strictPrice: false,
          strictPreference: true,
          strictCategory: false,
          strictMealType: false,
        );
        if (candidates.isNotEmpty) {
          isRelaxed = true;
          relaxationMessage = '취향(맛/스타일)에 맞는 맛있는 메뉴를 추천합니다.';
        }
      }

      // Step 3-5: 만약 특정 성향에서 해당 카테고리 후보가 0개라면 카테고리 내 인기 메뉴 추출
      if (candidates.isEmpty && filter.category != '상관없음') {
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
          relaxationMessage = '선택하신 [${filter.category}] 카테고리 인기 메뉴 중 추천합니다.';
        }
      }

      // Step 3-6: 최후의 안전장치 (기본 필터일 때)
      if (candidates.isEmpty) {
        candidates = allMenus;
      }

      // 최근 추천 목록 다시 제외 시도
      final filteredNonRecent = candidates
          .where((menu) => !recentExcludedIds.contains(menu.id))
          .toList();
      if (filteredNonRecent.isNotEmpty) {
        candidates = filteredNonRecent;
      }
    }

    // 4차: 최종 후보 중 1개 무작위 선택
    final selectedIndex = _random.nextInt(candidates.length);
    final chosenMenu = candidates[selectedIndex];

    return RecommendationResult(
      menuItem: chosenMenu,
      isRelaxed: isRelaxed,
      relaxationMessage: relaxationMessage,
      totalCandidates: candidates.length,
    );
  }

  /// 룰렛용 후보 메뉴 목록 추출 (선택된 옵션에 부합하는 메뉴 6개 엄선)
  List<MenuItem> getRouletteCandidates({
    required List<MenuItem> allMenus,
    required FilterCriteria filter,
    required List<String> recentExcludedIds,
    int count = 6,
  }) {
    if (allMenus.isEmpty) return [];

    // 1차: 엄격 필터링
    List<MenuItem> candidates = _applyFilter(
      menus: allMenus,
      filter: filter,
      strictCookingTime: true,
      strictPrice: true,
      strictPreference: true,
      strictCategory: true,
      strictMealType: true,
    );

    // 최근 제외 시도 (후보가 충분할 때)
    final nonRecent =
        candidates.where((m) => !recentExcludedIds.contains(m.id)).toList();
    if (nonRecent.length >= count) {
      candidates = nonRecent;
    }

    // 후보 수가 부족하면 조리시간/가격/식사방식 유연하게 완화 (카테고리/성향 100% 사수)
    if (candidates.length < count) {
      final relaxed = _applyFilter(
        menus: allMenus,
        filter: filter,
        strictCookingTime: false,
        strictPrice: false,
        strictPreference: true, // 매운맛, 국물, 다이어트, 고기, 밥, 면 등은 절대 사수!
        strictCategory: true, // 카테고리(분식/한식 등) 절대 사수!
        strictMealType: false,
      );
      if (relaxed.isNotEmpty) {
        candidates = relaxed;
      }
    }

    // 만약 카테고리가 '상관없음'이고 후보가 6개 미만이면, 성향에 맞는 다른 카테고리 음식까지 수집
    if (candidates.length < count && filter.category == '상관없음') {
      final prefOnly = _applyFilter(
        menus: allMenus,
        filter: filter,
        strictCookingTime: false,
        strictPrice: false,
        strictPreference: true,
        strictCategory: false,
        strictMealType: false,
      );
      if (prefOnly.isNotEmpty) {
        candidates = prefOnly;
      }
    }

    // 만약 카테고리가 특정되어 있고(예: 치킨), 그 안에서 성향(예: 매운맛) 만족 음식이 count 미만이면 카테고리 음식 우선 결합
    if (candidates.length < count && filter.category != '상관없음') {
      final catOnly = _applyFilter(
        menus: allMenus,
        filter: filter,
        strictCookingTime: false,
        strictPrice: false,
        strictPreference: false,
        strictCategory: true,
        strictMealType: false,
      );
      if (catOnly.isNotEmpty) {
        // 기존 성향 만족 메뉴를 우선 유지하면서 카테고리 메뉴로 보충
        final combined = [...candidates];
        for (final item in catOnly) {
          if (!combined.any((c) => c.id == item.id)) {
            combined.add(item);
          }
          if (combined.length >= count) break;
        }
        candidates = combined;
      }
    }

    if (candidates.isEmpty) {
      candidates = List<MenuItem>.from(allMenus);
    }

    final shuffled = List<MenuItem>.from(candidates)..shuffle(_random);
    final targetCount = min(count, shuffled.length);
    return shuffled.take(targetCount).toList();
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
    final isSpicyPreset =
        filter.quickPreset == 'spicy' || filter.preference == '매운 음식';
    final isHangoverPreset = filter.quickPreset == 'hangover' ||
        filter.preference == '뜨끈한 국물' ||
        filter.preference == '국물';
    final isDietPreset = filter.quickPreset == 'diet' ||
        filter.preference == '건강식' ||
        filter.category == '샐러드';
    final isLazyPreset = filter.quickPreset == 'lazy';
    final isBudgetPreset = filter.quickPreset == 'budget';
    final isDeliveryPreset =
        filter.quickPreset == 'delivery' || filter.mealType == '배달';

    return menus.where((menu) {
      // 1. 매운맛 조건 검증 (스파이시 프리셋 또는 매운 음식 선택 시 무조건 spicy == true 보장!)
      if (strictPreference && isSpicyPreset) {
        if (!menu.spicy) {
          return false;
        }
      }

      // 2. 국물/해장 조건 검증 (100% 국물/찌개/탕/국밥 요리만 필터링)
      if (strictPreference && isHangoverPreset) {
        final isHangoverDish = menu.soup ||
            menu.subCategory.contains('찌개') ||
            menu.subCategory.contains('탕') ||
            menu.subCategory.contains('국밥') ||
            menu.subCategory.contains('전골') ||
            (menu.subCategory == '국' && !menu.name.contains('국수')) ||
            menu.tags.any((t) =>
                t.contains('해장') ||
                t.contains('얼큰') ||
                t.contains('뚝배기'));
        if (!isHangoverDish) {
          return false;
        }
      }

      // 3. 다이어트 / 클린식단 조건 검증 (엄격한 healthy == true 식단만 필터링)
      if (strictPreference && isDietPreset) {
        if (!menu.healthy) {
          return false;
        }
      }

      // 4. 초간단 자취요리(lazy) 프리셋
      if (isLazyPreset && strictCookingTime) {
        if (menu.cookingTime > 10 && !menu.tags.contains('초간단')) {
          return false;
        }
      }

      // 5. 갓성비(budget) 프리셋
      if (isBudgetPreset && strictPrice) {
        if (menu.priceLevel > 1) {
          return false;
        }
      }

      // 6. 배달 프리셋 및 배달 식사형태 필터
      if (isDeliveryPreset && strictMealType) {
        if (!menu.deliveryAvailable && !menu.mealType.contains('배달')) {
          return false;
        }
      }

      // 7. 일반 식사 형태 필터 (혼밥, 집밥, 외식)
      if (strictMealType &&
          filter.mealType != '상관없음' &&
          filter.mealType != '배달') {
        if (!menu.mealType.contains(filter.mealType)) {
          return false;
        }
      }

      // 8. 가격 필터
      if (strictPrice && filter.price != '상관없음') {
        if (filter.price == '5천원 이하' && menu.priceLevel > 1) {
          return false;
        } else if (filter.price == '1만원 이하' && menu.priceLevel > 2) {
          return false;
        } else if (filter.price == '1만5천원 이하' && menu.priceLevel > 3) {
          return false;
        }
      }

      // 9. 음식 종류 / 카테고리 필터
      if (strictCategory && filter.category != '상관없음') {
        final cat = filter.category;
        if (cat == '면') {
          if (!menu.noodle &&
              !menu.subCategory.contains('면') &&
              !menu.name.contains('면') &&
              !menu.name.contains('국수') &&
              !menu.name.contains('우동') &&
              !menu.name.contains('라멘') &&
              !menu.name.contains('파스타')) {
            return false;
          }
        } else if (cat == '밥') {
          if (!menu.rice &&
              !menu.subCategory.contains('밥') &&
              !menu.subCategory.contains('덮밥') &&
              !menu.subCategory.contains('볶음밥') &&
              !menu.subCategory.contains('비빔밥') &&
              !menu.subCategory.contains('국밥') &&
              !menu.subCategory.contains('초밥')) {
            return false;
          }
        } else if (cat == '국/찌개') {
          if (!menu.soup &&
              !menu.subCategory.contains('찌개') &&
              !menu.subCategory.contains('탕') &&
              !menu.subCategory.contains('국밥') &&
              !menu.subCategory.contains('전골') &&
              (menu.subCategory != '국' || menu.name.contains('국수')) &&
              !menu.subCategory.contains('스프')) {
            return false;
          }
        } else if (cat == '고기') {
          if (!menu.meat &&
              !menu.tags.any((t) =>
                  t.contains('고기') ||
                  t.contains('삼겹') ||
                  t.contains('소고기') ||
                  t.contains('돼지') ||
                  t.contains('닭') ||
                  t.contains('스테이크'))) {
            return false;
          }
        } else if (cat == '샐러드') {
          if (!menu.healthy &&
              !menu.subCategory.contains('샐러드') &&
              !menu.name.contains('샐러드') &&
              !menu.tags.any((t) =>
                  t.contains('샐러드') ||
                  t.contains('다이어트') ||
                  t.contains('포케') ||
                  t.contains('건강'))) {
            return false;
          }
        } else {
          // 한식, 중식, 일식, 양식, 분식, 패스트푸드, 치킨, 기타
          if (menu.category != cat) {
            return false;
          }
        }
      }

      // 10. 조리시간 필터
      if (strictCookingTime && filter.cookingTime != '상관없음') {
        if (filter.cookingTime == '10분 이하' && menu.cookingTime > 10) {
          return false;
        } else if (filter.cookingTime == '20분 이하' && menu.cookingTime > 20) {
          return false;
        } else if (filter.cookingTime == '30분 이하' && menu.cookingTime > 30) {
          return false;
        }
      }

      // 11. 기타 세부 성향 필터
      if (strictPreference && filter.preference != '아무거나') {
        final pref = filter.preference;
        if (pref == '든든하게') {
          if (menu.priceLevel < 2 &&
              menu.cookingTime < 10 &&
              !menu.meat &&
              !menu.rice) {
            return false;
          }
        } else if (pref == '가볍게') {
          if (menu.priceLevel > 2 ||
              menu.cookingTime > 20 ||
              menu.tags.contains('푸짐한')) {
            return false;
          }
        } else if (pref == '면' || pref == '면치기') {
          if (!menu.noodle) return false;
        } else if (pref == '밥' || pref == '밥심') {
          if (!menu.rice) return false;
        } else if (pref == '고기' || pref == '고기/단백질') {
          if (!menu.meat) return false;
        }
      }

      return true;
    }).toList();
  }

  bool anyKeyword(String source, List<String> keywords) {
    return keywords.any((k) => source.contains(k));
  }
}

