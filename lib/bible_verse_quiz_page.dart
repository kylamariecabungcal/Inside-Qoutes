import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'services/rest_api_service.dart';

class BibleVerseQuizPage extends StatefulWidget {
  final String difficulty; // 'easy', 'medium', 'hard'

  const BibleVerseQuizPage({
    super.key,
    required this.difficulty,
  });

  @override
  State<BibleVerseQuizPage> createState() => _BibleVerseQuizPageState();
}

class _BibleVerseQuizPageState extends State<BibleVerseQuizPage> {
  int currentQuestionIndex = 0;
  int? selectedAnswer;
  int score = 0;
  bool showResult = false;
  bool isLoadingQuestions = true;
  List<Map<String, dynamic>> _questions = [];
  bool useFallback = false;
  String? _errorMessage;
  
  // Cache settings to avoid repeated lookups in build()
  AppSettings? _settings;
  bool _isTagalog = false;
  bool _isDark = false;
  bool _hasInitialized = false; // Track if we've initialized settings

  @override
  void initState() {
    super.initState();
    // Reset all state to ensure fresh quiz each time
    currentQuestionIndex = 0;
    selectedAnswer = null;
    score = 0;
    showResult = false;
    _questions = [];
    useFallback = false;
    _errorMessage = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache settings here - didChangeDependencies is called after initState
    // and when inherited widgets change, so it's safe to access context
    // Only initialize once to prevent infinite rebuilds
    if (!_hasInitialized) {
      _settings = AppSettings.of(context);
      _isTagalog = _settings!.isTagalog;
      _isDark = _settings!.isDark;
      _hasInitialized = true;
      _loadQuestions();
    }
  }

  Future<void> _loadQuestions() async {
    // Batch setState calls for better performance
    if (mounted) {
      setState(() {
        isLoadingQuestions = true;
        // Reset quiz state when loading new questions
        currentQuestionIndex = 0;
        selectedAnswer = null;
        score = 0;
        showResult = false;
      });
    }

    // Use cached settings, fallback to context lookup if not cached yet
    final isTagalog = _isTagalog ? _isTagalog : AppSettings.of(context).isTagalog;

    try {
      // Determine question count based on difficulty
      int count = 5;
      if (widget.difficulty == 'medium') count = 7;
      if (widget.difficulty == 'hard') count = 10;

      // Add unique identifier to ensure different questions each time
      final uniqueId = DateTime.now().millisecondsSinceEpoch;
      print('📡 Starting Bible verse quiz request...');
      print('   Difficulty: ${widget.difficulty}');
      print('   Count: $count');
      print('   Language: ${isTagalog ? 'tl' : 'en'}');
      print('   Unique ID: $uniqueId (ensures different questions each time)');

      final result = await RestApiService.instance
          .getBibleVerseQuiz(
            difficulty: widget.difficulty,
            count: count,
            language: isTagalog ? 'tl' : 'en',
          )
          .timeout(
            const Duration(seconds: 60), // Increased timeout for AI generation
            onTimeout: () => null,
          );

      // IMPORTANT: Only accept AI-generated questions - reject any fallback responses
      // Games MUST use AI (Gemini) - no hardcoded questions allowed
      if (result != null &&
          result['questions'] != null &&
          result['fallback'] != true) {
        final questions = (result['questions'] as List)
            .map((q) => q as Map<String, dynamic>)
            .toList();

        // Shuffle answer options for each question with better randomness
        // Use different random seeds for each question to ensure variety
        for (int i = 0; i < questions.length; i++) {
          _shuffleOptions(questions[i], i); // Pass index for unique seed
        }

        // Batch setState call - only update if mounted
        if (mounted) {
          setState(() {
            _questions = questions;
            isLoadingQuestions = false;
            useFallback = false;
            _errorMessage = null;
          });
        }
        print(
            '✅ Loaded ${_questions.length} AI-generated Bible verse quiz questions');
        return;
      } else {
        print('⚠️  Quiz API returned null or fallback flag');
        String? errorMsg;
        if (result != null) {
          print('   Result keys: ${result.keys}');
          print('   Has questions: ${result['questions'] != null}');
          print('   Fallback flag: ${result['fallback']}');
          errorMsg = result['error'] as String?;
          
          // Provide more helpful error message for Gemini API key issue
          if (errorMsg != null && errorMsg.contains('Gemini API key')) {
            errorMsg = isTagalog
                ? 'Kailangan ng Gemini API key para sa AI-generated questions. Paki-setup ang API key sa backend (.env file).'
                : 'Gemini API key is required for AI-generated questions. Please set up the API key in the backend (.env file).';
          }
        }
        if (mounted) {
          setState(() {
            _questions = [];
            isLoadingQuestions = false;
            useFallback = false;
            _errorMessage = errorMsg;
          });
        }
      }
    } catch (e) {
      print('═══════════════════════════════════════');
      print('❌ Error loading quiz questions: $e');
      print('   Error type: ${e.runtimeType}');
      if (e is TimeoutException) {
        print(
            '   ⚠️  Request timed out - backend might be slow or unreachable');
        print('   💡 Check if backend server is running on port 3000');
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        print('   ⚠️  Network error - cannot reach backend');
        print('   💡 Make sure:');
        print('      1. Backend server is running (node server.js)');
        print('      2. Phone and computer are on same Wi-Fi network');
        print('      3. IP address is correct in RestApiService');
        print('      4. Windows Firewall allows port 3000');
      } else {
        print('   ⚠️  Unexpected error occurred');
      }
      print('═══════════════════════════════════════');
    }

    // IMPORTANT: No fallback questions - games MUST use AI (Gemini) only
    // If AI is not available, show error instead of using hardcoded questions
    print('❌ Failed to load AI-generated questions');
    if (mounted) {
      setState(() {
        _questions = [];
        isLoadingQuestions = false;
        useFallback = false;
        if (_errorMessage == null) {
          _errorMessage = _isTagalog
              ? 'Hindi makakonekta sa AI service. Siguraduhin na ang backend server ay tumatakbo at mayroong Gemini API key.'
              : 'Unable to connect to AI service. Make sure the backend server is running and has a Gemini API key configured.';
        }
      });
    }
  }

  List<Map<String, dynamic>> get questions => _questions;

  // Shuffle answer options and update correct index with better randomness
  void _shuffleOptions(Map<String, dynamic> question, [int questionIndex = 0]) {
    final options = List<String>.from(question['options'] as List);
    final correctIndex = question['correct'] as int;
    final correctAnswer = options[correctIndex];

    // Use Random with unique seed for each question (time + question index + random offset)
    final seed = DateTime.now().millisecondsSinceEpoch + 
                 questionIndex * 1000 + 
                 Random().nextInt(10000);
    final random = Random(seed);
    
    // Fisher-Yates shuffle algorithm for better distribution
    for (int i = options.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      String temp = options[i];
      options[i] = options[j];
      options[j] = temp;
    }

    // Find new position of correct answer
    final newCorrectIndex = options.indexOf(correctAnswer);

    // Update question with shuffled options and new correct index
    question['options'] = options;
    question['correct'] = newCorrectIndex;
    
    // Debug: Print to verify correct answer is not always at same position
    print('   Q${questionIndex + 1}: Correct answer is at index: $newCorrectIndex (Letter: ${String.fromCharCode(65 + newCorrectIndex)})');
  }

  void _selectAnswer(int index) {
    if (selectedAnswer != null) return; // Prevent multiple selections

    if (mounted) {
      setState(() {
        selectedAnswer = index;
        if (index == questions[currentQuestionIndex]['correct']) {
          score++;
        }
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      if (mounted) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
        });
      }
    } else {
      // Save score to backend (fire and forget - don't block UI)
      RestApiService.instance.saveQuizScore(
        quizType: 'bible',
        difficulty: widget.difficulty,
        score: score,
        totalQuestions: questions.length,
      );
      if (mounted) {
        setState(() {
          showResult = true;
        });
      }
    }
  }

  void _restartQuiz() {
    // Go back to difficulty selection page
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Use cached settings, fallback to context lookup if not cached yet
    final settings = _settings ?? AppSettings.of(context);
    final isTagalog = _isTagalog ? _isTagalog : settings.isTagalog;
    final isDark = _isDark ? _isDark : settings.isDark;
    
    // Cache color calculations - these are const so they're optimized
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF001A4D);
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final backgroundColor =
        isDark ? const Color(0xFF050816) : const Color(0xFFF2F6FF);
    const correctColor = Colors.green;
    const wrongColor = Colors.red;

    // Show loading while fetching questions
    if (isLoadingQuestions) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            isTagalog ? 'Quiz sa Bibliya' : 'Bible Verse Quiz',
            style: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 3,
                ),
                const SizedBox(height: 32),
                Text(
                  isTagalog
                      ? 'Gumagawa ng mga tanong gamit ang AI...'
                      : 'Generating questions with AI...',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isTagalog
                      ? 'Ito ay maaaring tumagal ng ilang segundo habang ginagawa ng Google Gemini AI ang iyong mga tanong.'
                      : 'This may take a few seconds as Google Gemini AI generates your questions.',
                  style: TextStyle(
                    color: primaryTextColor.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryTextColor.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: primaryTextColor.withOpacity(0.6),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isTagalog
                              ? 'Bawat tanong ay unique at AI-generated'
                              : 'Each question is unique and AI-generated',
                          style: TextStyle(
                            color: primaryTextColor.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show error if no questions loaded
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            isTagalog ? 'Quiz sa Bibliya' : 'Bible Verse Quiz',
            style: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: primaryTextColor.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  isTagalog
                      ? 'Hindi makakuha ng mga tanong mula sa AI.'
                      : 'Unable to load AI-generated questions.',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: primaryTextColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_errorMessage!.contains('Gemini API key') || 
                            _errorMessage!.contains('API key'))
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: primaryTextColor.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: primaryTextColor.withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isTagalog ? 'Paano i-setup:' : 'How to setup:',
                                        style: TextStyle(
                                          color: primaryTextColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isTagalog
                                        ? '1. Kumuha ng Gemini API key sa https://aistudio.google.com/app/apikey\n2. I-add sa backend/.env file: GEMINI_API_KEY=your_key_here\n3. I-restart ang backend server'
                                        : '1. Get Gemini API key from https://aistudio.google.com/app/apikey\n2. Add to backend/.env file: GEMINI_API_KEY=your_key_here\n3. Restart backend server',
                                    style: TextStyle(
                                      color: primaryTextColor.withOpacity(0.7),
                                      fontSize: 11,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  Text(
                    isTagalog
                        ? 'Siguraduhin na ang backend server ay tumatakbo at mayroong Gemini API key na naka-configure.'
                        : 'Make sure the backend server is running and has a Gemini API key configured.',
                    style: TextStyle(
                      color: primaryTextColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 8),
                Text(
                  isTagalog
                      ? 'Ang mga tanong ay AI-generated gamit ang Google Gemini.'
                      : 'Questions are AI-generated using Google Gemini.',
                  style: TextStyle(
                    color: primaryTextColor.withOpacity(0.5),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _loadQuestions();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(isTagalog ? 'Subukan ulit' : 'Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isTagalog
                      ? 'Tiyakin na ang backend server ay tumatakbo at mayroong Gemini API key.'
                      : 'Make sure the backend server is running and has a Gemini API key.',
                  style: TextStyle(
                    color: primaryTextColor.withOpacity(0.5),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (showResult) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            isTagalog ? 'Mga Resulta' : 'Quiz Results',
            style: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  score == questions.length
                      ? Icons.celebration_rounded
                      : score >= questions.length / 2
                          ? Icons.emoji_events_rounded
                          : Icons.sentiment_dissatisfied_rounded,
                  size: 80,
                  color: score == questions.length
                      ? Colors.amber
                      : score >= questions.length / 2
                          ? Colors.blue
                          : Colors.orange,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isTagalog ? 'Natapos mo ang quiz!' : 'You completed the quiz!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                '${isTagalog ? 'Iyong score' : 'Your score'}: $score / ${questions.length}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                score == questions.length
                    ? (isTagalog
                        ? 'Perpekto! Napakahusay mo!'
                        : 'Perfect! You\'re amazing!')
                    : score >= questions.length / 2
                        ? (isTagalog
                            ? 'Magaling! Mahusay na kaalaman sa Bibliya!'
                            : 'Great! Good knowledge of the Bible!')
                        : (isTagalog
                            ? 'Subukan ulit! Patuloy na matuto!'
                            : 'Try again! Keep learning!'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: primaryTextColor.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _restartQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C6FB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isTagalog ? 'Magsimula ulit' : 'Play Again',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Safety check - ensure we have valid questions
    if (questions.isEmpty || currentQuestionIndex >= questions.length) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            isTagalog ? 'Quiz sa Bibliya' : 'Bible Verse Quiz',
            style: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: primaryTextColor.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  isTagalog
                      ? 'Walang available na questions. Subukan ulit.'
                      : 'No questions available. Please try again.',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _loadQuestions();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(isTagalog ? 'Subukan ulit' : 'Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    // Validate question has required fields
    if (currentQuestion['question'] == null ||
        currentQuestion['options'] == null ||
        (currentQuestion['options'] as List).isEmpty) {
      // Use postFrameCallback to avoid calling setState during build
      // This prevents infinite rebuild loops
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !isLoadingQuestions) {
          _loadQuestions();
        }
      });
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final progress = (currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          isTagalog
              ? 'Quiz sa Bibliya - ${widget.difficulty == 'easy' ? 'Madali' : widget.difficulty == 'medium' ? 'Katamtaman' : 'Mahirap'}'
              : 'Bible Verse Quiz - ${widget.difficulty[0].toUpperCase()}${widget.difficulty.substring(1)}',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          // AI-Generated badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF005BEA).withOpacity(0.2),
                  const Color(0xFF00C6FB).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF005BEA).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: const Color(0xFF005BEA),
                ),
                const SizedBox(width: 4),
                Text(
                  'AI',
                  style: TextStyle(
                    color: const Color(0xFF005BEA),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isTagalog
                      ? 'Tanong ${currentQuestionIndex + 1} / ${questions.length}'
                      : 'Question ${currentQuestionIndex + 1} / ${questions.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: primaryTextColor.withOpacity(0.7),
                      ),
                ),
                Text(
                  '$score ${isTagalog ? 'tama' : 'correct'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: primaryTextColor.withOpacity(0.7),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: primaryTextColor.withOpacity(0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF00C6FB)),
              ),
            ),
            const SizedBox(height: 32),
            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                currentQuestion['question'],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            // Options (3 choices)
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion['options'].length,
                itemBuilder: (context, index) {
                  final option = currentQuestion['options'][index];
                  final isSelected = selectedAnswer == index;
                  final isCorrect = index == currentQuestion['correct'];
                  Color? optionColor;

                  if (selectedAnswer != null) {
                    if (isSelected && isCorrect) {
                      optionColor = correctColor;
                    } else if (isSelected && !isCorrect) {
                      optionColor = wrongColor;
                    } else if (!isSelected && isCorrect) {
                      optionColor = correctColor;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _selectAnswer(index),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: optionColor != null
                              ? optionColor.withOpacity(0.1)
                              : cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: optionColor ?? Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: optionColor != null
                                    ? optionColor.withOpacity(0.2)
                                    : primaryTextColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C
                                  style: TextStyle(
                                    color: optionColor ?? primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: primaryTextColor,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                              ),
                            ),
                            if (selectedAnswer != null && isSelected)
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: optionColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Next button
            if (selectedAnswer != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C6FB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    currentQuestionIndex < questions.length - 1
                        ? (isTagalog ? 'Susunod' : 'Next')
                        : (isTagalog ? 'Tingnan ang Resulta' : 'See Results'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
