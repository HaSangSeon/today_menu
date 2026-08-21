import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/meal_history_item.dart';
import '../providers/menu_provider.dart';
import '../widgets/ad_banner_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmDialog(
      BuildContext context, MenuProvider menuProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '기록 전체 삭제',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
            ),
          ),
          content: Text(
            '최근 결정한 모든 메뉴 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                '취소',
                style: TextStyle(
                  color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await menuProvider.clearAllMealHistory();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('전체 메뉴 기록이 삭제되었습니다.'),
                      backgroundColor:
                          isDark ? const Color(0xFF2C323D) : Colors.black87,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('전체 삭제'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSingleItem(BuildContext context, MenuProvider menuProvider,
      MealHistoryItem item) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await menuProvider.deleteMealHistoryItem(item.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('\'${item.menuName}\' 기록이 삭제되었습니다.'),
          backgroundColor:
              isDark ? const Color(0xFF2C323D) : Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final history = menuProvider.mealHistory;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Text('식사 캘린더 & 기록'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: '기록 전체 삭제',
              onPressed: () => _showDeleteConfirmDialog(context, menuProvider),
            ),
          const SizedBox(width: 6),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: isDark
              ? AppTheme.textSecondaryDark
              : AppTheme.textSecondaryLight,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.calendar_month_rounded, size: 20),
              text: '달력',
            ),
            Tab(
              icon: Icon(Icons.insights_rounded, size: 20),
              text: '식습관 통계',
            ),
            Tab(
              icon: Icon(Icons.format_list_bulleted_rounded, size: 20),
              text: '전체 목록',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: 캘린더 뷰
                  _buildCalendarTab(context, history, isDark),

                  // Tab 2: 식습관 통계 뷰
                  _buildStatisticsTab(context, history, isDark),

                  // Tab 3: 전체 목록 뷰
                  _buildListTab(context, menuProvider, history, isDark),
                ],
              ),
            ),
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // 1. 캘린더 탭 구현
  // ========================================================
  Widget _buildCalendarTab(
      BuildContext context, List<MealHistoryItem> history, bool isDark) {
    // 날짜별 메뉴 매핑
    final Map<String, List<MealHistoryItem>> dateMap = {};
    for (final item in history) {
      final key =
          '${item.decidedAt.year}-${item.decidedAt.month.toString().padLeft(2, '0')}-${item.decidedAt.day.toString().padLeft(2, '0')}';
      dateMap.putIfAbsent(key, () => []).add(item);
    }

    final selectedKey =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final selectedDayMeals = dateMap[selectedKey] ?? [];

    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayWeekday =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month navigation bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.cardBorderDark : const Color(0xFFEDE8E1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                          _selectedMonth.year, _selectedMonth.month - 1);
                    });
                  },
                ),
                Text(
                  '${_selectedMonth.year}년 ${_selectedMonth.month}월',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                          _selectedMonth.year, _selectedMonth.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
              final isSun = day == '일';
              final isSat = day == '토';
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSun
                          ? AppTheme.accentRed
                          : isSat
                              ? Colors.blue
                              : (isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: firstDayWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index < firstDayWeekday) {
                return const SizedBox.shrink();
              }
              final day = index - firstDayWeekday + 1;
              final currentDate =
                  DateTime(_selectedMonth.year, _selectedMonth.month, day);
              final key =
                  '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
              final meals = dateMap[key] ?? [];
              final isSelected = _selectedDate.year == currentDate.year &&
                  _selectedDate.month == currentDate.month &&
                  _selectedDate.day == currentDate.day;
              final isToday = DateTime.now().year == currentDate.year &&
                  DateTime.now().month == currentDate.month &&
                  DateTime.now().day == currentDate.day;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = currentDate;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? AppTheme.primaryContainerDark
                            : AppTheme.primaryContainerLight)
                        : (isDark
                            ? const Color(0xFF1E232B)
                            : const Color(0xFFFAF9F6)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : isToday
                              ? AppTheme.secondary
                              : (isDark
                                  ? AppTheme.cardBorderDark
                                  : const Color(0xFFEBE6DF)),
                      width: isSelected || isToday ? 1.5 : 0.8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight),
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (meals.isNotEmpty)
                        Text(
                          meals.first.emoji,
                          style: const TextStyle(fontSize: 16),
                        )
                      else
                        const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Selected Day Meal Details
          Text(
            '${_selectedDate.month}월 ${_selectedDate.day}일 식사 내역',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),

          if (selectedDayMeals.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDark ? AppTheme.cardBorderDark : const Color(0xFFEFEFEF),
                ),
              ),
              child: Column(
                children: [
                  const Text('🍽️', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(
                    '이 날 결정한 메뉴 기록이 없습니다.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedDayMeals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = selectedDayMeals[index];
                return _buildHistoryCard(item, isDark);
              },
            ),
        ],
      ),
    );
  }

  // ========================================================
  // 2. 식습관 통계 탭 구현
  // ========================================================
  Widget _buildStatisticsTab(
      BuildContext context, List<MealHistoryItem> history, bool isDark) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📊', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              '아직 식사 기록이 충분하지 않아요.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '메뉴를 결정하고 기록을 쌓아보세요!',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    // 카테고리별 집계
    final Map<String, int> categoryCount = {};
    for (final item in history) {
      categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
    }

    final sortedCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalCount = history.length;
    final topCategory = sortedCategories.first.key;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Insight Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF3E2218), const Color(0xFF2D1E18)]
                    : [const Color(0xFFFFF0EB), const Color(0xFFFFE8E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primary.withAlpha(isDark ? 80 : 50),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '나의 최애 메뉴 성향',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFFFAB91)
                            : AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '지금까지 총 $totalCount끼 중 \'$topCategory\'을 가장 많이 드셨어요! 😋',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Category distribution
          Text(
            '음식 종류별 결정 비율',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppTheme.cardBorderDark : const Color(0xFFEDE8E1),
              ),
            ),
            child: Column(
              children: sortedCategories.map((entry) {
                final percent = (entry.value / totalCount) * 100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                            ),
                          ),
                          Text(
                            '${entry.value}회 (${percent.toStringAsFixed(0)}%)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? const Color(0xFF262B34)
                              : const Color(0xFFF0EBE5),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primary,
                          ),
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
    );
  }

  // ========================================================
  // 3. 전체 목록 탭 구현
  // ========================================================
  Widget _buildListTab(BuildContext context, MenuProvider menuProvider,
      List<MealHistoryItem> history, bool isDark) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 42)),
            const SizedBox(height: 12),
            Text(
              '아직 결정한 메뉴 기록이 없어요.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '오늘의 메뉴를 추천받고 [이걸로 결정!]을 눌러보세요.',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = history[index];

        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppTheme.accentRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 6),
                Text(
                  '삭제',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (direction) {
            _deleteSingleItem(context, menuProvider, item);
          },
          child: _buildHistoryCard(item, isDark, onDelete: () {
            _deleteSingleItem(context, menuProvider, item);
          }),
        );
      },
    );
  }

  Widget _buildHistoryCard(MealHistoryItem item, bool isDark,
      {VoidCallback? onDelete}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.cardBorderDark : const Color(0xFFEFEFEF),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Emoji badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primaryContainerDark
                  : AppTheme.primaryContainerLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Menu name & category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuName,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Date and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.decidedAt.month}월 ${item.decidedAt.day}일',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.decidedAt.hour < 12 ? '오전' : '오후'} ${item.decidedAt.hour % 12 == 0 ? 12 : item.decidedAt.hour % 12}:${item.decidedAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (onDelete != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: isDark
                    ? AppTheme.textMutedDark
                    : AppTheme.textMutedLight,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
              tooltip: '삭제',
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}
