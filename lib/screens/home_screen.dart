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
import '../widgets/notification_settings_dialog.dart';
import 'history_screen.dart';
import 'recommendation_screen.dart';
import 'roulette_screen.dart';

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
        toolbarHeight: 64,
        titleSpacing: 20,
        backgroundColor: isDark
            ? const Color(0xFF1D2128)
            : const Color(0xFFEFEAE1), // Distinct, warm luxury header color
        shape: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF2C323D)
                : const Color(0xFFDDD5C8), // Crisp divider line for clear separation
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Text(
              '오늘 뭐 먹지?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : const Color(0xFF1A1715),
              ),
            ),
            const SizedBox(width: 5),
            const Text('🍽️', style: TextStyle(fontSize: 18)),
          ],
        ),
        centerTitle: false,
        actions: [
          // 1. 다크 / 라이트 모드 전환 버튼
          _buildHeaderButton(
            context: context,
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: isDark ? '라이트 모드로 전환' : '다크 모드로 전환',
            iconColor: isDark ? const Color(0xFFFFD54F) : const Color(0xFF5D4037),
            onTap: () => themeProvider.toggleTheme(),
            isDark: isDark,
          ),
          const SizedBox(width: 6),

          // 2. 식사 캘린더 버튼
          _buildHeaderButton(
            context: context,
            icon: Icons.calendar_month_rounded,
            tooltip: '식사 캘린더 & 기록',
            iconColor: isDark ? AppTheme.primaryLight : AppTheme.primary,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(width: 6),

          // 3. 식사 알림 설정 버튼
          _buildHeaderButton(
            context: context,
            icon: Icons.notifications_none_rounded,
            tooltip: '식사 알림 설정',
            iconColor: isDark ? Colors.white70 : const Color(0xFF4E342E),
            onTap: () => NotificationSettingsDialog.show(context),
            isDark: isDark,
          ),
          const SizedBox(width: 16),
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

                        // Dual Action Buttons: [🎲 메뉴 룰렛] + [🍽️ 메뉴 골라줘!]
                        Row(
                          children: [
                            // 1. 룰렛 돌리기 버튼 (Luxury Amber Gradient)
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [
                                            const Color(0xFF3E2D18),
                                            const Color(0xFF2C1F10)
                                          ]
                                        : [
                                            const Color(0xFFFFF4E5),
                                            const Color(0xFFFFE6CC)
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFFFFA726).withAlpha(120)
                                        : const Color(0xFFFFB74D),
                                    width: 1.3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFA726)
                                          .withAlpha(isDark ? 30 : 25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RouletteScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('🎲',
                                          style: TextStyle(fontSize: 18)),
                                      const SizedBox(width: 6),
                                      Text(
                                        '메뉴 룰렛',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? const Color(0xFFFFB74D)
                                              : const Color(0xFFE65100),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // 2. 메인 추천 버튼 (Signature Coral-Red Gradient)
                            Expanded(
                              flex: 6,
                              child: Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF5722),
                                      Color(0xFFE64A19)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF5722)
                                          .withAlpha(100),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _onRecommendPressed(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.restaurant_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '메뉴 골라줘!',
                                        style: TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -0.4,
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

  Widget _buildHeaderButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF242A34)
                : const Color(0xFFFAF8F5), // Clean white-ivory squircle
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF353C49)
                  : const Color(0xFFD5CCC0),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 20 : 6),
                blurRadius: 3,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 19,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
