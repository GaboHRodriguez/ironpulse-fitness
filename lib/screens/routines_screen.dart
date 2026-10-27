import 'package:flutter/material.dart';
import '../data/exercise_catalog_seed.dart';
import '../models/fitness_models.dart';
import '../services/database_service.dart';
import 'exercises_catalog_screen.dart';
import 'workout_session_screen.dart';

class RoutinesScreen extends StatefulWidget {
  final String username;
  final String weightUnit;
  final VoidCallback onDataChanged;

  const RoutinesScreen({
    super.key,
    required this.username,
    required this.weightUnit,
    required this.onDataChanged,
  });

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  List<Routine> _routines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    setState(() => _loading = true);
    final list = await DatabaseService.instance.getAllRoutines();
    if (mounted) {
      setState(() {
        _routines = list;
        _loading = false;
      });
    }
  }

  Future<void> _openRoutineEditor({Routine? existingRoutine}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(existingRoutine: existingRoutine),
      ),
    );
    if (saved == true) {
      await _loadRoutines();
      widget.onDataChanged();
    }
  }

  Future<void> _showPresetTemplatesModal() async {
    final templates = ExerciseCatalogSeed.getPresetRoutineTemplates();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131926),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (ctx, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Plantillas de Rutinas Prearmadas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hola ${widget.username}, puedes importar cualquiera de estas divisiones profesionales y luego modificar sus días, series o ejercicios a tu gusto.',
              style: const TextStyle(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            ...templates.map((tpl) {
              final daysList = tpl['days'] as List<dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFF00).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${tpl['days_per_week']} Días / Semana',
                              style: const TextStyle(
                                color: Color(0xFFCCFF00),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await DatabaseService.instance
                                  .importPresetTemplate(tpl);
                              await _loadRoutines();
                              widget.onDataChanged();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '¡Rutina "${tpl['name']}" importada para ${widget.username}!',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.download_done_rounded,
                                size: 18),
                            label: const Text('Usar esta Rutina'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tpl['name'] as String,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tpl['description'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: daysList.map((d) {
                          return Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(
                              d['day_name'] as String,
                              style: const TextStyle(fontSize: 11.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteRoutine(Routine routine) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161D2B),
        title: const Text('Eliminar Rutina Semanal'),
        content: Text(
          '¿Seguro que deseas eliminar la rutina "${routine.name}", ${widget.username}? '
          'Tus registros históricos de pesos seguirán guardados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && routine.id != null) {
      await DatabaseService.instance.deleteRoutine(routine.id!);
      await _loadRoutines();
      widget.onDataChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutinas Semanales'),
        actions: [
          OutlinedButton.icon(
            onPressed: _showPresetTemplatesModal,
            icon: const Icon(Icons.auto_awesome_rounded, size: 17),
            label: const Text('Plantillas'),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => _openRoutineEditor(),
              icon: const Icon(Icons.add),
              label: const Text('Nueva Rutina'),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _routines.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 68,
                          color: Color(0xFFCCFF00),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '¡Armemos tu plan semanal, ${widget.username}!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Puedes crear una rutina desde cero eligiendo cuántos días a la semana entrenas, los ejercicios, series y repeticiones, o cargar una plantilla prearmada (Push/Pull/Legs, Torso/Pierna, Full Body).',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, height: 1.4),
                        ),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            FilledButton.icon(
                              onPressed: () => _openRoutineEditor(),
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Crear Rutina Personalizada'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _showPresetTemplatesModal,
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Importar Plantilla Prearmada'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _routines.length,
                  itemBuilder: (ctx, i) {
                    final routine = _routines[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: routine.isActive
                              ? const Color(0xFFCCFF00)
                              : const Color(0xFF28344B),
                          width: routine.isActive ? 1.8 : 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (routine.isActive)
                                  Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCCFF00),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'RUTINA ACTIVA',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${routine.days.length} Días / Semana',
                                    style: const TextStyle(
                                      color: Color(0xFF00E5FF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (!routine.isActive && routine.id != null)
                                  TextButton.icon(
                                    onPressed: () async {
                                      await DatabaseService.instance
                                          .setActiveRoutine(routine.id!);
                                      await _loadRoutines();
                                      widget.onDataChanged();
                                    },
                                    icon: const Icon(
                                        Icons.check_circle_outline,
                                        size: 18),
                                    label: const Text('Activar'),
                                  ),
                                IconButton(
                                  tooltip: 'Modificar Rutina',
                                  icon: const Icon(Icons.edit_outlined,
                                      color: Colors.white70),
                                  onPressed: () => _openRoutineEditor(
                                      existingRoutine: routine),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar Rutina',
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent),
                                  onPressed: () =>
                                      _confirmDeleteRoutine(routine),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              routine.name,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            if (routine.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                routine.description,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const Divider(height: 24),
                            // Listado de días de la rutina semanal
                            ...routine.days.map((day) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111622),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: const Color(0xFF232E42)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            day.dayName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFFCCFF00),
                                            ),
                                          ),
                                        ),
                                        FilledButton.tonalIcon(
                                          onPressed: () async {
                                            final logged =
                                                await Navigator.push<bool>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    WorkoutSessionScreen(
                                                  username: widget.username,
                                                  weightUnit: widget.weightUnit,
                                                  routine: routine,
                                                  routineDay: day,
                                                ),
                                              ),
                                            );
                                            if (logged == true) {
                                              widget.onDataChanged();
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.play_arrow_rounded,
                                              size: 18),
                                          label: const Text('Entrenar Día'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (day.exercises.isEmpty)
                                      const Text(
                                        'Sin ejercicios asignados aún.',
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12.5),
                                      )
                                    else
                                      ...day.exercises.map((item) {
                                        final exName = item.exercise?.name ??
                                            'Ejercicio #${item.exerciseId}';
                                        final eq =
                                            item.exercise?.equipment ?? '';
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.bolt_rounded,
                                                size: 15,
                                                color: Color(0xFF00E5FF),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  '$exName ($eq)',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white10,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${item.targetSets} series × ${item.targetReps} reps',
                                                  style: const TextStyle(
                                                    color: Color(0xFFCCFF00),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// =============================================================================
// EDITOR DE RUTINAS SEMANALES (Crear o Modificar Días, Ejercicios, Series y Reps)
// =============================================================================
class RoutineEditorScreen extends StatefulWidget {
  final Routine? existingRoutine;

  const RoutineEditorScreen({super.key, this.existingRoutine});

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late int _daysPerWeek;
  late List<_EditableRoutineDay> _editableDays;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final r = widget.existingRoutine;
    _nameCtrl = TextEditingController(
      text: r?.name ?? 'Mi Rutina de Hipertrofia',
    );
    _descCtrl = TextEditingController(
      text: r?.description ?? 'Planificación semanal personalizada',
    );
    _isActive = r?.isActive ?? true;
    _daysPerWeek = r != null && r.days.isNotEmpty ? r.days.length : 4;

    if (r != null && r.days.isNotEmpty) {
      _editableDays = r.days.map((d) {
        return _EditableRoutineDay(
          nameCtrl: TextEditingController(text: d.dayName),
          exercises: List<RoutineExerciseItem>.from(d.exercises),
        );
      }).toList();
    } else {
      _editableDays = List.generate(
        _daysPerWeek,
        (i) => _EditableRoutineDay(
          nameCtrl: TextEditingController(text: 'Día ${i + 1}: Entrenamiento'),
          exercises: [],
        ),
      );
    }
  }

  void _updateDaysCount(int newCount) {
    setState(() {
      _daysPerWeek = newCount;
      while (_editableDays.length < newCount) {
        final idx = _editableDays.length + 1;
        _editableDays.add(
          _EditableRoutineDay(
            nameCtrl: TextEditingController(text: 'Día $idx: Entrenamiento'),
            exercises: [],
          ),
        );
      }
      if (_editableDays.length > newCount) {
        _editableDays = _editableDays.sublist(0, newCount);
      }
    });
  }

  Future<void> _addExerciseToDay(int dayIndex) async {
    final selectedExercise = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
        builder: (_) => const ExercisesCatalogScreen(selectionMode: true),
      ),
    );

    if (selectedExercise == null || selectedExercise.id == null) return;

    // Solicitar cantidad de series y repeticiones objetivo
    final setsCtrl = TextEditingController(text: '4');
    final repsCtrl = TextEditingController(text: '8-12');

    final configured = await showDialog<RoutineExerciseItem>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161D2B),
        title: Text(selectedExercise.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modalidad: ${selectedExercise.equipment} • ${selectedExercise.muscleGroup}',
              style: const TextStyle(color: Color(0xFFCCFF00), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: setsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad de Series',
                hintText: 'Ej: 4',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsCtrl,
              decoration: const InputDecoration(
                labelText: 'Repeticiones por Serie',
                hintText: 'Ej: 8-12, 10, 15, Al fallo',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final sets = int.tryParse(setsCtrl.text.trim()) ?? 4;
              final reps =
                  repsCtrl.text.trim().isEmpty ? '10' : repsCtrl.text.trim();
              Navigator.pop(
                ctx,
                RoutineExerciseItem(
                  exerciseId: selectedExercise.id!,
                  orderIndex: _editableDays[dayIndex].exercises.length,
                  targetSets: sets.clamp(1, 20),
                  targetReps: reps,
                  exercise: selectedExercise,
                ),
              );
            },
            child: const Text('Agregar al Día'),
          ),
        ],
      ),
    );

    if (configured != null) {
      setState(() {
        _editableDays[dayIndex].exercises.add(configured);
      });
    }
  }

  Future<void> _editSetRepsDialog(int dayIndex, int exIndex) async {
    final item = _editableDays[dayIndex].exercises[exIndex];
    final setsCtrl = TextEditingController(text: item.targetSets.toString());
    final repsCtrl = TextEditingController(text: item.targetReps);

    final updated = await showDialog<RoutineExerciseItem>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161D2B),
        title: Text(item.exercise?.name ?? 'Editar Series y Repeticiones'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: setsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad de Series'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsCtrl,
              decoration: const InputDecoration(labelText: 'Repeticiones'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final sets = int.tryParse(setsCtrl.text.trim()) ?? item.targetSets;
              final reps = repsCtrl.text.trim().isEmpty
                  ? item.targetReps
                  : repsCtrl.text.trim();
              Navigator.pop(
                ctx,
                item.copyWith(targetSets: sets.clamp(1, 20), targetReps: reps),
              );
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );

    if (updated != null) {
      setState(() {
        _editableDays[dayIndex].exercises[exIndex] = updated;
      });
    }
  }

  Future<void> _saveRoutine() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un nombre para la rutina.')),
      );
      return;
    }

    final days = <RoutineDay>[];
    for (int i = 0; i < _editableDays.length; i++) {
      final ed = _editableDays[i];
      days.add(
        RoutineDay(
          dayNumber: i + 1,
          dayName: ed.nameCtrl.text.trim().isEmpty
              ? 'Día ${i + 1}'
              : ed.nameCtrl.text.trim(),
          exercises: ed.exercises,
        ),
      );
    }

    final routine = Routine(
      id: widget.existingRoutine?.id,
      name: _nameCtrl.text.trim(),
      daysPerWeek: days.length,
      description: _descCtrl.text.trim(),
      isActive: _isActive,
      createdAt:
          widget.existingRoutine?.createdAt ?? DateTime.now().toIso8601String(),
      days: days,
    );

    await DatabaseService.instance.saveRoutine(routine);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRoutine != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEditing ? 'Modificar Rutina Semanal' : 'Crear Rutina Semanal'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saveRoutine,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Guardar Rutina'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuración General de la Rutina',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCCFF00),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Rutina',
                      hintText: 'Ej: Rutina Hipertrofia 4 Días',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Descripción u Objetivo (Opcional)',
                      hintText: 'Ej: Enfoque en fuerza y sobrecarga progresiva',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cantidad de Días de Entrenamiento por Semana:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (idx) {
                      final d = idx + 1;
                      final selected = _daysPerWeek == d;
                      return ChoiceChip(
                        label: Text('$d ${d == 1 ? "Día" : "Días"}'),
                        selected: selected,
                        onSelected: (_) => _updateDaysCount(d),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Establecer como mi rutina activa'),
                    value: _isActive,
                    activeColor: const Color(0xFFCCFF00),
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tarjetas de configuración de cada día de la semana
          ...List.generate(_editableDays.length, (dayIdx) {
            final edDay = _editableDays[dayIdx];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFCCFF00),
                          foregroundColor: Colors.black,
                          child: Text(
                            '${dayIdx + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: edDay.nameCtrl,
                            decoration: InputDecoration(
                              labelText: 'Nombre del Día ${dayIdx + 1}',
                              hintText: 'Ej: Día ${dayIdx + 1} - Pecho y Bíceps',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.tonalIcon(
                          onPressed: () => _addExerciseToDay(dayIdx),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Agregar Ejercicio'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (edDay.exercises.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111622),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Text(
                          'Aún no has agregado ejercicios a este día. Pulsa "Agregar Ejercicio" para elegir barras, mancuernas, poleas o máquinas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      )
                    else
                      ...List.generate(edDay.exercises.length, (exIdx) {
                        final item = edDay.exercises[exIdx];
                        final ex = item.exercise;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111622),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF253047)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${exIdx + 1}.',
                                style: const TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex?.name ?? 'Ejercicio',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${ex?.equipment ?? ""} • ${ex?.muscleGroup ?? ""}',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => _editSetRepsDialog(dayIdx, exIdx),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCCFF00)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFCCFF00)
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${item.targetSets} series × ${item.targetReps}',
                                        style: const TextStyle(
                                          color: Color(0xFFCCFF00),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.edit,
                                        size: 13,
                                        color: Color(0xFFCCFF00),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Quitar ejercicio',
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    edDay.exercises.removeAt(exIdx);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _EditableRoutineDay {
  final TextEditingController nameCtrl;
  final List<RoutineExerciseItem> exercises;

  _EditableRoutineDay({
    required this.nameCtrl,
    required this.exercises,
  });
}
