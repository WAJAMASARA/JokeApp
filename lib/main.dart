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
      theme: ThemeData(primarySwatch: Colors.deepPurple),
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
  final JokeService _jokeService = JokeService();
  List<Map<String, dynamic>> _jokes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCachedJokes();
  }

  /// Loads cached jokes and displays them.
  Future<void> _loadCachedJokes() async {
    final cachedJokes = await _jokeService.getCachedJokes();
    setState(() => _jokes = cachedJokes);
  }

  /// Fetches jokes from the API and updates the UI.
  Future<void> _fetchJokes() async {
    setState(() => _isLoading = true);
    try {
      final jokes = await _jokeService.fetchAndCacheJokes();
      setState(() => _jokes = jokes);
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
        title: const Text('Joke App'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _fetchJokes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text('Fetch Jokes'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildJokeList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a list of jokes to display with enhanced UI.
  Widget _buildJokeList() {
    if (_jokes.isEmpty) {
      return const Center(
        child: Text('No jokes available.'),
      );
    }

    return ListView.builder(
      itemCount: _jokes.length,
      itemBuilder: (context, index) {
        final joke = _jokes[index];
        final isTwoPart = joke['type'] == 'twopart';
        final jokeText = isTwoPart
            ? '${joke['setup']}\n\n${joke['delivery']}'
            : joke['joke'];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          child: InkWell(
            onTap: () {
              // Optional: Add interaction, like showing a detailed view.
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isTwoPart)
                    Text(
                      joke['setup'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  if (isTwoPart)
                    const SizedBox(height: 8),
                  Text(
                    isTwoPart ? joke['delivery'] ?? '' : jokeText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
