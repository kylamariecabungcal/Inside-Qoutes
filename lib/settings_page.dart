import 'package:flutter/material.dart';
import 'app_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.of(context);
    final isDark = settings.isDark;
    final isTagalog = settings.isTagalog;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          isTagalog ? 'Mga Setting' : 'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          isTagalog ? 'Wika' : 'Language',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        RadioListTile<String>(
          title: const Text('English'),
          value: 'en',
          groupValue: settings.languageCode,
          onChanged: (value) {
            if (value != null) {
              settings.setLanguageCode(value);
            }
          },
        ),
        RadioListTile<String>(
          title: const Text('Tagalog'),
          value: 'tl',
          groupValue: settings.languageCode,
          onChanged: (value) {
            if (value != null) {
              settings.setLanguageCode(value);
            }
          },
        ),
        const SizedBox(height: 24),
        Text(
          isTagalog ? 'Tema' : 'Theme',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(isTagalog ? 'Dark mode' : 'Dark mode'),
          subtitle: Text(
            isTagalog
                ? (isDark ? 'Naka-dark mode' : 'Naka-light mode')
                : (isDark ? 'Dark theme is on' : 'Light theme is on'),
          ),
          value: isDark,
          onChanged: (value) {
            settings
                .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
          },
        ),
      ],
    );
  }
}


