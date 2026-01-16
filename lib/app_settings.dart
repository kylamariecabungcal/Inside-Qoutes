import 'package:flutter/material.dart';

/// Simple global settings holder using InheritedWidget.
/// Stores theme mode (dark/light) and language (en/tl).
class AppSettings extends InheritedWidget {
  const AppSettings({
    super.key,
    required this.themeMode,
    required this.languageCode,
    required this.setThemeMode,
    required this.setLanguageCode,
    required super.child,
  });

  final ThemeMode themeMode;
  final String languageCode; // 'en' or 'tl'
  final ValueChanged<ThemeMode> setThemeMode;
  final ValueChanged<String> setLanguageCode;

  static AppSettings of(BuildContext context) {
    final AppSettings? result =
        context.dependOnInheritedWidgetOfExactType<AppSettings>();
    assert(result != null, 'No AppSettings found in context');
    return result!;
  }

  bool get isDark => themeMode == ThemeMode.dark;
  bool get isTagalog => languageCode == 'tl';

  @override
  bool updateShouldNotify(AppSettings oldWidget) {
    return themeMode != oldWidget.themeMode ||
        languageCode != oldWidget.languageCode;
  }
}
