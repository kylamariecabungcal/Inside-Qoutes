import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'settings_page.dart';
import 'games_page.dart';
import 'services/rest_api_service.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.of(context);
    final isTagalog = settings.isTagalog;
    final isDark = settings.isDark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF001A4D);
    final backgroundColor =
        isDark ? const Color(0xFF050816) : const Color(0xFFF2F6FF);

    String title;
    Widget body;

    if (currentIndex == 0) {
      title = isTagalog ? 'Highlight ngayon' : 'Today\'s highlight';
      body = const _FeelingHomePage();
    } else if (currentIndex == 1) {
      title = isTagalog ? 'Mga Setting' : 'Settings';
      body = const SettingsPage();
    } else {
      title = isTagalog ? 'Mga Laro' : 'Games';
      body = const GamesPage();
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          title,
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: body,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onChanged: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }
}

class _FeelingHomePage extends StatefulWidget {
  const _FeelingHomePage();

  @override
  State<_FeelingHomePage> createState() => _FeelingHomePageState();
}

class _FeelingHomePageState extends State<_FeelingHomePage> {
  final TextEditingController _controller = TextEditingController();
  String? _advice;
  String? _bibleVerse;
  bool _isLoadingAdvice = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateAdvice() async {
    final text = _controller.text.trim();
    final settings = AppSettings.of(context);
    final isTagalog = settings.isTagalog;

    // Always call backend - even for empty text, AI will handle it
    if (mounted) {
      setState(() {
        _isLoadingAdvice = true;
        _advice = null;
      });
    }

    try {
      // Get advice from backend (AI-powered, no hardcoded responses)
      // Backend will use Gemini AI or local AI engine - both are AI-generated
      print('Requesting advice for: "$text"');

      final result = await RestApiService.instance
          .getAdvice(
        text: text, // Can be empty - AI will handle it
        language: isTagalog ? 'tl' : 'en',
      )
          .timeout(
        const Duration(seconds: 15), // Increased timeout for AI processing
        onTimeout: () {
          print('Advice request timed out');
          return null;
        },
      );

      print('Advice result: $result');

      if (result != null &&
          result['advice'] != null &&
          (result['advice'] as String).isNotEmpty) {
        if (mounted) {
          setState(() {
            _advice = result['advice'] as String;
            _bibleVerse = result['bibleVerse'] as String?;
            _isLoadingAdvice = false;
          });
        }
        print('Advice displayed successfully');
        if (_bibleVerse != null) {
          print('Bible Verse: $_bibleVerse');
        }
      } else {
        // If no response, try one more time
        print('No advice received, retrying...');
        try {
          final retryResult = await RestApiService.instance
              .getAdvice(
                text: text,
                language: isTagalog ? 'tl' : 'en',
              )
              .timeout(const Duration(seconds: 10));

          if (retryResult != null &&
              retryResult['advice'] != null &&
              (retryResult['advice'] as String).isNotEmpty) {
            if (mounted) {
              setState(() {
                _advice = retryResult['advice'] as String;
                _bibleVerse = retryResult['bibleVerse'] as String?;
                _isLoadingAdvice = false;
              });
            }
            print('Advice received on retry');
            if (_bibleVerse != null) {
              print('Bible Verse: $_bibleVerse');
            }
          } else {
            throw Exception('No advice received after retry');
          }
        } catch (retryError) {
          print('Retry also failed: $retryError');
          // Show error message
          if (mounted) {
            setState(() {
              _advice = isTagalog
                  ? 'Hindi makakonekta sa AI service. Siguraduhin na ang backend server ay tumatakbo sa http://10.0.2.165:3000 at subukan ulit.'
                  : 'Unable to connect to AI service. Make sure the backend server is running at http://10.0.2.165:3000 and try again.';
              _isLoadingAdvice = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error getting advice from backend: $e');
      // Show error message with helpful info
      if (mounted) {
        setState(() {
          _advice = isTagalog
              ? 'Hindi makakonekta sa AI service. Siguraduhin na ang backend server ay tumatakbo sa http://10.0.2.165:3000 at subukan ulit.'
              : 'Unable to connect to AI service. Make sure the backend server is running at http://10.0.2.165:3000 and try again.';
          _isLoadingAdvice = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.of(context);
    final isTagalog = settings.isTagalog;
    final isDark = settings.isDark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF001A4D);
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    const accentColor = Color(0xFF005BEA);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Quote Card with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1a1a2e),
                          const Color(0xFF16213e),
                        ]
                      : [
                          const Color(0xFF005BEA).withOpacity(0.1),
                          const Color(0xFF00C6FB).withOpacity(0.1),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accentColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.format_quote_rounded,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isTagalog
                          ? 'Hindi nanggagaling sa comfort zone ang magagandang bagay.'
                          : 'Great things never come from comfort zones.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: primaryTextColor,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // How are you feeling section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.emoji_emotions_outlined,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isTagalog
                        ? 'Kamusta ang pakiramdam mo ngayon?'
                        : 'How are you feeling today?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Enhanced TextField
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: isTagalog
                      ? 'I-type ang nararamdaman mo dito...'
                      : 'Type your feelings here...',
                  hintStyle: TextStyle(
                    color: primaryTextColor.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: accentColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: accentColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: accentColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                  prefixIcon: Icon(
                    Icons.edit_note_rounded,
                    color: accentColor.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Enhanced Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [accentColor, const Color(0xFF00C6FB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoadingAdvice ? null : _generateAdvice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _isLoadingAdvice
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isTagalog ? 'Tingnan ang payo' : 'See advice',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (_advice != null) ...[
              const SizedBox(height: 32),
              // Advice Card with better design
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1a1a2e),
                            const Color(0xFF16213e),
                          ]
                        : [
                            Colors.white,
                            const Color(0xFFF8FAFF),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline_rounded,
                            color: accentColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isTagalog ? 'Payo para sa iyo' : 'Advice for you',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        _advice!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: primaryTextColor,
                              height: 1.6,
                              fontSize: 15,
                            ),
                      ),
                    ),
                    if (_bibleVerse != null && _bibleVerse!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accentColor.withOpacity(0.1),
                              accentColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  color: accentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isTagalog ? 'Bible Verse' : 'Bible Verse',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _bibleVerse!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: primaryTextColor,
                                    height: 1.6,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBarColor = isDark ? const Color(0xFF111827) : Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: navBarColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.home_rounded,
                isActive: currentIndex == 0,
                onTap: () => onChanged(0),
              ),
              _BottomNavItem(
                icon: Icons.settings_rounded,
                isActive: currentIndex == 1,
                onTap: () => onChanged(1),
              ),
              _BottomNavItem(
                icon: Icons.games_rounded,
                isActive: currentIndex == 2,
                onTap: () => onChanged(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF005BEA);
    final inactiveColor = const Color(0xFF9AA2B1);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            if (isActive)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
