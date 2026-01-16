import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'emotions_quiz_difficulty_page.dart';
import 'bible_verse_quiz_difficulty_page.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.of(context);
    final isTagalog = settings.isTagalog;
    final isDark = settings.isDark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF001A4D);
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final backgroundColor =
        isDark ? const Color(0xFF050816) : const Color(0xFFF2F6FF);

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTagalog ? 'Pumili ng laro' : 'Choose a game',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isTagalog
                ? 'Mag-explore at matuto tungkol sa emosyon at bibliya'
                : 'Explore and learn about emotions and the bible',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: primaryTextColor.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 16),
          // AI-powered badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF005BEA).withOpacity(0.2),
                  const Color(0xFF00C6FB).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
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
                  size: 16,
                  color: const Color(0xFF005BEA),
                ),
                const SizedBox(width: 6),
                Text(
                  isTagalog
                      ? 'AI-Generated Questions'
                      : 'AI-Generated Questions',
                  style: TextStyle(
                    color: const Color(0xFF005BEA),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Column(
              children: [
                _GameButton(
                  title:
                      isTagalog ? 'Quiz tungkol sa Emosyon' : 'Emotions Quiz',
                  subtitle: isTagalog
                      ? 'Subukan ang iyong kaalaman sa emosyon'
                      : 'Test your knowledge about emotions',
                  icon: Icons.emoji_emotions_rounded,
                  color: const Color(0xFF005BEA),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EmotionsQuizDifficultyPage(),
                      ),
                    );
                  },
                  cardColor: cardColor,
                  textColor: primaryTextColor,
                ),
                const SizedBox(height: 16),
                _GameButton(
                  title: isTagalog ? 'Quiz sa Bibliya' : 'Bible Verse Quiz',
                  subtitle: isTagalog
                      ? 'Subukan ang iyong kaalaman sa Bibliya'
                      : 'Test your knowledge of the Bible',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF00C6FB),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BibleVerseQuizDifficultyPage(),
                      ),
                    );
                  },
                  cardColor: cardColor,
                  textColor: primaryTextColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameButton extends StatelessWidget {
  const _GameButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.cardColor,
    required this.textColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Color cardColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: color.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI-Powered',
                        style: TextStyle(
                          color: color.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
