import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.privacyPolicyTitle),
          content: SingleChildScrollView(
            child: Text(
              AppLocalizations.of(context)!.privacyPolicyContent,
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.privacyPolicyTitle),
      ),
      body: SafeArea(
        // <-- Add SafeArea here
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _showPrivacyPolicyDialog(context),
                child: Text(AppLocalizations.of(context)!.viewPrivacyPolicy),
              ),
              SizedBox(height: 20),
              /*   ElevatedButton(
                onPressed: _launchPrivacyPolicy,
                child:
                    Text(AppLocalizations.of(context)!.openPrivacyPolicyOnline),
              ), */
            ],
          ),
        ),
      ), // <-- End SafeArea
    );
  }
}

/* // Example of adding to app settings or drawer
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.policy),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          // Other settings...
        ],
      ),
    );
  }
}

 */
