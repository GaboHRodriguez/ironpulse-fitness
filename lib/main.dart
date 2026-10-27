import 'package:flutter/material.dart';
import 'models/fitness_models.dart';
import 'screens/home_shell_screen.dart';
import 'screens/welcome_username_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IronPulseApp());
}

class IronPulseApp extends StatelessWidget {
  const IronPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryNeon = Color(0xFFCCFF00);
    const Color secondaryCyan = Color(0xFF00E5FF);
    const Color darkBg = Color(0xFF0B0F17);
    const Color surfaceCard = Color(0xFF151C2C);

    final colorScheme = ColorScheme.dark(
      primary: primaryNeon,
      onPrimary: Colors.black,
      secondary: secondaryCyan,
      onSecondary: Colors.black,
      surface: surfaceCard,
      onSurface: Colors.white,
    );

    return MaterialApp(
      title: 'IronPulse - Asistente de Musculación',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: colorScheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101624),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: surfaceCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF243048)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0F1420),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF28354E)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF28354E)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryNeon, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryNeon,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF101624),
          indicatorColor: primaryNeon.withOpacity(0.22),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const _AppBootstrapScreen(),
    );
  }
}

class _AppBootstrapScreen extends StatefulWidget {
  const _AppBootstrapScreen();

  @override
  State<_AppBootstrapScreen> createState() => _AppBootstrapScreenState();
}

class _AppBootstrapScreenState extends State<_AppBootstrapScreen> {
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  Future<void> _checkUserProfile() async {
    final profile = await DatabaseService.instance.getUserProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFCCFF00)),
              SizedBox(height: 16),
              Text(
                'Cargando Base de Datos de Musculación...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (_profile == null) {
      return const WelcomeUsernameScreen();
    }
    return HomeShellScreen(initialProfile: _profile!);
  }
}
