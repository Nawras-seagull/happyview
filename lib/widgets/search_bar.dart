import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _onSubmit() async {
    final query = _controller.text.trim();

    if (query.isNotEmpty) {
      if (!_isSafeSearch(query)) {
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

          // Pass the results to the parent widget via the onSearch callback
          widget.onSearch(results);

          // Clear the text field after the search
          _controller.clear();
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching images: $e');
      }
    }
  }

  bool _isSafeSearch(String query) {
    final List<String> blockedWords = [
      'badword1',
      'badword2',
      'violence',
      'drugs',
      'blood',
      'sex',
      'hate',
      'kill',
      'gun',
      'weapon',
      'inappropriate',
      // Add more as needed
    ];

    final lowerQuery = query.toLowerCase();
    return !blockedWords.any((word) => lowerQuery.contains(word));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0), // Add left and right padding
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
                onPressed:
                    _onSubmit, // Trigger the search when the icon is pressed
              ),
            ),
            onSubmitted: (_) =>
                _onSubmit(), // Trigger the search when "Enter" is pressed
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
