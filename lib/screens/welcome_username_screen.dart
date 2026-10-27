import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../services/database_service.dart';
import 'home_shell_screen.dart';

class WelcomeUsernameScreen extends StatefulWidget {
  const WelcomeUsernameScreen({super.key});

  @override
  State<WelcomeUsernameScreen> createState() => _WelcomeUsernameScreenState();
}

class _WelcomeUsernameScreenState extends State<WelcomeUsernameScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  String _weightUnit = 'kg';
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _continueToApp() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escribe tu nombre o apodo para comenzar.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final UserProfile profile = await DatabaseService.instance
        .saveOrUpdateUserProfile(name, weightUnit: _weightUnit);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeShellScreen(initialProfile: profile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: const Color(0xFFCCFF00).withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFF00).withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        size: 46,
                        color: Color(0xFFCCFF00),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'IRONPULSE FITNESS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Asistente Inteligente de Entrenamiento de Musculación.\nSin cuentas ni contraseñas: ingresa solo tu nombre para interactuar contigo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) => _continueToApp(),
                      decoration: const InputDecoration(
                        labelText: '¿Cómo te llamas?',
                        hintText: 'Ej: Gabriel, Alex...',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Unidad de peso:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'kg', label: Text('KG')),
                            ButtonSegment(value: 'lb', label: Text('LB')),
                          ],
                          selected: {_weightUnit},
                          onSelectionChanged: (s) {
                            setState(() => _weightUnit = s.first);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _continueToApp,
                        icon: const Icon(Icons.bolt_rounded),
                        label: const Text(
                          'COMENZAR ENTRENAMIENTO',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
