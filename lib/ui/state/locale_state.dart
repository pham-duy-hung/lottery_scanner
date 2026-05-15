import 'package:flutter/material.dart';

class LocaleState extends ChangeNotifier {
  Locale _locale = const Locale('vi', 'VN');

  Locale get locale => _locale;
  bool get isVietnamese => _locale.languageCode == 'vi';

  void setVietnamese() => _set(const Locale('vi', 'VN'));
  void setEnglish() => _set(const Locale('en', 'US'));

  void _set(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }
}

final localeState = LocaleState();
