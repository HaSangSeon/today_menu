import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/menu_item.dart';

class MenuCard extends StatelessWidget {
  final MenuItem menu;
  final bool isRelaxed;
  final String? relaxationMessage;

  const MenuCard({
    super.key,
    required this.menu,
    this.isRelaxed = false,
    this.relaxationMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? AppTheme.cardBorderDark : const Color(0xFFF0EBE5),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Relaxation Banner if any
          if (isRelaxed && relaxationMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.secondaryContainerDark
                    : AppTheme.secondaryContainerLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: isDark
                        ? const Color(0xFFFFB300)
                        : const Color(0xFFE65100),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      relaxationMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFFFE082)
                            : const Color(0xFFE65100),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                // Big Emoji in circular badge
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.primaryContainerDark
                        : AppTheme.primaryContainerLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withAlpha(isDark ? 50 : 30),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      menu.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category & Subtitle
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF282D37)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    menu.subtitleFormatted,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Menu Name
                Text(
                  menu.name,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Divider(
                  color: isDark
                      ? AppTheme.dividerColorDark
                      : AppTheme.dividerColorLight,
                  height: 1,
                ),
                const SizedBox(height: 20),

                // Details: Price & Cooking Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoItem(
                      context: context,
                      icon: Icons.payments_outlined,
                      label: '예상 가격',
                      value: menu.estimatedPrice,
                    ),
                    Container(
                      height: 36,
                      width: 1,
                      color: isDark
                          ? AppTheme.dividerColorDark
                          : AppTheme.dividerColorLight,
                    ),
                    _buildInfoItem(
                      context: context,
                      icon: Icons.timer_outlined,
                      label: '조리 시간',
                      value: '약 ${menu.cookingTime}분',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tags
                if (menu.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: menu.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF262B34)
                              : const Color(0xFFFAF7F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.cardBorderDark
                                : const Color(0xFFECE5DD),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? AppTheme.textSecondaryDark
        : AppTheme.textSecondaryLight;
    final primaryColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.textPrimaryLight;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: secondaryColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}
