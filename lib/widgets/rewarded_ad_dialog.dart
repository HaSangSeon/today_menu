import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../providers/menu_provider.dart';
import '../services/ad_service.dart';

class RewardedAdDialog extends StatefulWidget {
  const RewardedAdDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const RewardedAdDialog(),
    );
  }

  @override
  State<RewardedAdDialog> createState() => _RewardedAdDialogState();
}

class _RewardedAdDialogState extends State<RewardedAdDialog> {
  bool _isLoadingAd = false;
  String? _errorMessage;

  Future<void> _watchAdAndEarnReward() async {
    setState(() {
      _isLoadingAd = true;
      _errorMessage = null;
    });

    final menuProvider = context.read<MenuProvider>();
    final adService = AdService();

    final earned = await adService.showRewardedAd(
      onUserEarnedReward: () async {
        await menuProvider.addRewardBonus();
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 추천 기회 ${AppConfig.rewardAdditionalCount}회가 추가되었습니다!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      onAdFailed: (error) {
        if (mounted) {
          setState(() {
            _isLoadingAd = false;
            _errorMessage = error;
          });
        }
      },
      onAdClosed: () {
        if (mounted) {
          setState(() {
            _isLoadingAd = false;
          });
        }
      },
    );

    if (!earned && mounted) {
      setState(() {
        _isLoadingAd = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryContainerDark
                    : AppTheme.primaryContainerLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '추천 횟수가 모두 소진되었어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '짧은 광고를 시청하시면\n오늘 추천 기회 ${AppConfig.rewardAdditionalCount}회를 즉시 추가해 드립니다.',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.accentRed,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoadingAd ? null : _watchAdAndEarnReward,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoadingAd) ...[
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '광고 불러오는 중...',
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      const Icon(Icons.play_circle_fill_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '광고 보고 ${AppConfig.rewardAdditionalCount}번 더 추천받기',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                '다음에 할게요',
                style: TextStyle(
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
    );
  }
}
