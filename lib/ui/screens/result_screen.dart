import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottery_scanner/ui/data/lottery_results_repository.dart';
import 'package:lottery_scanner/ui/l10n/app_strings.dart';
import 'package:lottery_scanner/ui/models/lottery_draw.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';
import 'package:lottery_scanner/ui/screens/camera_screen.dart';
import 'package:lottery_scanner/ui/screens/home_screen.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';
import 'package:lottery_scanner/ui/widgets/language_switcher.dart';
import 'package:lottery_scanner/ui/widgets/locale_fade.dart';
import 'package:lottery_scanner/ui/widgets/lottery_card.dart';
import 'package:lottery_scanner/ui/widgets/primary_button.dart';
import 'package:lottery_scanner/ui/widgets/province_results_list.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.session});

  final ScanSession session;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final region = s.regionLabel(session.region);
    final location = session.locationLabel(region);
    final date = DateFormat('dd/MM/yyyy').format(session.date);
    final number = session.scannedNumber ?? '------';

    final dayResults = LotteryResultsRepository.fetchDayResults(
      region: session.region,
      date: session.date,
      strings: s,
    );
    final matches = number != '------'
        ? LotteryResultsRepository.matchTicket(
            ticketNumber: number,
            results: dayResults,
            strings: s,
          )
        : <PrizeMatch>[];
    final won = matches.isNotEmpty;
    final best = won ? _bestMatch(matches) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.checkResult),
        automaticallyImplyLeading: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSwitcher(onDarkBackground: true),
          ),
        ],
      ),
      body: LocaleFade(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _Banner(won: won, s: s),
              const SizedBox(height: 24),
              LotteryCard(
                child: Column(
                  children: [
                    Text(location, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(date, style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),
                    Text(s.yourNumber, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 12),
                    _Digits(number: number),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (won && best != null)
                LotteryCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.emoji_events, color: AppColors.primaryDark, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${best.prizeLabel} · ${best.province}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (best.amount != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                best.amount!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                LotteryCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lose.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sentiment_neutral, color: AppColors.lose, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          s.noMatchAnyProvince,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              if (won && matches.length > 1) ...[
                const SizedBox(height: 12),
                LotteryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.matchedProvinces, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ...matches.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• ${m.province}: ${m.prizeLabel} (${m.winningNumber})',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              ProvinceResultsList(
                draws: dayResults.draws,
                matches: matches,
                highlightProvince: session.province,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: s.scanAnother,
                icon: Icons.document_scanner,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => CameraScreen(session: session)),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: s.backHome,
                outlined: true,
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
                  (_) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PrizeMatch _bestMatch(List<PrizeMatch> matches) {
    const order = [
      'giai_db',
      'giai_1',
      'giai_2',
      'giai_3',
      'giai_4',
      'giai_5',
      'giai_6',
      'giai_7',
      'giai_8',
    ];
    matches.sort(
      (a, b) => order.indexOf(a.prizeKey).compareTo(order.indexOf(b.prizeKey)),
    );
    return matches.first;
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.won, required this.s});
  final bool won;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final color = won ? AppColors.success : AppColors.lose;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.75)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(won ? Icons.celebration : Icons.info_outline, color: Colors.white, size: 56),
          const SizedBox(height: 12),
          Text(
            won ? s.congrats : s.notWon,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _Digits extends StatelessWidget {
  const _Digits({required this.number});
  final String number;

  @override
  Widget build(BuildContext context) {
    final digits = number.padRight(6, ' ').split('');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((d) {
        return Container(
          width: 44,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Text(
            d.trim().isEmpty ? '·' : d,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        );
      }).toList(),
    );
  }
}
