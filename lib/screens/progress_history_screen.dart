import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fitness_models.dart';
import '../services/database_service.dart';

class ProgressHistoryScreen extends StatefulWidget {
  final String username;
  final String weightUnit;

  const ProgressHistoryScreen({
    super.key,
    required this.username,
    required this.weightUnit,
  });

  @override
  State<ProgressHistoryScreen> createState() => _ProgressHistoryScreenState();
}

class _ProgressHistoryScreenState extends State<ProgressHistoryScreen> {
  List<WorkoutSession> _sessions = [];
  List<Exercise> _exercises = [];
  Exercise? _selectedExercise;
  List<Map<String, dynamic>> _chartData = [];
  bool _loading = true;
  bool _showEstimated1RM = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final sessions = await DatabaseService.instance.getWorkoutSessions();
    final exercises = await DatabaseService.instance.getAllExercises();

    // Elegir por defecto el primer ejercicio que tenga registros o el primero de la lista
    Exercise? defaultEx = exercises.isNotEmpty ? exercises.first : null;
    if (sessions.isNotEmpty && sessions.first.setLogs.isNotEmpty) {
      final lastExId = sessions.first.setLogs.first.exerciseId;
      defaultEx = exercises.firstWhere(
        (e) => e.id == lastExId,
        orElse: () => exercises.first,
      );
    }

    List<Map<String, dynamic>> history = [];
    if (defaultEx?.id != null) {
      history = await DatabaseService.instance
          .getExerciseProgressHistory(defaultEx!.id!);
    }

    if (mounted) {
      setState(() {
        _sessions = sessions;
        _exercises = exercises;
        _selectedExercise = defaultEx;
        _chartData = history;
        _loading = false;
      });
    }
  }

  Future<void> _onExerciseChanged(Exercise? ex) async {
    if (ex == null || ex.id == null) return;
    final history =
        await DatabaseService.instance.getExerciseProgressHistory(ex.id!);
    if (mounted) {
      setState(() {
        _selectedExercise = ex;
        _chartData = history;
      });
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  String _formatShortDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso, Récords (1RM) e Historial'),
        actions: [
          IconButton(
            tooltip: 'Actualizar datos',
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Tarjeta de Gráfico de Evolución de Peso por Ejercicio
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.trending_up_rounded,
                                color: Color(0xFFCCFF00)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Evolución de Cargas de ${widget.username}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(
                                  value: false,
                                  label: Text('Peso Máx',
                                      style: TextStyle(fontSize: 11.5)),
                                ),
                                ButtonSegment(
                                  value: true,
                                  label: Text('1RM Est.',
                                      style: TextStyle(fontSize: 11.5)),
                                ),
                              ],
                              selected: {_showEstimated1RM},
                              onSelectionChanged: (s) {
                                setState(() => _showEstimated1RM = s.first);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<Exercise>(
                          value: _selectedExercise,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E293B),
                          decoration: const InputDecoration(
                            labelText:
                                'Selecciona un Ejercicio para ver tu curva de fuerza',
                            prefixIcon: Icon(Icons.fitness_center),
                          ),
                          items: _exercises.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(
                                '${e.name} (${e.equipment})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: _onExerciseChanged,
                        ),
                        const SizedBox(height: 18),
                        if (_chartData.isEmpty)
                          Container(
                            height: 170,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF101520),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white10),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Aún no hay sesiones registradas para "${_selectedExercise?.name ?? ''}".\n'
                              'Completa un día de tu rutina y anota tus pesos para ver el gráfico de evolución aquí.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          )
                        else ...[
                          SizedBox(
                            height: 210,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _WeightProgressChartPainter(
                                data: _chartData,
                                use1RM: _showEstimated1RM,
                                unit: widget.weightUnit,
                                formatShortDate: _formatShortDate,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStatsSummaryRow(),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Bitácora de Sesiones y Pesos por Serie',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                if (_sessions.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.history_toggle_off_rounded,
                              size: 48, color: Colors.white38),
                          const SizedBox(height: 10),
                          Text(
                            'Sin entrenamientos guardados todavía, ${widget.username}.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Inicia cualquier día de tu rutina para guardar el peso de cada serie.',
                            style: TextStyle(color: Colors.white60),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._sessions.map((session) {
                    // Agrupar logs por ejercicio dentro de la sesión
                    final Map<String, List<WorkoutSetLog>> groupedByExercise =
                        {};
                    for (final log in session.setLogs) {
                      final key =
                          '${log.exerciseName ?? "Ejercicio #${log.exerciseId}"} (${log.equipment ?? ""})';
                      groupedByExercise.putIfAbsent(key, () => []).add(log);
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color(0xFFCCFF00).withOpacity(0.18),
                          foregroundColor: const Color(0xFFCCFF00),
                          child: const Icon(Icons.fitness_center_rounded),
                        ),
                        title: Text(
                          session.dayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          '${session.routineName} • ${_formatDate(session.sessionDate)} • ${session.setLogs.length} series',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12.5,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Eliminar registro de sesión',
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.white38, size: 20),
                          onPressed: () async {
                            if (session.id != null) {
                              await DatabaseService.instance
                                  .deleteWorkoutSession(session.id!);
                              await _loadData();
                            }
                          },
                        ),
                        children: groupedByExercise.entries.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF101520),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFF232F46)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00E5FF),
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: entry.value.map((setLog) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Serie ${setLog.setNumber}: ${setLog.weight} ${widget.weightUnit} × ${setLog.reps} reps',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
              ],
            ),
    );
  }

  Widget _buildStatsSummaryRow() {
    double bestWeight = 0;
    double best1RM = 0;
    for (final row in _chartData) {
      final w = (row['max_weight'] as num).toDouble();
      final rm = (row['max_1rm'] as num).toDouble();
      if (w > bestWeight) bestWeight = w;
      if (rm > best1RM) best1RM = rm;
    }
    final firstWeight = (_chartData.first['max_weight'] as num).toDouble();
    final lastWeight = (_chartData.last['max_weight'] as num).toDouble();
    final diff = lastWeight - firstWeight;

    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: 'Récord Peso Máx',
            value: '${bestWeight.toStringAsFixed(1)} ${widget.weightUnit}',
            color: const Color(0xFFCCFF00),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            label: '1RM Estimado',
            value: '${best1RM.toStringAsFixed(1)} ${widget.weightUnit}',
            color: const Color(0xFF00E5FF),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            label: 'Progreso Neto',
            value:
                '${diff >= 0 ? "+" : ""}${diff.toStringAsFixed(1)} ${widget.weightUnit}',
            color: diff >= 0 ? const Color(0xFF69F0AE) : Colors.orangeAccent,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF101520),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightProgressChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final bool use1RM;
  final String unit;
  final String Function(String) formatShortDate;

  _WeightProgressChartPainter({
    required this.data,
    required this.use1RM,
    required this.unit,
    required this.formatShortDate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const double padLeft = 44;
    const double padRight = 18;
    const double padTop = 22;
    const double padBottom = 28;

    final chartW = size.width - padLeft - padRight;
    final chartH = size.height - padTop - padBottom;

    final values = data.map((d) {
      return use1RM
          ? (d['max_1rm'] as num).toDouble()
          : (d['max_weight'] as num).toDouble();
    }).toList();

    final minVal = (values.reduce(math.min) * 0.88).clamp(0.0, double.infinity);
    final maxVal = math.max(values.reduce(math.max) * 1.08, minVal + 10);

    // Líneas guía horizontales
    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final ratio = i / 3.0;
      final y = padTop + chartH * (1 - ratio);
      canvas.drawLine(
        Offset(padLeft, y),
        Offset(size.width - padRight, y),
        gridPaint,
      );

      final v = minVal + (maxVal - minVal) * ratio;
      final tp = TextPainter(
        text: TextSpan(
          text: v.toStringAsFixed(0),
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(4, y - tp.height / 2));
    }

    // Calcular coordenadas de cada punto de sesión
    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final xRatio = values.length == 1 ? 0.5 : i / (values.length - 1);
      final yRatio = (values[i] - minVal) / (maxVal - minVal);
      final x = padLeft + chartW * xRatio;
      final y = padTop + chartH * (1 - yRatio);
      points.add(Offset(x, y));
    }

    // Área sombreada bajo la curva
    if (points.length > 1) {
      final areaPath = Path()..moveTo(points.first.dx, padTop + chartH);
      for (final p in points) {
        areaPath.lineTo(p.dx, p.dy);
      }
      areaPath.lineTo(points.last.dx, padTop + chartH);
      areaPath.close();

      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFCCFF00).withOpacity(0.32),
            const Color(0xFFCCFF00).withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(padLeft, padTop, chartW, chartH));
      canvas.drawPath(areaPath, areaPaint);

      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }

      final linePaint = Paint()
        ..color = const Color(0xFFCCFF00)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(linePath, linePaint);
    }

    // Dibujar nodos y etiquetas de peso y fecha
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      canvas.drawCircle(p, 5.5, Paint()..color = const Color(0xFF00E5FF));
      canvas.drawCircle(p, 2.5, Paint()..color = Colors.black);

      final valLabel = TextPainter(
        text: TextSpan(
          text: '${values[i].toStringAsFixed(1)} $unit',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      valLabel.paint(
        canvas,
        Offset(p.dx - valLabel.width / 2, p.dy - 16),
      );

      final dateStr = formatShortDate(data[i]['session_date'] as String);
      final dateTp = TextPainter(
        text: TextSpan(
          text: dateStr,
          style: const TextStyle(color: Colors.white54, fontSize: 9.5),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      dateTp.paint(
        canvas,
        Offset(p.dx - dateTp.width / 2, padTop + chartH + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeightProgressChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.use1RM != use1RM;
  }
}
