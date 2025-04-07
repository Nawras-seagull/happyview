import 'package:flutter/material.dart';
import 'package:happy_view/screens/suggestion_screen.dart';
import 'package:happy_view/screens/privacy_policy_screen.dart'; // Import the new screen
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          // Language Settings (existing code)
          ListTile(
            title: Text(localizations.changeLanguage),
            subtitle: Text(_getLanguageName(languageProvider.currentLocale.languageCode)),
            trailing: const Icon(Icons.language),
            onTap: () {
              _showLanguageDialog(context, languageProvider);
            },
          ),
          const Divider(),

          // Suggestion Screen (existing code)
          ListTile(
            title: Text(localizations.suggestionTitle),
            subtitle: Text(localizations.suggestion_subtitle),
            trailing: const Icon(Icons.lightbulb_outline),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SuggestionScreen()),
              );
            },
          ),
          const Divider(),

          // Privacy Policy (new addition)
          ListTile(

            title: Text(AppLocalizations.of(context)!.privacyPolicyTitle
),
            subtitle: Text(AppLocalizations.of(context)!.privacyPolicySubTitle),
            trailing: Icon(Icons.policy),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Existing helper methods remain the same...
  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'tr':
        return 'Türkçe';
      default:
        return 'English';
    }
  }
  
  void _showLanguageDialog(BuildContext context, LanguageProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, provider, 'en', 'English'),
              _buildLanguageOption(context, provider, 'ar', 'العربية'),
              _buildLanguageOption(context, provider, 'tr', 'Türkçe'),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLanguageOption(
    BuildContext context, 
    LanguageProvider provider, 
    String languageCode, 
    String languageName
  ) {
    final isSelected = provider.currentLocale.languageCode == languageCode;
    
    return ListTile(
      leading: isSelected ? Icon(Icons.check, color: Colors.blue) : SizedBox(width: 24),
      title: Text(languageName),
      onTap: () {
        provider.changeLanguage(languageCode);
        Navigator.pop(context);
      },
    );
  }
}