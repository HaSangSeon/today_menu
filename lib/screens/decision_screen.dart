import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_theme.dart';
import '../models/menu_item.dart';
import '../providers/filter_provider.dart';
import '../providers/menu_provider.dart';
import '../widgets/ad_banner_widget.dart';
import 'recommendation_screen.dart';

class DecisionScreen extends StatelessWidget {
  const DecisionScreen({super.key});

  void _shareMenu(MenuItem menu) {
    final text = '''
🍽️ [오늘 뭐 먹지? 메뉴 결정 완료!]
오늘의 메뉴는 바로 👉 '${menu.emoji} ${menu.name}'!
• 분류: ${menu.subtitleFormatted}
• 예상 가격: ${menu.estimatedPrice} (약 ${menu.cookingTime}분)

지긋지긋한 메뉴 고민, 1초 만에 해결해보세요! 😋
''';
    SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: '오늘의 메뉴: ${menu.name}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recommendation = menuProvider.currentRecommendation;
    final menu = recommendation?.menuItem;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        shape: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2C323D) : const Color(0xFFDDD5C8),
            width: 1,
          ),
        ),
        title: const Text('메뉴 결정 완료'),
        automaticallyImplyLeading: false,
        actions: [
          if (menu != null)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: '친구에게 공유',
              onPressed: () => _shareMenu(menu),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Confetti / Celebration Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.secondaryContainerDark
                              : AppTheme.secondaryContainerLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '🎉',
                            style: TextStyle(fontSize: 42),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        '오늘은 이걸로 결정!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '맛있고 행복한 식사 시간 되세요 😋',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Decision Card
                      if (menu != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primary
                                  .withAlpha(isDark ? 80 : 40),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary
                                    .withAlpha(isDark ? 30 : 20),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                menu.emoji,
                                style: const TextStyle(fontSize: 54),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                menu.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppTheme.textPrimaryDark
                                      : AppTheme.textPrimaryLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                menu.subtitleFormatted,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.textSecondaryLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF262B34)
                                      : const Color(0xFFF7F7F7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '예상 가격 ${menu.estimatedPrice} · 약 ${menu.cookingTime}분',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Share Action Button (카카오톡 / SNS 친구 공유)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _shareMenu(menu),
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text(
                              '친구에게 메뉴 공유하기',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: const BorderSide(
                                color: AppTheme.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons Area with Banner Ad on Top
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 30 : 10),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ad Banner placed above action buttons
                  const AdBannerWidget(),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      // Reroll action
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              final filterProvider =
                                  context.read<FilterProvider>();
                              final success = menuProvider.recommendMenu(
                                filterProvider.criteria,
                                consumeQuota: false,
                              );
                              if (success) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RecommendationScreen(),
                                  ),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: const [
                                Icon(Icons.autorenew_rounded, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  '다시 추천',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Return to Home
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).popUntil(
                                (route) => route.isFirst,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: const [
                                Icon(
                                  Icons.home_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '처음으로',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
