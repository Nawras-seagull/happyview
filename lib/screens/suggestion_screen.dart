import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SuggestionScreen extends StatefulWidget {
  const SuggestionScreen({super.key});

  @override
  SuggestionScreenState createState() => SuggestionScreenState();
}

class SuggestionScreenState extends State<SuggestionScreen> {
  final TextEditingController _suggestionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSubmitting = false;

  // Submit suggestion to Firestore
  Future<void> _submitSuggestion() async {
    
    if (_suggestionController.text.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _firestore.collection('suggestions').add({
        'suggestion': _suggestionController.text,
        'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
       'retentionPeriod': '50 days' // Add your retention policy

      });
      _suggestionController.clear(); // Clear the text field
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thank you for your suggestion!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting suggestion: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
            final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.suggestionTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _suggestionController,
              decoration: InputDecoration(
                hintText: localizations.suggestion_placeholder,
                border: OutlineInputBorder(),
              ),
              maxLines: 5, // Allow multiple lines for suggestions
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitSuggestion,
              child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(localizations.submit),
            ),
          ],
        ),
      ),
    );
  }
}