import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../services/database_service.dart';
import 'exercises_catalog_screen.dart';
import 'progress_history_screen.dart';
import 'routines_screen.dart';
import 'welcome_username_screen.dart';
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
  List<UserProfile> _allUsers = [];
  int _selectedIndex = 0;

  List<Routine> _routines = [];
  List<WorkoutSession> _recentSessions = [];
  int _totalCatalogExercises = 0;
  bool _loadingDashboard = true;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    DatabaseService.instance.currentGender = _profile.gender;
    _refreshDashboard();
  }

  Future<void> _refreshDashboard() async {
    final updatedProfile = await DatabaseService.instance.getUserProfile();
    final allUsers = await DatabaseService.instance.getAllUsers();
    final routines = await DatabaseService.instance.getAllRoutines();
    final sessions =
        await DatabaseService.instance.getWorkoutSessions(limit: 10);
    final exercises = await DatabaseService.instance.getAllExercises();

    if (mounted) {
      setState(() {
        if (updatedProfile != null) {
          _profile = updatedProfile;
          DatabaseService.instance.currentGender = updatedProfile.gender;
        }
        _allUsers = allUsers;
        _routines = routines;
        _recentSessions = sessions;
        _totalCatalogExercises = exercises.length;
        _loadingDashboard = false;
      });
    }
  }

  Future<void> _switchStudent(UserProfile targetUser) async {
    if (targetUser.id == null || targetUser.id == _profile.id) return;
    final switched =
        await DatabaseService.instance.switchActiveUser(targetUser.id!);
    if (switched != null && mounted) {
      await _refreshDashboard();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(
              'Alumno activo cambiado a: ${switched.username} (${switched.weightUnit})',
            ),
          ),
        );
      }
    }
  }

  Future<UserProfile?> _showCreateOrEditUserDialog({
    UserProfile? editingUser,
  }) async {
    final isEditing = editingUser != null;
    final nameCtrl =
        TextEditingController(text: isEditing ? editingUser.username : '');
    String unit = isEditing ? editingUser.weightUnit : 'kg';
    String gender = isEditing ? editingUser.gender : 'male';

    return showDialog<UserProfile>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF161D2B),
          title: Text(
            isEditing
                ? 'Editar Alumno / Usuario'
                : 'Nuevo Alumno / Usuario',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sin contraseñas ni cuentas: identifica a cada alumno con su nombre o alias y selecciona su sexo para usar el Maniquí 3D correspondiente.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre o Alias del Alumno',
                  hintText: 'Ej: Martín, Sofía, Carlos...',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Sexo del Alumno (Maniquí 3D):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'male',
                    icon: Icon(Icons.male_rounded),
                    label: Text('Varón'),
                  ),
                  ButtonSegment(
                    value: 'female',
                    icon: Icon(Icons.female_rounded),
                    label: Text('Mujer'),
                  ),
                ],
                selected: {gender},
                onSelectionChanged: (s) {
                  setDialogState(() => gender = s.first);
                },
              ),
              const SizedBox(height: 14),
              const Text(
                'Unidad de Peso Preferida:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'kg', label: Text('Kilogramos (kg)')),
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
                final clean = nameCtrl.text.trim();
                if (clean.isEmpty) return;
                final UserProfile saved;
                if (isEditing && editingUser.id != null) {
                  saved = await DatabaseService.instance
                      .saveOrUpdateUserProfile(
                    clean,
                    weightUnit: unit,
                    gender: gender,
                    userId: editingUser.id,
                  );
                } else {
                  saved = await DatabaseService.instance.createOrSelectUser(
                    clean,
                    weightUnit: unit,
                    gender: gender,
                  );
                }
                if (ctx.mounted) {
                  Navigator.pop(ctx, saved);
                }
              },
              child: Text(isEditing ? 'Guardar Cambios' : 'Crear y Activar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUsersManagerModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131926),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          Future<void> reloadSheetUsers() async {
            await _refreshDashboard();
            if (sheetCtx.mounted) {
              setSheetState(() {});
            }
          }

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.65,
            minChildSize: 0.45,
            maxChildSize: 0.9,
            builder: (ctx, scrollCtrl) => ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.groups_rounded,
                      color: Color(0xFFCCFF00),
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alumnos / Usuarios de la App',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Cambia de alumno en 1 toque sin contraseñas',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        final created = await _showCreateOrEditUserDialog();
                        if (created != null) {
                          await reloadSheetUsers();
                          if (sheetCtx.mounted) {
                            Navigator.pop(sheetCtx);
                          }
                        }
                      },
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('Nuevo Alumno'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._allUsers.map((u) {
                  final isCurrent = u.id == _profile.id;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isCurrent
                            ? const Color(0xFFCCFF00)
                            : const Color(0xFF263248),
                        width: isCurrent ? 1.8 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      onTap: () async {
                        Navigator.pop(sheetCtx);
                        await _switchStudent(u);
                      },
                      leading: CircleAvatar(
                        backgroundColor: isCurrent
                            ? const Color(0xFFCCFF00)
                            : const Color(0xFF00E5FF).withOpacity(0.18),
                        foregroundColor:
                            isCurrent ? Colors.black : const Color(0xFF00E5FF),
                        child: Text(
                          u.username.isNotEmpty
                              ? u.username[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              u.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${u.genderLabel} • ${u.weightUnit.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFF00),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ACTIVO',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        isCurrent
                            ? 'Viendo sus rutinas, pesos e historial ahora'
                            : 'Toca para cambiar a este alumno',
                        style: TextStyle(
                          color: isCurrent
                              ? const Color(0xFFCCFF00)
                              : Colors.white54,
                          fontSize: 12.5,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Editar nombre o unidad',
                            icon: const Icon(Icons.edit_outlined,
                                color: Colors.white70, size: 20),
                            onPressed: () async {
                              final edited = await _showCreateOrEditUserDialog(
                                editingUser: u,
                              );
                              if (edited != null) {
                                await reloadSheetUsers();
                              }
                            },
                          ),
                          IconButton(
                            tooltip: 'Eliminar alumno',
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent, size: 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (dCtx) => AlertDialog(
                                  backgroundColor: const Color(0xFF161D2B),
                                  title: const Text('Eliminar Alumno'),
                                  content: Text(
                                    '¿Seguro que deseas eliminar a "${u.username}" junto con sus rutinas y sesiones registradas?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dCtx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(dCtx, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && u.id != null) {
                                final nextActive = await DatabaseService
                                    .instance
                                    .deleteUserProfile(u.id!);
                                if (nextActive == null) {
                                  if (sheetCtx.mounted) {
                                    Navigator.pop(sheetCtx);
                                  }
                                  if (mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const WelcomeUsernameScreen(),
                                      ),
                                    );
                                  }
                                } else {
                                  await reloadSheetUsers();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
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
            const Flexible(
              child: Text(
                'IRONPULSE ASSISTANT',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: Icon(
                _profile.isFemale
                    ? Icons.female_rounded
                    : Icons.male_rounded,
                size: 18,
                color: const Color(0xFFCCFF00),
              ),
              label: Text(
                '${_profile.username} (${_profile.genderLabel} • ${_profile.weightUnit}) ▾',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: _showUsersManagerModal,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Barra Rápida de Cambio de Alumno / Entrenador
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF141B29),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF26334D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.switch_account_rounded,
                        size: 18,
                        color: Color(0xFF00E5FF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Alumnos Registrados (${_allUsers.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () async {
                          final created = await _showCreateOrEditUserDialog();
                          if (created != null) {
                            await _refreshDashboard();
                          }
                        },
                        icon: const Icon(Icons.person_add_alt_1_rounded,
                            size: 16),
                        label: const Text('Agregar Alumno'),
                      ),
                      IconButton(
                        tooltip: 'Gestionar todos los alumnos',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.settings_outlined,
                            size: 18, color: Colors.white70),
                        onPressed: _showUsersManagerModal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _allUsers.map((u) {
                        final selected = u.id == _profile.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: selected,
                            selectedColor:
                                const Color(0xFFCCFF00).withOpacity(0.25),
                            avatar: CircleAvatar(
                              backgroundColor: selected
                                  ? const Color(0xFFCCFF00)
                                  : Colors.white24,
                              foregroundColor:
                                  selected ? Colors.black : Colors.white,
                              child: Text(
                                u.username.isNotEmpty
                                    ? u.username[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            label: Text(
                              u.username,
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                color: selected
                                    ? const Color(0xFFCCFF00)
                                    : Colors.white,
                              ),
                            ),
                            onSelected: (_) => _switchStudent(u),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
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
        key: ValueKey('routines_${_profile.id}_${_profile.username}_${_profile.gender}'),
        username: _profile.username,
        weightUnit: _profile.weightUnit,
        onDataChanged: _refreshDashboard,
      ),
      ExercisesCatalogScreen(
        key: ValueKey('catalog_${_profile.id}_${_profile.gender}'),
      ),
      ProgressHistoryScreen(
        key: ValueKey('progress_${_profile.id}_${_profile.username}'),
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
