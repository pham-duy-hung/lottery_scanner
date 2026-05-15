import 'package:flutter/material.dart';
import 'package:lottery_scanner/ui/state/locale_state.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key, this.onDarkBackground = false});

  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    final isVi = localeState.isVietnamese;
    final bg = onDarkBackground
        ? Colors.white.withValues(alpha: 0.15)
        : AppColors.surface;
    final selectedFg = onDarkBackground ? AppColors.primary : Colors.white;
    final unselectedFg =
        onDarkBackground ? Colors.white70 : AppColors.textSecondary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _chip('VI', isVi, localeState.setVietnamese, selectedFg, unselectedFg, onDarkBackground),
            _chip('EN', !isVi, localeState.setEnglish, selectedFg, unselectedFg, onDarkBackground),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    String label,
    bool selected,
    VoidCallback onTap,
    Color selectedFg,
    Color unselectedFg,
    bool onDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? (onDark ? Colors.white : AppColors.primary) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: selected ? selectedFg : unselectedFg,
          ),
        ),
      ),
    );
  }
}
