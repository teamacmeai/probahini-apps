import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_localizations.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('settings'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: Text(localizations.translate('dark_mode')),
                subtitle: Text('Toggle dark/light theme'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              );
            },
          ),
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return ListTile(
                title: Text(localizations.translate('language')),
                subtitle: Text(languageProvider.isBangla ? 'বাংলা' : 'English'),
                leading: const Icon(Icons.language),
                trailing: Switch(
                  value: languageProvider.isBangla,
                  onChanged: (value) {
                    languageProvider.toggleLanguage();
                  },
                ),
                onTap: () {
                  languageProvider.toggleLanguage();
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
