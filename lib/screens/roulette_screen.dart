import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/menu_item.dart';
import '../providers/filter_provider.dart';
import '../providers/menu_provider.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/quota_badge.dart';
import '../widgets/rewarded_ad_dialog.dart';
import 'decision_screen.dart';

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<MenuItem> _candidates = [];
  int _winningIndex = 0;
  double _currentAngle = 0.0;
  double _targetAngle = 0.0;
  bool _isSpinning = false;
  int _lastTickSector = -1;

  final List<Color> _sliceColors = const [
    Color(0xFFFF5252), // Coral Vivid Red
    Color(0xFFFF9100), // Rich Sunset Orange
    Color(0xFFFFC400), // Warm Gold
    Color(0xFF00C853), // Fresh Emerald Green
    Color(0xFF2979FF), // Vibrant Ocean Blue
    Color(0xFFAA00FF), // Deep Royal Purple
    Color(0xFFFF4081), // Vivid Berry Pink
    Color(0xFF00B0FF), // Bright Sky Blue
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _controller.addListener(_onAnimationTick);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinCompleted();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCandidates();
    });
  }

  void _loadCandidates() {
    final filter = context.read<FilterProvider>().criteria;
    final candidates = context
        .read<MenuProvider>()
        .getRouletteCandidates(filter, count: 6);
    setState(() {
      _candidates = candidates;
    });
  }

  void _onAnimationTick() {
    setState(() {
      _currentAngle = _animation.value;
    });

    if (_candidates.isEmpty) return;

    final sliceAngle = (2 * pi) / _candidates.length;
    final normalized = (_currentAngle % (2 * pi));
    final currentSector = (normalized / sliceAngle).floor();
    if (currentSector != _lastTickSector) {
      _lastTickSector = currentSector;
      HapticFeedback.selectionClick();
    }
  }

  void _onSpinCompleted() {
    setState(() {
      _isSpinning = false;
    });
    HapticFeedback.heavyImpact();

    final winner = _candidates[_winningIndex];
    context.read<MenuProvider>().setRouletteWinner(winner);

    _showLuxuryWinnerModal(winner);
  }

  void _spin() {
    if (_isSpinning || _candidates.isEmpty) return;

    final menuProvider = context.read<MenuProvider>();
    if (!menuProvider.hasQuota) {
      RewardedAdDialog.show(context);
      return;
    }

    menuProvider.consumeQuotaForRoulette();

    final rand = Random();
    _winningIndex = rand.nextInt(_candidates.length);

    final numSlices = _candidates.length;
    final sliceAngle = (2 * pi) / numSlices;
    final winnerMiddleAngle =
        (_winningIndex * sliceAngle) + (sliceAngle / 2);
    final baseTarget = (2 * pi) - winnerMiddleAngle;
    final extraSpins = (7 + rand.nextInt(3)) * 2 * pi;

    final normalizedStart = _currentAngle % (2 * pi);
    _targetAngle = normalizedStart + extraSpins + baseTarget;

    _animation = Tween<double>(
      begin: normalizedStart,
      end: _targetAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    setState(() {
      _isSpinning = true;
    });

    _controller.reset();
    _controller.forward();
  }

  void _showLuxuryWinnerModal(MenuItem winner) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1F27) : const Color(0xFFFAF8F5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 90 : 40),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          22,
          14,
          22,
          MediaQuery.of(context).viewInsets.bottom + 26,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF384050)
                        : const Color(0xFFDDD6CC),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Celebration Tag Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8F00), Color(0xFFFF6F00)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8F00).withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎉', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text(
                      '오늘의 룰렛 당첨 메뉴!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Giant glowing food icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF2C221D)
                      : const Color(0xFFFFEFE9),
                  border: Border.all(
                    color: AppTheme.primary.withAlpha(isDark ? 160 : 120),
                    width: 2.5,
                  ),
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
                    winner.emoji,
                    style: const TextStyle(fontSize: 46),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Winning dish name
              Text(
                winner.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : const Color(0xFF1E1B18),
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle & Tags
              Text(
                winner.subtitleFormatted,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : const Color(0xFF7A736C),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Specs (Cooking time & Estimated price)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF242A36)
                      : const Color(0xFFF4EFE7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF343D4D)
                        : const Color(0xFFE2DAD0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 18, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '소요시간',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : const Color(0xFF7A736C),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${winner.cookingTime}분',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : const Color(0xFF221F1C),
                          ),
                        ),
                      ],
                    ),
                    Container(
                        width: 1,
                        height: 18,
                        color: isDark
                            ? const Color(0xFF3C4759)
                            : const Color(0xFFDDD5CA)),
                    Row(
                      children: [
                        const Icon(Icons.wallet_rounded,
                            size: 18, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '예상가격',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : const Color(0xFF7A736C),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          winner.estimatedPrice,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : const Color(0xFF221F1C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Dual Action Buttons: [ 한 번 더 돌리기 ] + [ 이 메뉴로 결정하기! ]
              Row(
                children: [
                  // Retry Button
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _spin();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF4A5568)
                                : const Color(0xFFD2C7B8),
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 18,
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : const Color(0xFF4A443E),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '다시 돌리기',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.textPrimaryDark
                                    : const Color(0xFF4A443E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Confirm Button (Vibrant Coral Gradient)
                  Expanded(
                    flex: 6,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5722).withAlpha(100),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DecisionScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 19),
                            SizedBox(width: 6),
                            Text(
                              '이 메뉴로 결정! 🍽️',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
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
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: 10,
        backgroundColor:
            isDark ? const Color(0xFF1D2128) : const Color(0xFFEFEAE1),
        shape: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2C323D) : const Color(0xFFDDD5C8),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            const Text('🎲 ', style: TextStyle(fontSize: 18)),
            Text(
              '메뉴 룰렛 돌리기',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : const Color(0xFF1A1715),
              ),
            ),
          ],
        ),
        actions: const [
          QuotaBadge(),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section: Candidate Pills & Shuffle Button
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF222732)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF343D4D)
                      : const Color(0xFFE6DFD5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 20 : 6),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3B2A1E)
                                  : const Color(0xFFFFEDE5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('🎯',
                                style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '룰렛 후보 메뉴 6종',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : const Color(0xFF1E1B18),
                            ),
                          ),
                        ],
                      ),
                      // Shuffle Button
                      InkWell(
                        onTap: _isSpinning ? null : _loadCandidates,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 14,
                                color: isDark
                                    ? const Color(0xFFFFAB91)
                                    : AppTheme.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '후보 다시뽑기',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFFFFAB91)
                                      : AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Candidate list chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _candidates.map((menu) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C3443)
                                : const Color(0xFFF7F4EF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF3D4759)
                                  : const Color(0xFFE2D9CC),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(menu.emoji,
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                menu.name,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppTheme.textPrimaryDark
                                      : const Color(0xFF332E29),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Center Roulette Wheel
            Expanded(
              child: Center(
                child: _candidates.isEmpty
                    ? const CircularProgressIndicator(color: AppTheme.primary)
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final wheelSize = min(
                              constraints.maxWidth - 36,
                              constraints.maxHeight - 24);

                          return SizedBox(
                            width: wheelSize,
                            height: wheelSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer casino rim with gold border & LED bulb dots
                                CustomPaint(
                                  size: Size(wheelSize, wheelSize),
                                  painter: CasinoRimPainter(
                                    isDark: isDark,
                                    isSpinning: _isSpinning,
                                  ),
                                ),

                                // Spinning Wheel Canvas
                                Transform.rotate(
                                  angle: _currentAngle,
                                  child: CustomPaint(
                                    size: Size(wheelSize - 28, wheelSize - 28),
                                    painter: LuxuryRoulettePainter(
                                      candidates: _candidates,
                                      colors: _sliceColors,
                                      isDark: isDark,
                                    ),
                                  ),
                                ),

                                // Center START Knob
                                GestureDetector(
                                  onTap: _spin,
                                  child: Container(
                                    width: 78,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: isDark
                                            ? [
                                                const Color(0xFF384050),
                                                const Color(0xFF1E222A)
                                              ]
                                            : [
                                                const Color(0xFFFFFFFF),
                                                const Color(0xFFF2ECE4)
                                              ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withAlpha(isDark ? 100 : 40),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                        BoxShadow(
                                          color: AppTheme.primary
                                              .withAlpha(_isSpinning ? 90 : 40),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: _isSpinning
                                            ? const Color(0xFFFFAB91)
                                            : AppTheme.primary,
                                        width: 3.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _isSpinning
                                                ? Icons.sync_rounded
                                                : Icons.play_arrow_rounded,
                                            color: AppTheme.primary,
                                            size: 26,
                                          ),
                                          Text(
                                            _isSpinning ? '회전중' : 'START',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: AppTheme.primary,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Top Pointer Needle (🔻)
                                Positioned(
                                  top: 2,
                                  child: CustomPaint(
                                    size: const Size(28, 28),
                                    painter: TopPointerPainter(
                                      color: const Color(0xFFFF3D00),
                                      isDark: isDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),

            // Bottom Action Bar
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
                  const AdBannerWidget(),
                  const SizedBox(height: 8),

                  // Giant Gradient Spin Button
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: _isSpinning
                          ? const LinearGradient(
                              colors: [Color(0xFF888888), Color(0xFF666666)],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isSpinning
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFFFF5722).withAlpha(100),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSpinning ? null : _spin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isSpinning
                                ? Icons.sync_rounded
                                : Icons.casino_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isSpinning
                                ? '룰렛이 돌아가고 있어요... 🎯'
                                : '돌려라! 메뉴 룰렛 🎲',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.4,
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

/// Outer Casino Rim with Golden LEDs
class CasinoRimPainter extends CustomPainter {
  final bool isDark;
  final bool isSpinning;

  CasinoRimPainter({required this.isDark, required this.isSpinning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;

    // 1. Outer rim band
    final rimPaint = Paint()
      ..color = isDark ? const Color(0xFF282F3C) : const Color(0xFFE5DDD2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, rimPaint);

    // 2. Gold border line
    final borderPaint = Paint()
      ..color = isDark ? const Color(0xFFD4AF37) : const Color(0xFFC8A758)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, outerRadius - 1.5, borderPaint);

    // 3. LED Bulb dots around perimeter (16 lights)
    const numBulbs = 16;
    for (int i = 0; i < numBulbs; i++) {
      final angle = (i * 2 * pi) / numBulbs;
      final bulbRadius = outerRadius - 8;
      final bx = center.dx + bulbRadius * cos(angle);
      final by = center.dy + bulbRadius * sin(angle);

      final isBulbGold = (i % 2 == 0);
      final bulbColor = isBulbGold
          ? const Color(0xFFFFD54F)
          : (isDark ? const Color(0xFFFF7043) : const Color(0xFFFFFFFF));

      final bulbPaint = Paint()..color = bulbColor;
      canvas.drawCircle(Offset(bx, by), 3.5, bulbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CasinoRimPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.isSpinning != isSpinning;
}

/// Luxury Custom Wheel Painter
class LuxuryRoulettePainter extends CustomPainter {
  final List<MenuItem> candidates;
  final List<Color> colors;
  final bool isDark;

  LuxuryRoulettePainter({
    required this.candidates,
    required this.colors,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candidates.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final numSlices = candidates.length;
    final sliceAngle = (2 * pi) / numSlices;

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = isDark ? const Color(0xFF1B1F27) : Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < numSlices; i++) {
      final startAngle = (i * sliceAngle) - (pi / 2);
      paint.color = colors[i % colors.length];

      // Draw slice
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        paint,
      );

      // Draw white divider lines
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        borderPaint,
      );

      // Draw Emoji & Text
      final menu = candidates[i];
      final middleAngle = startAngle + (sliceAngle / 2);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(middleAngle);

      final normalizedAngle = (middleAngle + pi / 2) % (2 * pi);
      final isUpsideDown =
          normalizedAngle > (pi / 2) && normalizedAngle < (3 * pi / 2);

      // Draw Emoji
      final emojiPainter = TextPainter(
        text: TextSpan(
          text: menu.emoji,
          style: const TextStyle(fontSize: 24),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      emojiPainter.paint(
        canvas,
        Offset(radius * 0.72 - (emojiPainter.width / 2),
            -(emojiPainter.height / 2)),
      );

      // Draw Menu Name
      final displayName =
          menu.name.length > 5 ? '${menu.name.substring(0, 5)}..' : menu.name;
      final namePainter = TextPainter(
        text: TextSpan(
          text: displayName,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black87,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      if (isUpsideDown) {
        canvas.save();
        canvas.translate(radius * 0.38, 0);
        canvas.rotate(pi);
        namePainter.paint(
          canvas,
          Offset(-(namePainter.width / 2), -(namePainter.height / 2)),
        );
        canvas.restore();
      } else {
        namePainter.paint(
          canvas,
          Offset(radius * 0.38 - (namePainter.width / 2),
              -(namePainter.height / 2)),
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant LuxuryRoulettePainter oldDelegate) =>
      oldDelegate.candidates != candidates || oldDelegate.isDark != isDark;
}

/// Needle Pointer
class TopPointerPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  TopPointerPainter({required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black, 4, true);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant TopPointerPainter oldDelegate) => false;
}
