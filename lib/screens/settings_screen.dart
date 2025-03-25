import 'package:flutter/material.dart';
import 'package:happy_view/screens/suggestion_screen.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        ListTile(
          title:  Text(localizations.changeLanguage),
          subtitle: Text(_getLanguageName(languageProvider.currentLocale.languageCode)),
          trailing: const Icon(Icons.language),
          onTap: () {
            _showLanguageDialog(context, languageProvider);
          },
        ),
        const Divider(),
        ListTile(
          title: Text(localizations.suggestionTitle),
          subtitle:  Text(localizations.suggestion_subtitle),
          trailing: const Icon(Icons.lightbulb_outline),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SuggestionScreen()),
            );
          },
        ),
        const Divider(),
      ],
    ),
  );
}
  // Helper method to get language name from code
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
  
  // Show language selection dialog
  void _showLanguageDialog(BuildContext context, LanguageProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
       //   title: Text(AppLocalizations.of(context)!.changeLanguage),
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
  
  // Build a language option for the dialog
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