import 'dart:async';
import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../services/database_service.dart';
import '../widgets/exercise_technique_animation.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final String username;
  final String weightUnit;
  final Routine routine;
  final RoutineDay routineDay;

  const WorkoutSessionScreen({
    super.key,
    required this.username,
    required this.weightUnit,
    required this.routine,
    required this.routineDay,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final List<_ExerciseSessionTracker> _trackers = [];
  bool _loading = true;
  late Timer _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initSessionData();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (final tr in _trackers) {
      for (final s in tr.sets) {
        s.weightCtrl.dispose();
        s.repsCtrl.dispose();
      }
    }
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int _parseDefaultReps(String targetReps) {
    final match = RegExp(r'\d+').firstMatch(targetReps);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 10;
    }
    return 10;
  }

  Future<void> _initSessionData() async {
    setState(() => _loading = true);
    final List<_ExerciseSessionTracker> list = [];

    for (final item in widget.routineDay.exercises) {
      final ex = item.exercise ??
          await DatabaseService.instance.getExerciseById(item.exerciseId);
      if (ex == null) continue;

      // Consultar la última sesión guardada para este ejercicio (Serie por Serie)
      final lastSetsMap = await DatabaseService.instance
          .getLastSessionSetsForExercise(item.exerciseId);
      final prLog = await DatabaseService.instance
          .getPersonalRecordForExercise(item.exerciseId);

      final defaultReps = _parseDefaultReps(item.targetReps);
      final List<_SetEntryController> setEntries = [];

      for (int sNum = 1; sNum <= item.targetSets; sNum++) {
        // Si existe registro de esa serie exacta en la última sesión, usarlo;
        // si no, usar la serie 1 anterior como referencia para saber con cuánto empezar
        final prevLog = lastSetsMap[sNum] ?? lastSetsMap[1];
        final initialWeight = prevLog != null
            ? (prevLog.weight % 1 == 0
                ? prevLog.weight.toInt().toString()
                : prevLog.weight.toString())
            : '';
        final initialReps =
            prevLog != null ? prevLog.reps.toString() : defaultReps.toString();

        setEntries.add(
          _SetEntryController(
            setNumber: sNum,
            previousLog: prevLog,
            weightCtrl: TextEditingController(text: initialWeight),
            repsCtrl: TextEditingController(text: initialReps),
            isCompleted: false,
          ),
        );
      }

      list.add(
        _ExerciseSessionTracker(
          routineItem: item,
          exercise: ex,
          lastSessionSets: lastSetsMap,
          personalRecord: prLog,
          sets: setEntries,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _trackers
          ..clear()
          ..addAll(list);
        _loading = false;
      });
    }
  }

  void _addExtraSet(_ExerciseSessionTracker tracker) {
    setState(() {
      final nextSetNumber = tracker.sets.length + 1;
      final lastSet = tracker.sets.isNotEmpty ? tracker.sets.last : null;
      final prevLog = tracker.lastSessionSets[nextSetNumber] ??
          lastSet?.previousLog;

      tracker.sets.add(
        _SetEntryController(
          setNumber: nextSetNumber,
          previousLog: prevLog,
          weightCtrl: TextEditingController(
            text: lastSet?.weightCtrl.text ?? '',
          ),
          repsCtrl: TextEditingController(
            text: lastSet?.repsCtrl.text ?? '10',
          ),
          isCompleted: false,
        ),
      );
    });
  }

  void _removeLastSet(_ExerciseSessionTracker tracker) {
    if (tracker.sets.length <= 1) return;
    setState(() {
      final removed = tracker.sets.removeLast();
      removed.weightCtrl.dispose();
      removed.repsCtrl.dispose();
    });
  }

  void _adjustWeight(TextEditingController ctrl, double delta) {
    final current = double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0.0;
    final next = (current + delta).clamp(0.0, 1500.0);
    ctrl.text = next % 1 == 0 ? next.toInt().toString() : next.toStringAsFixed(1);
    setState(() {});
  }

  Future<void> _finishAndSaveWorkout() async {
    final List<WorkoutSetLog> logsToSave = [];
    final nowIso = DateTime.now().toIso8601String();

    for (final tr in _trackers) {
      for (final s in tr.sets) {
        final w = double.tryParse(s.weightCtrl.text.replaceAll(',', '.')) ?? 0.0;
        final r = int.tryParse(s.repsCtrl.text.trim()) ?? 0;
        // Guardar todas las series que tengan peso o hayan sido marcadas como completadas
        if (s.isCompleted || w > 0) {
          logsToSave.add(
            WorkoutSetLog(
              exerciseId: tr.exercise.id!,
              setNumber: s.setNumber,
              weight: w,
              reps: r > 0 ? r : 1,
              isCompleted: true,
              loggedAt: nowIso,
            ),
          );
        }
      }
    }

    if (logsToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.username}, ingresa al menos el peso de una serie o márcala como completada antes de guardar.',
          ),
        ),
      );
      return;
    }

    final session = WorkoutSession(
      routineId: widget.routine.id,
      routineDayId: widget.routineDay.id,
      routineName: widget.routine.name,
      dayName: widget.routineDay.dayName,
      sessionDate: nowIso,
      durationSeconds: _elapsedSeconds,
      setLogs: logsToSave,
    );

    await DatabaseService.instance.saveWorkoutSession(session);

    if (mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF161D2B),
          title: Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: Color(0xFFCCFF00), size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text('¡Gran entrenamiento, ${widget.username}!'),
              ),
            ],
          ),
          content: Text(
            'Se han guardado ${logsToSave.length} series en la base de datos.\n\n'
            'En tu próxima sesión de "${widget.routineDay.dayName}", el asistente recordará automáticamente con cuánto peso comenzaste y terminaste cada ejercicio.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.routineDay.dayName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Atleta: ${widget.username} • Tiempo: ${_formatDuration(_elapsedSeconds)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFFCCFF00)),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _finishAndSaveWorkout,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Finalizar y Guardar Pesos'),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _trackers.isEmpty
              ? const Center(
                  child: Text('Este día no tiene ejercicios configurados.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _trackers.length,
                  itemBuilder: (ctx, exIdx) {
                    final tr = _trackers[exIdx];
                    final firstPrev = tr.lastSessionSets[1];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 18),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Encabezado del Ejercicio + Botón para desplegar Animación Técnica
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      const Color(0xFF00E5FF).withOpacity(0.18),
                                  foregroundColor: const Color(0xFF00E5FF),
                                  child: Text(
                                    '${exIdx + 1}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tr.exercise.name,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Modalidad: ${tr.exercise.equipment} • Meta: ${tr.routineItem.targetSets} series × ${tr.routineItem.targetReps} reps',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      tr.showAnimation = !tr.showAnimation;
                                    });
                                  },
                                  icon: Icon(
                                    tr.showAnimation
                                        ? Icons.visibility_off_outlined
                                        : Icons.play_circle_outline,
                                    size: 17,
                                  ),
                                  label: Text(
                                    tr.showAnimation ? 'Ocultar' : 'Técnica',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),

                            // Banner de Memoria Inteligente (Con cuánto peso comenzar hoy)
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(
                                color: firstPrev != null
                                    ? const Color(0xFFCCFF00).withOpacity(0.12)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: firstPrev != null
                                      ? const Color(0xFFCCFF00).withOpacity(0.45)
                                      : Colors.white12,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    firstPrev != null
                                        ? Icons.history_edu_rounded
                                        : Icons.info_outline_rounded,
                                    color: firstPrev != null
                                        ? const Color(0xFFCCFF00)
                                        : Colors.white60,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      firstPrev != null
                                          ? 'Última vez comenzaste la Serie 1 con ${firstPrev.weight} ${widget.weightUnit} (${firstPrev.reps} reps). '
                                              '${tr.personalRecord != null ? "• Récord: ${tr.personalRecord!.weight} ${widget.weightUnit}" : ""}'
                                          : 'Primera vez registrando este ejercicio. Anota el peso de cada serie para recordarlo en tu próxima sesión.',
                                      style: TextStyle(
                                        color: firstPrev != null
                                            ? const Color(0xFFCCFF00)
                                            : Colors.white70,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Animación técnica desplegable dentro del entrenamiento
                            if (tr.showAnimation) ...[
                              const SizedBox(height: 12),
                              ExerciseTechniqueAnimation(
                                exercise: tr.exercise,
                                height: 215,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tr.exercise.instructions,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),
                            ],

                            const SizedBox(height: 14),
                            // Encabezados de la tabla de series
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 48,
                                    child: Text(
                                      'SERIE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 3,
                                    child: Text(
                                      'ANTERIOR',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'PESO (${widget.weightUnit.toUpperCase()})',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    flex: 2,
                                    child: Text(
                                      'REPS',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 44,
                                    child: Center(
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Filas de cada serie individual
                            ...tr.sets.map((s) {
                              final prevText = s.previousLog != null
                                  ? '${s.previousLog!.weight} ${widget.weightUnit} × ${s.previousLog!.reps}'
                                  : 'Sin registro';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: s.isCompleted
                                      ? const Color(0xFFCCFF00)
                                          .withOpacity(0.12)
                                      : const Color(0xFF101520),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: s.isCompleted
                                        ? const Color(0xFFCCFF00)
                                        : const Color(0xFF232F46),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Número de Serie
                                    SizedBox(
                                      width: 44,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white10,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '#${s.setNumber}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Peso de la vez anterior en esta serie
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        prevText,
                                        style: TextStyle(
                                          color: s.previousLog != null
                                              ? const Color(0xFF00E5FF)
                                              : Colors.white38,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    // Input de Peso con botones rápidos -2.5 / +2.5
                                    Expanded(
                                      flex: 4,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () => _adjustWeight(
                                                s.weightCtrl, -2.5),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white10,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(Icons.remove,
                                                  size: 15),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: TextField(
                                              controller: s.weightCtrl,
                                              keyboardType:
                                                  const TextInputType
                                                      .numberWithOptions(
                                                      decimal: true),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 8,
                                                ),
                                                hintText: '0',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          InkWell(
                                            onTap: () => _adjustWeight(
                                                s.weightCtrl, 2.5),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white10,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(Icons.add,
                                                  size: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Input de Repeticiones realizadas
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: s.repsCtrl,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 8,
                                          ),
                                          hintText: '10',
                                        ),
                                      ),
                                    ),
                                    // Check de serie completada
                                    SizedBox(
                                      width: 44,
                                      child: IconButton(
                                        icon: Icon(
                                          s.isCompleted
                                              ? Icons.check_circle_rounded
                                              : Icons
                                                  .radio_button_unchecked_rounded,
                                          color: s.isCompleted
                                              ? const Color(0xFFCCFF00)
                                              : Colors.white54,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            s.isCompleted = !s.isCompleted;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Botones para agregar o quitar series en vivo
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => _addExtraSet(tr),
                                  icon: const Icon(Icons.add, size: 17),
                                  label: const Text('Añadir Serie'),
                                ),
                                if (tr.sets.length > 1)
                                  TextButton.icon(
                                    onPressed: () => _removeLastSet(tr),
                                    icon: const Icon(Icons.remove,
                                        size: 17, color: Colors.white54),
                                    label: const Text(
                                      'Quitar última',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _ExerciseSessionTracker {
  final RoutineExerciseItem routineItem;
  final Exercise exercise;
  final Map<int, WorkoutSetLog> lastSessionSets;
  final WorkoutSetLog? personalRecord;
  final List<_SetEntryController> sets;
  bool showAnimation = false;

  _ExerciseSessionTracker({
    required this.routineItem,
    required this.exercise,
    required this.lastSessionSets,
    this.personalRecord,
    required this.sets,
  });
}

class _SetEntryController {
  final int setNumber;
  final WorkoutSetLog? previousLog;
  final TextEditingController weightCtrl;
  final TextEditingController repsCtrl;
  bool isCompleted;

  _SetEntryController({
    required this.setNumber,
    this.previousLog,
    required this.weightCtrl,
    required this.repsCtrl,
    this.isCompleted = false,
  });
}
