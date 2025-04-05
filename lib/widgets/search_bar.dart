import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happy_view/services/profanity_filter.dart';
import 'package:happy_view/services/unsplash_service.dart.dart';
import 'package:http/http.dart' as http;

class FunSearchBar extends StatefulWidget {
  final Function(List<dynamic>) onSearch;

  const FunSearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  _FunSearchBarState createState() => _FunSearchBarState();
}

class _FunSearchBarState extends State<FunSearchBar> {
  final TextEditingController _controller = TextEditingController();
  //List<String> _blockedWords = [];

  @override
  void initState() {
    super.initState();

    // Load bad words from multiple JSON files
 profanityFilter.loadBadWords('assets/profanity/en.json').then((_) {
    print('Loaded en.json');
  });
  profanityFilter.loadBadWords('assets/profanity/ar.json').then((_) {
    print('Loaded ar.json');
  });
  profanityFilter.loadBadWords('assets/profanity/tr.json').then((_) {
    print('Loaded tr.json');
  });

  }

/* 
  Future<void> _loadBlockedWords() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/blocked_words.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      setState(() {
        _blockedWords = List<String>.from(data['blocked_words'] ?? []);
      });
    } catch (e) {
      print('Failed to load blocked words: $e');
    }
  }
 */
  Future<void> _onSubmit() async {
    final query = _controller.text.trim();

    if (query.isNotEmpty) {
      /*  if (!_isSafeSearch(query)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a safe search term.')),
        );
        return;
      } */
      if (profanityFilter.containsBadWords(query)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a safe search term.')),
        );
        return;
      }

      HapticFeedback.lightImpact(); // Small vibration effect

      final url =
          'https://api.unsplash.com/search/photos?query=$query&client_id=${UnsplashService.accessKey}&per_page=20';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final results = data['results'] as List<dynamic>;

          widget.onSearch(results);
          _controller.clear(); // Clear after search
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching images: $e');
      }
    }
  }

/*   bool _isSafeSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return !_blockedWords.any((word) => lowerQuery.contains(word));
  } */

  final profanityFilter = ProfanityFilter();

  void checkMessage(String input) {
    if (profanityFilter.containsBadWords(input)) {
      print('Profanity detected!');
    } else {
      print('Clean!');
    }

    print('Censored: ${profanityFilter.censor(input)}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: _onSubmit,
              ),
            ),
            onSubmitted: (_) => _onSubmit(),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '🔒 Safe search is ON',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
