import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happy_view/screens/home.dart';
import 'package:happy_view/services/pixabay_services.dart';
import 'package:happy_view/services/profanity_filter.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart'; // A popular Flutter translation package
import '../l10n/app_localizations.dart';
/////////////
class FunSearchBar extends StatefulWidget {
  final Function( String) onSearch;

  const FunSearchBar({super.key, required this.onSearch});

  @override
  FunSearchBarState createState() => FunSearchBarState();
}

class FunSearchBarState extends State<FunSearchBar> {
  final TextEditingController _controller = TextEditingController();
  //List<String> _blockedWords = [];
  final GoogleTranslator translator = GoogleTranslator();

  @override 
  void initState() {
    super.initState();

    // Load bad words from multiple JSON files
    profanityFilter.loadBadWords('assets/profanity/en.json');
    // Add more languages as needed
    // profanityFilter.loadBadWords('assets/profanity/es.json');
    // profanityFilter.loadBadWords('assets/profanity/fr.json');
    // _loadBlockedWords();
  }

  Future<void> _onSubmit() async {
    final query = _controller.text.trim();
    final localizations = AppLocalizations.of(context)!;
    final translatedtitle = localizations.translated;

    if (query.isNotEmpty) {
      /*  if (!_isSafeSearch(query)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a safe search term.')),
        );
        return;
      } */
      // Check for profanity
      if (profanityFilter.containsBadWords(query)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.safeSearchText)),
        );
        return;
      }

      HapticFeedback.lightImpact(); // Small vibration effect
      // Translate query to English if not already in English
      String englishQuery = query;
      try {
        // Translate to English
        var translation = await translator.translate(query, to: 'en');
        englishQuery = translation.text;

        if (kDebugMode) {
          print('Original query: "$query"');
        }
        if (kDebugMode) {
          print('Translated query: "$englishQuery"');
        }

        // Show translation notification
        if (englishQuery != query) {
          if (!mounted) return; // Check if the widget is still mounted
          if (profanityFilter.containsBadWords(englishQuery)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.safeSearch)),
            );
            return;
          } else {
            // Show translation notification
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"$translatedtitle" "$query" → "$englishQuery"'),
                duration: Duration(seconds: 2),
              ),
            );
          }
       
        }
      } catch (e) {
        if (kDebugMode) {
          print('Translation error: $e');
        }
        // Fall back to original query if translation fails
      }
      // Properly encode the URL parameters
   //   final encodedQuery = Uri.encodeComponent(englishQuery);
    /*   final url =
      //use pixbay api url
       'https://pixabay.com/api/?key=${PixabayService.accessKey}&q=$encodedQuery&image_type=photo&safesearch=true&per_page=20';
          //'https://api.unsplash.com/search/photos?query=$encodedQuery&client_id=${UnsplashService.accessKey}&per_page=20';
 */
String plusQuery = englishQuery.trim().replaceAll(RegExp(r'\s+'), '+');

String baseUrl = 'https://pixabay.com/api/?key=${PixabayService.accessKey}&q=';
String suffixUrl = '&image_type=photo&safesearch=true&per_page=20';



// Cut the query only if it's too long
if (plusQuery.length > 100) {
  plusQuery = plusQuery.substring(0, 100);
}

// Now encode safely
final encodedQuery = Uri.encodeComponent(plusQuery);
final url = '$baseUrl$encodedQuery$suffixUrl';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = await compute(parseJson, response.body);

       //   final data = json.decode(response.body) as Map<String, dynamic>;
        //  final results = data['hits'] as List<dynamic>;

          widget.onSearch( englishQuery);
          _controller.clear(); // Clear after search
        } else {
          if (kDebugMode) {
            print('Error: ${response.statusCode}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching images: $e');
        }
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
          localizations.safeSearchEnabled,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }
}

