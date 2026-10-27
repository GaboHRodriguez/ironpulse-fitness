import 'package:flutter/material.dart';
import '../data/exercise_catalog_seed.dart';
import '../models/fitness_models.dart';
import '../services/database_service.dart';
import '../widgets/exercise_technique_animation.dart';

class ExercisesCatalogScreen extends StatefulWidget {
  final bool selectionMode;

  const ExercisesCatalogScreen({
    super.key,
    this.selectionMode = false,
  });

  @override
  State<ExercisesCatalogScreen> createState() => _ExercisesCatalogScreenState();
}

class _ExercisesCatalogScreenState extends State<ExercisesCatalogScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedMuscle = 'Todos';
  String _selectedEquipment = 'Todos';
  List<Exercise> _exercises = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() => _loading = true);
    final list = await DatabaseService.instance.getAllExercises(
      muscleGroup: _selectedMuscle,
      equipment: _selectedEquipment,
      searchQuery: _searchCtrl.text,
    );
    if (mounted) {
      setState(() {
        _exercises = list;
        _loading = false;
      });
    }
  }

  Color _getEquipmentBadgeColor(String eq) {
    if (eq.contains('Barra')) return const Color(0xFF00E5FF);
    if (eq.contains('Mancuerna')) return const Color(0xFFCCFF00);
    if (eq.contains('Polea')) return const Color(0xFFFF9100);
    if (eq.contains('Máquina') || eq.contains('Multipower')) {
      return const Color(0xFFE040FB);
    }
    return const Color(0xFF69F0AE);
  }

  Future<void> _showCreateCustomExerciseDialog() async {
    final nameCtrl = TextEditingController();
    final secCtrl = TextEditingController();
    final instCtrl = TextEditingController(
      text: '1. Posición inicial estable y controlada.\n'
          '2. Ejecuta la fase concéntrica exhalando.\n'
          '3. Controla el descenso (fase excéntrica) en 2-3 segundos.',
    );
    final mistakesCtrl = TextEditingController(
      text: 'Evitar usar inercia lumbar o acortar el rango de movimiento.',
    );
    final gifUrlCtrl = TextEditingController();

    String muscle = ExerciseCatalogSeed.muscleGroups[1];
    String equipment = ExerciseCatalogSeed.equipmentTypes[1];
    String pattern = 'bench_press';

    final created = await showDialog<Exercise>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF161D2B),
          title: const Text('Nuevo Ejercicio Personalizado'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Ejercicio *',
                      hintText: 'Ej: Remo con Barra en Banco Inclinado',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: muscle,
                    dropdownColor: const Color(0xFF1E293B),
                    decoration: const InputDecoration(labelText: 'Grupo Muscular Principal'),
                    items: ExerciseCatalogSeed.muscleGroups
                        .where((m) => m != 'Todos')
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => muscle = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: equipment,
                    dropdownColor: const Color(0xFF1E293B),
                    decoration: const InputDecoration(
                      labelText: 'Modalidad / Equipamiento (Barra, Mancuerna, Polea...)',
                    ),
                    items: ExerciseCatalogSeed.equipmentTypes
                        .where((e) => e != 'Todos')
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => equipment = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: pattern,
                    dropdownColor: const Color(0xFF1E293B),
                    decoration: const InputDecoration(
                      labelText: 'Patrón de Animación Biomecánica',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'bench_press', child: Text('Empuje Horizontal (Press Banca / Fondos)')),
                      DropdownMenuItem(value: 'incline_press', child: Text('Empuje Inclinado')),
                      DropdownMenuItem(value: 'fly', child: Text('Aperturas / Cruces de Polea')),
                      DropdownMenuItem(value: 'lat_pulldown', child: Text('Tracción Vertical (Jalón / Dominadas)')),
                      DropdownMenuItem(value: 'row', child: Text('Tracción Horizontal (Remos)')),
                      DropdownMenuItem(value: 'overhead_press', child: Text('Empuje Vertical (Press Militar)')),
                      DropdownMenuItem(value: 'lateral_raise', child: Text('Elevaciones Hombro (Lateral / Frontal / Pájaros)')),
                      DropdownMenuItem(value: 'squat', child: Text('Sentadilla / Prensa / Cuádriceps')),
                      DropdownMenuItem(value: 'deadlift', child: Text('Bisagra de Cadera (Peso Muerto / RDL)')),
                      DropdownMenuItem(value: 'leg_extension', child: Text('Extensión de Rodilla en Máquina')),
                      DropdownMenuItem(value: 'leg_curl', child: Text('Flexión Femoral en Máquina')),
                      DropdownMenuItem(value: 'bicep_curl', child: Text('Flexión de Codo (Curl de Bíceps)')),
                      DropdownMenuItem(value: 'tricep_pushdown', child: Text('Extensión de Codo en Polea (Tríceps)')),
                      DropdownMenuItem(value: 'skullcrusher', child: Text('Press Francés / Rompecráneos')),
                      DropdownMenuItem(value: 'hip_thrust', child: Text('Empuje de Cadera (Hip Thrust / Core)')),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => pattern = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: secCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Músculos Secundarios',
                      hintText: 'Ej: Tríceps, Deltoides Anterior',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: instCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Instrucciones de Técnica Correcta',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: mistakesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Errores Comunes a Evitar',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: gifUrlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'URL de GIF o Imagen Animada (Opcional)',
                      hintText: 'https://.../ejercicio.gif',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Guardar Ejercicio'),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final newEx = Exercise(
                  name: nameCtrl.text.trim(),
                  muscleGroup: muscle,
                  secondaryMuscles: secCtrl.text.trim(),
                  equipment: equipment,
                  movementPattern: pattern,
                  instructions: instCtrl.text.trim(),
                  commonMistakes: mistakesCtrl.text.trim(),
                  externalMediaUrl: gifUrlCtrl.text.trim().isEmpty
                      ? null
                      : gifUrlCtrl.text.trim(),
                  isCustom: true,
                );
                final saved =
                    await DatabaseService.instance.insertCustomExercise(newEx);
                Navigator.pop(ctx, saved);
              },
            ),
          ],
        ),
      ),
    );

    if (created != null) {
      await _loadExercises();
      if (widget.selectionMode && mounted) {
        Navigator.pop(context, created);
      }
    }
  }

  void _showExerciseDetailModal(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121824),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.55,
        maxChildSize: 0.94,
        builder: (ctx, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (widget.selectionMode)
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context, exercise);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Elegir'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoBadge(
                  icon: Icons.accessibility_new_rounded,
                  text: 'Músculo: ${exercise.muscleGroup}',
                  color: const Color(0xFFCCFF00),
                ),
                _InfoBadge(
                  icon: Icons.fitness_center_rounded,
                  text: 'Modalidad: ${exercise.equipment}',
                  color: _getEquipmentBadgeColor(exercise.equipment),
                ),
                _InfoBadge(
                  icon: Icons.speed_rounded,
                  text: 'Nivel: ${exercise.difficulty}',
                  color: Colors.white70,
                ),
              ],
            ),
            if (exercise.secondaryMuscles.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Sinergistas / Secundarios: ${exercise.secondaryMuscles}',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            // Animación Técnica Biomecánica + GIF
            ExerciseTechniqueAnimation(
              exercise: exercise,
              height: 250,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2233),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF28344B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: Color(0xFFCCFF00), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Ejecución Técnica Correcta Paso a Paso',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFFCCFF00),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    exercise.instructions,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (exercise.commonMistakes.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF291820),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.redAccent.withOpacity(0.45)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.redAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Errores Técnicos Comunes a Evitar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exercise.commonMistakes,
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.45,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectionMode
              ? 'Seleccionar Ejercicio'
              : 'Enciclopedia de Musculación (${_exercises.length})',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              onPressed: _showCreateCustomExerciseDialog,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Crear Ejercicio'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros por Grupo Muscular y Equipamiento
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(
              color: Color(0xFF131926),
              border: Border(
                bottom: BorderSide(color: Color(0xFF242F46)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => _loadExercises(),
                  decoration: InputDecoration(
                    hintText:
                        'Buscar por ejercicio, músculo o modalidad (barra, mancuerna, polea...)',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              _loadExercises();
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                // Filtro por Grupo Muscular
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ExerciseCatalogSeed.muscleGroups.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final m = ExerciseCatalogSeed.muscleGroups[i];
                      final selected = _selectedMuscle == m;
                      return ChoiceChip(
                        label: Text(m),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedMuscle = m);
                          _loadExercises();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Filtro por Modalidad / Equipamiento (Barras, Mancuernas, Poleas, Máquinas...)
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ExerciseCatalogSeed.equipmentTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final eq = ExerciseCatalogSeed.equipmentTypes[i];
                      final selected = _selectedEquipment == eq;
                      return FilterChip(
                        label: Text(
                          eq == 'Todos' ? 'Equipamiento: Todos' : eq,
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedEquipment = eq);
                          _loadExercises();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Lista de ejercicios con vista previa técnica
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _exercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded,
                                size: 54, color: Colors.white38),
                            const SizedBox(height: 12),
                            const Text(
                              'No se encontraron ejercicios con esos filtros.',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedMuscle = 'Todos';
                                  _selectedEquipment = 'Todos';
                                  _searchCtrl.clear();
                                });
                                _loadExercises();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Limpiar filtros'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _exercises.length,
                        itemBuilder: (ctx, idx) {
                          final ex = _exercises[idx];
                          final eqColor = _getEquipmentBadgeColor(ex.equipment);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showExerciseDetailModal(ex),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Mini animación biomecánica en vivo
                                    SizedBox(
                                      width: 112,
                                      height: 92,
                                      child: IgnorePointer(
                                        child: ExerciseTechniqueAnimation(
                                          exercise: ex,
                                          height: 92,
                                          showControls: false,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex.name,
                                            style: const TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: [
                                              _InfoBadge(
                                                icon: Icons.accessibility_new,
                                                text: ex.muscleGroup,
                                                color: const Color(0xFFCCFF00),
                                              ),
                                              _InfoBadge(
                                                icon: Icons.fitness_center,
                                                text: ex.equipment,
                                                color: eqColor,
                                              ),
                                            ],
                                          ),
                                          if (ex.secondaryMuscles.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              ex.secondaryMuscles,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (widget.selectionMode)
                                      FilledButton.icon(
                                        onPressed: () =>
                                            Navigator.pop(context, ex),
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text('Añadir'),
                                      )
                                    else
                                      IconButton(
                                        tooltip: 'Ver animación y técnica',
                                        icon: const Icon(
                                          Icons.play_circle_outline_rounded,
                                          color: Color(0xFFCCFF00),
                                          size: 28,
                                        ),
                                        onPressed: () =>
                                            _showExerciseDetailModal(ex),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
