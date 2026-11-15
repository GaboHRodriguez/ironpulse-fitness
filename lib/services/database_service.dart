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

  /// Sexo del alumno/usuario activo ('male' o 'female') para el maniquí 3D
  String currentGender = 'male';
  bool get isCurrentFemale => currentGender.toLowerCase() == 'female';

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
      version: 4,
      onCreate: _onCreate,
      onUpgrade: (db, oldV, newV) async {
        await _ensureMultiUserSchema(db);
        await _syncCatalogExercises(db);
      },
    );
    await _ensureMultiUserSchema(db);
    await _syncCatalogExercises(db);
    return db;
  }

  Future<void> _ensureMultiUserSchema(Database db) async {
    Future<bool> hasColumn(String table, String column) async {
      final info = await db.rawQuery('PRAGMA table_info($table)');
      return info.any((row) =>
          (row['name'] as String?)?.toLowerCase() == column.toLowerCase());
    }

    if (!await hasColumn('user_profile', 'is_active')) {
      await db.execute(
          'ALTER TABLE user_profile ADD COLUMN is_active INTEGER NOT NULL DEFAULT 0');
      final users = await db.query('user_profile', orderBy: 'id ASC', limit: 1);
      if (users.isNotEmpty) {
        await db.update(
          'user_profile',
          {'is_active': 1},
          where: 'id = ?',
          whereArgs: [users.first['id']],
        );
      }
    }

    if (!await hasColumn('user_profile', 'gender')) {
      await db.execute(
          "ALTER TABLE user_profile ADD COLUMN gender TEXT NOT NULL DEFAULT 'male'");
    }

    if (!await hasColumn('routines', 'user_id')) {
      await db.execute(
          'ALTER TABLE routines ADD COLUMN user_id INTEGER NOT NULL DEFAULT 1');
    }

    if (!await hasColumn('workout_sessions', 'user_id')) {
      await db.execute(
          'ALTER TABLE workout_sessions ADD COLUMN user_id INTEGER NOT NULL DEFAULT 1');
    }
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
        gender TEXT NOT NULL DEFAULT 'male',
        is_active INTEGER NOT NULL DEFAULT 0,
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
        user_id INTEGER NOT NULL DEFAULT 1,
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
        user_id INTEGER NOT NULL DEFAULT 1,
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
  // PERFILES MULTI-USUARIO / ALUMNOS (Sin Contraseñas - Identificación por Alias)
  // ===========================================================================
  Future<List<UserProfile>> _getAllUsersFromPrefs(SharedPreferences prefs) async {
    final rawList = prefs.getString('ip_users_list_v1');
    if (rawList != null) {
      final decoded = jsonDecode(rawList) as List<dynamic>;
      final users = decoded
          .map((e) => UserProfile.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      users.sort((a, b) {
        final cmp = (b.isActive ? 1 : 0).compareTo(a.isActive ? 1 : 0);
        return cmp != 0 ? cmp : a.username.toLowerCase().compareTo(b.username.toLowerCase());
      });
      return users;
    }

    // Migrar usuario único anterior si existía
    final legacyRaw = prefs.getString('ip_user_profile_v1');
    if (legacyRaw != null) {
      final legacy = UserProfile.fromMap(jsonDecode(legacyRaw) as Map<String, dynamic>)
          .copyWith(id: 1, isActive: true);
      await _saveUsersListToPrefs(prefs, [legacy]);
      return [legacy];
    }
    return [];
  }

  Future<void> _saveUsersListToPrefs(
      SharedPreferences prefs, List<UserProfile> users) async {
    await prefs.setString(
      'ip_users_list_v1',
      jsonEncode(users.map((u) => u.toMap()).toList()),
    );
    final active = users.where((u) => u.isActive).isNotEmpty
        ? users.firstWhere((u) => u.isActive)
        : (users.isNotEmpty ? users.first : null);
    if (active != null) {
      await prefs.setString('ip_user_profile_v1', jsonEncode(active.toMap()));
    } else {
      await prefs.remove('ip_user_profile_v1');
    }
  }

  Future<List<UserProfile>> getAllUsers() async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      return _getAllUsersFromPrefs(prefs);
    }

    final rows = await db.query(
      'user_profile',
      orderBy: 'is_active DESC, username COLLATE NOCASE ASC',
    );
    return rows.map((r) => UserProfile.fromMap(r)).toList();
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final users = await _getAllUsersFromPrefs(prefs);
      if (users.isEmpty) return null;
      final active =
          users.firstWhere((u) => u.isActive, orElse: () => users.first);
      currentGender = active.gender;
      return active;
    }

    final activeRows = await db.query(
      'user_profile',
      where: 'is_active = 1',
      limit: 1,
    );
    if (activeRows.isNotEmpty) {
      final active = UserProfile.fromMap(activeRows.first);
      currentGender = active.gender;
      return active;
    }

    final anyRows = await db.query('user_profile', orderBy: 'id ASC', limit: 1);
    if (anyRows.isEmpty) return null;

    final firstUser =
        UserProfile.fromMap(anyRows.first).copyWith(isActive: true);
    await db.update(
      'user_profile',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [firstUser.id],
    );
    currentGender = firstUser.gender;
    return firstUser;
  }

  Future<int> _resolveActiveUserId([int? explicitUserId]) async {
    if (explicitUserId != null) return explicitUserId;
    final profile = await getUserProfile();
    return profile?.id ?? 1;
  }

  /// Crea un nuevo usuario/alumno (o si ya existe ese nombre/alias, lo activa).
  Future<UserProfile> createOrSelectUser(
    String username, {
    String weightUnit = 'kg',
    String gender = 'male',
  }) async {
    final cleanName = username.trim();
    final now = DateTime.now().toIso8601String();
    currentGender = gender;
    final db = await database;

    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final users = await _getAllUsersFromPrefs(prefs);
      final existingIdx = users.indexWhere(
        (u) => u.username.toLowerCase() == cleanName.toLowerCase(),
      );

      if (existingIdx != -1) {
        final targetId = users[existingIdx].id!;
        final updatedList = users.map((u) {
          if (u.id == targetId) {
            return u.copyWith(
              username: cleanName,
              weightUnit: weightUnit,
              gender: gender,
              isActive: true,
            );
          }
          return u.copyWith(isActive: false);
        }).toList();
        await _saveUsersListToPrefs(prefs, updatedList);
        final res = updatedList.firstWhere((u) => u.id == targetId);
        currentGender = res.gender;
        return res;
      }

      final nextId = users.isEmpty
          ? 1
          : (users.map((u) => u.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      final newUser = UserProfile(
        id: nextId,
        username: cleanName,
        weightUnit: weightUnit,
        gender: gender,
        isActive: true,
        createdAt: now,
      );
      final nextList = [
        ...users.map((u) => u.copyWith(isActive: false)),
        newUser,
      ];
      await _saveUsersListToPrefs(prefs, nextList);
      currentGender = newUser.gender;
      return newUser;
    }

    return await db.transaction((txn) async {
      final existing = await txn.query(
        'user_profile',
        where: 'LOWER(username) = ?',
        whereArgs: [cleanName.toLowerCase()],
        limit: 1,
      );

      await txn.update('user_profile', {'is_active': 0});

      if (existing.isNotEmpty) {
        final existingUser = UserProfile.fromMap(existing.first);
        final updated = existingUser.copyWith(
          username: cleanName,
          weightUnit: weightUnit,
          gender: gender,
          isActive: true,
        );
        await txn.update(
          'user_profile',
          updated.toMap(),
          where: 'id = ?',
          whereArgs: [existingUser.id],
        );
        currentGender = updated.gender;
        return updated;
      }

      final profile = UserProfile(
        username: cleanName,
        weightUnit: weightUnit,
        gender: gender,
        isActive: true,
        createdAt: now,
      );
      final id = await txn.insert('user_profile', profile.toMap());
      currentGender = profile.gender;
      return profile.copyWith(id: id);
    });
  }

  /// Actualiza el nombre/alias, unidad o sexo del usuario actualmente activo (o uno específico).
  Future<UserProfile> saveOrUpdateUserProfile(
    String username, {
    String weightUnit = 'kg',
    String? gender,
    int? userId,
  }) async {
    final cleanName = username.trim();
    final db = await database;
    final now = DateTime.now().toIso8601String();

    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final users = await _getAllUsersFromPrefs(prefs);
      final targetId = userId ??
          (users.where((u) => u.isActive).isNotEmpty
              ? users.firstWhere((u) => u.isActive).id
              : null);

      if (targetId == null) {
        return createOrSelectUser(
          cleanName,
          weightUnit: weightUnit,
          gender: gender ?? 'male',
        );
      }

      UserProfile? updatedProfile;
      final nextList = users.map((u) {
        if (u.id == targetId) {
          updatedProfile = u.copyWith(
            username: cleanName,
            weightUnit: weightUnit,
            gender: gender ?? u.gender,
            isActive: true,
          );
          return updatedProfile!;
        }
        return u.copyWith(isActive: false);
      }).toList();

      if (updatedProfile == null) {
        return createOrSelectUser(
          cleanName,
          weightUnit: weightUnit,
          gender: gender ?? 'male',
        );
      }
      await _saveUsersListToPrefs(prefs, nextList);
      currentGender = updatedProfile!.gender;
      return updatedProfile!;
    }

    final existing = userId != null
        ? (await db.query('user_profile', where: 'id = ?', whereArgs: [userId]))
            .map((r) => UserProfile.fromMap(r))
            .firstOrNull
        : await getUserProfile();

    if (existing == null) {
      return createOrSelectUser(
        cleanName,
        weightUnit: weightUnit,
        gender: gender ?? 'male',
      );
    } else {
      final updated = existing.copyWith(
        username: cleanName,
        weightUnit: weightUnit,
        gender: gender ?? existing.gender,
        isActive: true,
        createdAt: existing.createdAt.isEmpty ? now : existing.createdAt,
      );
      await db.transaction((txn) async {
        await txn.update('user_profile', {'is_active': 0});
        await txn.update(
          'user_profile',
          updated.toMap(),
          where: 'id = ?',
          whereArgs: [existing.id],
        );
      });
      currentGender = updated.gender;
      return updated;
    }
  }

  /// Cambia rápidamente el usuario/alumno activo sin pedir contraseña.
  Future<UserProfile?> switchActiveUser(int userId) async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final users = await _getAllUsersFromPrefs(prefs);
      UserProfile? active;
      final updated = users.map((u) {
        final isTarget = u.id == userId;
        final copy = u.copyWith(isActive: isTarget);
        if (isTarget) active = copy;
        return copy;
      }).toList();
      await _saveUsersListToPrefs(prefs, updated);
      if (active != null) currentGender = active!.gender;
      return active;
    }

    await db.transaction((txn) async {
      await txn.update('user_profile', {'is_active': 0});
      await txn.update(
        'user_profile',
        {'is_active': 1},
        where: 'id = ?',
        whereArgs: [userId],
      );
    });
    return getUserProfile();
  }

  /// Elimina un usuario/alumno junto con sus rutinas y sesiones, y devuelve el nuevo usuario activo (o null).
  Future<UserProfile?> deleteUserProfile(int userId) async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final users = await _getAllUsersFromPrefs(prefs);
      users.removeWhere((u) => u.id == userId);
      if (users.isNotEmpty && !users.any((u) => u.isActive)) {
        users[0] = users[0].copyWith(isActive: true);
      }
      await _saveUsersListToPrefs(prefs, users);

      // Limpiar rutinas y sesiones de este usuario en prefs
      final allRoutines = await _getAllRoutinesUnfilteredFromPrefs(prefs);
      allRoutines.removeWhere((r) => (r.userId ?? 1) == userId);
      await _persistRoutinesToPrefs(prefs, allRoutines);

      final allSessions = await _getAllSessionsUnfilteredFromPrefs(prefs);
      allSessions.removeWhere((s) => (s.userId ?? 1) == userId);
      await _persistSessionsToPrefs(prefs, allSessions);

      return users.isEmpty ? null : users.firstWhere((u) => u.isActive);
    }

    await db.transaction((txn) async {
      final userRoutines = await txn.query(
        'routines',
        columns: ['id'],
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      for (final r in userRoutines) {
        final rId = r['id'] as int;
        final oldDays = await txn.query(
          'routine_days',
          columns: ['id'],
          where: 'routine_id = ?',
          whereArgs: [rId],
        );
        for (final od in oldDays) {
          await txn.delete(
            'routine_exercises',
            where: 'routine_day_id = ?',
            whereArgs: [od['id']],
          );
        }
        await txn.delete('routine_days', where: 'routine_id = ?', whereArgs: [rId]);
      }
      await txn.delete('routines', where: 'user_id = ?', whereArgs: [userId]);

      final userSessions = await txn.query(
        'workout_sessions',
        columns: ['id'],
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      for (final s in userSessions) {
        await txn.delete(
          'workout_set_logs',
          where: 'session_id = ?',
          whereArgs: [s['id']],
        );
      }
      await txn.delete('workout_sessions', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('user_profile', where: 'id = ?', whereArgs: [userId]);

      final remaining = await txn.query('user_profile', orderBy: 'id ASC');
      if (remaining.isNotEmpty &&
          !remaining.any((r) => (r['is_active'] as int? ?? 0) == 1)) {
        await txn.update(
          'user_profile',
          {'is_active': 1},
          where: 'id = ?',
          whereArgs: [remaining.first['id']],
        );
      }
    });

    return getUserProfile();
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
  // RUTINAS SEMANALES POR USUARIO / ALUMNO (Crear, Modificar, Copiar, Plantillas)
  // ===========================================================================
  Future<List<Routine>> _getAllRoutinesUnfilteredFromPrefs(
      SharedPreferences prefs) async {
    final allExercises = await getAllExercises();
    final Map<int, Exercise> exerciseMap = {
      for (final e in allExercises)
        if (e.id != null) e.id!: e,
    };

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
          return RoutineExerciseItem.fromMap(iMap, exercise: exerciseMap[exId]);
        }).toList();
        days.add(RoutineDay.fromMap(dMap, exercises: items));
      }
      routines.add(Routine.fromMap(rMap, days: days));
    }
    return routines;
  }

  Future<List<Routine>> getAllRoutines({int? userId}) async {
    final activeUserId = await _resolveActiveUserId(userId);
    final db = await database;
    final allExercises = await getAllExercises();
    final Map<int, Exercise> exerciseMap = {
      for (final e in allExercises)
        if (e.id != null) e.id!: e,
    };

    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final all = await _getAllRoutinesUnfilteredFromPrefs(prefs);
      final routines =
          all.where((r) => (r.userId ?? 1) == activeUserId).toList();
      routines.sort((a, b) => (b.isActive ? 1 : 0).compareTo(a.isActive ? 1 : 0));
      return routines;
    }

    final routineRows = await db.query(
      'routines',
      where: 'user_id = ? OR (user_id IS NULL AND ? = 1)',
      whereArgs: [activeUserId, activeUserId],
      orderBy: 'is_active DESC, id DESC',
    );

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

  Future<Routine> saveRoutine(Routine routine, {int? userId}) async {
    final activeUserId = await _resolveActiveUserId(userId ?? routine.userId);
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final allRoutines = await _getAllRoutinesUnfilteredFromPrefs(prefs);
      final userRoutines =
          allRoutines.where((r) => (r.userId ?? 1) == activeUserId).toList();
      final bool makeActive = routine.isActive || userRoutines.isEmpty;
      final int routineId = routine.id ??
          (allRoutines.isEmpty
              ? 1
              : allRoutines.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);

      final updatedRoutine = routine.copyWith(
        id: routineId,
        userId: activeUserId,
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
      for (final r in allRoutines) {
        if (r.id == routineId) {
          nextList.add(updatedRoutine);
          replaced = true;
        } else if ((r.userId ?? 1) == activeUserId) {
          nextList.add(makeActive ? r.copyWith(isActive: false) : r);
        } else {
          nextList.add(r);
        }
      }
      if (!replaced) nextList.add(updatedRoutine);

      await _persistRoutinesToPrefs(prefs, nextList);
      return updatedRoutine;
    }

    return await db.transaction((txn) async {
      final existingCountSq = await txn.rawQuery(
        'SELECT COUNT(*) as c FROM routines WHERE user_id = ?',
        [activeUserId],
      );
      final int existingCount = (existingCountSq.first['c'] as int?) ?? 0;
      final bool makeActive = routine.isActive || existingCount == 0;

      if (makeActive) {
        await txn.update(
          'routines',
          {'is_active': 0},
          where: 'user_id = ?',
          whereArgs: [activeUserId],
        );
      }

      int routineId;
      if (routine.id == null) {
        routineId = await txn.insert('routines', {
          'user_id': activeUserId,
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
            'user_id': activeUserId,
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

      return routine.copyWith(
        id: routineId,
        userId: activeUserId,
        isActive: makeActive,
      );
    });
  }

  /// Permite al entrenador copiar/asignar una rutina existente a otro alumno en 1 clic.
  Future<Routine> copyRoutineToUser(Routine sourceRoutine, int targetUserId) async {
    final copied = Routine(
      userId: targetUserId,
      name: sourceRoutine.name,
      daysPerWeek: sourceRoutine.days.length,
      description: sourceRoutine.description,
      isActive: true,
      createdAt: DateTime.now().toIso8601String(),
      days: sourceRoutine.days
          .map(
            (d) => RoutineDay(
              dayNumber: d.dayNumber,
              dayName: d.dayName,
              exercises: d.exercises
                  .map(
                    (e) => RoutineExerciseItem(
                      exerciseId: e.exerciseId,
                      orderIndex: e.orderIndex,
                      targetSets: e.targetSets,
                      targetReps: e.targetReps,
                      notes: e.notes,
                      exercise: e.exercise,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
    return saveRoutine(copied, userId: targetUserId);
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

  Future<void> setActiveRoutine(int routineId, {int? userId}) async {
    final activeUserId = await _resolveActiveUserId(userId);
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final list = await _getAllRoutinesUnfilteredFromPrefs(prefs);
      final updated = list.map((r) {
        if ((r.userId ?? 1) == activeUserId) {
          return r.copyWith(isActive: r.id == routineId);
        }
        return r;
      }).toList();
      await _persistRoutinesToPrefs(prefs, updated);
      return;
    }

    await db.transaction((txn) async {
      await txn.update(
        'routines',
        {'is_active': 0},
        where: 'user_id = ?',
        whereArgs: [activeUserId],
      );
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
      final list = await _getAllRoutinesUnfilteredFromPrefs(prefs);
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

  Future<Routine> importPresetTemplate(
    Map<String, dynamic> template, {
    int? userId,
  }) async {
    final activeUserId = await _resolveActiveUserId(userId);
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
      userId: activeUserId,
      name: template['name'] as String,
      daysPerWeek: template['days_per_week'] as int,
      description: template['description'] as String,
      isActive: true,
      createdAt: DateTime.now().toIso8601String(),
      days: days,
    );

    return await saveRoutine(newRoutine, userId: activeUserId);
  }

  // ===========================================================================
  // HISTORIAL DE ENTRENAMIENTOS Y MEMORIA DE PESOS POR SERIE (POR ALUMNO)
  // ===========================================================================
  Future<Map<int, WorkoutSetLog>> getLastSessionSetsForExercise(
    int exerciseId, {
    int? userId,
  }) async {
    final activeUserId = await _resolveActiveUserId(userId);
    final db = await database;
    if (db == null) {
      final sessions = await getWorkoutSessions(limit: 200, userId: activeUserId);
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
      SELECT l.session_id 
      FROM workout_set_logs l
      INNER JOIN workout_sessions s ON l.session_id = s.id
      WHERE l.exercise_id = ? AND l.is_completed = 1
        AND (s.user_id = ? OR (s.user_id IS NULL AND ? = 1))
      ORDER BY l.id DESC 
      LIMIT 1
    ''', [exerciseId, activeUserId, activeUserId]);

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

  Future<WorkoutSetLog?> getPersonalRecordForExercise(
    int exerciseId, {
    int? userId,
  }) async {
    final activeUserId = await _resolveActiveUserId(userId);
    final db = await database;
    if (db == null) {
      final sessions = await getWorkoutSessions(limit: 200, userId: activeUserId);
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

    final rows = await db.rawQuery('''
      SELECT l.*
      FROM workout_set_logs l
      INNER JOIN workout_sessions s ON l.session_id = s.id
      WHERE l.exercise_id = ? AND l.is_completed = 1
        AND (s.user_id = ? OR (s.user_id IS NULL AND ? = 1))
      ORDER BY l.weight DESC, l.reps DESC
      LIMIT 1
    ''', [exerciseId, activeUserId, activeUserId]);
    if (rows.isEmpty) return null;
    return WorkoutSetLog.fromMap(rows.first);
  }

  Future<List<WorkoutSession>> _getAllSessionsUnfilteredFromPrefs(
      SharedPreferences prefs) async {
    final raw = prefs.getString('ip_sessions_v1') ?? '[]';
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    final List<WorkoutSession> list = [];
    for (final sJson in decoded) {
      final sMap = Map<String, dynamic>.from(sJson as Map);
      final rawLogs = (sMap['set_logs'] as List<dynamic>?) ?? [];
      final logs = rawLogs
          .map((l) => WorkoutSetLog.fromMap(Map<String, dynamic>.from(l as Map)))
          .toList();
      list.add(WorkoutSession.fromMap(sMap, setLogs: logs));
    }
    return list;
  }

  Future<int> saveWorkoutSession(WorkoutSession session, {int? userId}) async {
    final activeUserId = await _resolveActiveUserId(userId ?? session.userId);
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final existing = await _getAllSessionsUnfilteredFromPrefs(prefs);
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
        userId: activeUserId,
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
      final sessionMap = session.toMap();
      sessionMap['user_id'] = activeUserId;
      final sessionId = await txn.insert('workout_sessions', sessionMap);
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

  Future<List<WorkoutSession>> getWorkoutSessions({
    int limit = 50,
    int? userId,
  }) async {
    final activeUserId = await _resolveActiveUserId(userId);
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final all = await _getAllSessionsUnfilteredFromPrefs(prefs);
      return all
          .where((s) => (s.userId ?? 1) == activeUserId)
          .take(limit)
          .toList();
    }

    final sessionRows = await db.query(
      'workout_sessions',
      where: 'user_id = ? OR (user_id IS NULL AND ? = 1)',
      whereArgs: [activeUserId, activeUserId],
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
    int exerciseId, {
    int? userId,
  }) async {
    final activeUserId = await _resolveActiveUserId(userId);
    final db = await database;
    if (db == null) {
      final sessions =
          (await getWorkoutSessions(limit: 200, userId: activeUserId))
              .reversed
              .toList();
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
        AND (s.user_id = ? OR (s.user_id IS NULL AND ? = 1))
      GROUP BY s.id
      ORDER BY s.session_date ASC, s.id ASC
    ''', [exerciseId, activeUserId, activeUserId]);

    return rows;
  }

  Future<void> deleteWorkoutSession(int sessionId) async {
    final db = await database;
    if (db == null) {
      final prefs = await _ensurePrefsSeeded();
      final list = await _getAllSessionsUnfilteredFromPrefs(prefs);
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
