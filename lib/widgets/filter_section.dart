import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/filter_criteria.dart';
import '../providers/filter_provider.dart';

class FilterSection extends StatelessWidget {
  const FilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        final criteria = filterProvider.criteria;

        // 식사 방식에 따른 스마트 시간 라벨
        String timeLabel = '⏱️ 식사 / 준비 속도';
        if (criteria.mealType == '집밥') {
          timeLabel = '🍳 직접 요리 조리시간';
        } else if (criteria.mealType == '배달') {
          timeLabel = '🛵 배달 도착 소요시간';
        } else if (criteria.mealType == '외식') {
          timeLabel = '🚶 외식 / 식사 속도';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // [카드 1] ⚡ 1초 상황별 빠른 추천 (프리셋 영역)
            // ==========================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? AppTheme.cardBorderDark
                      : const Color(0xFFE8E2D9),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 20 : 6),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3E2723)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('⚡', style: TextStyle(fontSize: 15)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1초 빠른 상황별 추천',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '귀찮을 땐 터치 한 번으로 메뉴 고민 끝!',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 프리셋 가로 스크롤 카드 목록 (고정 높이 및 일정한 테두리 두께로 흔들림 방지)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: FilterCriteria.presets.map((preset) {
                        final isSelected = criteria.quickPreset == preset['id'];

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              filterProvider.togglePreset(preset['id']!);
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                        ? AppTheme.primaryContainerDark
                                        : AppTheme.primaryContainerLight)
                                    : (isDark
                                        ? const Color(0xFF222730)
                                        : const Color(0xFFF9F7F4)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : (isDark
                                          ? AppTheme.cardBorderDark
                                          : const Color(0xFFE2DDD5)),
                                  width: 1.2, // 테두리 두께 고정으로 레이아웃 흔들림 100% 제거
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    preset['emoji']!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    preset['label']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? (isDark
                                              ? const Color(0xFFFFAB91)
                                              : AppTheme.primaryDark)
                                          : (isDark
                                              ? AppTheme.textPrimaryDark
                                              : AppTheme.textPrimaryLight),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ==========================================
            // [카드 2] 🎛️ 내 맘대로 상세 맞춤 설정 (독립 영역 분리)
            // ==========================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? AppTheme.cardBorderDark
                      : const Color(0xFFE8E2D9),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 20 : 6),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상세 설정 헤더 & 고정 높이 초기화 버튼 영역 (Layout Shift 방지)
                  SizedBox(
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.primaryContainerDark
                                    : AppTheme.primaryContainerLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('🎛️',
                                  style: TextStyle(fontSize: 14)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '내 맘대로 상세 설정',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        // 초기화 버튼: maintainSize로 높이 요동 100% 방지
                        Visibility(
                          visible: !criteria.isDefault,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: InkWell(
                            onTap: () {
                              filterProvider.resetFilter();
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    size: 14,
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '초기화',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 1. 음식 종류 (카테고리)
                  _buildFixedChipRow(
                    context: context,
                    title: '🍲 어떤 음식이 땡기나요? (카테고리)',
                    options: FilterCriteria.categoryOptions,
                    selected: criteria.category,
                    onSelected: (val) => filterProvider.updateCategory(val),
                  ),
                  const SizedBox(height: 12),

                  // 2. 식사 방식
                  _buildFixedChipRow(
                    context: context,
                    title: '🍽️ 식사 방식',
                    options: FilterCriteria.mealTypeOptions,
                    selected: criteria.mealType,
                    onSelected: (val) => filterProvider.updateMealType(val),
                  ),
                  const SizedBox(height: 12),

                  // 3. 소요시간
                  _buildFixedChipRow(
                    context: context,
                    title: timeLabel,
                    options: FilterCriteria.cookingTimeOptions,
                    selected: criteria.cookingTime,
                    onSelected: (val) =>
                        filterProvider.updateCookingTime(val),
                  ),
                  const SizedBox(height: 12),

                  // 4. 한 끼 예산
                  _buildFixedChipRow(
                    context: context,
                    title: '💰 한 끼 예산',
                    options: FilterCriteria.priceOptions,
                    selected: criteria.price,
                    onSelected: (val) => filterProvider.updatePrice(val),
                  ),
                  const SizedBox(height: 12),

                  // 5. 오늘 땡기는 느낌
                  _buildFixedChipRow(
                    context: context,
                    title: '✨ 오늘 땡기는 느낌',
                    options: FilterCriteria.preferenceOptions,
                    selected: criteria.preference,
                    onSelected: (val) =>
                        filterProvider.updatePreference(val),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 고정 높이와 고정 테두리 두께로 어떤 상태 변화에도 1px의 흔들림도 없는 커스텀 알약형 칩 행
  Widget _buildFixedChipRow({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String selected,
    required Function(String) onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 5),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: options.map((option) {
              final isSelected = selected == option;

              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () => onSelected(option),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 32, // 정확한 고정 높이 지정으로 상하 요동 방지
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? AppTheme.primaryContainerDark
                              : AppTheme.primaryContainerLight)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : (isDark
                                ? AppTheme.cardBorderDark
                                : const Color(0xFFE2DDD5)),
                        width: 1.2, // 테두리 두께를 항상 1.2로 고정하여 픽셀 흔들림 방지
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? (isDark
                                ? const Color(0xFFFFAB91)
                                : AppTheme.primaryDark)
                            : (isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
