import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/menu_provider.dart';
import 'rewarded_ad_dialog.dart';

class QuotaBadge extends StatelessWidget {
  const QuotaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        final quota = menuProvider.remainingQuota;
        final isZero = quota == 0;

        final badgeBg = isZero
            ? AppTheme.accentRed.withAlpha(isDark ? 50 : 25)
            : (isDark
                ? AppTheme.primaryContainerDark
                : AppTheme.primaryContainerLight);

        final badgeBorder = isZero
            ? AppTheme.accentRed.withAlpha(isDark ? 120 : 80)
            : AppTheme.primary.withAlpha(isDark ? 80 : 50);

        final textColor = isZero
            ? (isDark ? const Color(0xFFFF8A80) : AppTheme.accentRed)
            : (isDark ? const Color(0xFFFFAB91) : AppTheme.primaryDark);

        final iconColor = isZero
            ? (isDark ? const Color(0xFFFF8A80) : AppTheme.accentRed)
            : AppTheme.primary;

        return InkWell(
          onTap: () {
            RewardedAdDialog.show(context);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: badgeBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 15,
                  color: iconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isZero ? '횟수 충전' : '오늘 추천 $quota회',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 13,
                  color: textColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
