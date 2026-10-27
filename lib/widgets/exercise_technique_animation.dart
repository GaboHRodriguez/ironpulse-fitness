import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/fitness_models.dart';

class ExerciseTechniqueAnimation extends StatefulWidget {
  final Exercise exercise;
  final double height;
  final bool showControls;

  const ExerciseTechniqueAnimation({
    super.key,
    required this.exercise,
    this.height = 240,
    this.showControls = true,
  });

  @override
  State<ExerciseTechniqueAnimation> createState() =>
      _ExerciseTechniqueAnimationState();
}

class _ExerciseTechniqueAnimationState extends State<ExerciseTechniqueAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showExternalGif = false;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSpeed() {
    setState(() {
      if (_speed == 1.0) {
        _speed = 0.5; // Cámara lenta técnica
        _controller.duration = const Duration(milliseconds: 5600);
      } else {
        _speed = 1.0;
        _controller.duration = const Duration(milliseconds: 2800);
      }
      if (_controller.isAnimating) {
        _controller.repeat();
      }
    });
  }

  Future<void> _openVideoSearch() async {
    final query = Uri.encodeComponent('${widget.exercise.name} tecnica correcta musculacion');
    final uri = Uri.parse('https://www.youtube.com/results?search_query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasGif = widget.exercise.externalMediaUrl != null &&
        widget.exercise.externalMediaUrl!.trim().isNotEmpty;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF111622),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF283246), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Contenido principal: Animación Biomecánica Vectorial Offline o GIF Externo
          Positioned.fill(
            child: _showExternalGif && hasGif
                ? Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(8),
                    child: Image.network(
                      widget.exercise.externalMediaUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off_rounded,
                                color: Colors.black54, size: 36),
                            const SizedBox(height: 8),
                            const Text(
                              'Sin conexión para el GIF externo.\nCambiando a animación vectorial offline.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _showExternalGif = false),
                              child: const Text('Ver Vectorial Offline'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      // Ciclo senoidal suave: 0 -> 1 (Fase Concéntrica) -> 0 (Fase Excéntrica)
                      final raw = _controller.value;
                      final phase = 0.5 - 0.5 * math.cos(raw * 2 * math.pi);
                      final isConcentric = raw < 0.5;

                      return CustomPaint(
                        painter: _BiomechanicsPainter(
                          pattern: widget.exercise.movementPattern,
                          equipment: widget.exercise.equipment,
                          muscleGroup: widget.exercise.muscleGroup,
                          t: phase,
                          isConcentric: isConcentric,
                        ),
                      );
                    },
                  ),
          ),

          // Etiqueta superior izquierda: Modalidad de equipamiento + Grupo muscular
          Positioned(
            top: 10,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.68),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFCCFF00).withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fitness_center,
                      size: 13, color: Color(0xFFCCFF00)),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.exercise.equipment} • ${widget.exercise.muscleGroup}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Controles inferiores (Alternar Vectorial/GIF, Cámara lenta 0.5x, Pausa, YouTube)
          if (widget.showControls)
            Positioned(
              bottom: 8,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_showExternalGif)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MiniControlBtn(
                          icon: _controller.isAnimating
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          label: _controller.isAnimating ? 'Pausar' : 'Play',
                          onTap: () {
                            setState(() {
                              if (_controller.isAnimating) {
                                _controller.stop();
                              } else {
                                _controller.repeat();
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _MiniControlBtn(
                          icon: Icons.slow_motion_video_rounded,
                          label: '${_speed}x',
                          active: _speed < 1.0,
                          onTap: _toggleSpeed,
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasGif)
                        _MiniControlBtn(
                          icon: _showExternalGif
                              ? Icons.architecture_rounded
                              : Icons.gif_box_outlined,
                          label: _showExternalGif
                              ? 'Vector Offline'
                              : 'Ver GIF',
                          active: _showExternalGif,
                          onTap: () => setState(
                              () => _showExternalGif = !_showExternalGif),
                        ),
                      const SizedBox(width: 6),
                      _MiniControlBtn(
                        icon: Icons.ondemand_video_rounded,
                        label: 'Video',
                        onTap: _openVideoSearch,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _MiniControlBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFCCFF00).withOpacity(0.22)
              : Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? const Color(0xFFCCFF00)
                : Colors.white.withOpacity(0.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? const Color(0xFFCCFF00) : Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFFCCFF00) : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BiomechanicsPainter extends CustomPainter {
  final String pattern;
  final String equipment;
  final String muscleGroup;
  final double t; // 0.0 (inicio/estiramiento) -> 1.0 (contracción máxima)
  final bool isConcentric;

  _BiomechanicsPainter({
    required this.pattern,
    required this.equipment,
    required this.muscleGroup,
    required this.t,
    required this.isConcentric,
  });

  double _lerp(double a, double b, double p) => a + (b - a) * p;
  Offset _lerpOffset(Offset a, Offset b, double p) =>
      Offset(_lerp(a.dx, b.dx, p), _lerp(a.dy, b.dy, p));

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Cuadrícula técnica biomecánica de fondo
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.55)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < w; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Suelo del gimnasio
    final floorY = h * 0.78;
    final floorPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(w * 0.1, floorY), Offset(w * 0.9, floorY), floorPaint);

    // Pinceles para estructura, cuerpo y músculos activos
    final equipPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final bodyPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;

    final activeMusclePaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF00E5FF),
        const Color(0xFFCCFF00),
        t,
      )!
      ..strokeWidth = 9.5
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0xFFCCFF00).withOpacity(0.22 + 0.25 * t)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final weightPlatePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;

    final cx = w * 0.5;

    // Dibujar según el patrón biomecánico
    switch (pattern) {
      case 'bench_press':
      case 'fly':
      case 'skullcrusher':
        _drawBenchExercise(
          canvas,
          cx,
          floorY,
          equipPaint,
          bodyPaint,
          activeMusclePaint,
          glowPaint,
          weightPlatePaint,
        );
        break;
      case 'incline_press':
        _drawInclineBenchExercise(
          canvas,
          cx,
          floorY,
          equipPaint,
          bodyPaint,
          activeMusclePaint,
          glowPaint,
          weightPlatePaint,
        );
        break;
      case 'squat':
      case 'lunge':
      case 'calf_raise':
        _drawSquatOrLegExercise(
          canvas,
          cx,
          floorY,
          equipPaint,
          bodyPaint,
          activeMusclePaint,
          glowPaint,
          weightPlatePaint,
        );
        break;
      case 'deadlift':
      case 'row':
        _drawHingeOrRowExercise(
          canvas,
          cx,
          floorY,
          equipPaint,
          bodyPaint,
          activeMusclePaint,
          glowPaint,
          weightPlatePaint,
        );
        break;
      case 'lat_pulldown':
        _drawLatPulldownExercise(
          canvas,
          cx,
          floorY,
          equipPaint,
          bodyPaint,
          activeMusclePaint,
          glowPaint,
          weightPlatePaint,
        );
        break;
      case 'overhead_press':
      case 'lateral_raise':
      case 'shrug':
        _drawShoulderStandingExercise(
          canvas,
          cx,
          floorY,
          equipPaint,
          bodyPaint,
          activeMusclePaint,
          glowPaint,
          weightPlatePaint,
        );
        break;
      case 'bicep_curl':
      case 'tricep_pushdown':
        _drawArmIsolationExercise(
          canvas,
          cx,
          floorY,
          equipPaint,
          bodyPaint,
          activeMusclePaint,
          glowPaint,
          weightPlatePaint,
        );
        break;
      case 'leg_extension':
      case 'leg_curl':
        _drawLegMachineExercise(
          canvas,
          cx,
          floorY,
          equipPaint,
          bodyPaint,
          activeMusclePaint,
          glowPaint,
          weightPlatePaint,
        );
        break;
      case 'hip_thrust':
      case 'crunch':
      case 'plank':
      default:
        _drawCoreOrHipThrustExercise(
          canvas,
          cx,
          floorY,
          equipPaint,
          bodyPaint,
          activeMusclePaint,
          glowPaint,
          weightPlatePaint,
        );
        break;
    }

    // Indicador de fase biomecánica y respiración (arriba a la derecha)
    _drawPhaseBadge(canvas, size);
  }

  void _drawBenchExercise(
    Canvas canvas,
    double cx,
    double floorY,
    Paint equipPaint,
    Paint bodyPaint,
    Paint activePaint,
    Paint glowPaint,
    Paint weightPaint,
  ) {
    final benchY = floorY - 36;
    // Banco horizontal y patas
    canvas.drawLine(Offset(cx - 65, benchY), Offset(cx + 35, benchY), equipPaint);
    canvas.drawLine(Offset(cx - 50, benchY), Offset(cx - 50, floorY), equipPaint);
    canvas.drawLine(Offset(cx + 20, benchY), Offset(cx + 20, floorY), equipPaint);

    // Atleta acostado en el banco
    final head = Offset(cx - 55, benchY - 12);
    final shoulder = Offset(cx - 35, benchY - 10);
    final hip = Offset(cx + 22, benchY - 10);
    final knee = Offset(cx + 48, benchY - 8);
    final foot = Offset(cx + 52, floorY);

    canvas.drawCircle(head, 9, bodyPaint);
    canvas.drawLine(shoulder, hip, bodyPaint);
    canvas.drawLine(hip, knee, bodyPaint);
    canvas.drawLine(knee, foot, bodyPaint);

    // Movimiento de brazos (Press / Fly / Skullcrusher)
    Offset elbow;
    Offset hand;
    if (pattern == 'skullcrusher') {
      elbow = Offset(cx - 38, benchY - 46);
      hand = _lerpOffset(
        Offset(cx - 64, benchY - 22),
        Offset(cx - 38, benchY - 78),
        t,
      );
    } else {
      elbow = _lerpOffset(
        Offset(cx - 32, benchY + 6),
        Offset(cx - 35, benchY - 42),
        t,
      );
      hand = _lerpOffset(
        Offset(cx - 32, benchY - 22),
        Offset(cx - 35, benchY - 76),
        t,
      );
    }

    // Iluminación del músculo activo (Pecho / Tríceps)
    canvas.drawCircle(shoulder, 16, glowPaint);
    canvas.drawLine(shoulder, elbow, activePaint);
    canvas.drawLine(elbow, hand, activePaint);

    // Dibujar Barra o Mancuerna
    _drawWeightAt(canvas, hand, weightPaint);
  }

  void _drawInclineBenchExercise(
    Canvas canvas,
    double cx,
    double floorY,
    Paint equipPaint,
    Paint bodyPaint,
    Paint activePaint,
    Paint glowPaint,
    Paint weightPaint,
  ) {
    // Banco inclinado a 35°
    final seat = Offset(cx + 10, floorY - 32);
    final backTop = Offset(cx - 42, floorY - 75);
    canvas.drawLine(backTop, seat, equipPaint);
    canvas.drawLine(seat, Offset(cx + 35, floorY - 28), equipPaint);
    canvas.drawLine(Offset(cx - 25, floorY - 60), Offset(cx - 25, floorY), equipPaint);
    canvas.drawLine(Offset(cx + 15, floorY - 32), Offset(cx + 15, floorY), equipPaint);

    final head = Offset(cx - 40, floorY - 86);
    final shoulder = Offset(cx - 26, floorY - 68);
    final hip = Offset(cx + 8, floorY - 38);
    final knee = Offset(cx + 36, floorY - 34);
    final foot = Offset(cx + 42, floorY);

    canvas.drawCircle(head, 9, bodyPaint);
    canvas.drawLine(shoulder, hip, bodyPaint);
    canvas.drawLine(hip, knee, bodyPaint);
    canvas.drawLine(knee, foot, bodyPaint);

    final elbow = _lerpOffset(
      Offset(cx - 20, floorY - 48),
      Offset(cx - 24, floorY - 96),
      t,
    );
    final hand = _lerpOffset(
      Offset(cx - 22, floorY - 76),
      Offset(cx - 24, floorY - 126),
      t,
    );

    canvas.drawCircle(shoulder, 16, glowPaint);
    canvas.drawLine(shoulder, elbow, activePaint);
    canvas.drawLine(elbow, hand, activePaint);
    _drawWeightAt(canvas, hand, weightPaint);
  }

  void _drawSquatOrLegExercise(
    Canvas canvas,
    double cx,
    double floorY,
    Paint equipPaint,
    Paint bodyPaint,
    Paint activePaint,
    Paint glowPaint,
    Paint weightPaint,
  ) {
    // t=0: abajo (excéntrica/profundo), t=1: arriba (extensión concéntrica)
    final double depth = 1.0 - t;
    final ankle = Offset(cx, floorY - (pattern == 'calf_raise' ? t * 14 : 0));
    final knee = Offset(cx + 22 * depth, floorY - 40 + 12 * depth);
    final hip = Offset(cx - 26 * depth, floorY - 82 + 34 * depth);
    final shoulder = Offset(cx - 8 * depth, hip.dy - 48);
    final head = Offset(shoulder.dx + 4, shoulder.dy - 16);

    canvas.drawCircle(head, 9.5, bodyPaint);
    // Torso
    canvas.drawLine(shoulder, hip, bodyPaint);
    // Muslo y glúteo activos
    canvas.drawCircle(hip, 15, glowPaint);
    canvas.drawLine(hip, knee, activePaint);
    canvas.drawLine(knee, ankle, pattern == 'calf_raise' ? activePaint : bodyPaint);
    // Pie
    canvas.drawLine(ankle, Offset(ankle.dx + 16, floorY), bodyPaint);

    // Brazos sosteniendo la barra sobre los trapecios
    final barPos = Offset(shoulder.dx - 4, shoulder.dy + 4);
    canvas.drawLine(shoulder, barPos, bodyPaint);
    _drawWeightAt(canvas, barPos, weightPaint);
  }

  void _drawHingeOrRowExercise(
    Canvas canvas,
    double cx,
    double floorY,
    Paint equipPaint,
    Paint bodyPaint,
    Paint activePaint,
    Paint glowPaint,
    Paint weightPaint,
  ) {
    final isRow = pattern == 'row';
    // En Peso Muerto el torso sube con t; en Remo el torso se mantiene inclinado y jalan los brazos
    final torsoAngle = isRow ? 0.85 : _lerp(0.95, 0.08, t);

    final ankle = Offset(cx - 10, floorY);
    final knee = Offset(cx + 6, floorY - 38);
    final hip = Offset(cx - 18, floorY - 76);
    final shoulder = Offset(
      hip.dx + math.sin(torsoAngle) * 52,
      hip.dy - math.cos(torsoAngle) * 52,
    );
    final head = Offset(
      shoulder.dx + math.sin(torsoAngle) * 15,
      shoulder.dy - math.cos(torsoAngle) * 15,
    );

    canvas.drawCircle(head, 9.5, bodyPaint);
    canvas.drawLine(ankle, knee, bodyPaint);
    canvas.drawLine(knee, hip, isRow ? bodyPaint : activePaint);
    canvas.drawLine(hip, shoulder, activePaint);
    canvas.drawCircle(isRow ? shoulder : hip, 16, glowPaint);

    Offset elbow;
    Offset hand;
    if (isRow) {
      elbow = _lerpOffset(
        Offset(shoulder.dx + 2, shoulder.dy + 26),
        Offset(hip.dx + 6, hip.dy - 14),
        t,
      );
      hand = _lerpOffset(
        Offset(shoulder.dx + 6, shoulder.dy + 52),
        Offset(hip.dx + 18, hip.dy + 6),
        t,
      );
    } else {
      elbow = Offset(shoulder.dx, shoulder.dy + 26);
      hand = Offset(shoulder.dx + 2, shoulder.dy + 52);
    }

    canvas.drawLine(shoulder, elbow, isRow ? activePaint : bodyPaint);
    canvas.drawLine(elbow, hand, isRow ? activePaint : bodyPaint);
    _drawWeightAt(canvas, hand, weightPaint);
  }

  void _drawLatPulldownExercise(
    Canvas canvas,
    double cx,
    double floorY,
    Paint equipPaint,
    Paint bodyPaint,
    Paint activePaint,
    Paint glowPaint,
    Paint weightPaint,
  ) {
    // Torre de polea alta o barra de dominadas
    final topBarY = floorY - 148;
    canvas.drawLine(Offset(cx - 45, topBarY), Offset(cx + 45, topBarY), equipPaint);

    final hip = Offset(cx, floorY - 38);
    final knee = Offset(cx + 26, floorY - 36);
    final foot = Offset(cx + 26, floorY);
    final shoulder = Offset(cx - 4, hip.dy - 48);
    final head = Offset(shoulder.dx, shoulder.dy - 16);

    // Asiento
    canvas.drawLine(Offset(cx - 18, floorY - 34), Offset(cx + 22, floorY - 34), equipPaint);
    canvas.drawLine(Offset(cx, floorY - 34), Offset(cx, floorY), equipPaint);

    canvas.drawCircle(head, 9, bodyPaint);
    canvas.drawLine(hip, knee, bodyPaint);
    canvas.drawLine(knee, foot, bodyPaint);
    canvas.drawLine(hip, shoulder, activePaint);
    canvas.drawCircle(shoulder, 16, glowPaint);

    // Movimiento de jalón vertical
    final handY = _lerp(topBarY + 18, shoulder.dy + 4, t);
    final elbowY = _lerp(topBarY + 42, shoulder.dy + 22, t);
    final elbow = Offset(cx - 22, elbowY);
    final hand = Offset(cx + 6, handY);

    // Cable desde la polea superior
    final cablePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(hand.dx, topBarY), hand, cablePaint);

    canvas.drawLine(shoulder, elbow, activePaint);
    canvas.drawLine(elbow, hand, activePaint);
    _drawWeightAt(canvas, hand, weightPaint);
  }

  void _drawShoulderStandingExercise(
    Canvas canvas,
    double cx,
    double floorY,
    Paint equipPaint,
    Paint bodyPaint,
    Paint activePaint,
    Paint glowPaint,
    Paint weightPaint,
  ) {
    final footL = Offset(cx - 18, floorY);
    final footR = Offset(cx + 18, floorY);
    final hip = Offset(cx, floorY - 66);
    final shoulder = Offset(cx, hip.dy - 50);
    final head = Offset(cx, shoulder.dy - 18);

    canvas.drawLine(footL, hip, bodyPaint);
    canvas.drawLine(footR, hip, bodyPaint);
    canvas.drawLine(hip, shoulder, bodyPaint);
    canvas.drawCircle(head, 9.5, bodyPaint);
    canvas.drawCircle(shoulder, 16, glowPaint);

    if (pattern == 'lateral_raise') {
      // Elevaciones laterales bilaterales
      final angle = _lerp(0.15, 1.48, t);
      final armLen = 46.0;
      final handL = Offset(
        shoulder.dx - 12 - math.sin(angle) * armLen,
        shoulder.dy + math.cos(angle) * armLen,
      );
      final handR = Offset(
        shoulder.dx + 12 + math.sin(angle) * armLen,
        shoulder.dy + math.cos(angle) * armLen,
      );
      canvas.drawLine(Offset(shoulder.dx - 10, shoulder.dy), handL, activePaint);
      canvas.drawLine(Offset(shoulder.dx + 10, shoulder.dy), handR, activePaint);
      _drawWeightAt(canvas, handL, weightPaint, radius: 7);
      _drawWeightAt(canvas, handR, weightPaint, radius: 7);
    } else {
      // Press Militar (Overhead Press)
      final elbowY = _lerp(shoulder.dy + 18, shoulder.dy - 26, t);
      final handY = _lerp(shoulder.dy - 4, shoulder.dy - 58, t);
      final elbowL = Offset(cx - 26, elbowY);
      final elbowR = Offset(cx + 26, elbowY);
      final handL = Offset(cx - 22, handY);
      final handR = Offset(cx + 22, handY);

      canvas.drawLine(shoulder, elbowL, activePaint);
      canvas.drawLine(shoulder, elbowR, activePaint);
      canvas.drawLine(elbowL, handL, activePaint);
      canvas.drawLine(elbowR, handR, activePaint);
      // Barra olímpica horizontal si aplica
      canvas.drawLine(
        Offset(handL.dx - 12, handY),
        Offset(handR.dx + 12, handY),
        equipPaint,
      );
      _drawWeightAt(canvas, handL, weightPaint, radius: 8);
      _drawWeightAt(canvas, handR, weightPaint, radius: 8);
    }
  }

  void _drawArmIsolationExercise(
    Canvas canvas,
    double cx,
    double floorY,
    Paint equipPaint,
    Paint bodyPaint,
    Paint activePaint,
    Paint glowPaint,
    Paint weightPaint,
  ) {
    final isTricep = pattern == 'tricep_pushdown';
    final foot = Offset(cx, floorY);
    final hip = Offset(cx, floorY - 68);
    final shoulder = Offset(cx, hip.dy - 50);
    final head = Offset(cx + 4, shoulder.dy - 16);

    canvas.drawLine(foot, hip, bodyPaint);
    canvas.drawLine(hip, shoulder, bodyPaint);
    canvas.drawCircle(head, 9.5, bodyPaint);

    // El codo permanece fijo pegado al torso (clave técnica de bíceps/tríceps)
    final elbow = Offset(cx + 4, shoulder.dy + 28);
    canvas.drawLine(shoulder, elbow, activePaint);
    canvas.drawCircle(elbow, 14, glowPaint);

    // Si es curl: t=0 abajo, t=1 arriba. Si es extensión de tríceps en polea: t=0 arriba, t=1 abajo
    final double angle = isTricep
        ? _lerp(2.2, 0.35, t)
        : _lerp(0.35, 2.35, t);

    final forearmLen = 34.0;
    final hand = Offset(
      elbow.dx + math.sin(angle) * forearmLen,
      elbow.dy + math.cos(angle) * forearmLen,
    );

    if (isTricep) {
      // Dibujar cable desde polea superior
      final cablePaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(cx + 30, floorY - 145), hand, cablePaint);
    }

    canvas.drawLine(elbow, hand, activePaint);
    _drawWeightAt(canvas, hand, weightPaint, radius: 8.5);
  }

  void _drawLegMachineExercise(
    Canvas canvas,
    double cx,
    double floorY,
    Paint equipPaint,
    Paint bodyPaint,
    Paint activePaint,
    Paint glowPaint,
    Paint weightPaint,
  ) {
    // Asiento de máquina de cuádriceps / femoral
    final seat = Offset(cx - 10, floorY - 44);
    final knee = Offset(cx + 22, floorY - 44);
    final backTop = Offset(cx - 24, floorY - 94);

    canvas.drawLine(backTop, seat, equipPaint);
    canvas.drawLine(seat, knee, equipPaint);
    canvas.drawLine(seat, Offset(seat.dx, floorY), equipPaint);

    final head = Offset(backTop.dx + 4, backTop.dy - 14);
    canvas.drawCircle(head, 9, bodyPaint);
    canvas.drawLine(backTop, seat, bodyPaint);
    canvas.drawLine(seat, knee, activePaint);
    canvas.drawCircle(knee, 15, glowPaint);

    final isCurl = pattern == 'leg_curl';
    final legAngle = isCurl
        ? _lerp(1.45, 0.15, t)
        : _lerp(0.15, 1.48, t);

    final ankle = Offset(
      knee.dx + math.sin(legAngle) * 42,
      knee.dy + math.cos(legAngle) * 42,
    );

    canvas.drawLine(knee, ankle, activePaint);
    _drawWeightAt(canvas, ankle, weightPaint, radius: 8);
  }

  void _drawCoreOrHipThrustExercise(
    Canvas canvas,
    double cx,
    double floorY,
    Paint equipPaint,
    Paint bodyPaint,
    Paint activePaint,
    Paint glowPaint,
    Paint weightPaint,
  ) {
    // Banco de apoyo escapular
    canvas.drawRect(
      Rect.fromLTWH(cx - 68, floorY - 38, 28, 38),
      equipPaint,
    );

    final shoulder = Offset(cx - 42, floorY - 42);
    final head = Offset(cx - 56, floorY - 48);
    final hipY = _lerp(floorY - 12, floorY - 42, t);
    final hip = Offset(cx, hipY);
    final knee = Offset(cx + 36, floorY - 42);
    final foot = Offset(cx + 38, floorY);

    canvas.drawCircle(head, 9, bodyPaint);
    canvas.drawLine(shoulder, hip, activePaint);
    canvas.drawLine(hip, knee, activePaint);
    canvas.drawLine(knee, foot, bodyPaint);
    canvas.drawCircle(hip, 16, glowPaint);

    _drawWeightAt(canvas, Offset(hip.dx, hip.dy - 6), weightPaint, radius: 10);
  }

  void _drawWeightAt(
    Canvas canvas,
    Offset pos,
    Paint weightPaint, {
    double radius = 10,
  }) {
    canvas.drawCircle(pos, radius, weightPaint);
    final innerPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, radius * 0.38, innerPaint);
  }

  void _drawPhaseBadge(Canvas canvas, Size size) {
    final text = isConcentric
        ? 'FASE CONCÉNTRICA (Exhala ↑)'
        : 'FASE EXCÉNTRICA (Controla ↓)';
    final color = isConcentric
        ? const Color(0xFFCCFF00)
        : const Color(0xFF00E5FF);

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - tp.width - 26, 10, tp.width + 16, 24),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.black.withOpacity(0.68),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = color.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(canvas, Offset(size.width - tp.width - 18, 15));
  }

  @override
  bool shouldRepaint(covariant _BiomechanicsPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.isConcentric != isConcentric ||
        oldDelegate.pattern != pattern;
  }
}
