import 'package:flutter/material.dart';
import 'package:lottery_scanner/ui/state/locale_state.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';

/// Toggle VI / EN với vòng trắng trượt (giống thiết kế trên AppBar đỏ).
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key, this.onDarkBackground = false});

  final bool onDarkBackground;

  static const _width = 88.0;
  static const _height = 34.0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeState,
      builder: (context, _) {
        final isVi = localeState.isVietnamese;
        return GestureDetector(
          onTap: () {
            if (isVi) {
              localeState.setEnglish();
            } else {
              localeState.setVietnamese();
            }
          },
          child: Container(
            width: _width,
            height: _height,
            decoration: BoxDecoration(
              color: onDarkBackground
                  ? Colors.white.withValues(alpha: 0.18)
                  : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(_height / 2),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  alignment: isVi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      width: _width / 2 - 3,
                      height: _height - 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _Label(
                        text: 'VI',
                        selected: isVi,
                        onDark: onDarkBackground,
                        onTap: localeState.setVietnamese,
                      ),
                    ),
                    Expanded(
                      child: _Label(
                        text: 'EN',
                        selected: !isVi,
                        onDark: onDarkBackground,
                        onTap: localeState.setEnglish,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.text,
    required this.selected,
    required this.onDark,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool onDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = onDark ? AppColors.primary : Colors.white;
    final inactiveColor = onDark ? Colors.white : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? activeColor : inactiveColor.withValues(alpha: onDark ? 0.85 : 1),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
