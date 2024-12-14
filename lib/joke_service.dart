import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class to fetch jokes from the JokeAPI and cache them.
class JokeService {
  final Dio _dio = Dio(); // HTTP client instance.
  final String baseUrl = 'https://v2.jokeapi.dev/joke'; // API base URL.

  /// Fetches a list of jokes from the API and caches them.
  Future<List<Map<String, dynamic>>> fetchAndCacheJokes() async {
    try {
      final response = await _dio.get(
        '$baseUrl/Programming',
        queryParameters: {
          'amount': 5, // Number of jokes to fetch.
          'type': 'single,twopart', // Include both types of jokes.
          'blacklistFlags': 'nsfw,religious,political,racist,sexist,explicit', // Exclude certain categories.
        },
      );

      if (response.statusCode == 200 && response.data['error'] == false) {
        final List<dynamic> jokeJson = response.data['jokes'];
        final jokes = jokeJson.cast<Map<String, dynamic>>();

        // Cache jokes locally.
        await _cacheJokes(jokes);
        return jokes;
      } else {
        throw Exception('Failed to load jokes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching jokes: $e');
    }
  }

  /// Caches jokes in shared preferences.
  Future<void> _cacheJokes(List<Map<String, dynamic>> jokes) async {
    final prefs = await SharedPreferences.getInstance();
    final jokesJson = jsonEncode(jokes);
    await prefs.setString('cached_jokes', jokesJson);
  }

  /// Retrieves cached jokes from shared preferences.
  Future<List<Map<String, dynamic>>> getCachedJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final jokesJson = prefs.getString('cached_jokes');

    if (jokesJson != null) {
      final List<dynamic> jokeList = jsonDecode(jokesJson);
      return jokeList.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
