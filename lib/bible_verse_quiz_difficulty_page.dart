import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'bible_verse_quiz_page.dart';

class BibleVerseQuizDifficultyPage extends StatelessWidget {
  const BibleVerseQuizDifficultyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.of(context);
    final isTagalog = settings.isTagalog;
    final isDark = settings.isDark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF001A4D);
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final backgroundColor =
        isDark ? const Color(0xFF050816) : const Color(0xFFF2F6FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          isTagalog ? 'Pumili ng Antas' : 'Choose Difficulty',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTagalog
                  ? 'Pumili ng antas ng kahirapan'
                  : 'Select difficulty level',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isTagalog
                  ? 'Ang antas ay tutukoy sa kahirapan ng mga tanong'
                  : 'Difficulty determines the complexity of questions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: primaryTextColor.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Column(
                children: [
                  _DifficultyButton(
                    title: isTagalog ? 'Madali' : 'Easy',
                    subtitle: isTagalog
                        ? '5 tanong - Mga kilalang talata'
                        : '5 questions - Well-known verses',
                    icon: Icons.sentiment_satisfied_rounded,
                    color: Colors.green,
                    difficulty: 'easy',
                    cardColor: cardColor,
                    textColor: primaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  _DifficultyButton(
                    title: isTagalog ? 'Katamtaman' : 'Medium',
                    subtitle: isTagalog
                        ? '7 tanong - Mas detalyadong talata'
                        : '7 questions - More detailed verses',
                    icon: Icons.sentiment_neutral_rounded,
                    color: Colors.orange,
                    difficulty: 'medium',
                    cardColor: cardColor,
                    textColor: primaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  _DifficultyButton(
                    title: isTagalog ? 'Mahirap' : 'Hard',
                    subtitle: isTagalog
                        ? '10 tanong - Advanced na kaalaman'
                        : '10 questions - Advanced knowledge',
                    icon: Icons.sentiment_very_dissatisfied_rounded,
                    color: Colors.red,
                    difficulty: 'hard',
                    cardColor: cardColor,
                    textColor: primaryTextColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  const _DifficultyButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.cardColor,
    required this.textColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String difficulty;
  final Color cardColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BibleVerseQuizPage(difficulty: difficulty),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textColor.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
