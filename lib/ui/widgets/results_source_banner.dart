import 'package:flutter/material.dart';
import 'package:lottery_scanner/ui/data/lottery_results_repository.dart';
import 'package:lottery_scanner/ui/l10n/app_strings.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';

class ResultsSourceBanner extends StatelessWidget {
  const ResultsSourceBanner({
    super.key,
    required this.source,
    this.loadError,
    this.onRetry,
  });

  final LotteryResultsSource source;
  final String? loadError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isLive = source == LotteryResultsSource.minhNgoc;
    final bg = isLive
        ? AppColors.success.withValues(alpha: 0.12)
        : AppColors.info.withValues(alpha: 0.12);
    final fg = isLive ? AppColors.success : AppColors.info;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isLive ? Icons.cloud_done_outlined : Icons.science_outlined, color: fg, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLive ? s.sourceMinhNgoc : s.sourceMock,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                if (loadError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    loadError!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (!isLive && onRetry != null)
            TextButton(onPressed: onRetry, child: Text(s.retry)),
        ],
      ),
    );
  }
}
