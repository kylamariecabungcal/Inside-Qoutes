import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';
import '../app_config.dart';

/// REST API Backend Service
///
/// Connects to a Node.js/Express backend via HTTP REST API
class RestApiService {
  static RestApiService? _instance;
  static RestApiService get instance => _instance ??= RestApiService._();

  RestApiService._() {
    // Log on initialization to verify correct URL is being used
    print('🔧 RestApiService initialized with baseUrl: $baseUrl');
    print(
        '📱 Testing mode: ${AppConfig.useLocalhost ? "BROWSER (localhost)" : "PHONE (10.0.2.165)"}');
  }

  // Backend API base URL - automatically selected based on AppConfig
  late final String baseUrl = AppConfig.getBaseUrl();

  String? _userId;
  String? _sessionToken;

  Future<void> initialize() async {
    // Load saved session if exists
    final savedUserId = await _loadSavedUserId();
    final savedToken = await _loadSavedToken();
    if (savedUserId != null && savedToken != null) {
      _userId = savedUserId;
      _sessionToken = savedToken;
    }
  }

  String? get currentUserId => _userId;
  bool get isLoggedIn => _userId != null && _sessionToken != null;

  Future<bool> signInAnonymously() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/anonymous'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _userId = data['userId'] as String?;
        _sessionToken = data['token'] as String?;

        if (_userId != null) {
          await _saveUserId(_userId!);
          if (_sessionToken != null) {
            await _saveToken(_sessionToken!);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    if (_sessionToken != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_sessionToken',
          },
        );
      } catch (e) {
        print('Error signing out: $e');
      }
    }
    _userId = null;
    _sessionToken = null;
    await _clearSavedData();
  }

  // User Settings
  Future<void> saveUserSettings({
    required String themeMode,
    required String languageCode,
  }) async {
    if (!isLoggedIn) return;
    try {
      await http.put(
        Uri.parse('$baseUrl/users/$_userId/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_sessionToken',
        },
        body: json.encode({
          'themeMode': themeMode,
          'languageCode': languageCode,
        }),
      );
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserSettings() async {
    if (!isLoggedIn) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$_userId/settings'),
        headers: {
          'Authorization': 'Bearer $_sessionToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting settings: $e');
      return null;
    }
  }

  // Quiz Scores
  Future<void> saveQuizScore({
    required String quizType,
    required String difficulty,
    required int score,
    required int totalQuestions,
  }) async {
    if (!isLoggedIn) return;
    try {
      await http.post(
        Uri.parse('$baseUrl/users/$_userId/quiz-scores'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_sessionToken',
        },
        body: json.encode({
          'quizType': quizType,
          'difficulty': difficulty,
          'score': score,
          'totalQuestions': totalQuestions,
          'percentage': (score / totalQuestions * 100).round(),
        }),
      );
    } catch (e) {
      print('Error saving quiz score: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getQuizScores() async {
    if (!isLoggedIn) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$_userId/quiz-scores'),
        headers: {
          'Authorization': 'Bearer $_sessionToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      print('Error getting quiz scores: $e');
      return [];
    }
  }

  // Favorites
  Future<void> addFavorite({
    required String type,
    required String content,
    String? reference,
  }) async {
    if (!isLoggedIn) {
      final signedIn = await signInAnonymously();
      if (!signedIn) {
        print('Cannot add favorite: user not signed in');
        throw Exception('Not signed in');
      }
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$_userId/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_sessionToken',
        },
        body: json.encode({
          'type': type,
          'content': content,
          'reference': reference,
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        print(
            'Error adding favorite: status=${response.statusCode}, body=${response.body}');
        throw HttpException('Failed to add favorite: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    if (!isLoggedIn) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$_userId/favorites'),
        headers: {
          'Authorization': 'Bearer $_sessionToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  /// Remove a favorite by id. Returns true on success, false otherwise.
  Future<bool> removeFavorite(String favoriteId) async {
    if (!isLoggedIn) return false;
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$_userId/favorites/$favoriteId'),
        headers: {
          'Authorization': 'Bearer $_sessionToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }

      print(
          'Error removing favorite: status=${response.statusCode}, body=${response.body}');
      return false;
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }

  // User Profile
  Future<void> updateProfile({
    String? name,
    String? email,
  }) async {
    if (!isLoggedIn) return;
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;

      await http.put(
        Uri.parse('$baseUrl/users/$_userId/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_sessionToken',
        },
        body: json.encode(data),
      );
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    if (!isLoggedIn) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$_userId/profile'),
        headers: {
          'Authorization': 'Bearer $_sessionToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  // Local storage helpers
  Future<void> _saveUserId(String userId) async {
    await LocalStorageService.saveUserId(userId);
  }

  Future<String?> _loadSavedUserId() async {
    return LocalStorageService.getUserId();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await LocalStorageService.initialize();
    await prefs.setString('sessionToken', token);
  }

  Future<String?> _loadSavedToken() async {
    final prefs = await LocalStorageService.initialize();
    return prefs.getString('sessionToken');
  }

  Future<void> _clearSavedData() async {
    final prefs = await LocalStorageService.initialize();
    await prefs.remove('userId');
    await prefs.remove('sessionToken');
  }

  // Get advice based on emotion/feeling
  Future<Map<String, dynamic>?> getAdvice({
    required String text,
    required String language,
  }) async {
    try {
      print('═══════════════════════════════════════');
      print('🌐 Calling advice API');
      print('   URL: $baseUrl/advice');
      print('   Text: "$text"');
      print('   Language: $language');
      print('═══════════════════════════════════════');

      final response = await http
          .post(
        Uri.parse('$baseUrl/advice'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'text': text,
          'language': language,
        }),
      )
          .timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          print('HTTP request timed out');
          throw TimeoutException('Request timed out');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body) as Map<String, dynamic>;
        print('Successfully got advice: ${result['advice']}');
        return result;
      } else {
        print('Error: Status code ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('═══════════════════════════════════════');
      print('❌ Error getting advice: $e');
      print('   Error type: ${e.runtimeType}');
      print('   Attempted URL: $baseUrl/advice');
      if (e is TimeoutException) {
        print(
            '   ⚠️  Request timed out - backend might be slow or unreachable');
        print('   💡 Check if backend server is running on port 3000');
      } else if (e is SocketException ||
          e.toString().contains('Failed host lookup')) {
        print('   ⚠️  Network error - cannot reach backend at $baseUrl');
        print('   💡 Make sure:');
        print('      1. Backend server is running (node server.js)');
        print('      2. Phone and computer are on same Wi-Fi network');
        print('      3. IP address is correct: 10.0.2.165');
        print('      4. Windows Firewall allows port 3000');
      } else {
        print('   ⚠️  Unexpected error occurred');
      }
      print('═══════════════════════════════════════');
      rethrow; // Re-throw so caller can handle it
    }
  }

  // Test connection to backend
  Future<bool> testConnection() async {
    try {
      print('🧪 Testing connection to: $baseUrl/health');
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('✅ Connection test successful!');
        print('   Response: ${response.body}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  // Get Bible verse quiz questions (AI-generated)
  Future<Map<String, dynamic>?> getBibleVerseQuiz({
    required String difficulty,
    required int count,
    required String language,
  }) async {
    try {
      print(
          '📖 Requesting Bible verse quiz: difficulty=$difficulty, count=$count');

      final response = await http
          .post(
        Uri.parse('$baseUrl/quiz/bible-verse'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'difficulty': difficulty,
          'count': count,
          'language': language,
        }),
      )
          .timeout(
        const Duration(seconds: 60), // Increased timeout for AI generation
        onTimeout: () {
          throw TimeoutException('Quiz generation timed out');
        },
      );

      print('Response status: ${response.statusCode}');
      print(
          'Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final result = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Received ${result['count']} Bible verse quiz questions');
        return result;
      } else if (response.statusCode == 503) {
        // Gemini not available - return fallback flag
        final result = json.decode(response.body) as Map<String, dynamic>;
        print('⚠️  Quiz generation unavailable (Gemini not configured)');
        print('   Error message: ${result['error']}');
        return result;
      } else {
        print('❌ Unexpected status code: ${response.statusCode}');
        print('   Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('═══════════════════════════════════════');
      print('❌ Error getting Bible verse quiz: $e');
      print('   Error type: ${e.runtimeType}');
      print('   URL attempted: $baseUrl/quiz/bible-verse');
      if (e is TimeoutException) {
        print('   ⚠️  Request timed out');
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        print('   ⚠️  Network error - cannot reach backend');
      }
      print('═══════════════════════════════════════');
      rethrow;
    }
  }

  // Get Emotions quiz questions (AI-generated)
  Future<Map<String, dynamic>?> getEmotionsQuiz({
    required String difficulty,
    required int count,
    required String language,
  }) async {
    try {
      print(
          '😊 Requesting Emotions quiz: difficulty=$difficulty, count=$count');

      final response = await http
          .post(
        Uri.parse('$baseUrl/quiz/emotions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'difficulty': difficulty,
          'count': count,
          'language': language,
        }),
      )
          .timeout(
        const Duration(seconds: 60), // Increased timeout for AI generation
        onTimeout: () {
          throw TimeoutException('Quiz generation timed out');
        },
      );

      print('Response status: ${response.statusCode}');
      print(
          'Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final result = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Received ${result['count']} Emotions quiz questions');
        return result;
      } else if (response.statusCode == 503) {
        // Gemini not available - return fallback flag
        final result = json.decode(response.body) as Map<String, dynamic>;
        print('⚠️  Quiz generation unavailable (Gemini not configured)');
        print('   Error message: ${result['error']}');
        return result;
      } else {
        print('❌ Unexpected status code: ${response.statusCode}');
        print('   Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('═══════════════════════════════════════');
      print('❌ Error getting Emotions quiz: $e');
      print('   Error type: ${e.runtimeType}');
      print('   URL attempted: $baseUrl/quiz/emotions');
      if (e is TimeoutException) {
        print('   ⚠️  Request timed out');
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        print('   ⚠️  Network error - cannot reach backend');
      }
      print('═══════════════════════════════════════');
      rethrow;
    }
  }
}
