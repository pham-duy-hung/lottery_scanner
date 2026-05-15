import 'package:flutter/material.dart';
import 'package:lottery_scanner/ui/l10n/app_strings.dart';
import 'package:lottery_scanner/ui/models/scan_session.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';

class RegionSelector extends StatelessWidget {
  const RegionSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final LotteryRegion selected;
  final ValueChanged<LotteryRegion> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Row(
      children: [
        Expanded(
          child: _RegionChip(
            label: s.regionNorth,
            icon: Icons.location_city,
            isSelected: selected == LotteryRegion.mienBac,
            onTap: () => onChanged(LotteryRegion.mienBac),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RegionChip(
            label: s.regionSouth,
            icon: Icons.map,
            isSelected: selected == LotteryRegion.mienNam,
            onTap: () => onChanged(LotteryRegion.mienNam),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RegionChip(
            label: s.regionCentral,
            icon: Icons.terrain,
            isSelected: selected == LotteryRegion.mienTrung,
            onTap: () => onChanged(LotteryRegion.mienTrung),
          ),
        ),
      ],
    );
  }
}

class _RegionChip extends StatelessWidget {
  const _RegionChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.accent.withValues(alpha: 0.35) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
