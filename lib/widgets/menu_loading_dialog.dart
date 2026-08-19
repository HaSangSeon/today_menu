import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class MenuLoadingDialog extends StatefulWidget {
  const MenuLoadingDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const MenuLoadingDialog(),
    );
  }

  @override
  State<MenuLoadingDialog> createState() => _MenuLoadingDialogState();
}

class _MenuLoadingDialogState extends State<MenuLoadingDialog>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, String>> _sampleMenus = [
    {'emoji': '🍲', 'name': '얼큰한 찌개 찾는 중...'},
    {'emoji': '🥩', 'name': '든든한 고기 요리 검토 중...'},
    {'emoji': '🍝', 'name': '맛있는 양식 & 면류 스캔 중...'},
    {'emoji': '🍣', 'name': '깔끔한 일식 메뉴 탐색 중...'},
    {'emoji': '🥟', 'name': '취향 저격 메뉴 엄선 중...'},
    {'emoji': '🍱', 'name': '오늘의 최적 메뉴 결정 중...'},
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Change menu text & emoji every 220ms
    _timer = Timer.periodic(const Duration(milliseconds: 220), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _sampleMenus.length;
        });
      }
    });

    // Auto dismiss after 1.4 seconds
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = _sampleMenus[_currentIndex];

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing emoji container
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.primaryContainerDark
                        : AppTheme.primaryContainerLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withAlpha(isDark ? 60 : 35),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      current['emoji']!,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                '오늘의 인생 메뉴 찾는 중!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  current['name']!,
                  key: ValueKey<int>(_currentIndex),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 6,
                  width: 140,
                  child: LinearProgressIndicator(
                    backgroundColor: isDark
                        ? const Color(0xFF2C323D)
                        : const Color(0xFFEEEEEE),
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
