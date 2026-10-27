class UserProfile {
  final int? id;
  final String username;
  final String weightUnit; // 'kg' or 'lb'
  final String createdAt;

  UserProfile({
    this.id,
    required this.username,
    this.weightUnit = 'kg',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'weight_unit': weightUnit,
      'created_at': createdAt,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      username: map['username'] as String,
      weightUnit: (map['weight_unit'] as String?) ?? 'kg',
      createdAt: (map['created_at'] as String?) ?? '',
    );
  }

  UserProfile copyWith({
    int? id,
    String? username,
    String? weightUnit,
    String? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      weightUnit: weightUnit ?? this.weightUnit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Exercise {
  final int? id;
  final String name;
  final String muscleGroup;
  final String secondaryMuscles;
  final String equipment; // Barra, Mancuernas, Polea, Máquina, Peso Corporal, Barra EZ, Kettlebell, Multipower
  final String movementPattern; // bench_press, incline_press, fly, squat, deadlift, lunge, leg_extension, leg_curl, calf_raise, lat_pulldown, row, overhead_press, lateral_raise, bicep_curl, tricep_pushdown, skullcrusher, crunch, plank, hip_thrust, shrug
  final String difficulty; // Principiante, Intermedio, Avanzado
  final String instructions;
  final String commonMistakes;
  final String? externalMediaUrl; // URL de GIF o Video demostrativo
  final bool isCustom;

  Exercise({
    this.id,
    required this.name,
    required this.muscleGroup,
    required this.secondaryMuscles,
    required this.equipment,
    required this.movementPattern,
    this.difficulty = 'Intermedio',
    required this.instructions,
    required this.commonMistakes,
    this.externalMediaUrl,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'muscle_group': muscleGroup,
      'secondary_muscles': secondaryMuscles,
      'equipment': equipment,
      'movement_pattern': movementPattern,
      'difficulty': difficulty,
      'instructions': instructions,
      'common_mistakes': commonMistakes,
      'external_media_url': externalMediaUrl,
      'is_custom': isCustom ? 1 : 0,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int?,
      name: map['name'] as String,
      muscleGroup: map['muscle_group'] as String,
      secondaryMuscles: (map['secondary_muscles'] as String?) ?? '',
      equipment: map['equipment'] as String,
      movementPattern: (map['movement_pattern'] as String?) ?? 'bench_press',
      difficulty: (map['difficulty'] as String?) ?? 'Intermedio',
      instructions: (map['instructions'] as String?) ?? '',
      commonMistakes: (map['common_mistakes'] as String?) ?? '',
      externalMediaUrl: map['external_media_url'] as String?,
      isCustom: (map['is_custom'] as int? ?? 0) == 1,
    );
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? muscleGroup,
    String? secondaryMuscles,
    String? equipment,
    String? movementPattern,
    String? difficulty,
    String? instructions,
    String? commonMistakes,
    String? externalMediaUrl,
    bool? isCustom,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      equipment: equipment ?? this.equipment,
      movementPattern: movementPattern ?? this.movementPattern,
      difficulty: difficulty ?? this.difficulty,
      instructions: instructions ?? this.instructions,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      externalMediaUrl: externalMediaUrl ?? this.externalMediaUrl,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

class Routine {
  final int? id;
  final String name;
  final int daysPerWeek;
  final String description;
  final bool isActive;
  final String createdAt;
  final List<RoutineDay> days;

  Routine({
    this.id,
    required this.name,
    required this.daysPerWeek,
    required this.description,
    this.isActive = false,
    required this.createdAt,
    this.days = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'days_per_week': daysPerWeek,
      'description': description,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map, {List<RoutineDay> days = const []}) {
    return Routine(
      id: map['id'] as int?,
      name: map['name'] as String,
      daysPerWeek: map['days_per_week'] as int,
      description: (map['description'] as String?) ?? '',
      isActive: (map['is_active'] as int? ?? 0) == 1,
      createdAt: (map['created_at'] as String?) ?? '',
      days: days,
    );
  }

  Routine copyWith({
    int? id,
    String? name,
    int? daysPerWeek,
    String? description,
    bool? isActive,
    String? createdAt,
    List<RoutineDay>? days,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      days: days ?? this.days,
    );
  }
}

class RoutineDay {
  final int? id;
  final int? routineId;
  final int dayNumber; // 1..7
  final String dayName; // Ej: "Día 1 - Pecho y Tríceps"
  final List<RoutineExerciseItem> exercises;

  RoutineDay({
    this.id,
    this.routineId,
    required this.dayNumber,
    required this.dayName,
    this.exercises = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      'day_number': dayNumber,
      'day_name': dayName,
    };
  }

  factory RoutineDay.fromMap(
    Map<String, dynamic> map, {
    List<RoutineExerciseItem> exercises = const [],
  }) {
    return RoutineDay(
      id: map['id'] as int?,
      routineId: map['routine_id'] as int?,
      dayNumber: map['day_number'] as int,
      dayName: map['day_name'] as String,
      exercises: exercises,
    );
  }

  RoutineDay copyWith({
    int? id,
    int? routineId,
    int? dayNumber,
    String? dayName,
    List<RoutineExerciseItem>? exercises,
  }) {
    return RoutineDay(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      dayNumber: dayNumber ?? this.dayNumber,
      dayName: dayName ?? this.dayName,
      exercises: exercises ?? this.exercises,
    );
  }
}

class RoutineExerciseItem {
  final int? id;
  final int? routineDayId;
  final int exerciseId;
  final int orderIndex;
  final int targetSets;
  final String targetReps; // Ej: "8-12" o "10"
  final String notes;
  final Exercise? exercise;

  RoutineExerciseItem({
    this.id,
    this.routineDayId,
    required this.exerciseId,
    required this.orderIndex,
    required this.targetSets,
    required this.targetReps,
    this.notes = '',
    this.exercise,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (routineDayId != null) 'routine_day_id': routineDayId,
      'exercise_id': exerciseId,
      'order_index': orderIndex,
      'target_sets': targetSets,
      'target_reps': targetReps,
      'notes': notes,
    };
  }

  factory RoutineExerciseItem.fromMap(Map<String, dynamic> map, {Exercise? exercise}) {
    return RoutineExerciseItem(
      id: map['id'] as int?,
      routineDayId: map['routine_day_id'] as int?,
      exerciseId: map['exercise_id'] as int,
      orderIndex: map['order_index'] as int? ?? 0,
      targetSets: map['target_sets'] as int? ?? 4,
      targetReps: (map['target_reps'] as String?) ?? '10',
      notes: (map['notes'] as String?) ?? '',
      exercise: exercise,
    );
  }

  RoutineExerciseItem copyWith({
    int? id,
    int? routineDayId,
    int? exerciseId,
    int? orderIndex,
    int? targetSets,
    String? targetReps,
    String? notes,
    Exercise? exercise,
  }) {
    return RoutineExerciseItem(
      id: id ?? this.id,
      routineDayId: routineDayId ?? this.routineDayId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      notes: notes ?? this.notes,
      exercise: exercise ?? this.exercise,
    );
  }
}

class WorkoutSession {
  final int? id;
  final int? routineId;
  final int? routineDayId;
  final String routineName;
  final String dayName;
  final String sessionDate; // ISO 8601
  final int durationSeconds;
  final String notes;
  final List<WorkoutSetLog> setLogs;

  WorkoutSession({
    this.id,
    this.routineId,
    this.routineDayId,
    required this.routineName,
    required this.dayName,
    required this.sessionDate,
    this.durationSeconds = 0,
    this.notes = '',
    this.setLogs = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'routine_id': routineId,
      'routine_day_id': routineDayId,
      'routine_name': routineName,
      'day_name': dayName,
      'session_date': sessionDate,
      'duration_seconds': durationSeconds,
      'notes': notes,
    };
  }

  factory WorkoutSession.fromMap(
    Map<String, dynamic> map, {
    List<WorkoutSetLog> setLogs = const [],
  }) {
    return WorkoutSession(
      id: map['id'] as int?,
      routineId: map['routine_id'] as int?,
      routineDayId: map['routine_day_id'] as int?,
      routineName: (map['routine_name'] as String?) ?? 'Entrenamiento',
      dayName: (map['day_name'] as String?) ?? 'Sesión libre',
      sessionDate: map['session_date'] as String,
      durationSeconds: (map['duration_seconds'] as int?) ?? 0,
      notes: (map['notes'] as String?) ?? '',
      setLogs: setLogs,
    );
  }
}

class WorkoutSetLog {
  final int? id;
  final int? sessionId;
  final int exerciseId;
  final String? exerciseName;
  final String? equipment;
  final int setNumber; // 1, 2, 3, 4...
  final double weight;
  final int reps;
  final bool isCompleted;
  final String loggedAt;

  WorkoutSetLog({
    this.id,
    this.sessionId,
    required this.exerciseId,
    this.exerciseName,
    this.equipment,
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.isCompleted = true,
    required this.loggedAt,
  });

  /// Fórmula de Epley para estimar 1RM (Repetición Máxima)
  double get estimatedOneRepMax {
    if (weight <= 0 || reps <= 0) return 0;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30.0);
  }

  /// Volumen de la serie (Peso * Repeticiones)
  double get volume => weight * reps;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'weight': weight,
      'reps': reps,
      'is_completed': isCompleted ? 1 : 0,
      'logged_at': loggedAt,
    };
  }

  factory WorkoutSetLog.fromMap(Map<String, dynamic> map) {
    return WorkoutSetLog(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int?,
      exerciseId: map['exercise_id'] as int,
      exerciseName: map['exercise_name'] as String?,
      equipment: map['equipment'] as String?,
      setNumber: map['set_number'] as int,
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
      isCompleted: (map['is_completed'] as int? ?? 1) == 1,
      loggedAt: (map['logged_at'] as String?) ?? '',
    );
  }
}
