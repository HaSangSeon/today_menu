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

        // 식사 방식에 따른 스마트 시간 라벨 계산
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
            // Filter header with Reset button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      '맞춤 필터 설정',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.primaryContainerDark
                            : AppTheme.primaryContainerLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '혼밥 맞춤',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFFFAB91)
                              : AppTheme.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!criteria.isDefault)
                  TextButton.icon(
                    onPressed: () {
                      filterProvider.resetFilter();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 15),
                    label: const Text(
                      '초기화',
                      style: TextStyle(fontSize: 12.5),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // 1. 1인 가구 1초 퀵 테마 프리셋
            _buildPresetSection(context, filterProvider, criteria, isDark),
            const SizedBox(height: 16),

            const Divider(height: 1),
            const SizedBox(height: 14),

            // 2. 음식 종류 (최상단 배치!)
            _buildFilterRow(
              context: context,
              title: '🍲 어떤 음식이 땡기나요? (카테고리)',
              options: FilterCriteria.categoryOptions,
              selected: criteria.category,
              onSelected: (val) => filterProvider.updateCategory(val),
            ),
            const SizedBox(height: 14),

            // 3. 식사 방식 (어떻게 먹을까?)
            _buildFilterRow(
              context: context,
              title: '🍽️ 식사 방식',
              options: FilterCriteria.mealTypeOptions,
              selected: criteria.mealType,
              onSelected: (val) => filterProvider.updateMealType(val),
            ),
            const SizedBox(height: 14),

            // 4. 소요시간 (식사 방식에 따라 스마트 라벨 적용)
            _buildFilterRow(
              context: context,
              title: timeLabel,
              options: FilterCriteria.cookingTimeOptions,
              selected: criteria.cookingTime,
              onSelected: (val) => filterProvider.updateCookingTime(val),
            ),
            const SizedBox(height: 14),

            // 5. 한 끼 예산 / 가격대
            _buildFilterRow(
              context: context,
              title: '💰 한 끼 예산',
              options: FilterCriteria.priceOptions,
              selected: criteria.price,
              onSelected: (val) => filterProvider.updatePrice(val),
            ),
            const SizedBox(height: 14),

            // 6. 오늘 땡기는 느낌 / 성향
            _buildFilterRow(
              context: context,
              title: '✨ 오늘 땡기는 느낌',
              options: FilterCriteria.preferenceOptions,
              selected: criteria.preference,
              onSelected: (val) => filterProvider.updatePreference(val),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPresetSection(
    BuildContext context,
    FilterProvider filterProvider,
    FilterCriteria criteria,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '⚡ 혼자 있을 때 1초 퀵 테마',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFFFE082)
                    : const Color(0xFFE65100),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '터치 한 번으로 조건 자동완성!',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppTheme.textMutedDark
                    : AppTheme.textMutedLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? AppTheme.primaryContainerDark
                              : AppTheme.primaryContainerLight)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : (isDark
                                ? AppTheme.cardBorderDark
                                : const Color(0xFFE2DDD5)),
                        width: isSelected ? 1.8 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withAlpha(isDark ? 40 : 25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          preset['emoji']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              preset['label']!,
                              style: TextStyle(
                                fontSize: 12.5,
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
                      ],
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

  Widget _buildFilterRow({
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
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
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
                child: ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (bool sel) {
                    if (sel) {
                      onSelected(option);
                    }
                  },
                  showCheckmark: false,
                  selectedColor: isDark
                      ? AppTheme.primaryContainerDark
                      : AppTheme.primaryContainerLight,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.primary
                        : (isDark
                            ? AppTheme.cardBorderDark
                            : const Color(0xFFE0E0E0)),
                    width: isSelected ? 1.5 : 1,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (isDark
                            ? const Color(0xFFFFAB91)
                            : AppTheme.primaryDark)
                        : (isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
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
