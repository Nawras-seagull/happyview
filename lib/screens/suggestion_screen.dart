import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';

// Add this to your main.dart or where you initialize Firebase
Future<void> initializeFirebase() async {
  await Firebase.initializeApp();
}

/// Service class to handle Firestore operations
class SuggestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Submit a suggestion to Firestore as an anonymous user
  ///
  /// [content] is required and must be 1-1000 characters
  /// [email] is optional for contact information
  /// [category] is optional for categorizing the suggestion
  Future<DocumentReference> submitSuggestion({
    required String content,
    String? email,
    String? category,
  }) async {
    // Validate content length client-side to match security rules
    if (content.isEmpty || content.length > 200) {
      throw Exception(
          "Suggestion content must be between 1 and 200 characters");
    }

    // Create suggestion data
    final Map<String, dynamic> suggestionData = {
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Add optional fields if they exist
    if (email != null && email.isNotEmpty) {
      suggestionData['email'] = email;
    }
    if (category != null && category.isNotEmpty) {
      suggestionData['category'] = category;
    }

    try {
      // Add the document to Firestore
      final docRef =
          await _firestore.collection('suggestions').add(suggestionData);
      if (kDebugMode) {
        print("Suggestion submitted with ID: ${docRef.id}");
      }
      return docRef;
    } catch (error) {
      if (kDebugMode) {
        print("Error submitting suggestion: $error");
      }
      throw Exception("Failed to submit suggestion: $error");
    }
  }
}

/// Example widget for submitting suggestions
class SuggestionForm extends StatefulWidget {
  const SuggestionForm({super.key});

  @override
  SuggestionFormState createState() => SuggestionFormState();
}

class SuggestionFormState extends State<SuggestionForm> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _emailController = TextEditingController();
  final _categoryController = TextEditingController();
  final SuggestionService _suggestionService = SuggestionService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _emailController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final localizations = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await _suggestionService.submitSuggestion(
          content: _contentController.text,
          email: _emailController.text,
          category: _categoryController.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.suggestion_message)),
        );

        // Clear the form
        _contentController.clear();
        _emailController.clear();
        _categoryController.clear();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: localizations.suggestionTitle, // Localized label
                border: const OutlineInputBorder(),
                hintText:
                    localizations.suggestion_placeholder, // Localized hint
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations
                      .suggestionValidationEmpty; // Localized validation
                }
                if (value.length > 1000) {
                  return localizations
                      .suggestionValidationLength; // Localized validation
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: localizations.emailLabel, // Localized label
                border: const OutlineInputBorder(),
                hintText: localizations.emailHint, // Localized hint
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: localizations.categoryLabel, // Localized label
                border: const OutlineInputBorder(),
                hintText: localizations.categoryHint, // Localized hint
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : Text(localizations.submit), // Localized button text
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage in your app
class SuggestionScreen extends StatelessWidget {
  const SuggestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.suggestionTitle), // Localized title
      ),
      body: SafeArea(
        // <-- Add SafeArea here
        child: const SingleChildScrollView(
          child: SuggestionForm(),
        ),
      ), // <-- End SafeArea
    );
  }
}
