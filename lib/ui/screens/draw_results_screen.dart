import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottery_scanner/ui/data/lottery_results_repository.dart';
import 'package:lottery_scanner/ui/l10n/app_strings.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';
import 'package:lottery_scanner/ui/widgets/language_switcher.dart';
import 'package:lottery_scanner/ui/widgets/locale_fade.dart';
import 'package:lottery_scanner/ui/widgets/province_results_list.dart';

/// Xem toàn bộ kết quả các tỉnh đã quay trong ngày (không cần quét vé).
class DrawResultsScreen extends StatelessWidget {
  const DrawResultsScreen({
    super.key,
    required this.region,
    required this.date,
    this.province,
  });

  final LotteryRegion region;
  final DateTime date;
  final String? province;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final results = LotteryResultsRepository.fetchDayResults(
      region: region,
      date: date,
      strings: s,
    );
    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    final regionName = s.regionLabel(region);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.dayResults),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSwitcher(onDarkBackground: true),
          ),
        ],
      ),
      body: LocaleFade(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    regionName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  if (province != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${s.province}: $province',
                      style: TextStyle(
                        color: AppColors.accent.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            ProvinceResultsList(
              draws: results.draws,
              highlightProvince: province,
              initiallyExpanded: province != null,
            ),
          ],
        ),
      ),
    );
  }
}
