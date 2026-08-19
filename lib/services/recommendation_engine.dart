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

    // 2차: 최근 5개 추천 제외
    List<MenuItem> nonRecentCandidates = candidates
        .where((menu) => !recentExcludedIds.contains(menu.id))
        .toList();

    if (nonRecentCandidates.isNotEmpty) {
      candidates = nonRecentCandidates;
    }

    // 3차: 조건 완화 단계 (단, 매운맛/국물/다이어트/프리셋 등 사용자의 핵심 성향은 절대 훼손하지 않음!)
    if (candidates.isEmpty) {
      // Step 3-1: 조리시간 완화 (카테고리/성향/가격/식사방식 유지)
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

      // Step 3-2: 가격 및 조리시간 완화 (카테고리/성향/식사방식 유지)
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

      // Step 3-3: 식사 형태 완화 (성향 및 카테고리는 유지)
      if (candidates.isEmpty) {
        candidates = _applyFilter(
          menus: allMenus,
          filter: filter,
          strictCookingTime: false,
          strictPrice: false,
          strictPreference: true, // 핵심 성향(매운맛, 다이어트, 국물 등)은 끝까지 유지!
          strictCategory: true,
          strictMealType: false,
        );
        if (candidates.isNotEmpty) {
          isRelaxed = true;
          relaxationMessage = '선택하신 카테고리와 취향에 맞는 메뉴를 엄선했습니다.';
        }
      }

      // Step 3-4: 카테고리만 완화하고 성향(매운맛, 다이어트 등)은 계속 사수!
      if (candidates.isEmpty) {
        candidates = _applyFilter(
          menus: allMenus,
          filter: filter,
          strictCookingTime: false,
          strictPrice: false,
          strictPreference: true, // 성향 끝까지 사수!
          strictCategory: false,
          strictMealType: false,
        );
        if (candidates.isNotEmpty) {
          isRelaxed = true;
          relaxationMessage = '취향(맛/스타일)에 맞는 다른 카테고리 메뉴를 추천합니다.';
        }
      }

      // Step 3-5: 최후의 안전장치
      if (candidates.isEmpty) {
        candidates = allMenus;
        isRelaxed = true;
        relaxationMessage = '조건에 맞는 메뉴를 찾지 못해 전체 인기 메뉴 중 추천합니다.';
      }

      // 최근 추천 목록 다시 제외 시도
      final filteredNonRecent = candidates
          .where((menu) => !recentExcludedIds.contains(menu.id))
          .toList();
      if (filteredNonRecent.isNotEmpty) {
        candidates = filteredNonRecent;
      }
    }

    // 4차: 후보 중 1개 선택
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
    final isSpicyPreset =
        filter.quickPreset == 'spicy' || filter.preference == '매운 음식';
    final isHangoverPreset =
        filter.quickPreset == 'hangover' || filter.preference == '뜨끈한 국물' || filter.preference == '국물';
    final isDietPreset =
        filter.quickPreset == 'diet' || filter.preference == '건강식' || filter.category == '샐러드';
    final isLazyPreset = filter.quickPreset == 'lazy';
    final isBudgetPreset = filter.quickPreset == 'budget';

    return menus.where((menu) {
      // 1. 매운맛 조건 검증 (스파이시 프리셋 또는 매운 음식 선택 시 무조건 spicy == true 보장!)
      if (strictPreference && isSpicyPreset) {
        if (!menu.spicy) {
          return false;
        }
      }

      // 2. 국물/해장 조건 검증
      if (strictPreference && isHangoverPreset) {
        final isHangoverDish = menu.soup ||
            menu.subCategory.contains('찌개') ||
            menu.subCategory.contains('탕') ||
            menu.subCategory.contains('국') ||
            menu.tags.any((t) =>
                t.contains('해장') ||
                t.contains('얼큰') ||
                t.contains('국물') ||
                t.contains('뚝배기'));
        if (!isHangoverDish) {
          return false;
        }
      }

      // 3. 다이어트 / 클린식단 조건 검증 (엄격한 다이어트 식단만 필터링)
      if (strictPreference && isDietPreset) {
        final name = menu.name;
        final sub = menu.subCategory;
        final tagsStr = menu.tags.join(' ');

        // 밀가루 면, 고칼로리 튀김, 찌개, 정크푸드는 다이어트에서 완벽 배제
        final isHeavyFood = anyKeyword(name, [
          '칼국수', '라면', '짜장', '짬뽕', '튀김', '돈까스', '치킨', '피자', '버거',
          '핫도그', '떡볶이', '순대', '부대찌개', '곱창', '대창', '막창', '마라탕'
        ]);
        if (isHeavyFood) return false;

        final isCleanDietDish = menu.healthy ||
            name.contains('샐러드') ||
            sub.contains('샐러드') ||
            name.contains('포케') ||
            name.contains('닭가슴살') ||
            name.contains('월남쌈') ||
            name.contains('단백질') ||
            name.contains('곤드레') ||
            name.contains('새싹비빔밥') ||
            name.contains('쌈밥') ||
            name.contains('훈제오리') ||
            name.contains('두부') ||
            name.contains('샤브샤브') ||
            name.contains('메밀소바') ||
            name.contains('숙회') ||
            name.contains('회덮밥') ||
            tagsStr.contains('다이어트') ||
            tagsStr.contains('샐러드') ||
            tagsStr.contains('포케') ||
            tagsStr.contains('클린');

        if (!isCleanDietDish) {
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

      // 6. 식사 형태 필터
      if (strictMealType && filter.mealType != '상관없음') {
        if (!menu.mealType.contains(filter.mealType)) {
          return false;
        }
      }

      // 7. 가격 필터
      if (strictPrice && filter.price != '상관없음') {
        if (filter.price == '5천원 이하' && menu.priceLevel > 1) {
          return false;
        } else if (filter.price == '1만원 이하' && menu.priceLevel > 2) {
          return false;
        } else if (filter.price == '1만5천원 이하' && menu.priceLevel > 3) {
          return false;
        }
      }

      // 8. 음식 종류 / 카테고리 필터
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
              !menu.subCategory.contains('국') &&
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

      // 9. 조리시간 필터
      if (strictCookingTime && filter.cookingTime != '상관없음') {
        if (filter.cookingTime == '10분 이하' && menu.cookingTime > 10) {
          return false;
        } else if (filter.cookingTime == '20분 이하' && menu.cookingTime > 20) {
          return false;
        } else if (filter.cookingTime == '30분 이하' && menu.cookingTime > 30) {
          return false;
        }
      }

      // 10. 기타 세부 성향 필터
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
