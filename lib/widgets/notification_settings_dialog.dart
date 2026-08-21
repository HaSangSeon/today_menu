import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/notification_service.dart';

class NotificationSettingsDialog extends StatefulWidget {
  const NotificationSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationSettingsDialog(),
    );
  }

  @override
  State<NotificationSettingsDialog> createState() =>
      _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState
    extends State<NotificationSettingsDialog> {
  bool _lunchEnabled = true;
  bool _dinnerEnabled = true;
  int _lunchHour = 11;
  int _lunchMinute = 30;
  int _dinnerHour = 17;
  int _dinnerMinute = 30;
  bool _isLoading = true;

  // 대중적인 점심 시간 옵션 목록
  final List<Map<String, dynamic>> _lunchPresets = [
    {'label': '11:00', 'hour': 11, 'minute': 0},
    {'label': '11:30', 'hour': 11, 'minute': 30, 'tag': '추천'},
    {'label': '12:00', 'hour': 12, 'minute': 0},
    {'label': '12:30', 'hour': 12, 'minute': 30},
  ];

  // 대중적인 저녁 시간 옵션 목록
  final List<Map<String, dynamic>> _dinnerPresets = [
    {'label': '17:00', 'hour': 17, 'minute': 0},
    {'label': '17:30', 'hour': 17, 'minute': 30, 'tag': '추천'},
    {'label': '18:00', 'hour': 18, 'minute': 0},
    {'label': '18:30', 'hour': 18, 'minute': 30},
    {'label': '19:00', 'hour': 19, 'minute': 0},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await NotificationService().getSettings();
    if (mounted) {
      setState(() {
        _lunchEnabled = settings['lunchEnabled'] as bool? ?? true;
        _dinnerEnabled = settings['dinnerEnabled'] as bool? ?? true;
        _lunchHour = settings['lunchHour'] as int? ?? 11;
        _lunchMinute = settings['lunchMinute'] as int? ?? 30;
        _dinnerHour = settings['dinnerHour'] as int? ?? 17;
        _dinnerMinute = settings['dinnerMinute'] as int? ?? 30;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    await NotificationService().saveSettings(
      lunchEnabled: _lunchEnabled,
      dinnerEnabled: _dinnerEnabled,
      lunchHour: _lunchHour,
      lunchMinute: _lunchMinute,
      dinnerHour: _dinnerHour,
      dinnerMinute: _dinnerMinute,
    );
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('식사 알림 설정이 저장되었습니다! ⏰'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2027) : const Color(0xFFFAF8F5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 90 : 30),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: _isLoading
            ? const SizedBox(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Drag Handle Indicator
                    Center(
                      child: Container(
                        width: 38,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3B4352)
                              : const Color(0xFFDDD6CC),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header: Icon + Title + Close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          const Color(0xFF4A2518),
                                          const Color(0xFF331B12)
                                        ]
                                      : [
                                          const Color(0xFFFFECE5),
                                          const Color(0xFFFFDCD2)
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: AppTheme.primary
                                      .withAlpha(isDark ? 90 : 50),
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Text('🔔',
                                    style: TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '식사 알림 설정',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.6,
                                    color: isDark
                                        ? AppTheme.textPrimaryDark
                                        : const Color(0xFF1A1715),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '결정장애 오기 전, 딱 맞춰 골라드려요',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : const Color(0xFF7A736C),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Close X button
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF282F3B)
                                  : const Color(0xFFEDE7DF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : const Color(0xFF5A524C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 1. 점심 알림 카드 (간편 원터치 시간 선택)
                    _buildMealSection(
                      context: context,
                      emoji: '☀️',
                      title: '점심 메뉴 알림',
                      subtitle: '오전 직장/학교 점심 고민 해결',
                      enabled: _lunchEnabled,
                      currentHour: _lunchHour,
                      currentMinute: _lunchMinute,
                      presets: _lunchPresets,
                      onToggle: (val) =>
                          setState(() => _lunchEnabled = val),
                      onSelectTime: (h, m) => setState(() {
                        _lunchHour = h;
                        _lunchMinute = m;
                      }),
                      accentColor: const Color(0xFFFF9800),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),

                    // 2. 저녁 알림 카드 (간편 원터치 시간 선택)
                    _buildMealSection(
                      context: context,
                      emoji: '🌙',
                      title: '저녁 메뉴 알림',
                      subtitle: '퇴근길 & 저녁 배달 메뉴 추천',
                      enabled: _dinnerEnabled,
                      currentHour: _dinnerHour,
                      currentMinute: _dinnerMinute,
                      presets: _dinnerPresets,
                      onToggle: (val) =>
                          setState(() => _dinnerEnabled = val),
                      onSelectTime: (h, m) => setState(() {
                        _dinnerHour = h;
                        _dinnerMinute = m;
                      }),
                      accentColor: const Color(0xFFFF7043),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    // 3. 테스트 알림 버튼
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          await NotificationService().sendTestNotification();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    '테스트 알림이 발송되었습니다! 상단 알림창을 내려 확인해보세요 🔔'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: const Text(
                          '지금 알림 테스트해보기',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? const Color(0xFFFFAB91)
                              : AppTheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          elevation: 3,
                          shadowColor: AppTheme.primary.withAlpha(100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '알림 설정 저장하기',
                              style: TextStyle(
                                fontSize: 16,
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
      ),
    );
  }

  Widget _buildMealSection({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required bool enabled,
    required int currentHour,
    required int currentMinute,
    required List<Map<String, dynamic>> presets,
    required ValueChanged<bool> onToggle,
    required Function(int hour, int minute) onSelectTime,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? (enabled ? const Color(0xFF222833) : const Color(0xFF1D2128))
            : (enabled
                ? const Color(0xFFFFFFFF)
                : const Color(0xFFF2EFEB)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: enabled
              ? (isDark
                  ? accentColor.withAlpha(90)
                  : accentColor.withAlpha(60))
              : (isDark ? const Color(0xFF2F3746) : const Color(0xFFE5DDD3)),
          width: enabled ? 1.4 : 1.0,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: accentColor.withAlpha(isDark ? 20 : 12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Emoji + Title + Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C3442)
                          : const Color(0xFFF8F4EE),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : const Color(0xFF1E1B18),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : const Color(0xFF7A736C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch.adaptive(
                value: enabled,
                onChanged: onToggle,
                activeTrackColor: AppTheme.primary,
              ),
            ],
          ),

          // Row 2: One-touch time chips
          if (enabled) ...[
            const SizedBox(height: 14),
            Container(
              height: 1,
              color: isDark
                  ? const Color(0xFF2D3543)
                  : const Color(0xFFF0EBE3),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : const Color(0xFF7A736C),
                ),
                const SizedBox(width: 5),
                Text(
                  '알림 받을 시간 선택',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : const Color(0xFF6B635C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((preset) {
                final isSelected = preset['hour'] == currentHour &&
                    preset['minute'] == currentMinute;
                final tag = preset['tag'] as String?;

                return InkWell(
                  onTap: () => onSelectTime(
                    preset['hour'] as int,
                    preset['minute'] as int,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : (isDark
                              ? const Color(0xFF2B3340)
                              : const Color(0xFFF6F3EE)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : (isDark
                                ? const Color(0xFF3B4657)
                                : const Color(0xFFDDD5CA)),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withAlpha(80),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          preset['label'] as String,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppTheme.textPrimaryDark
                                    : const Color(0xFF332D27)),
                          ),
                        ),
                        if (tag != null) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withAlpha(50)
                                  : (isDark
                                      ? AppTheme.primaryContainerDark
                                      : const Color(0xFFFFEDE6)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
