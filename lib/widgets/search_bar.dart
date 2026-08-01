import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happy_view/services/backend_config.dart';
import 'package:happy_view/services/profanity_filter.dart';
import 'package:http/http.dart' as http;
import '../l10n/app_localizations.dart';

class FunSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const FunSearchBar({super.key, required this.onSearch});

  @override
  FunSearchBarState createState() => FunSearchBarState();
}

class FunSearchBarState extends State<FunSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override 
  void initState() {
    super.initState();

    // Load bad words from JSON assets
    profanityFilter.loadBadWords('assets/profanity/en.json');
  }

  Future<void> _onSubmit() async {
    final query = _controller.text.trim();
    final localizations = AppLocalizations.of(context)!;
    final translatedtitle = localizations.translated;

    if (query.isNotEmpty) {
      // Check for profanity in the original query
      if (profanityFilter.containsBadWords(query)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.safeSearchText)),
        );
        return;
      }

      HapticFeedback.lightImpact(); // Small vibration effect

      // Translate query to English if needed, via the backend proxy
      String englishQuery = query;
      try {
        final translateUrl = Uri.parse(
            '${BackendConfig.baseUrl}/api/translate?q=${Uri.encodeQueryComponent(query)}&to=en');
        final translateResponse = await http.get(translateUrl);
        if (translateResponse.statusCode == 200) {
          final decoded =
              json.decode(translateResponse.body) as Map<String, dynamic>;
          englishQuery = decoded['translatedText'] as String? ?? query;
        }

        if (kDebugMode) {
          print('Original query: "$query"');
          print('Translated query: "$englishQuery"');
        }

        if (englishQuery != query) {
          if (!mounted) return;
          if (profanityFilter.containsBadWords(englishQuery)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.safeSearch)),
            );
            return;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"$translatedtitle" "$query" → "$englishQuery"'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Translation error: $e');
        }
      }

      // Prepare query for URL
      String cleanQuery = englishQuery.trim();
      if (cleanQuery.length > 100) {
        cleanQuery = cleanQuery.substring(0, 100);
      }

      // Construct your new backend proxy URL
      final encodedQuery = Uri.encodeComponent(cleanQuery);
      final url = '${BackendConfig.baseUrl}/api/search?query=$encodedQuery&lang=en';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          widget.onSearch(englishQuery);
          _controller.clear(); // Clear search bar after successful submit
        } else {
          if (kDebugMode) {
            print('Proxy Server Error: ${response.statusCode}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching images via proxy: $e');
        }
      }
    }
  }

  final profanityFilter = ProfanityFilter('');

  void checkMessage(String input) {
    if (profanityFilter.containsBadWords(input)) {
      if (kDebugMode) {
        print('Profanity detected!');
      }
    } else {
      if (kDebugMode) {
        print('Clean!');
      }
    }

    if (kDebugMode) {
      print('Censored: ${profanityFilter.censor(input)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: localizations.search,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _onSubmit,
              ),
            ),
            onSubmitted: (_) => _onSubmit(),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          localizations.safeSearchEnabled,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }
}