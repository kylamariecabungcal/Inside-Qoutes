import 'package:flutter/material.dart';
import 'home_page.dart';
import 'app_settings.dart';
import 'services/local_storage_service.dart';
import 'services/rest_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.initialize();
  await RestApiService.instance.initialize();
  runApp(const InsideQoutesApp());
}

class InsideQoutesApp extends StatefulWidget {
  const InsideQoutesApp({super.key});

  @override
  State<InsideQoutesApp> createState() => _InsideQoutesAppState();
}

class _InsideQoutesAppState extends State<InsideQoutesApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String _languageCode = 'en'; // 'en' or 'tl'
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    _initializeAuth();
  }

  Future<void> _initializeSettings() async {
    // Load from local storage first
    final savedTheme = LocalStorageService.getThemeMode();
    final savedLanguage = LocalStorageService.getLanguageCode();

    if (savedTheme != null) {
      setState(() {
        _themeMode = savedTheme == 'dark'
            ? ThemeMode.dark
            : savedTheme == 'system'
                ? ThemeMode.system
                : ThemeMode.light;
      });
    }

    if (savedLanguage != null) {
      setState(() {
        _languageCode = savedLanguage;
      });
    }

    // Then try to load from backend
    if (RestApiService.instance.isLoggedIn) {
      final apiSettings = await RestApiService.instance.getUserSettings();
      if (apiSettings != null) {
        setState(() {
          if (apiSettings['themeMode'] != null) {
            final theme = apiSettings['themeMode'] as String;
            _themeMode = theme == 'dark'
                ? ThemeMode.dark
                : theme == 'system'
                    ? ThemeMode.system
                    : ThemeMode.light;
          }
          if (apiSettings['languageCode'] != null) {
            _languageCode = apiSettings['languageCode'] as String;
          }
        });
      }
    }

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _initializeAuth() async {
    // Sign in anonymously if not logged in
    if (!RestApiService.instance.isLoggedIn) {
      await RestApiService.instance.signInAnonymously();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    final lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 139, 173, 228),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );

    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 139, 173, 228),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
    );

    return AppSettings(
      themeMode: _themeMode,
      languageCode: _languageCode,
      setThemeMode: (mode) {
        setState(() {
          _themeMode = mode;
        });
        // Save to local storage
        LocalStorageService.saveThemeMode(mode == ThemeMode.dark
            ? 'dark'
            : mode == ThemeMode.system
                ? 'system'
                : 'light');
        // Save to backend
        RestApiService.instance.saveUserSettings(
          themeMode: mode == ThemeMode.dark
              ? 'dark'
              : mode == ThemeMode.system
                  ? 'system'
                  : 'light',
          languageCode: _languageCode,
        );
      },
      setLanguageCode: (code) {
        setState(() {
          _languageCode = code;
        });
        // Save to local storage
        LocalStorageService.saveLanguageCode(code);
        // Save to backend
        RestApiService.instance.saveUserSettings(
          themeMode: _themeMode == ThemeMode.dark
              ? 'dark'
              : _themeMode == ThemeMode.system
                  ? 'system'
                  : 'light',
          languageCode: code,
        );
      },
      child: MaterialApp(
        title: 'Inside Qoutes',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _themeMode,
        home: const LandingPage(),
      ),
    );
  }
}

// Logo widget (PNG supports transparency natively)
class _TransparentLogo extends StatelessWidget {
  const _TransparentLogo({
    required this.assetPath,
    required this.width,
    required this.height,
  });

  final String assetPath;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.of(context);
    final isTagalog = settings.isTagalog;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF005BEA), Color(0xFF00C6FB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo (PNG with transparent background)
            _TransparentLogo(
              assetPath: 'assets/logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 24),
            Text(
              'Inside Qoutes',
              textAlign: TextAlign.center,
              style: textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isTagalog
                  ? 'Araw-araw na mga pagninilay na ginawa para sa iyo. Lumangoy at ma-inspire.'
                  : 'Daily reflections crafted just for you. Dive in and feel inspired.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF005BEA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 8,
                  shadowColor: Colors.white.withOpacity(0.5),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HomeShell()),
                  );
                },
                child: Text(
                  isTagalog ? 'Magsimula' : 'Get Started',
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
