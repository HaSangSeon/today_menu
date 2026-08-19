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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter header with Reset button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '맞춤 필터 설정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
                if (!criteria.isDefault)
                  TextButton.icon(
                    onPressed: () {
                      filterProvider.resetFilter();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text(
                      '초기화',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 1. 식사 형태
            _buildFilterRow(
              context: context,
              title: '🍽️ 식사 형태',
              options: FilterCriteria.mealTypeOptions,
              selected: criteria.mealType,
              onSelected: (val) => filterProvider.updateMealType(val),
            ),
            const SizedBox(height: 14),

            // 2. 가격대
            _buildFilterRow(
              context: context,
              title: '💰 가격',
              options: FilterCriteria.priceOptions,
              selected: criteria.price,
              onSelected: (val) => filterProvider.updatePrice(val),
            ),
            const SizedBox(height: 14),

            // 3. 음식 종류
            _buildFilterRow(
              context: context,
              title: '🍲 음식 종류',
              options: FilterCriteria.categoryOptions,
              selected: criteria.category,
              onSelected: (val) => filterProvider.updateCategory(val),
            ),
            const SizedBox(height: 14),

            // 4. 조리시간
            _buildFilterRow(
              context: context,
              title: '⏱️ 조리시간',
              options: FilterCriteria.cookingTimeOptions,
              selected: criteria.cookingTime,
              onSelected: (val) => filterProvider.updateCookingTime(val),
            ),
            const SizedBox(height: 14),

            // 5. 추천 성향
            _buildFilterRow(
              context: context,
              title: '✨ 추천 성향',
              options: FilterCriteria.preferenceOptions,
              selected: criteria.preference,
              onSelected: (val) => filterProvider.updatePreference(val),
            ),
          ],
        );
      },
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
