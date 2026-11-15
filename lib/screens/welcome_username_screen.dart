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
  String _gender = 'male'; // 'male' = Varón, 'female' = Mujer
  bool _saving = false;
  List<UserProfile> _existingUsers = [];

  @override
  void initState() {
    super.initState();
    _loadExistingUsers();
  }

  Future<void> _loadExistingUsers() async {
    final users = await DatabaseService.instance.getAllUsers();
    if (mounted) {
      setState(() => _existingUsers = users);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectExistingUser(UserProfile user) async {
    if (user.id == null) return;
    setState(() => _saving = true);
    final active = await DatabaseService.instance.switchActiveUser(user.id!);
    if (mounted && active != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeShellScreen(initialProfile: active),
        ),
      );
    }
  }

  Future<void> _continueToApp() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, escribe el nombre o alias del alumno/usuario para comenzar.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final UserProfile profile = await DatabaseService.instance
        .createOrSelectUser(name, weightUnit: _weightUnit, gender: _gender);

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
            constraints: const BoxConstraints(maxWidth: 460),
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
                      'Modo Multi-Usuario / Entrenador y Alumnos.\nSin contraseñas ni cuentas: identifica a cada alumno solo con su nombre o alias para gestionar sus rutinas y pesos por separado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                    if (_existingUsers.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Seleccionar Alumno / Usuario registrado:',
                          style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _existingUsers.map((u) {
                          return ActionChip(
                            avatar: Icon(
                              u.isFemale
                                  ? Icons.female_rounded
                                  : Icons.male_rounded,
                              size: 16,
                              color: u.isFemale
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFFCCFF00),
                            ),
                            label: Text(
                              '${u.username} (${u.genderLabel} • ${u.weightUnit})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed:
                                _saving ? null : () => _selectExistingUser(u),
                          );
                        }).toList(),
                      ),
                      const Divider(height: 28),
                    ] else
                      const SizedBox(height: 24),
                    TextField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) => _continueToApp(),
                      decoration: const InputDecoration(
                        labelText: 'Nombre o Alias del Alumno / Usuario',
                        hintText: 'Ej: Gabriel, Martín, Lucía...',
                        prefixIcon: Icon(Icons.person_add_alt_1_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sexo (Maniquí 3D):',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'male',
                              icon: Icon(Icons.male_rounded, size: 18),
                              label: Text('Varón'),
                            ),
                            ButtonSegment(
                              value: 'female',
                              icon: Icon(Icons.female_rounded, size: 18),
                              label: Text('Mujer'),
                            ),
                          ],
                          selected: {_gender},
                          onSelectionChanged: (s) {
                            setState(() => _gender = s.first);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                          'INGRESAR / CREAR ALUMNO',
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
