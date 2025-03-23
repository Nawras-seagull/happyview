import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // Make the state class public by removing the underscore
  HomeScreenState createState() => HomeScreenState();
}

// Changed from _HomeScreenState to HomeScreenState (public)
class HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.hello,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                localizations.welcome,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Text(
                localizations.greeting('User'),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                localizations.itemCount(_counter),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                localizations.currentDate(DateTime.now()),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Item'),
                onPressed: _incrementCounter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}