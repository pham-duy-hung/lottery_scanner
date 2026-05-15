import 'package:flutter/material.dart';
import 'package:lottery_scanner/ui/l10n/app_strings.dart';
import 'package:lottery_scanner/ui/models/lottery_draw.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';
class ProvinceResultsList extends StatelessWidget {
  const ProvinceResultsList({
    super.key,
    required this.draws,
    this.matches = const [],
    this.highlightProvince,
    this.initiallyExpanded = false,
  });

  final List<ProvinceDraw> draws;
  final List<PrizeMatch> matches;
  final String? highlightProvince;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.allProvincesToday(draws.length),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          s.allProvincesHint,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 12),
        ...draws.map((draw) {
          final provinceMatches =
              matches.where((m) => m.province == draw.province).toList();
          final hasWin = provinceMatches.isNotEmpty;
          final isSelected = highlightProvince == draw.province;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: initiallyExpanded || isSelected || hasWin,
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                collapsedBackgroundColor: AppColors.surface,
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                collapsedShape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hasWin
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasWin ? Icons.emoji_events : Icons.location_on,
                    color: hasWin ? AppColors.success : AppColors.primary,
                    size: 22,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        draw.province,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.yourProvince,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    if (hasWin) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    ],
                  ],
                ),
                subtitle: hasWin
                    ? Text(
                        s.wonAtProvince(draw.province),
                        style: const TextStyle(color: AppColors.success, fontSize: 12),
                      )
                    : null,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      children: draw.prizes.map((prize) {
                        final matched = provinceMatches.any((m) => m.prizeKey == prize.key);
                        return _PrizeRow(
                          label: s.prizeLabel(prize.key),
                          numbers: prize.numbers,
                          amount: prize.amount,
                          highlighted: matched,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PrizeRow extends StatelessWidget {
  const _PrizeRow({
    required this.label,
    required this.numbers,
    this.amount,
    this.highlighted = false,
  });

  final String label;
  final List<String> numbers;
  final String? amount;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: highlighted
            ? Border.all(color: AppColors.success.withValues(alpha: 0.4))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: highlighted ? AppColors.success : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: numbers
                  .map(
                    (n) => Text(
                      n,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: highlighted ? AppColors.primary : AppColors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (amount != null)
            Text(
              amount!,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}
