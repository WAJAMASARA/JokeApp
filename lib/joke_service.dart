import 'package:dio/dio.dart';

/// Service class to fetch jokes from the JokeAPI.
class JokeService {
  final Dio _dio = Dio(); // HTTP client instance.
  final String baseUrl = 'https://v2.jokeapi.dev/joke'; // API base URL.

  /// Fetches a list of jokes from the API.
  Future<List<Map<String, dynamic>>> fetchJokesRaw() async {
    try {
      // Send GET request with query parameters.
      final response = await _dio.get(
        '$baseUrl/programming', // Endpoint for programming jokes.
        queryParameters: {
          'amount': 3, // Number of jokes to fetch.
          'type': 'single,twopart', // Joke types to include.
          'blacklistFlag': 'nsfw,religious,political,racist,sexist,explicit', // Exclude certain categories.
        },
      );

      // Check for a successful response.
      if (response.statusCode == 200) {
        // Check if the API returned an error.
        if (response.data['error'] == true) {
          throw Exception(response.data['message'] ?? 'Failed to fetch jokes');
        }

        // Extract and return jokes as a list of maps.
        final List<dynamic> jokeJson = response.data['jokes'];
        return jokeJson.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load jokes: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors and rethrow.
      throw Exception('Error fetching jokes: $e');
    }
  }
}
