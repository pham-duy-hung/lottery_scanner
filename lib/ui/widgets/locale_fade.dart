import 'package:flutter/material.dart';
import 'package:lottery_scanner/ui/state/locale_state.dart';

/// Fade nhẹ khi đổi ngôn ngữ.
class LocaleFade extends StatelessWidget {
  const LocaleFade({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeState,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(localeState.locale.languageCode),
            child: child,
          ),
        );
      },
    );
  }
}
