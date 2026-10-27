import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/fitness_models.dart';
import '../data/exercise_catalog_seed.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;
  static bool _usePrefsFallback = kIsWeb;

  DatabaseService._internal();

  Future<Database?> get database async {
    if (_usePrefsFallback) return null;
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database;
    } catch (_) {
      _usePrefsFallback = true;
      await _ensurePrefsSeeded();
      return null;
    }
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(docsDir.path, 'ironpulse_fitness_v1.db');

    final db = await openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldV, newV) async {
        await _syncCatalogExercises(db);
      },
    );
    await _syncCatalogExercises(db);
    return db;
  }

  Future<void> _syncCatalogExercises(Database db) async {
    final existingRows = await db.query('exercises');
    final Map<String, Map<String, dynamic>> existingByName = {
      for (final r in existingRows)
        (r['name'] as String).toLowerCase(): r,
    };

    for (final seedEx in ExerciseCatalogSeed.initialExercises) {
      final key = seedEx.name.toLowerCase();
      if (!existingByName.containsKey(key)) {
        // Si antes se llamaba "Curl Femoral Tumbado en Máquina (Lying Leg Curl)", actualizarlo
        if (seedEx.movementPattern == 'lying_leg_curl' &&
            existingByName.containsKey(
                'curl femoral tumbado en máquina (lying leg curl)')) {
          final oldId = existingByName[
              'curl femoral tumbado en máquina (lying leg curl)']!['id'];
          await db.update(
            'exercises',
            seedEx.toMap(),
            where: 'id = ?',
            whereArgs: [oldId],
          );
        } else if (seedEx.movementPattern == 'plank' &&
            existingByName.containsKey(
                'plancha abdominal isométrica (plank) / rueda abdominal')) {
          final oldId = existingByName[
              'plancha abdominal isométrica (plank) / rueda abdominal']!['id'];
          await db.update(
            'exercises',
            seedEx.toMap(),
            where: 'id = ?',
            whereArgs: [oldId],
          );
        } else {
          await db.insert('exercises', seedEx.toMap());
        }
      } else {
        final existingId = existingByName[key]!['id'];
        await db.update(
          'exercises',
          {
            'movement_pattern': seedEx.movementPattern,
            'external_media_url': seedEx.externalMediaUrl,
            'instructions': seedEx.instructions,
            'common_mistakes': seedEx.commonMistakes,
          },
          where: 'id = ?',
          whereArgs: [existingId],
        );
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        weight_unit TEXT NOT NULL DEFAULT 'kg',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        muscle_group TEXT NOT NULL,
        secondary_muscles TEXT,
        equipment TEXT NOT NULL,
        movement_pattern TEXT NOT NULL,
        difficulty TEXT NOT NULL DEFAULT 'Intermedio',
        instructions TEXT NOT NULL,
        common_mistakes TEXT,
        external_media_url TEXT,
        is_custom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE routines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        days_per_week INTEGER NOT NULL,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE routine_days (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routine_id INTEGER NOT NULL,
        day_number INTEGER NOT NULL,
        day_name TEXT NOT NULL,
        FOREIGN KEY (routine_id) REFERENCES routines (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE routine_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routine_day_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        order_index INTEGER NOT NULL DEFAULT 0,
        target_sets INTEGER NOT NULL DEFAULT 4,
        target_reps TEXT NOT NULL DEFAULT '8-12',
        notes TEXT,
        FOREIGN KEY (routine_day_id) REFERENCES routine_days (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routine_id INTEGER,
        routine_day_id INTEGER,
        routine_name TEXT NOT NULL,
        day_name TEXT NOT NULL,
        session_date TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL DEFAULT 0,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_set_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        set_number INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 1,
        logged_at TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES workout_sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    final batch = db.batch();
    for (final ex in ExerciseCatalogSeed.initialExercises) {
      batch.insert('exercises', ex.toMap());
    }
    await batch.commit(noResult: true);
  }

  // ===========================================================================
  // MOTOR DE PERSISTENCIA JSON LOCAL (SharedPreferences fallback para Desktop/Web)
  // ===========================================================================
  Future<SharedPreferences> _ensurePrefsSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('ip_exercises_v1')) {
      final List<Map<String, dynamic>> seeded = [];
      for (int i = 0; i < ExerciseCatalogSeed.initialExercises.length; i++) {
        final ex = ExerciseCatalogSeed.initialExercises[i].copyWith(id: i + 1);
        seeded.add(ex.toMap());
      }
      await prefs.setString('ip_exercises_v1', jsonEncode(seeded));
    } else {
      // Sincronizar nuevos ejercicios del catálogo sin perder los personalizados
      final raw = prefs.getString('ip_exercises_v1') ?? '[]';
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<Exercise> currentList = decoded
          .map((e) => Exercise.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      bool changed = false;
      int maxId = currentList.isEmpty
          ? 0
          : currentList.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b);

      for (final seedEx in ExerciseCatalogSeed.initialExercises) {
        final idx = currentList.indexWhere(
          (e) =>
              e.name.toLowerCase() == seedEx.name.toLowerCase() ||
              (seedEx.movementPattern == 'lying_leg_curl' &&
                  e.name.toLowerCase().contains('curl femoral tumbado')) ||
              (seedEx.movementPattern == 'plank' &&
                  e.name.toLowerCase().contains('plancha abdominal')),
        );
        if (idx == -1) {
          maxId++;
          currentList.add(seedEx.copyWith(id: maxId));
          changed = true;
        } else if (currentList[idx].movementPattern != seedEx.movementPattern ||
            currentList[idx].name != seedEx.name) {
          currentList[idx] = seedEx.copyWith(id: currentList[idx].id);
          changed = true;
        }
      }
      if (changed) {
        await prefs.setString(
          'ip_exercises_v1',
          jsonEncode(currentList.map((e) => e.toMap()).toList()),
        );
      }
    }
    return prefs;
  }

  // ===========================================================================
  // PERFIL DE USUARIO (Sin Registro de Contraseña - Interactivo)
  // ===========================================================================
  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final raw = prefs.getString('ip_user_profile_v1');
      if (raw == null) return null;
      return UserProfile.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    }

    final rows = await db.query('user_profile', limit: 1);
    if (rows.isEmpty) return null;
    return UserProfile.fromMap(rows.first);
  }

  Future<UserProfile> saveOrUpdateUserProfile(String username,
      {String weightUnit = 'kg'}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final profile = UserProfile(
        id: 1,
        username: username.trim(),
        weightUnit: weightUnit,
        createdAt: now,
      );
      await prefs.setString('ip_user_profile_v1', jsonEncode(profile.toMap()));
      return profile;
    }

    final existing = await getUserProfile();
    if (existing == null) {
      final profile = UserProfile(
        username: username.trim(),
        weightUnit: weightUnit,
        createdAt: now,
      );
      final id = await db.insert('user_profile', profile.toMap());
      return profile.copyWith(id: id);
    } else {
      final updated = existing.copyWith(
        username: username.trim(),
        weightUnit: weightUnit,
      );
      await db.update(
        'user_profile',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
      return updated;
    }
  }

  // ===========================================================================
  // CATÁLOGO DE EJERCICIOS
  // ===========================================================================
  Future<List<Exercise>> getAllExercises({
    String? muscleGroup,
    String? equipment,
    String? searchQuery,
  }) async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final raw = prefs.getString('ip_exercises_v1') ?? '[]';
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      var list = decoded
          .map((e) => Exercise.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();

      if (muscleGroup != null && muscleGroup != 'Todos') {
        list = list.where((e) => e.muscleGroup == muscleGroup).toList();
      }
      if (equipment != null && equipment != 'Todos') {
        list = list.where((e) => e.equipment == equipment).toList();
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        list = list
            .where((e) =>
                e.name.toLowerCase().contains(q) ||
                e.secondaryMuscles.toLowerCase().contains(q) ||
                e.equipment.toLowerCase().contains(q))
            .toList();
      }
      list.sort((a, b) {
        final cmp = a.muscleGroup.compareTo(b.muscleGroup);
        return cmp != 0 ? cmp : a.name.compareTo(b.name);
      });
      return list;
    }

    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (muscleGroup != null && muscleGroup != 'Todos') {
      whereClauses.add('muscle_group = ?');
      whereArgs.add(muscleGroup);
    }
    if (equipment != null && equipment != 'Todos') {
      whereClauses.add('equipment = ?');
      whereArgs.add(equipment);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add(
          '(name LIKE ? OR secondary_muscles LIKE ? OR equipment LIKE ?)');
      final q = '%${searchQuery.trim()}%';
      whereArgs.addAll([q, q, q]);
    }

    final rows = await db.query(
      'exercises',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'muscle_group ASC, name ASC',
    );
    return rows.map((r) => Exercise.fromMap(r)).toList();
  }

  Future<Exercise?> getExerciseById(int id) async {
    final all = await getAllExercises();
    for (final e in all) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<Exercise> insertCustomExercise(Exercise exercise) async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final all = await getAllExercises();
      final nextId =
          all.isEmpty ? 1 : (all.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      final saved = exercise.copyWith(id: nextId);
      all.add(saved);
      await prefs.setString(
        'ip_exercises_v1',
        jsonEncode(all.map((e) => e.toMap()).toList()),
      );
      return saved;
    }

    final id = await db.insert('exercises', exercise.toMap());
    return exercise.copyWith(id: id);
  }

  // ===========================================================================
  // RUTINAS SEMANALES (Crear, Modificar, Eliminar y Plantillas)
  // ===========================================================================
  Future<List<Routine>> getAllRoutines() async {
    final db = await database;
    final allExercises = await getAllExercises();
    final Map<int, Exercise> exerciseMap = {
      for (final e in allExercises)
        if (e.id != null) e.id!: e,
    };

    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final raw = prefs.getString('ip_routines_v1') ?? '[]';
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<Routine> routines = [];

      for (final rJson in decoded) {
        final rMap = Map<String, dynamic>.from(rJson as Map);
        final rawDays = (rMap['days'] as List<dynamic>?) ?? [];
        final List<RoutineDay> days = [];

        for (final dJson in rawDays) {
          final dMap = Map<String, dynamic>.from(dJson as Map);
          final rawItems = (dMap['exercises'] as List<dynamic>?) ?? [];
          final items = rawItems.map((iJson) {
            final iMap = Map<String, dynamic>.from(iJson as Map);
            final exId = iMap['exercise_id'] as int;
            return RoutineExerciseItem.fromMap(iMap,
                exercise: exerciseMap[exId]);
          }).toList();
          days.add(RoutineDay.fromMap(dMap, exercises: items));
        }
        routines.add(Routine.fromMap(rMap, days: days));
      }
      routines.sort((a, b) => (b.isActive ? 1 : 0).compareTo(a.isActive ? 1 : 0));
      return routines;
    }

    final routineRows =
        await db.query('routines', orderBy: 'is_active DESC, id DESC');

    final List<Routine> routines = [];
    for (final rMap in routineRows) {
      final int routineId = rMap['id'] as int;
      final dayRows = await db.query(
        'routine_days',
        where: 'routine_id = ?',
        whereArgs: [routineId],
        orderBy: 'day_number ASC',
      );

      final List<RoutineDay> days = [];
      for (final dMap in dayRows) {
        final int dayId = dMap['id'] as int;
        final itemRows = await db.query(
          'routine_exercises',
          where: 'routine_day_id = ?',
          whereArgs: [dayId],
          orderBy: 'order_index ASC',
        );

        final items = itemRows.map((iMap) {
          final exId = iMap['exercise_id'] as int;
          return RoutineExerciseItem.fromMap(iMap, exercise: exerciseMap[exId]);
        }).toList();

        days.add(RoutineDay.fromMap(dMap, exercises: items));
      }

      routines.add(Routine.fromMap(rMap, days: days));
    }
    return routines;
  }

  Future<Routine> saveRoutine(Routine routine) async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final existing = await getAllRoutines();
      final bool makeActive = routine.isActive || existing.isEmpty;
      final int routineId = routine.id ??
          (existing.isEmpty
              ? 1
              : existing.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);

      final updatedRoutine = routine.copyWith(
        id: routineId,
        daysPerWeek: routine.days.length,
        isActive: makeActive,
        days: List.generate(routine.days.length, (i) {
          return routine.days[i].copyWith(
            id: routineId * 100 + i + 1,
            routineId: routineId,
            dayNumber: i + 1,
          );
        }),
      );

      final List<Routine> nextList = [];
      bool replaced = false;
      for (final r in existing) {
        if (r.id == routineId) {
          nextList.add(updatedRoutine);
          replaced = true;
        } else {
          nextList.add(makeActive ? r.copyWith(isActive: false) : r);
        }
      }
      if (!replaced) nextList.add(updatedRoutine);

      await _persistRoutinesToPrefs(prefs, nextList);
      return updatedRoutine;
    }

    return await db.transaction((txn) async {
      final existingCountSq =
          await txn.rawQuery('SELECT COUNT(*) as c FROM routines');
      final int existingCount = (existingCountSq.first['c'] as int?) ?? 0;
      final bool makeActive = routine.isActive || existingCount == 0;

      if (makeActive) {
        await txn.update('routines', {'is_active': 0});
      }

      int routineId;
      if (routine.id == null) {
        routineId = await txn.insert('routines', {
          'name': routine.name,
          'days_per_week': routine.days.length,
          'description': routine.description,
          'is_active': makeActive ? 1 : 0,
          'created_at': routine.createdAt,
        });
      } else {
        routineId = routine.id!;
        await txn.update(
          'routines',
          {
            'name': routine.name,
            'days_per_week': routine.days.length,
            'description': routine.description,
            'is_active': makeActive ? 1 : 0,
          },
          where: 'id = ?',
          whereArgs: [routineId],
        );

        final oldDays = await txn.query(
          'routine_days',
          columns: ['id'],
          where: 'routine_id = ?',
          whereArgs: [routineId],
        );
        for (final od in oldDays) {
          await txn.delete(
            'routine_exercises',
            where: 'routine_day_id = ?',
            whereArgs: [od['id']],
          );
        }
        await txn.delete('routine_days',
            where: 'routine_id = ?', whereArgs: [routineId]);
      }

      for (int i = 0; i < routine.days.length; i++) {
        final day = routine.days[i];
        final dayId = await txn.insert('routine_days', {
          'routine_id': routineId,
          'day_number': i + 1,
          'day_name': day.dayName,
        });

        for (int j = 0; j < day.exercises.length; j++) {
          final item = day.exercises[j];
          await txn.insert('routine_exercises', {
            'routine_day_id': dayId,
            'exercise_id': item.exerciseId,
            'order_index': j,
            'target_sets': item.targetSets,
            'target_reps': item.targetReps,
            'notes': item.notes,
          });
        }
      }

      return routine.copyWith(id: routineId, isActive: makeActive);
    });
  }

  Future<void> _persistRoutinesToPrefs(
      SharedPreferences prefs, List<Routine> routines) async {
    final serialized = routines.map((r) {
      final map = r.toMap();
      map['days'] = r.days.map((d) {
        final dMap = d.toMap();
        dMap['exercises'] = d.exercises.map((e) => e.toMap()).toList();
        return dMap;
      }).toList();
      return map;
    }).toList();
    await prefs.setString('ip_routines_v1', jsonEncode(serialized));
  }

  Future<void> setActiveRoutine(int routineId) async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final list = await getAllRoutines();
      final updated =
          list.map((r) => r.copyWith(isActive: r.id == routineId)).toList();
      await _persistRoutinesToPrefs(prefs, updated);
      return;
    }

    await db.transaction((txn) async {
      await txn.update('routines', {'is_active': 0});
      await txn.update(
        'routines',
        {'is_active': 1},
        where: 'id = ?',
        whereArgs: [routineId],
      );
    });
  }

  Future<void> deleteRoutine(int routineId) async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final list = await getAllRoutines();
      list.removeWhere((r) => r.id == routineId);
      await _persistRoutinesToPrefs(prefs, list);
      return;
    }

    await db.transaction((txn) async {
      final oldDays = await txn.query(
        'routine_days',
        columns: ['id'],
        where: 'routine_id = ?',
        whereArgs: [routineId],
      );
      for (final od in oldDays) {
        await txn.delete(
          'routine_exercises',
          where: 'routine_day_id = ?',
          whereArgs: [od['id']],
        );
      }
      await txn.delete('routine_days',
          where: 'routine_id = ?', whereArgs: [routineId]);
      await txn.delete('routines', where: 'id = ?', whereArgs: [routineId]);
    });
  }

  Future<Routine> importPresetTemplate(Map<String, dynamic> template) async {
    final allExercises = await getAllExercises();
    final Map<String, Exercise> byName = {
      for (final e in allExercises) e.name.toLowerCase(): e,
    };

    final List<RoutineDay> days = [];
    final List<dynamic> rawDays = template['days'] as List<dynamic>;

    for (final rawDay in rawDays) {
      final int dayNum = rawDay['day_number'] as int;
      final String dayName = rawDay['day_name'] as String;
      final List<dynamic> rawExs = rawDay['exercises'] as List<dynamic>;

      final List<RoutineExerciseItem> items = [];
      for (int i = 0; i < rawExs.length; i++) {
        final rawEx = rawExs[i];
        final String exName = (rawEx['name'] as String).toLowerCase();
        final Exercise? matched = byName[exName] ??
            allExercises.cast<Exercise?>().firstWhere(
                  (e) =>
                      e != null &&
                      e.name.toLowerCase().contains(exName.split(' ').first),
                  orElse: () => allExercises.first,
                );

        if (matched != null && matched.id != null) {
          items.add(
            RoutineExerciseItem(
              exerciseId: matched.id!,
              orderIndex: i,
              targetSets: rawEx['sets'] as int,
              targetReps: rawEx['reps'] as String,
              exercise: matched,
            ),
          );
        }
      }

      days.add(
        RoutineDay(
          dayNumber: dayNum,
          dayName: dayName,
          exercises: items,
        ),
      );
    }

    final newRoutine = Routine(
      name: template['name'] as String,
      daysPerWeek: template['days_per_week'] as int,
      description: template['description'] as String,
      isActive: true,
      createdAt: DateTime.now().toIso8601String(),
      days: days,
    );

    return await saveRoutine(newRoutine);
  }

  // ===========================================================================
  // HISTORIAL DE ENTRENAMIENTOS Y MEMORIA DE PESOS POR SERIE
  // ===========================================================================
  Future<Map<int, WorkoutSetLog>> getLastSessionSetsForExercise(
      int exerciseId) async {
    final db = await database;
    if (db == null) {
      final sessions = await getWorkoutSessions(limit: 200);
      for (final s in sessions) {
        final matching =
            s.setLogs.where((l) => l.exerciseId == exerciseId).toList();
        if (matching.isNotEmpty) {
          return {for (final l in matching) l.setNumber: l};
        }
      }
      return {};
    }

    final lastSessionRows = await db.rawQuery('''
      SELECT session_id 
      FROM workout_set_logs 
      WHERE exercise_id = ? AND is_completed = 1
      ORDER BY id DESC 
      LIMIT 1
    ''', [exerciseId]);

    if (lastSessionRows.isEmpty) return {};

    final int lastSessionId = lastSessionRows.first['session_id'] as int;
    final setRows = await db.query(
      'workout_set_logs',
      where: 'session_id = ? AND exercise_id = ?',
      whereArgs: [lastSessionId, exerciseId],
      orderBy: 'set_number ASC',
    );

    final Map<int, WorkoutSetLog> map = {};
    for (final row in setRows) {
      final log = WorkoutSetLog.fromMap(row);
      map[log.setNumber] = log;
    }
    return map;
  }

  Future<WorkoutSetLog?> getPersonalRecordForExercise(int exerciseId) async {
    final db = await database;
    if (db == null) {
      final sessions = await getWorkoutSessions(limit: 200);
      WorkoutSetLog? best;
      for (final s in sessions) {
        for (final l in s.setLogs) {
          if (l.exerciseId == exerciseId) {
            if (best == null || l.weight > best.weight) {
              best = l;
            }
          }
        }
      }
      return best;
    }

    final rows = await db.query(
      'workout_set_logs',
      where: 'exercise_id = ? AND is_completed = 1',
      whereArgs: [exerciseId],
      orderBy: 'weight DESC, reps DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WorkoutSetLog.fromMap(rows.first);
  }

  Future<int> saveWorkoutSession(WorkoutSession session) async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final existing = await getWorkoutSessions(limit: 500);
      final int nextId = existing.isEmpty
          ? 1
          : (existing.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);

      final allExercises = await getAllExercises();
      final exMap = {
        for (final e in allExercises)
          if (e.id != null) e.id!: e
      };

      final savedSession = WorkoutSession(
        id: nextId,
        routineId: session.routineId,
        routineDayId: session.routineDayId,
        routineName: session.routineName,
        dayName: session.dayName,
        sessionDate: session.sessionDate,
        durationSeconds: session.durationSeconds,
        notes: session.notes,
        setLogs: session.setLogs.map((l) {
          final ex = exMap[l.exerciseId];
          return WorkoutSetLog(
            id: nextId * 1000 + l.setNumber,
            sessionId: nextId,
            exerciseId: l.exerciseId,
            exerciseName: ex?.name,
            equipment: ex?.equipment,
            setNumber: l.setNumber,
            weight: l.weight,
            reps: l.reps,
            isCompleted: l.isCompleted,
            loggedAt: l.loggedAt,
          );
        }).toList(),
      );

      existing.insert(0, savedSession);
      await _persistSessionsToPrefs(prefs, existing);
      return nextId;
    }

    return await db.transaction((txn) async {
      final sessionId = await txn.insert('workout_sessions', session.toMap());
      for (final log in session.setLogs) {
        await txn.insert('workout_set_logs', {
          'session_id': sessionId,
          'exercise_id': log.exerciseId,
          'set_number': log.setNumber,
          'weight': log.weight,
          'reps': log.reps,
          'is_completed': log.isCompleted ? 1 : 0,
          'logged_at': log.loggedAt,
        });
      }
      return sessionId;
    });
  }

  Future<void> _persistSessionsToPrefs(
      SharedPreferences prefs, List<WorkoutSession> sessions) async {
    final serialized = sessions.map((s) {
      final map = s.toMap();
      map['set_logs'] = s.setLogs.map((l) {
        final lMap = l.toMap();
        lMap['exercise_name'] = l.exerciseName;
        lMap['equipment'] = l.equipment;
        return lMap;
      }).toList();
      return map;
    }).toList();
    await prefs.setString('ip_sessions_v1', jsonEncode(serialized));
  }

  Future<List<WorkoutSession>> getWorkoutSessions({int limit = 50}) async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final raw = prefs.getString('ip_sessions_v1') ?? '[]';
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<WorkoutSession> list = [];
      for (final sJson in decoded.take(limit)) {
        final sMap = Map<String, dynamic>.from(sJson as Map);
        final rawLogs = (sMap['set_logs'] as List<dynamic>?) ?? [];
        final logs = rawLogs
            .map((l) =>
                WorkoutSetLog.fromMap(Map<String, dynamic>.from(l as Map)))
            .toList();
        list.add(WorkoutSession.fromMap(sMap, setLogs: logs));
      }
      return list;
    }

    final sessionRows = await db.query(
      'workout_sessions',
      orderBy: 'session_date DESC, id DESC',
      limit: limit,
    );

    final List<WorkoutSession> sessions = [];
    for (final sMap in sessionRows) {
      final int sId = sMap['id'] as int;
      final logRows = await db.rawQuery('''
        SELECT l.*, e.name as exercise_name, e.equipment as equipment
        FROM workout_set_logs l
        LEFT JOIN exercises e ON l.exercise_id = e.id
        WHERE l.session_id = ?
        ORDER BY l.id ASC
      ''', [sId]);

      final logs = logRows.map((l) => WorkoutSetLog.fromMap(l)).toList();
      sessions.add(WorkoutSession.fromMap(sMap, setLogs: logs));
    }
    return sessions;
  }

  Future<List<Map<String, dynamic>>> getExerciseProgressHistory(
      int exerciseId) async {
    final db = await database;
    if (db == null) {
      final sessions = (await getWorkoutSessions(limit: 200)).reversed.toList();
      final List<Map<String, dynamic>> history = [];

      for (final s in sessions) {
        final logs =
            s.setLogs.where((l) => l.exerciseId == exerciseId).toList();
        if (logs.isEmpty) continue;
        double maxWeight = 0;
        double max1rm = 0;
        double totalVolume = 0;
        for (final l in logs) {
          if (l.weight > maxWeight) maxWeight = l.weight;
          if (l.estimatedOneRepMax > max1rm) max1rm = l.estimatedOneRepMax;
          totalVolume += l.volume;
        }
        history.add({
          'session_date': s.sessionDate,
          'max_weight': maxWeight,
          'max_1rm': max1rm,
          'total_volume': totalVolume,
          'sets_count': logs.length,
        });
      }
      return history;
    }

    final rows = await db.rawQuery('''
      SELECT 
        s.session_date,
        MAX(l.weight) as max_weight,
        MAX(l.weight * (1.0 + l.reps / 30.0)) as max_1rm,
        SUM(l.weight * l.reps) as total_volume,
        COUNT(l.id) as sets_count
      FROM workout_set_logs l
      INNER JOIN workout_sessions s ON l.session_id = s.id
      WHERE l.exercise_id = ? AND l.is_completed = 1
      GROUP BY s.id
      ORDER BY s.session_date ASC, s.id ASC
    ''', [exerciseId]);

    return rows;
  }

  Future<void> deleteWorkoutSession(int sessionId) async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final list = await getWorkoutSessions(limit: 500);
      list.removeWhere((s) => s.id == sessionId);
      await _persistSessionsToPrefs(prefs, list);
      return;
    }

    await db.transaction((txn) async {
      await txn.delete('workout_set_logs',
          where: 'session_id = ?', whereArgs: [sessionId]);
      await txn.delete('workout_sessions',
          where: 'id = ?', whereArgs: [sessionId]);
    });
  }
}
