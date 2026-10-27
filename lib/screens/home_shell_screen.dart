import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../services/database_service.dart';
import 'exercises_catalog_screen.dart';
import 'progress_history_screen.dart';
import 'routines_screen.dart';
import 'workout_session_screen.dart';

class HomeShellScreen extends StatefulWidget {
  final UserProfile initialProfile;

  const HomeShellScreen({
    super.key,
    required this.initialProfile,
  });

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  late UserProfile _profile;
  int _selectedIndex = 0;

  List<Routine> _routines = [];
  List<WorkoutSession> _recentSessions = [];
  int _totalCatalogExercises = 0;
  bool _loadingDashboard = true;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    _refreshDashboard();
  }

  Future<void> _refreshDashboard() async {
    final routines = await DatabaseService.instance.getAllRoutines();
    final sessions =
        await DatabaseService.instance.getWorkoutSessions(limit: 10);
    final exercises = await DatabaseService.instance.getAllExercises();
    final updatedProfile = await DatabaseService.instance.getUserProfile();

    if (mounted) {
      setState(() {
        if (updatedProfile != null) _profile = updatedProfile;
        _routines = routines;
        _recentSessions = sessions;
        _totalCatalogExercises = exercises.length;
        _loadingDashboard = false;
      });
    }
  }

  Future<void> _showEditUsernameDialog() async {
    final nameCtrl = TextEditingController(text: _profile.username);
    String unit = _profile.weightUnit;

    final updated = await showDialog<UserProfile>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF161D2B),
          title: const Text('Personalización Interactiva'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu nombre se usa únicamente para saludarte y personalizar tu asistente sin cuentas ni contraseñas.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tu Nombre o Apodo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Unidad de Peso Preferida:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'kg', label: Text('Kilogramos (kg)')),
                  ButtonSegment(value: 'lb', label: Text('Libras (lb)')),
                ],
                selected: {unit},
                onSelectionChanged: (s) {
                  setDialogState(() => unit = s.first);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final saved = await DatabaseService.instance
                    .saveOrUpdateUserProfile(
                  nameCtrl.text.trim(),
                  weightUnit: unit,
                );
                Navigator.pop(ctx, saved);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (updated != null) {
      setState(() => _profile = updated);
    }
  }

  String _getInteractiveGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '¡Buenos días, ${_profile.username}! ¿Listo para romper tus marcas hoy?';
    } else if (hour < 19) {
      return '¡Buenas tardes, ${_profile.username}! Es momento de darle duro a las pesas.';
    } else {
      return '¡Buenas noches, ${_profile.username}! Gran hora para cerrar el día entrenando.';
    }
  }

  Widget _buildDashboardTab() {
    if (_loadingDashboard) {
      return const Center(child: CircularProgressIndicator());
    }

    final Routine? activeRoutine = _routines.isNotEmpty
        ? _routines.firstWhere(
            (r) => r.isActive,
            orElse: () => _routines.first,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFF00),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'IRONPULSE ASSISTANT',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                fontSize: 17,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: const Icon(Icons.person, size: 17, color: Color(0xFFCCFF00)),
              label: Text(
                '${_profile.username} (${_profile.weightUnit})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _showEditUsernameDialog,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner de Saludo Interactivo Personalizado
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A253A), Color(0xFF111726)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFCCFF00).withOpacity(0.5),
                  width: 1.4,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded,
                          color: Color(0xFFCCFF00), size: 26),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getInteractiveGreeting(),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activeRoutine != null
                        ? 'Tu rutina activa es "${activeRoutine.name}" (${activeRoutine.days.length} días por semana). Selecciona el día que te toca entrenar hoy para cargar tus pesos serie por serie.'
                        : 'Aún no tienes una rutina semanal activa. Crea una personalizada o importa una plantilla prearmada en 1 clic.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tarjetas de Resumen Rápido
            Row(
              children: [
                Expanded(
                  child: _DashboardStatCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'Rutinas Creadas',
                    value: '${_routines.length}',
                    color: const Color(0xFFCCFF00),
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardStatCard(
                    icon: Icons.fitness_center_rounded,
                    label: 'Ejercicios Guía',
                    value: '$_totalCatalogExercises',
                    color: const Color(0xFF00E5FF),
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DashboardStatCard(
                    icon: Icons.emoji_events_rounded,
                    label: 'Sesiones Guardadas',
                    value: '${_recentSessions.length}',
                    color: const Color(0xFF69F0AE),
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Sección de Entrenamiento Día a Día (Rutina Activa)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Entrenar Hoy (Registro de Pesos)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  icon: const Icon(Icons.edit_calendar_rounded, size: 17),
                  label: const Text('Gestionar Rutinas'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (activeRoutine == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.playlist_add_check_circle_rounded,
                          size: 48, color: Color(0xFFCCFF00)),
                      const SizedBox(height: 12),
                      Text(
                        '${_profile.username}, configura tu primera rutina semanal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Define cuántos días a la semana entrenas y qué ejercicios (barras, mancuernas, poleas o máquinas) realizas cada día.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () => setState(() => _selectedIndex = 1),
                        icon: const Icon(Icons.add),
                        label: const Text('Ir a Mis Rutinas Semanales'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...activeRoutine.days.map((day) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          const Color(0xFFCCFF00).withOpacity(0.18),
                      foregroundColor: const Color(0xFFCCFF00),
                      child: Text(
                        'D${day.dayNumber}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    title: Text(
                      day.dayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        day.exercises.isEmpty
                            ? 'Sin ejercicios asignados'
                            : '${day.exercises.length} ejercicios: ${day.exercises.map((e) => e.exercise?.name ?? "").join(" • ")}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    trailing: FilledButton.icon(
                      onPressed: () async {
                        final saved = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutSessionScreen(
                              username: _profile.username,
                              weightUnit: _profile.weightUnit,
                              routine: activeRoutine,
                              routineDay: day,
                            ),
                          ),
                        );
                        if (saved == true) {
                          _refreshDashboard();
                        }
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('Registrar Pesos'),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboardTab(),
      RoutinesScreen(
        username: _profile.username,
        weightUnit: _profile.weightUnit,
        onDataChanged: _refreshDashboard,
      ),
      const ExercisesCatalogScreen(),
      ProgressHistoryScreen(
        username: _profile.username,
        weightUnit: _profile.weightUnit,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) {
          setState(() => _selectedIndex = idx);
          if (idx == 0) _refreshDashboard();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Inicio / Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Mi Rutina',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center_rounded),
            label: 'Ejercicios',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progreso',
          ),
        ],
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _DashboardStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF151C2C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
