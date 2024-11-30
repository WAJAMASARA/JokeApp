import 'package:flutter/material.dart';
import 'joke_service.dart';

void main() => runApp(const MyApp());

/// Entry point of the app, wraps the JokeListPage in a MaterialApp.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joke App',
      theme: ThemeData(primarySwatch: Colors.deepPurple), // Updated color scheme
      home: const JokeListPage(),
    );
  }
}

/// Main page of the app to display and fetch jokes.
class JokeListPage extends StatefulWidget {
  const JokeListPage({super.key});

  @override
  _JokeListPageState createState() => _JokeListPageState();
}

class _JokeListPageState extends State<JokeListPage> {
  final JokeService _jokeService = JokeService(); // Handles joke fetching logic
  List<Map<String, dynamic>> _jokesRaw = []; // List to store fetched jokes
  bool _isLoading = false; // Loading indicator

  /// Fetches jokes from the service and updates the UI.
  Future<void> _fetchJokes() async {
    setState(() => _isLoading = true);
    try {
      _jokesRaw = await _jokeService.fetchJokesRaw();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch jokes: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Joke App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple, // Unified color scheme
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade100, Colors.white], // Smooth gradient
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Text
              const Text(
                'Welcome to the Joke App!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  shadows: [Shadow(color: Colors.white, blurRadius: 2)],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Instructions Text
              const Text(
                'Click the button to fetch random jokes!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Fetch Jokes Button
              ElevatedButton(
                onPressed: _fetchJokes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Fetch Jokes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Joke List or Loading Indicator
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildJokeList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a list of jokes to display.
  Widget _buildJokeList() {
    if (_jokesRaw.isEmpty) {
      return const Center(
        child: Text(
          'No jokes fetched yet.',
          style: TextStyle(fontSize: 18, color: Colors.deepPurple),
        ),
      );
    }

    return ListView.builder(
      itemCount: _jokesRaw.length,
      itemBuilder: (context, index) {
        final joke = _jokesRaw[index];

        // Render joke based on its type.
        final isTwoPart = joke['type'] == 'twopart';
        final jokeText = isTwoPart
            ? '${joke['setup']}\n\n${joke['delivery']}' // Two-part joke
            : joke['joke']; // Single-line joke

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              jokeText,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }
}
