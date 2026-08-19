import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/filter_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/menu_card.dart';
import '../widgets/quota_badge.dart';
import 'decision_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onRerollPressed(BuildContext context) {
    final menuProvider = context.read<MenuProvider>();
    final filterProvider = context.read<FilterProvider>();

    final success = menuProvider.recommendMenu(
      filterProvider.criteria,
      consumeQuota: false,
    );
    if (success) {
      _animController.reset();
      _animController.forward();
    }
  }

  void _onConfirmPressed(BuildContext context) async {
    final menuProvider = context.read<MenuProvider>();
    await menuProvider.confirmCurrentMenu();

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DecisionScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recommendation = menuProvider.currentRecommendation;

    if (recommendation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('오늘의 추천')),
        body: const Center(child: Text('추천 데이터가 없습니다.')),
      );
    }

    final menu = recommendation.menuItem;

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 메뉴 추천'),
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
          const QuotaBadge(),
          const SizedBox(width: 12),
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
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '오늘의 추천 메뉴입니다!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Animated Hero Menu Card
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: MenuCard(
                            menu: menu,
                            isRelaxed: recommendation.isRelaxed,
                            relaxationMessage:
                                recommendation.relaxationMessage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  // Banner Ad placed ABOVE action buttons
                  const AdBannerWidget(),
                  const SizedBox(height: 6),

                  // Action Buttons: Re-roll & Confirm with perfect center alignment
                  Row(
                    children: [
                      // Re-roll button (다시 골라줘)
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => _onRerollPressed(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: const [
                                Icon(Icons.autorenew_rounded, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  '다시 골라줘',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Confirm decision button (이걸로 결정!)
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => _onConfirmPressed(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: const [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '이걸로 결정!',
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
