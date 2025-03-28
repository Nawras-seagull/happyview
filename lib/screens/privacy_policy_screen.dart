import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _launchPrivacyPolicy() async {
    final Uri privacyPolicyUrl =
        Uri.parse('https://your-website.com/privacy-policy');
    if (!await launchUrl(privacyPolicyUrl)) {
      throw Exception('Could not launch privacy policy');
    }
  }

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
      body: Center(
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
    );
  }
}

// Example of adding to app settings or drawer
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

// Firebase Analytics Opt-Out Example
class AnalyticsOptOut extends StatefulWidget {
  const AnalyticsOptOut({super.key});

  @override
  AnalyticsOptOutState createState() => AnalyticsOptOutState();
}

class AnalyticsOptOutState extends State<AnalyticsOptOut> {
  bool _analyticsEnabled = true;

  void _toggleAnalytics(bool value) {
    setState(() {
      _analyticsEnabled = value;
      // Implement Firebase analytics enable/disable logic
      // Example:
      // FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text('Enable Analytics'),
      subtitle: Text('Optional data collection for app improvement'),
      value: _analyticsEnabled,
      onChanged: _toggleAnalytics,
    );
  }
}
