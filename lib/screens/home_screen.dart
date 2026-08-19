import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/filter_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/filter_section.dart';
import '../widgets/menu_loading_dialog.dart';
import '../widgets/quota_badge.dart';
import '../widgets/rewarded_ad_dialog.dart';
import 'history_screen.dart';
import 'recommendation_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onRecommendPressed(BuildContext context) async {
    final menuProvider = context.read<MenuProvider>();
    final filterProvider = context.read<FilterProvider>();

    if (!menuProvider.hasQuota) {
      RewardedAdDialog.show(context);
      return;
    }

    // Show 1.4s menu exploration loading dialog for engaging UX
    await MenuLoadingDialog.show(context);

    if (!context.mounted) return;

    final success = menuProvider.recommendMenu(filterProvider.criteria);
    if (success && menuProvider.currentRecommendation != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const RecommendationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '오늘 뭐 먹지?',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryContainerDark
                    : AppTheme.primaryContainerLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.primary.withAlpha(isDark ? 80 : 50),
                  width: 0.8,
                ),
              ),
              child: Text(
                '결정장애 해결소',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFFFAB91)
                      : AppTheme.primaryDark,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: isDark ? '라이트 모드로 전환' : '다크 모드로 전환',
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: '메뉴 검색',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: '최근 뭐 먹었지?',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: menuProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Main scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Badges Row: Decision badge & Quota badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Feature Badge
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.secondaryContainerDark
                                        : AppTheme.secondaryContainerLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '🎯',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '지긋지긋한 메뉴 결정장애 탈출!',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? const Color(0xFFFFE082)
                                                : const Color(0xFFE65100),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const QuotaBadge(),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // App Big Title and Subtitle
                          Text(
                            '오늘 뭐 먹지?',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '1초 만에 딱 골라드려요 🍽️',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Filter Section (Two distinct cards)
                          const FilterSection(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Area: Ad Banner & Big Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 30 : 12),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Banner Ad inside Action Area
                        const AdBannerWidget(),
                        const SizedBox(height: 6),

                        // Giant Primary Recommendation Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => _onRecommendPressed(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              elevation: 4,
                              shadowColor: AppTheme.primary.withAlpha(100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.restaurant_rounded,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '오늘 메뉴 골라줘!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
