import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  final List<dynamic> searchResults;

  const SearchScreen({Key? key, required this.searchResults}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: searchResults.isEmpty
          ? const Center(
              child: Text(
                'No results found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
              ),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final image = searchResults[index];
                return Image.network(
                  image['urls']['small'], // Display the image
                  fit: BoxFit.cover,
                );
              },
            ),
    );
  }
}
