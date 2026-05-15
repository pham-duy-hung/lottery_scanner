import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lottery_scanner/ui/l10n/app_strings.dart';
import 'package:lottery_scanner/ui/screens/home_screen.dart';
import 'package:lottery_scanner/ui/state/locale_state.dart';
import 'package:lottery_scanner/ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LotteryScannerApp());
}

class LotteryScannerApp extends StatelessWidget {
  const LotteryScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeState,
      builder: (context, _) {
        final strings = AppStrings(localeState.locale);
        return MaterialApp(
          title: strings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: localeState.locale,
          supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => AppStringsScope(
            strings: AppStrings(localeState.locale),
            child: child ?? const SizedBox.shrink(),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
