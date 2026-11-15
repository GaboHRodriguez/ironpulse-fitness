import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/fitness_models.dart';
import '../services/database_service.dart';

class ExerciseTechniqueAnimation extends StatefulWidget {
  final Exercise exercise;
  final double height;
  final bool showControls;

  const ExerciseTechniqueAnimation({
    super.key,
    required this.exercise,
    this.height = 260,
    this.showControls = true,
  });

  @override
  State<ExerciseTechniqueAnimation> createState() =>
      _ExerciseTechniqueAnimationState();
}

class _ExerciseTechniqueAnimationState extends State<ExerciseTechniqueAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late PageController _pageController;
  int _currentSlide = 0; // 0 = Ejecución Maniquí 3D, 1 = Mapa Muscular Maniquí 3D
  String _mannequinView = 'dual'; // 'dual', 'front', 'back'
  bool _showExternalGif = false;
  double _speed = 1.0;
  bool? _overrideIsFemale; // null = usa automáticamente el sexo del alumno activo

  bool get _effectiveIsFemale =>
      _overrideIsFemale ?? DatabaseService.instance.isCurrentFemale;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _goToSlide(int index) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
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

  void _toggleGenderPreview() {
    setState(() {
      _overrideIsFemale = !_effectiveIsFemale;
    });
  }

  Future<void> _openVideoSearch() async {
    final query = Uri.encodeComponent(
        '${widget.exercise.name} tecnica correcta musculacion');
    final uri =
        Uri.parse('https://www.youtube.com/results?search_query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasGif = widget.exercise.externalMediaUrl != null &&
        widget.exercise.externalMediaUrl!.trim().isNotEmpty;
    final isFemale = _effectiveIsFemale;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF0E131F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF283246), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // CARRUSEL DESLIZABLE (Slide 0: Ejercicio con Maniquí 3D | Slide 1: Maniquí Muscular 3D)
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                },
              ),
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (idx) {
                  setState(() => _currentSlide = idx);
                },
                children: [
                  // SLIDE 1: EJECUCIÓN DEL EJERCICIO REALIZADA POR EL MANIQUÍ 3D
                  _buildExerciseExecutionSlide(hasGif, isFemale),

                  // SLIDE 2: MANIQUÍ ANATÓMICO 3D (MÚSCULOS TRABAJADOS)
                  _buildDigitalMannequinSlide(isFemale),
                ],
              ),
            ),
          ),

          // Etiqueta superior izquierda: Selector rápido de diapositiva del carrusel
          if (widget.showControls)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFCCFF00).withOpacity(0.45),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CarouselTabPill(
                      icon: Icons.fitness_center_rounded,
                      label: '1. Ejercicio 3D',
                      selected: _currentSlide == 0,
                      onTap: () => _goToSlide(0),
                    ),
                    const SizedBox(width: 4),
                    _CarouselTabPill(
                      icon: Icons.accessibility_new_rounded,
                      label: '2. Músculos (${isFemale ? "Mujer" : "Varón"})',
                      selected: _currentSlide == 1,
                      onTap: () => _goToSlide(1),
                    ),
                  ],
                ),
              ),
            )
          else
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _currentSlide == 0 ? 'Maniquí 3D ▸' : '◂ Músculos',
                  style: const TextStyle(
                    color: Color(0xFFCCFF00),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Flechas laterales sutiles para indicar que es un carrusel deslizable
          if (widget.showControls) ...[
            if (_currentSlide == 0)
              Positioned(
                right: 6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _CarouselArrowButton(
                    icon: Icons.chevron_right_rounded,
                    tooltip: 'Deslizar a Maniquí Muscular 3D',
                    onTap: () => _goToSlide(1),
                  ),
                ),
              ),
            if (_currentSlide == 1)
              Positioned(
                left: 6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _CarouselArrowButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Volver a la animación del ejercicio',
                    onTap: () => _goToSlide(0),
                  ),
                ),
              ),
          ],

          // Indicadores de puntos del carrusel + Controles inferiores
          if (widget.showControls)
            Positioned(
              bottom: 8,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Controles izquierdos según la vista actual
                  if (_currentSlide == 0 && !_showExternalGif)
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
                        const SizedBox(width: 5),
                        _MiniControlBtn(
                          icon: Icons.slow_motion_video_rounded,
                          label: '${_speed}x',
                          active: _speed < 1.0,
                          onTap: _toggleSpeed,
                        ),
                        const SizedBox(width: 5),
                        _MiniControlBtn(
                          icon: isFemale
                              ? Icons.female_rounded
                              : Icons.male_rounded,
                          label: isFemale ? 'Mujer' : 'Varón',
                          active: _overrideIsFemale != null,
                          onTap: _toggleGenderPreview,
                        ),
                      ],
                    )
                  else if (_currentSlide == 1)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MiniControlBtn(
                          icon: Icons.compare_arrows_rounded,
                          label: _mannequinView == 'dual'
                              ? 'Vista: 360° Dual'
                              : (_mannequinView == 'front'
                                  ? 'Vista: Frontal'
                                  : 'Vista: Espalda'),
                          active: true,
                          onTap: () {
                            setState(() {
                              if (_mannequinView == 'dual') {
                                _mannequinView = 'front';
                              } else if (_mannequinView == 'front') {
                                _mannequinView = 'back';
                              } else {
                                _mannequinView = 'dual';
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 5),
                        _MiniControlBtn(
                          icon: isFemale
                              ? Icons.female_rounded
                              : Icons.male_rounded,
                          label: isFemale ? 'Mujer' : 'Varón',
                          active: _overrideIsFemale != null,
                          onTap: _toggleGenderPreview,
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),

                  // Puntos indicadores del carrusel en el centro
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _goToSlide(0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: _currentSlide == 0 ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _currentSlide == 0
                                ? const Color(0xFFCCFF00)
                                : Colors.white30,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => _goToSlide(1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: _currentSlide == 1 ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _currentSlide == 1
                                ? const Color(0xFF00E5FF)
                                : Colors.white30,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Controles derechos
                  if (_currentSlide == 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasGif)
                          _MiniControlBtn(
                            icon: _showExternalGif
                                ? Icons.accessibility_new_rounded
                                : Icons.gif_box_outlined,
                            label: _showExternalGif ? 'Maniquí 3D' : 'GIF',
                            active: _showExternalGif,
                            onTap: () => setState(
                                () => _showExternalGif = !_showExternalGif),
                          ),
                        const SizedBox(width: 5),
                        _MiniControlBtn(
                          icon: Icons.ondemand_video_rounded,
                          label: 'Video',
                          onTap: _openVideoSearch,
                        ),
                      ],
                    )
                  else
                    _MiniControlBtn(
                      icon: Icons.fitness_center_rounded,
                      label: 'Ver Ejercicio',
                      onTap: () => _goToSlide(0),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseExecutionSlide(bool hasGif, bool isFemale) {
    if (_showExternalGif && hasGif) {
      return Container(
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
                  'Sin conexión para el GIF externo.\nCambiando a animación con Maniquí 3D offline.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black87, fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => _showExternalGif = false),
                  child: const Text('Ver Maniquí 3D Offline'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final raw = _controller.value;
        final phase = 0.5 - 0.5 * math.cos(raw * 2 * math.pi);
        final isConcentric = raw < 0.5;

        return CustomPaint(
          painter: _BiomechanicsPainter(
            exerciseName: widget.exercise.name,
            pattern: widget.exercise.movementPattern,
            equipment: widget.exercise.equipment,
            muscleGroup: widget.exercise.muscleGroup,
            isFemale: isFemale,
            t: phase,
            isConcentric: isConcentric,
            showBadges: widget.showControls,
          ),
        );
      },
    );
  }

  Widget _buildDigitalMannequinSlide(bool isFemale) {
    final activation = _MuscleActivationResolver.resolve(widget.exercise);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final raw = _controller.value;
        final pulse = 0.5 - 0.5 * math.cos(raw * 2 * math.pi);

        return CustomPaint(
          painter: _AnatomicalMannequinPainter(
            exercise: widget.exercise,
            activation: activation,
            pulse: pulse,
            viewMode: _mannequinView,
            isFemale: isFemale,
            showLabels: widget.showControls,
          ),
        );
      },
    );
  }
}

class _CarouselTabPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CarouselTabPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFCCFF00) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: selected ? Colors.black : Colors.white70,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white70,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarouselArrowButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CarouselArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.55),
      shape: CircleBorder(
        side: BorderSide(color: const Color(0xFFCCFF00).withOpacity(0.55)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            color: const Color(0xFFCCFF00),
            size: 22,
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
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
              size: 13.5,
              color: active ? const Color(0xFFCCFF00) : Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFFCCFF00) : Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// RESOLUTOR ANATÓMICO DE MÚSCULOS PRIMARIOS Y SECUNDARIOS PARA EL MANIQUÍ 3D
// =============================================================================
class _MuscleActivationData {
  final Set<String> primaryZones;
  final Set<String> secondaryZones;
  final List<String> primaryLabels;
  final List<String> secondaryLabels;

  const _MuscleActivationData({
    required this.primaryZones,
    required this.secondaryZones,
    required this.primaryLabels,
    required this.secondaryLabels,
  });
}

class _MuscleActivationResolver {
  static _MuscleActivationData resolve(Exercise ex) {
    final Set<String> primary = {};
    final Set<String> secondary = {};
    final List<String> pLabels = [ex.muscleGroup];
    final List<String> sLabels = ex.secondaryMuscles
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final mg = ex.muscleGroup.toLowerCase();
    final name = ex.name.toLowerCase();
    final sec = ex.secondaryMuscles.toLowerCase();
    final pat = ex.movementPattern.toLowerCase();

    if (mg.contains('pecho')) {
      primary.add('chest');
      if (pat == 'incline_press' || name.contains('inclinad')) {
        primary.add('delt_front');
      }
    } else if (mg.contains('espalda')) {
      primary.add('lats');
      primary.add('upper_back');
      if (name.contains('peso muerto') || pat == 'deadlift') {
        primary.add('lower_back');
      }
      if (name.contains('remo') || name.contains('encogimiento')) {
        primary.add('traps');
      }
    } else if (mg.contains('hombro')) {
      if (name.contains('posterior') ||
          name.contains('pájaro') ||
          name.contains('face pull')) {
        primary.add('delt_rear');
        primary.add('upper_back');
      } else if (name.contains('lateral')) {
        primary.add('delt_side');
        primary.add('delt_front');
      } else if (name.contains('encogimiento') || pat == 'shrug') {
        primary.add('traps');
      } else {
        primary.add('delt_front');
        primary.add('delt_side');
      }
    } else if (mg.contains('cuádriceps') || mg.contains('cuadriceps')) {
      primary.add('quads');
      if (pat == 'squat' || pat == 'lunge' || pat == 'thruster') {
        secondary.add('glutes');
      }
    } else if (mg.contains('isquio') ||
        mg.contains('glúteo') ||
        mg.contains('gluteo')) {
      if (name.contains('hip thrust') ||
          name.contains('glúteo') ||
          name.contains('patada') ||
          pat == 'hip_thrust') {
        primary.add('glutes');
        secondary.add('hamstrings');
      } else if (name.contains('curl') ||
          pat == 'leg_curl' ||
          pat == 'lying_leg_curl') {
        primary.add('hamstrings');
      } else {
        primary.add('hamstrings');
        primary.add('glutes');
      }
    } else if (mg.contains('bíceps') || mg.contains('biceps')) {
      primary.add('biceps');
      if (name.contains('martillo') || name.contains('inverso')) {
        primary.add('forearms');
      }
    } else if (mg.contains('tríceps') || mg.contains('triceps')) {
      primary.add('triceps');
    } else if (mg.contains('abdomen') || mg.contains('core')) {
      primary.add('abs');
      primary.add('obliques');
    } else if (mg.contains('pantorrilla') || mg.contains('antebrazo')) {
      if (name.contains('antebrazo') || name.contains('muñeca')) {
        primary.add('forearms');
      } else {
        primary.add('calves');
      }
    }

    void matchSecondary(String text) {
      if (text.contains('tríceps') || text.contains('triceps')) {
        secondary.add('triceps');
      }
      if (text.contains('bíceps') ||
          text.contains('biceps') ||
          text.contains('braquial')) {
        secondary.add('biceps');
      }
      if (text.contains('antebrazo') || text.contains('agarre')) {
        secondary.add('forearms');
      }
      if (text.contains('deltoides anterior') || text.contains('hombro')) {
        secondary.add('delt_front');
      }
      if (text.contains('deltoides lateral')) {
        secondary.add('delt_side');
      }
      if (text.contains('deltoides posterior')) {
        secondary.add('delt_rear');
      }
      if (text.contains('trapecio')) {
        secondary.add('traps');
      }
      if (text.contains('romboides') ||
          text.contains('espalda media') ||
          text.contains('redondo')) {
        secondary.add('upper_back');
      }
      if (text.contains('dorsal')) {
        secondary.add('lats');
      }
      if (text.contains('lumbar') || text.contains('erector')) {
        secondary.add('lower_back');
      }
      if (text.contains('glúteo') || text.contains('gluteo')) {
        secondary.add('glutes');
      }
      if (text.contains('isquio') || text.contains('femoral')) {
        secondary.add('hamstrings');
      }
      if (text.contains('cuádriceps') || text.contains('cuadriceps')) {
        secondary.add('quads');
      }
      if (text.contains('pantorrilla') ||
          text.contains('gemelo') ||
          text.contains('sóleo')) {
        secondary.add('calves');
      }
      if (text.contains('core') ||
          text.contains('abdomen') ||
          text.contains('abdominal') ||
          text.contains('estabilizador')) {
        secondary.add('abs');
        secondary.add('obliques');
      }
      if (text.contains('pecho') || text.contains('pectoral')) {
        secondary.add('chest');
      }
    }

    matchSecondary(sec);
    secondary.removeAll(primary);

    return _MuscleActivationData(
      primaryZones: primary,
      secondaryZones: secondary,
      primaryLabels: pLabels,
      secondaryLabels: sLabels,
    );
  }
}

// =============================================================================
// SLIDE 2: MANIQUÍ ANATÓMICO 3D ESTILO PORCELANA BLANCA/MARFIL (VARÓN Y MUJER)
// =============================================================================
class _AnatomicalMannequinPainter extends CustomPainter {
  final Exercise exercise;
  final _MuscleActivationData activation;
  final double pulse; // 0.0 -> 1.0
  final String viewMode; // 'dual', 'front', 'back'
  final bool isFemale;
  final bool showLabels;

  _AnatomicalMannequinPainter({
    required this.exercise,
    required this.activation,
    required this.pulse,
    required this.viewMode,
    required this.isFemale,
    required this.showLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawStudioBackdrop(canvas, size);

    final double bodyTop = showLabels ? 42.0 : 18.0;
    final double bodyBottom = showLabels ? h - 38.0 : h - 10.0;
    final double bodyHeight = (bodyBottom - bodyTop).clamp(90.0, 400.0);

    if (viewMode == 'front') {
      _drawPorcelain3DMannequin(
        canvas,
        center: Offset(w * 0.5, bodyTop + bodyHeight * 0.5),
        height: bodyHeight,
        isFront: true,
        caption: isFemale ? 'FRONTAL (MUJER)' : 'FRONTAL (VARÓN)',
      );
    } else if (viewMode == 'back') {
      _drawPorcelain3DMannequin(
        canvas,
        center: Offset(w * 0.5, bodyTop + bodyHeight * 0.5),
        height: bodyHeight,
        isFront: false,
        caption: isFemale ? 'ESPALDA (MUJER)' : 'ESPALDA (VARÓN)',
      );
    } else {
      final double spread = w > 340 ? 0.24 : 0.26;
      _drawPorcelain3DMannequin(
        canvas,
        center: Offset(w * (0.5 - spread), bodyTop + bodyHeight * 0.5),
        height: bodyHeight,
        isFront: true,
        caption: 'FRONTAL',
      );
      _drawPorcelain3DMannequin(
        canvas,
        center: Offset(w * (0.5 + spread), bodyTop + bodyHeight * 0.5),
        height: bodyHeight,
        isFront: false,
        caption: 'ESPALDA',
      );
    }

    if (showLabels) {
      _drawMuscleLegendPanel(canvas, size);
    }
  }

  void _drawStudioBackdrop(Canvas canvas, Size size) {
    final bgRect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.15),
        radius: 1.1,
        colors: [
          Color(0xFF232B3A),
          Color(0xFF141A26),
          Color(0xFF0B0E16),
        ],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // Piso con reflejo suave bajo el maniquí 3D
    final floorOval = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.85),
      width: size.width * 0.78,
      height: 26,
    );
    canvas.drawOval(
      floorOval,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.10),
            Colors.transparent,
          ],
        ).createShader(floorOval),
    );
  }

  void _drawPorcelain3DMannequin(
    Canvas canvas, {
    required Offset center,
    required double height,
    required bool isFront,
    required String caption,
  }) {
    final double s = height / 215.0;
    final double cx = center.dx;
    final double topY = center.dy - height * 0.48;

    Offset pt(double dx, double dy) => Offset(cx + dx * s, topY + dy * s);
    Rect rc(double left, double top, double w, double h) =>
        Rect.fromLTWH(cx + left * s, topY + top * s, w * s, h * s);

    // Sombras proyectadas en los pies (efecto estudio 3D como en la imagen de referencia)
    canvas.drawOval(
      rc(-22, 189, 44, 8),
      Paint()
        ..color = Colors.black.withOpacity(0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Función que pinta una región del maniquí 3D blanco/marfil con brillo especular
    // o iluminada cuando el músculo está activo
    void draw3DPart(
      Path path,
      String zoneKey, {
      Rect? boundsHint,
      bool addSpecular = true,
    }) {
      final Rect b = boundsHint ?? path.getBounds();
      final bool isPrimary = activation.primaryZones.contains(zoneKey);
      final bool isSecondary = activation.secondaryZones.contains(zoneKey);

      if (isPrimary) {
        canvas.drawPath(
          path,
          Paint()
            ..color = Color.lerp(
              const Color(0xFFFF5252),
              const Color(0xFFCCFF00),
              pulse,
            )!
                .withOpacity(0.38 + 0.25 * pulse)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );

        final activeGrad = LinearGradient(
          begin: const Alignment(-0.5, -0.7),
          end: const Alignment(0.7, 0.8),
          colors: [
            const Color(0xFFFFFFFF),
            Color.lerp(
                const Color(0xFFFF8A65), const Color(0xFFD4FF33), pulse)!,
            Color.lerp(
                const Color(0xFFE64A19), const Color(0xFF88B800), pulse)!,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(b);

        canvas.drawPath(path, Paint()..shader = activeGrad);
      } else if (isSecondary) {
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFF00E5FF).withOpacity(0.26 + 0.14 * pulse)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );

        final secGrad = const LinearGradient(
          begin: Alignment(-0.5, -0.7),
          end: Alignment(0.7, 0.8),
          colors: [
            Color(0xFFF2FDFF),
            Color(0xFF4DD0E1),
            Color(0xFF00838F),
          ],
          stops: [0.0, 0.48, 1.0],
        ).createShader(b);

        canvas.drawPath(path, Paint()..shader = secGrad);
      } else {
        // Porcelana / Resina 3D Blanca-Marfil con sombreado cilíndrico suave
        // (idéntico al maniquí 3D blanco de la imagen de referencia)
        final porcelainGrad = const LinearGradient(
          begin: Alignment(-0.65, -0.65),
          end: Alignment(0.85, 0.75),
          colors: [
            Color(0xFFFFFFFF), // Brillo especular blanco puro
            Color(0xFFF1F2F5), // Marfil claro 3D
            Color(0xFFD5D8DF), // Medio tono escultural
            Color(0xFF9EA4B0), // Sombra de contorno 3D
          ],
          stops: [0.0, 0.28, 0.70, 1.0],
        ).createShader(b);

        canvas.drawPath(path, Paint()..shader = porcelainGrad);
      }

      // Contorno suave de escultura 3D (gris cálido en reposo, neón en activo)
      canvas.drawPath(
        path,
        Paint()
          ..color = isPrimary
              ? const Color(0xFFCCFF00)
              : (isSecondary
                  ? const Color(0xFF00E5FF)
                  : const Color(0xFF888F9C).withOpacity(0.65))
          ..style = PaintingStyle.stroke
          ..strokeWidth = (isPrimary || isSecondary) ? 1.15 * s : 0.75 * s,
      );

      // Reflejo especular brillante (glossy 3D mannequin finish)
      if (addSpecular && b.width > 4 * s && b.height > 4 * s) {
        final specRect = Rect.fromLTWH(
          b.left + b.width * 0.18,
          b.top + b.height * 0.10,
          b.width * 0.24,
          b.height * 0.42,
        );
        canvas.drawOval(
          specRect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.55),
                Colors.white.withOpacity(0.0),
              ],
            ).createShader(specRect),
        );
      }
    }

    // Proporciones diferenciadas entre VARÓN y MUJER (como en la foto de referencia)
    final double shoulderHalf = isFemale ? 18.2 : 22.8;
    final double chestWidth = isFemale ? 16.5 : 21.0;
    final double waistHalf = isFemale ? 11.2 : 15.8;
    final double hipHalf = isFemale ? 19.5 : 16.8;
    final double armThick = isFemale ? 7.8 : 10.2;
    final double forearmThick = isFemale ? 6.4 : 8.5;

    // -------------------------------------------------------------------------
    // 1. CABEZA Y ROSTRO ESCULPIDO 3D + CUELLO
    // -------------------------------------------------------------------------
    final neckW = isFemale ? 5.2 : 7.0;
    final neckPath = Path()
      ..moveTo(cx - neckW * s, topY + 25 * s)
      ..lineTo(cx + neckW * s, topY + 25 * s)
      ..lineTo(cx + (neckW + 2.8) * s, topY + 37 * s)
      ..lineTo(cx - (neckW + 2.8) * s, topY + 37 * s)
      ..close();
    draw3DPart(neckPath, 'neck', addSpecular: false);

    // Cráneo y mandíbula esculpida
    final headW = isFemale ? 18.5 : 20.5;
    final headH = isFemale ? 25.0 : 26.5;
    final headPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        rc(-headW / 2, 1.5, headW, headH),
        topLeft: Radius.circular(10 * s),
        topRight: Radius.circular(10 * s),
        bottomLeft: Radius.circular((isFemale ? 9.5 : 7.5) * s),
        bottomRight: Radius.circular((isFemale ? 9.5 : 7.5) * s),
      ));
    draw3DPart(headPath, 'head');

    // Orejas 3D
    canvas.drawOval(
      rc(-headW / 2 - 1.8, 11.5, 2.5, 6.0),
      Paint()..color = const Color(0xFFD2D6DE),
    );
    canvas.drawOval(
      rc(headW / 2 - 0.7, 11.5, 2.5, 6.0),
      Paint()..color = const Color(0xFFB5BAC6),
    );

    if (isFront) {
      // Rasgos faciales sutiles de maniquí 3D (arco superciliar, nariz y labios en relieve)
      final featurePaint = Paint()
        ..color = const Color(0xFF9EA4B0).withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85 * s
        ..strokeCap = StrokeCap.round;
      // Cejas / cuencas suaves
      canvas.drawArc(
        rc(-6.5, 10.5, 5.0, 2.8),
        math.pi * 1.1,
        math.pi * 0.8,
        false,
        featurePaint,
      );
      canvas.drawArc(
        rc(1.5, 10.5, 5.0, 2.8),
        math.pi * 1.1,
        math.pi * 0.8,
        false,
        featurePaint,
      );
      // Puente nasal y punta de la nariz con brillo blanco
      canvas.drawLine(pt(0, 11.5), pt(-0.8, 17.5), featurePaint);
      canvas.drawLine(pt(-0.8, 17.5), pt(1.0, 17.8), featurePaint);
      // Labios esculpidos
      canvas.drawLine(pt(-2.8, 21.0), pt(2.8, 21.0), featurePaint);
      // Clavículas 3D
      canvas.drawLine(
        pt(-2, 37.5),
        pt(-shoulderHalf * 0.82, 36.5),
        featurePaint,
      );
      canvas.drawLine(
        pt(2, 37.5),
        pt(shoulderHalf * 0.82, 36.5),
        featurePaint,
      );
    }

    // -------------------------------------------------------------------------
    // 2. TRAPECIOS
    // -------------------------------------------------------------------------
    if (isFront) {
      final trapL = Path()
        ..moveTo(cx - neckW * s, topY + 30 * s)
        ..lineTo(cx - shoulderHalf * s, topY + 37.5 * s)
        ..lineTo(cx - (neckW + 3) * s, topY + 39 * s)
        ..close();
      final trapR = Path()
        ..moveTo(cx + neckW * s, topY + 30 * s)
        ..lineTo(cx + shoulderHalf * s, topY + 37.5 * s)
        ..lineTo(cx + (neckW + 3) * s, topY + 39 * s)
        ..close();
      draw3DPart(trapL, 'traps', addSpecular: false);
      draw3DPart(trapR, 'traps', addSpecular: false);
    } else {
      final trapBack = Path()
        ..moveTo(cx, topY + 27 * s)
        ..lineTo(cx - shoulderHalf * s, topY + 38 * s)
        ..lineTo(cx - 10 * s, topY + 55 * s)
        ..lineTo(cx, topY + 66 * s)
        ..lineTo(cx + 10 * s, topY + 55 * s)
        ..lineTo(cx + shoulderHalf * s, topY + 38 * s)
        ..close();
      draw3DPart(trapBack, 'traps');
    }

    // -------------------------------------------------------------------------
    // 3. TORSO ESCULPIDO 3D (DIFERENCIADO VARÓN vs MUJER)
    // -------------------------------------------------------------------------
    if (isFront) {
      if (isFemale) {
        // Torso superior y busto anatómico femenino 3D (como el maniquí mujer de referencia)
        final chestBaseL = Path()
          ..moveTo(cx - 0.8 * s, topY + 38 * s)
          ..lineTo(cx - chestWidth * s, topY + 38 * s)
          ..quadraticBezierTo(
              cx - (chestWidth + 2.5) * s, topY + 50 * s, cx - 14 * s, topY + 59 * s)
          ..quadraticBezierTo(cx - 6.5 * s, topY + 61 * s, cx - 0.8 * s, topY + 55 * s)
          ..close();
        final chestBaseR = Path()
          ..moveTo(cx + 0.8 * s, topY + 38 * s)
          ..lineTo(cx + chestWidth * s, topY + 38 * s)
          ..quadraticBezierTo(
              cx + (chestWidth + 2.5) * s, topY + 50 * s, cx + 14 * s, topY + 59 * s)
          ..quadraticBezierTo(cx + 6.5 * s, topY + 61 * s, cx + 0.8 * s, topY + 55 * s)
          ..close();
        draw3DPart(chestBaseL, 'chest');
        draw3DPart(chestBaseR, 'chest');

        // Esferas esculturales suaves del busto femenino para realismo 3D
        final bustL = Path()..addOval(rc(-15.8, 43.5, 14.0, 14.5));
        final bustR = Path()..addOval(rc(1.8, 43.5, 14.0, 14.5));
        draw3DPart(bustL, 'chest');
        draw3DPart(bustR, 'chest');
      } else {
        // Pectorales masculinos amplios y esculpidos
        final pecL = Path()
          ..moveTo(cx - 1.0 * s, topY + 38 * s)
          ..lineTo(cx - chestWidth * s, topY + 38 * s)
          ..quadraticBezierTo(
              cx - (chestWidth + 3.5) * s, topY + 50 * s, cx - 19 * s, topY + 58.5 * s)
          ..quadraticBezierTo(cx - 9 * s, topY + 61 * s, cx - 1.0 * s, topY + 56.5 * s)
          ..close();
        final pecR = Path()
          ..moveTo(cx + 1.0 * s, topY + 38 * s)
          ..lineTo(cx + chestWidth * s, topY + 38 * s)
          ..quadraticBezierTo(
              cx + (chestWidth + 3.5) * s, topY + 50 * s, cx + 19 * s, topY + 58.5 * s)
          ..quadraticBezierTo(cx + 9 * s, topY + 61 * s, cx + 1.0 * s, topY + 56.5 * s)
          ..close();
        draw3DPart(pecL, 'chest');
        draw3DPart(pecR, 'chest');
      }

      // Dorsales asomando en vista frontal (más anchos en varón)
      if (!isFemale) {
        final latFrontL = Path()
          ..moveTo(cx - 20 * s, topY + 56 * s)
          ..quadraticBezierTo(cx - 22.5 * s, topY + 67 * s, cx - 16.5 * s, topY + 76 * s)
          ..lineTo(cx - 14.5 * s, topY + 58.5 * s)
          ..close();
        final latFrontR = Path()
          ..moveTo(cx + 20 * s, topY + 56 * s)
          ..quadraticBezierTo(cx + 22.5 * s, topY + 67 * s, cx + 16.5 * s, topY + 76 * s)
          ..lineTo(cx + 14.5 * s, topY + 58.5 * s)
          ..close();
        draw3DPart(latFrontL, 'lats', addSpecular: false);
        draw3DPart(latFrontR, 'lats', addSpecular: false);
      }

      // Cintura y Oblicuos (silueta reloj de arena en mujer, atlética en varón)
      final obliqL = Path()
        ..moveTo(cx - (isFemale ? 14.0 : 17.5) * s, topY + 58.5 * s)
        ..lineTo(cx - 8.5 * s, topY + 58.5 * s)
        ..lineTo(cx - 8.5 * s, topY + 93 * s)
        ..lineTo(cx - hipHalf * s, topY + 95 * s)
        ..quadraticBezierTo(
            cx - waistHalf * s, topY + 75 * s, cx - (isFemale ? 14.0 : 17.5) * s, topY + 58.5 * s)
        ..close();
      final obliqR = Path()
        ..moveTo(cx + (isFemale ? 14.0 : 17.5) * s, topY + 58.5 * s)
        ..lineTo(cx + 8.5 * s, topY + 58.5 * s)
        ..lineTo(cx + 8.5 * s, topY + 93 * s)
        ..lineTo(cx + hipHalf * s, topY + 95 * s)
        ..quadraticBezierTo(
            cx + waistHalf * s, topY + 75 * s, cx + (isFemale ? 14.0 : 17.5) * s, topY + 58.5 * s)
        ..close();
      draw3DPart(obliqL, 'obliques');
      draw3DPart(obliqR, 'obliques');

      // Abdomen central (suave y estilizado con línea alba y ombligo como en la foto)
      final absCenterL = Path()
        ..addRRect(RRect.fromRectAndRadius(
          rc(-8.8, 58.5, 8.2, 35.0),
          Radius.circular(4 * s),
        ));
      final absCenterR = Path()
        ..addRRect(RRect.fromRectAndRadius(
          rc(0.6, 58.5, 8.2, 35.0),
          Radius.circular(4 * s),
        ));
      draw3DPart(absCenterL, 'abs');
      draw3DPart(absCenterR, 'abs');

      // Ombligo esculpido en 3D
      canvas.drawOval(
        rc(-1.2, 82.5, 2.4, 3.2),
        Paint()..color = const Color(0xFF7B8290).withOpacity(0.75),
      );
    } else {
      // VISTA POSTERIOR DE LA ESPALDA
      final upperBackL = Path()
        ..moveTo(cx - shoulderHalf * s, topY + 41 * s)
        ..lineTo(cx - 9 * s, topY + 51 * s)
        ..lineTo(cx - 10 * s, topY + 63 * s)
        ..lineTo(cx - (shoulderHalf + 1) * s, topY + 55 * s)
        ..close();
      final upperBackR = Path()
        ..moveTo(cx + shoulderHalf * s, topY + 41 * s)
        ..lineTo(cx + 9 * s, topY + 51 * s)
        ..lineTo(cx + 10 * s, topY + 63 * s)
        ..lineTo(cx + (shoulderHalf + 1) * s, topY + 55 * s)
        ..close();
      draw3DPart(upperBackL, 'upper_back');
      draw3DPart(upperBackR, 'upper_back');

      final latBackL = Path()
        ..moveTo(cx - (shoulderHalf + 0.5) * s, topY + 55 * s)
        ..lineTo(cx - 9.5 * s, topY + 63 * s)
        ..lineTo(cx - 6.5 * s, topY + 86 * s)
        ..lineTo(cx - waistHalf * s, topY + 83 * s)
        ..close();
      final latBackR = Path()
        ..moveTo(cx + (shoulderHalf + 0.5) * s, topY + 55 * s)
        ..lineTo(cx + 9.5 * s, topY + 63 * s)
        ..lineTo(cx + 6.5 * s, topY + 86 * s)
        ..lineTo(cx + waistHalf * s, topY + 83 * s)
        ..close();
      draw3DPart(latBackL, 'lats');
      draw3DPart(latBackR, 'lats');

      final lumbarL = Path()
        ..addRRect(RRect.fromRectAndRadius(
          rc(-9.0, 66, 8.2, 24),
          Radius.circular(3.5 * s),
        ));
      final lumbarR = Path()
        ..addRRect(RRect.fromRectAndRadius(
          rc(0.8, 66, 8.2, 24),
          Radius.circular(3.5 * s),
        ));
      draw3DPart(lumbarL, 'lower_back');
      draw3DPart(lumbarR, 'lower_back');
    }

    // -------------------------------------------------------------------------
    // 4. HOMBROS (DELTOIDES) Y BRAZOS ESCULPIDOS EN 3D
    // -------------------------------------------------------------------------
    final String deltZone = isFront ? 'delt_front' : 'delt_rear';
    final bool highlightSideDelt =
        activation.primaryZones.contains('delt_side') ||
            activation.secondaryZones.contains('delt_side');
    final String effectiveDeltZone = highlightSideDelt ? 'delt_side' : deltZone;

    final double armOutX = shoulderHalf + armThick * 0.92;
    final deltL = Path()
      ..moveTo(cx - (shoulderHalf - 2) * s, topY + 37.5 * s)
      ..quadraticBezierTo(
          cx - (armOutX + 2) * s, topY + 40 * s, cx - armOutX * s, topY + 53.5 * s)
      ..lineTo(cx - (shoulderHalf - 1) * s, topY + 53.5 * s)
      ..close();
    final deltR = Path()
      ..moveTo(cx + (shoulderHalf - 2) * s, topY + 37.5 * s)
      ..quadraticBezierTo(
          cx + (armOutX + 2) * s, topY + 40 * s, cx + armOutX * s, topY + 53.5 * s)
      ..lineTo(cx + (shoulderHalf - 1) * s, topY + 53.5 * s)
      ..close();
    draw3DPart(deltL, effectiveDeltZone);
    draw3DPart(deltR, effectiveDeltZone);

    // Brazo superior (Bíceps / Tríceps)
    final String upperArmZone = isFront ? 'biceps' : 'triceps';
    final upperArmL = Path()
      ..addRRect(RRect.fromRectAndRadius(
        rc(-armOutX - 0.5, 52.5, armThick, 24.5),
        Radius.circular(5 * s),
      ));
    final upperArmR = Path()
      ..addRRect(RRect.fromRectAndRadius(
        rc(armOutX - armThick + 0.5, 52.5, armThick, 24.5),
        Radius.circular(5 * s),
      ));
    draw3DPart(upperArmL, upperArmZone);
    draw3DPart(upperArmR, upperArmZone);

    if (isFront &&
        (activation.primaryZones.contains('triceps') ||
            activation.secondaryZones.contains('triceps'))) {
      final triEdgeL = Path()
        ..addRRect(RRect.fromRectAndRadius(
          rc(-armOutX - 2.8, 54, 3.0, 20),
          Radius.circular(2 * s),
        ));
      final triEdgeR = Path()
        ..addRRect(RRect.fromRectAndRadius(
          rc(armOutX - 0.2, 54, 3.0, 20),
          Radius.circular(2 * s),
        ));
      draw3DPart(triEdgeL, 'triceps', addSpecular: false);
      draw3DPart(triEdgeR, 'triceps', addSpecular: false);
    }

    // Antebrazos
    final forearmL = Path()
      ..moveTo(cx - (armOutX + 0.5) * s, topY + 76.5 * s)
      ..lineTo(cx - (armOutX - armThick + 0.5) * s, topY + 76.5 * s)
      ..lineTo(cx - (armOutX - armThick + 2.2) * s, topY + 102 * s)
      ..lineTo(cx - (armOutX - armThick + 2.2 + forearmThick) * s, topY + 102 * s)
      ..close();
    final forearmR = Path()
      ..moveTo(cx + (armOutX + 0.5) * s, topY + 76.5 * s)
      ..lineTo(cx + (armOutX - armThick + 0.5) * s, topY + 76.5 * s)
      ..lineTo(cx + (armOutX - armThick + 2.2) * s, topY + 102 * s)
      ..lineTo(cx + (armOutX - armThick + 2.2 + forearmThick) * s, topY + 102 * s)
      ..close();
    draw3DPart(forearmL, 'forearms');
    draw3DPart(forearmR, 'forearms');

    // Manos 3D esculpidas en porcelana
    final handL = Path()
      ..addOval(rc(-armOutX - 0.5, 101.5, forearmThick * 0.9, 10.5));
    final handR = Path()
      ..addOval(rc(armOutX - forearmThick * 0.85, 101.5, forearmThick * 0.9, 10.5));
    draw3DPart(handL, 'hand', addSpecular: false);
    draw3DPart(handR, 'hand', addSpecular: false);

    // -------------------------------------------------------------------------
    // 5. PELVIS / GLÚTEOS Y PIERNAS 3D (CADERA FEMENINA vs MASCULINA)
    // -------------------------------------------------------------------------
    if (!isFront) {
      final gluteL = Path()
        ..moveTo(cx - waistHalf * s, topY + 89 * s)
        ..lineTo(cx - 0.6 * s, topY + 91 * s)
        ..lineTo(cx - 0.6 * s, topY + 115 * s)
        ..quadraticBezierTo(
            cx - (hipHalf + 2.5) * s, topY + 115 * s, cx - hipHalf * s, topY + 98 * s)
        ..close();
      final gluteR = Path()
        ..moveTo(cx + waistHalf * s, topY + 89 * s)
        ..lineTo(cx + 0.6 * s, topY + 91 * s)
        ..lineTo(cx + 0.6 * s, topY + 115 * s)
        ..quadraticBezierTo(
            cx + (hipHalf + 2.5) * s, topY + 115 * s, cx + hipHalf * s, topY + 98 * s)
        ..close();
      draw3DPart(gluteL, 'glutes');
      draw3DPart(gluteR, 'glutes');
    } else {
      final pelvis = Path()
        ..moveTo(cx - hipHalf * s, topY + 93 * s)
        ..lineTo(cx + hipHalf * s, topY + 93 * s)
        ..lineTo(cx + (isFemale ? 4.5 : 7.5) * s, topY + 109 * s)
        ..lineTo(cx - (isFemale ? 4.5 : 7.5) * s, topY + 109 * s)
        ..close();
      draw3DPart(pelvis, 'abs', addSpecular: false);
    }

    // Muslos 3D (Cuádriceps frontal / Isquiotibiales posterior)
    final String thighZone = isFront ? 'quads' : 'hamstrings';
    final double thighTop = isFront ? 102.0 : 113.0;
    final double thighBot = 149.0;

    final thighL = Path()
      ..moveTo(cx - hipHalf * s, topY + thighTop * s)
      ..lineTo(cx - 1.8 * s, topY + (thighTop + 4) * s)
      ..lineTo(cx - 3.8 * s, topY + thighBot * s)
      ..lineTo(cx - 14.5 * s, topY + thighBot * s)
      ..quadraticBezierTo(
        cx - (hipHalf + 1.5) * s,
        topY + ((thighTop + thighBot) * 0.5) * s,
        cx - hipHalf * s,
        topY + thighTop * s,
      )
      ..close();

    final thighR = Path()
      ..moveTo(cx + hipHalf * s, topY + thighTop * s)
      ..lineTo(cx + 1.8 * s, topY + (thighTop + 4) * s)
      ..lineTo(cx + 3.8 * s, topY + thighBot * s)
      ..lineTo(cx + 14.5 * s, topY + thighBot * s)
      ..quadraticBezierTo(
        cx + (hipHalf + 1.5) * s,
        topY + ((thighTop + thighBot) * 0.5) * s,
        cx + hipHalf * s,
        topY + thighTop * s,
      )
      ..close();

    draw3DPart(thighL, thighZone);
    draw3DPart(thighR, thighZone);

    // Rodillas 3D (rótula suave en porcelana)
    final kneeL = Path()..addOval(rc(-14.2, 146.5, 10.2, 7.5));
    final kneeR = Path()..addOval(rc(4.0, 146.5, 10.2, 7.5));
    draw3DPart(kneeL, thighZone, addSpecular: false);
    draw3DPart(kneeR, thighZone, addSpecular: false);

    // Pantorrillas / Gemelos 3D
    final calfL = Path()
      ..moveTo(cx - 14.2 * s, topY + 152 * s)
      ..lineTo(cx - 4.0 * s, topY + 152 * s)
      ..quadraticBezierTo(
          cx - 3.0 * s, topY + 166 * s, cx - 5.8 * s, topY + 185 * s)
      ..lineTo(cx - 11.5 * s, topY + 185 * s)
      ..quadraticBezierTo(
          cx - 16.5 * s, topY + 165 * s, cx - 14.2 * s, topY + 152 * s)
      ..close();

    final calfR = Path()
      ..moveTo(cx + 14.2 * s, topY + 152 * s)
      ..lineTo(cx + 4.0 * s, topY + 152 * s)
      ..quadraticBezierTo(
          cx + 3.0 * s, topY + 166 * s, cx + 5.8 * s, topY + 185 * s)
      ..lineTo(cx + 11.5 * s, topY + 185 * s)
      ..quadraticBezierTo(
          cx + 16.5 * s, topY + 165 * s, cx + 14.2 * s, topY + 152 * s)
      ..close();

    draw3DPart(calfL, 'calves');
    draw3DPart(calfR, 'calves');

    // Pies 3D esculpidos sobre el suelo
    final footL = Path()
      ..moveTo(cx - 11.5 * s, topY + 184.5 * s)
      ..lineTo(cx - 5.5 * s, topY + 184.5 * s)
      ..lineTo(cx - 4.2 * s, topY + 191.5 * s)
      ..lineTo(cx - 14.5 * s, topY + 191.5 * s)
      ..close();
    final footR = Path()
      ..moveTo(cx + 11.5 * s, topY + 184.5 * s)
      ..lineTo(cx + 5.5 * s, topY + 184.5 * s)
      ..lineTo(cx + 4.2 * s, topY + 191.5 * s)
      ..lineTo(cx + 14.5 * s, topY + 191.5 * s)
      ..close();
    draw3DPart(footL, 'foot', addSpecular: false);
    draw3DPart(footR, 'foot', addSpecular: false);

    if (showLabels) {
      final tp = TextPainter(
        text: TextSpan(
          text: caption,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, topY + 194 * s));
    }
  }

  void _drawMuscleLegendPanel(Canvas canvas, Size size) {
    final primaryText = 'Principal: ${exercise.muscleGroup}';
    final secondaryText = exercise.secondaryMuscles.trim().isNotEmpty
        ? 'Sinergistas: ${exercise.secondaryMuscles}'
        : 'Aislamiento focalizado';

    final tpPrimary = TextPainter(
      text: TextSpan(
        children: [
          const TextSpan(
            text: '● ',
            style: TextStyle(color: Color(0xFFCCFF00), fontSize: 11),
          ),
          TextSpan(
            text: primaryText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      maxLines: 1,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.46);

    final tpSecondary = TextPainter(
      text: TextSpan(
        children: [
          const TextSpan(
            text: '● ',
            style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10),
          ),
          TextSpan(
            text: secondaryText,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      maxLines: 1,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.46);

    final boxW = math.max(tpPrimary.width, tpSecondary.width) + 18;
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - boxW - 10, 8, boxW, 36),
      const Radius.circular(12),
    );

    canvas.drawRRect(
      boxRect,
      Paint()..color = Colors.black.withOpacity(0.74),
    );
    canvas.drawRRect(
      boxRect,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    tpPrimary.paint(canvas, Offset(size.width - boxW - 1, 12));
    tpSecondary.paint(canvas, Offset(size.width - boxW - 1, 26));
  }

  @override
  bool shouldRepaint(covariant _AnatomicalMannequinPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.viewMode != viewMode ||
        oldDelegate.isFemale != isFemale ||
        oldDelegate.exercise.name != exercise.name;
  }
}

// =============================================================================
// SLIDE 1: EJECUCIÓN DEL EJERCICIO REALIZADA POR EL MANIQUÍ 3D + EQUIPAMIENTO
// =============================================================================
class _BiomechanicsPainter extends CustomPainter {
  final String exerciseName;
  final String pattern;
  final String equipment;
  final String muscleGroup;
  final bool isFemale;
  final double t; // 0.0 (estiramiento) -> 1.0 (contracción máxima)
  final bool isConcentric;
  final bool showBadges;

  _BiomechanicsPainter({
    required this.exerciseName,
    required this.pattern,
    required this.equipment,
    required this.muscleGroup,
    required this.isFemale,
    required this.t,
    required this.isConcentric,
    this.showBadges = true,
  });

  double _lerp(double a, double b, double p) => a + (b - a) * p;
  Offset _lerpOffset(Offset a, Offset b, double p) =>
      Offset(_lerp(a.dx, b.dx, p), _lerp(a.dy, b.dy, p));

  bool get _isBulgarian =>
      exerciseName.toLowerCase().contains('búlgara') ||
      exerciseName.toLowerCase().contains('bulgara');

  bool get _isKettlebellOrBulgarianBag =>
      equipment.toLowerCase().contains('kettlebell') ||
      exerciseName.toLowerCase().contains('kettlebell') ||
      exerciseName.toLowerCase().contains('pesa rusa') ||
      exerciseName.toLowerCase().contains('mancuerna búlgara') ||
      exerciseName.toLowerCase().contains('saco búlgaro');

  bool get _isPlateLoad =>
      exerciseName.toLowerCase().contains('con disco') ||
      (equipment.toLowerCase().contains('disco') &&
          !_isKettlebellOrBulgarianBag &&
          !_isBulgarian);

  bool get _isDumbbell => equipment.toLowerCase().contains('mancuerna');
  bool get _isEZBar => equipment.toLowerCase().contains('ez');
  bool get _isSmith =>
      equipment.toLowerCase().contains('smith') ||
      equipment.toLowerCase().contains('multipower') ||
      exerciseName.toLowerCase().contains('multipower') ||
      exerciseName.toLowerCase().contains('smith');
  bool get _isBarbell =>
      equipment.toLowerCase() == 'barra' ||
      (_isSmith && !equipment.toLowerCase().contains('polea'));
  bool get _isCable =>
      equipment.toLowerCase().contains('polea') ||
      equipment.toLowerCase().contains('cable');
  bool get _isMachine => equipment.toLowerCase().contains('máquina');
  bool get _isBodyweight => equipment.toLowerCase().contains('peso corporal');

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Escenario de estudio 3D con cuadrícula sutil y suelo reflectante
    final bgRect = Offset.zero & size;
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.0, -0.1),
          radius: 1.05,
          colors: [
            Color(0xFF1E2636),
            Color(0xFF111722),
            Color(0xFF0A0E15),
          ],
        ).createShader(bgRect),
    );

    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.45)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < w; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final floorY = h * 0.79;
    canvas.drawLine(
      Offset(w * 0.06, floorY),
      Offset(w * 0.94, floorY),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 2.5,
    );

    final cx = w * 0.5;
    final nameLower = exerciseName.toLowerCase();

    // Si es Multipower / Smith, dibujar primero las guías verticales cromadas del bastidor
    if (_isSmith) {
      _drawSmithMachineFrame(canvas, cx - 8, floorY);
    }

    // Seleccionar animación específica del ejercicio y máquina
    if (_isMachine && nameLower.contains('prensa')) {
      _draw45DegreeLegPressMachine(canvas, cx, floorY);
    } else if (_isMachine && nameLower.contains('hack')) {
      _drawHackSquatMachine(canvas, cx, floorY);
    } else if (pattern == 'bench_press' ||
        pattern == 'fly' ||
        pattern == 'skullcrusher') {
      _drawBenchExercise3D(canvas, cx, floorY);
    } else if (pattern == 'incline_press') {
      _drawInclineBenchExercise3D(canvas, cx, floorY);
    } else if (pattern == 'squat' ||
        pattern == 'lunge' ||
        pattern == 'calf_raise') {
      _drawSquatOrLegExercise3D(canvas, cx, floorY);
    } else if (pattern == 'deadlift' || pattern == 'row') {
      _drawHingeOrRowExercise3D(canvas, cx, floorY);
    } else if (pattern == 'lat_pulldown') {
      _drawLatPulldownExercise3D(canvas, cx, floorY);
    } else if (pattern == 'overhead_press' ||
        pattern == 'lateral_raise' ||
        pattern == 'shrug') {
      _drawShoulderStandingExercise3D(canvas, cx, floorY);
    } else if (pattern == 'bicep_curl' || pattern == 'tricep_pushdown') {
      _drawArmIsolationExercise3D(canvas, cx, floorY);
    } else if (pattern == 'leg_extension' || pattern == 'leg_curl') {
      _drawLegMachineExercise3D(canvas, cx, floorY);
    } else if (pattern == 'lying_leg_curl') {
      _drawLyingLegCurlExercise3D(canvas, cx, floorY);
    } else if (pattern == 'isometric_squat') {
      _drawIsometricSquatExercise3D(canvas, cx, floorY);
    } else if (pattern == 'plank') {
      _drawPlankExercise3D(canvas, cx, floorY);
    } else if (pattern == 'kettlebell_swing') {
      _drawKettlebellSwingExercise3D(canvas, cx, floorY);
    } else if (pattern == 'thruster') {
      _drawThrusterExercise3D(canvas, cx, floorY);
    } else if (pattern == 'crunch') {
      _drawCrunchExercise3D(canvas, cx, floorY);
    } else {
      _drawHipThrustExercise3D(canvas, cx, floorY);
    }

    if (showBadges) {
      _drawPhaseAndEquipmentBadges(canvas, size);
    }
  }

  // ===========================================================================
  // PRIMITIVAS DEL MANIQUÍ ARTICULADO 3D (PORCELANA BLANCA/MARFIL VARÓN/MUJER)
  // ===========================================================================
  void _draw3DLimb(
    Canvas canvas,
    Offset start,
    Offset end, {
    required double rStart,
    required double rEnd,
    bool isActive = false,
    double bulge = 0.22,
  }) {
    final scale = isFemale ? 0.88 : 1.0;
    final rs = rStart * scale;
    final re = rEnd * scale;

    final dv = end - start;
    final len = dv.distance;
    if (len < 1.0) return;

    final ux = dv.dx / len;
    final uy = dv.dy / len;
    final nx = -uy;
    final ny = ux;

    final mid = Offset((start.dx + end.dx) * 0.5, (start.dy + end.dy) * 0.5);
    final rMid = ((rs + re) * 0.5) * (1.0 + bulge + (isActive ? 0.14 * t : 0.0));

    final p1 = Offset(start.dx + nx * rs, start.dy + ny * rs);
    final p2 = Offset(end.dx + nx * re, end.dy + ny * re);
    final p3 = Offset(end.dx - nx * re, end.dy - ny * re);
    final p4 = Offset(start.dx - nx * rs, start.dy - ny * rs);
    final ctrlTop = Offset(mid.dx + nx * rMid, mid.dy + ny * rMid);
    final ctrlBot = Offset(mid.dx - nx * rMid, mid.dy - ny * rMid);

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..quadraticBezierTo(ctrlTop.dx, ctrlTop.dy, p2.dx, p2.dy)
      ..arcToPoint(p3, radius: Radius.circular(re), clockwise: true)
      ..quadraticBezierTo(ctrlBot.dx, ctrlBot.dy, p4.dx, p4.dy)
      ..arcToPoint(p1, radius: Radius.circular(rs), clockwise: true)
      ..close();

    final bounds = path.getBounds();

    if (isActive) {
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(
            const Color(0xFFFF5252),
            const Color(0xFFCCFF00),
            t,
          )!
              .withOpacity(0.32 + 0.22 * t)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }

    // Gradiente cilíndrico 3D de porcelana blanca o músculo iluminado
    final grad = LinearGradient(
      begin: Alignment(nx * 0.8, ny * 0.8),
      end: Alignment(-nx * 0.8, -ny * 0.8),
      colors: isActive
          ? [
              const Color(0xFFFFFFFF),
              Color.lerp(
                  const Color(0xFFFF8A65), const Color(0xFFCCFF00), t)!,
              Color.lerp(
                  const Color(0xFFD84315), const Color(0xFF689F38), t)!,
            ]
          : const [
              Color(0xFFFFFFFF),
              Color(0xFFF1F2F6),
              Color(0xFFD4D8E0),
              Color(0xFF969CA8),
            ],
      stops: isActive ? const [0.0, 0.45, 1.0] : const [0.0, 0.30, 0.72, 1.0],
    ).createShader(bounds);

    canvas.drawPath(path, Paint()..shader = grad);
    canvas.drawPath(
      path,
      Paint()
        ..color = isActive
            ? const Color(0xFFCCFF00)
            : const Color(0xFF7E8594).withOpacity(0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? 1.1 : 0.8,
    );

    // Brillo especular a lo largo del miembro 3D
    final specStart =
        Offset(start.dx + nx * rs * 0.35, start.dy + ny * rs * 0.35);
    final specEnd = Offset(end.dx + nx * re * 0.35, end.dy + ny * re * 0.35);
    canvas.drawLine(
      specStart,
      specEnd,
      Paint()
        ..color = Colors.white.withOpacity(0.65)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  void _draw3DTorso(
    Canvas canvas,
    Offset hip,
    Offset shoulder, {
    bool isActive = false,
    double facing = 1.0, // 1.0 = mira a la derecha, -1.0 = mira a la izquierda
  }) {
    final dv = shoulder - hip;
    final len = dv.distance;
    if (len < 1.0) return;

    final ux = dv.dx / len;
    final uy = dv.dy / len;
    // Vector frontal (hacia donde mira el pecho del maniquí)
    final fx = -uy * facing;
    final fy = ux * facing;

    final double ribFront = isFemale ? 9.5 : 11.8;
    final double ribBack = isFemale ? 7.2 : 9.2;
    final double waistFront = isFemale ? 6.2 : 8.8;
    final double waistBack = isFemale ? 5.8 : 8.0;
    final double hipFront = isFemale ? 8.5 : 8.8;
    final double hipBack = isFemale ? 10.5 : 9.0; // Mayor curva glútea en mujer

    final waist = _lerpOffset(hip, shoulder, 0.42);
    final chest = _lerpOffset(hip, shoulder, 0.76);

    final sFront =
        Offset(shoulder.dx + fx * ribFront, shoulder.dy + fy * ribFront);
    final sBack =
        Offset(shoulder.dx - fx * ribBack, shoulder.dy - fy * ribBack);
    final wFront =
        Offset(waist.dx + fx * waistFront, waist.dy + fy * waistFront);
    final wBack = Offset(waist.dx - fx * waistBack, waist.dy - fy * waistBack);
    final hFront = Offset(hip.dx + fx * hipFront, hip.dy + fy * hipFront);
    final hBack = Offset(hip.dx - fx * hipBack, hip.dy - fy * hipBack);

    final path = Path()
      ..moveTo(hFront.dx, hFront.dy)
      ..quadraticBezierTo(wFront.dx, wFront.dy, sFront.dx, sFront.dy)
      ..arcToPoint(sBack, radius: const Radius.circular(9), clockwise: false)
      ..quadraticBezierTo(wBack.dx, wBack.dy, hBack.dx, hBack.dy)
      ..arcToPoint(hFront, radius: const Radius.circular(9), clockwise: false)
      ..close();

    final bounds = path.getBounds();
    if (isActive) {
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFCCFF00).withOpacity(0.28 + 0.2 * t)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    final grad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isActive
          ? [
              const Color(0xFFFFFFFF),
              Color.lerp(
                  const Color(0xFFFF8A65), const Color(0xFFCCFF00), t)!,
              Color.lerp(
                  const Color(0xFFD84315), const Color(0xFF689F38), t)!,
            ]
          : const [
              Color(0xFFFFFFFF),
              Color(0xFFF2F3F7),
              Color(0xFFD2D6DF),
              Color(0xFF949AA7),
            ],
    ).createShader(bounds);

    canvas.drawPath(path, Paint()..shader = grad);
    canvas.drawPath(
      path,
      Paint()
        ..color = isActive
            ? const Color(0xFFCCFF00)
            : const Color(0xFF7E8594).withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    // Si el maniquí es Mujer, esculpir el volumen 3D del busto femenino en el pecho
    if (isFemale) {
      final bustCenter = Offset(
        chest.dx + fx * (ribFront + 2.2),
        chest.dy + fy * (ribFront + 2.2),
      );
      final bustRect = Rect.fromCenter(center: bustCenter, width: 11, height: 11);
      canvas.drawOval(
        bustRect,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.3, -0.3),
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFE8EAEF),
              Color(0xFFA8B0BE),
            ],
          ).createShader(bustRect),
      );
      canvas.drawOval(
        bustRect,
        Paint()
          ..color = const Color(0xFF888F9C).withOpacity(0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.75,
      );
    }

    // Esfera de cadera / glúteo 3D
    final pelvisRadius = isFemale ? 9.8 : 9.0;
    final pelvisRect =
        Rect.fromCircle(center: hip, radius: pelvisRadius);
    canvas.drawOval(
      pelvisRect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFE5E7EC),
            Color(0xFF9EA4B0),
          ],
        ).createShader(pelvisRect),
    );
  }

  void _draw3DHead(
    Canvas canvas,
    Offset headCenter,
    Offset shoulderCenter, {
    double facing = 1.0,
  }) {
    // Cuello cilíndrico 3D
    _draw3DLimb(
      canvas,
      shoulderCenter,
      headCenter,
      rStart: isFemale ? 3.8 : 4.6,
      rEnd: isFemale ? 3.4 : 4.2,
      bulge: 0.0,
    );

    final double rx = isFemale ? 8.8 : 9.5;
    final double ry = isFemale ? 10.2 : 11.0;
    final headRect =
        Rect.fromCenter(center: headCenter, width: rx * 2, height: ry * 2);

    canvas.drawOval(
      headRect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 0.9,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF2F3F7),
            Color(0xFFD0D4DD),
            Color(0xFF9096A4),
          ],
          stops: [0.0, 0.35, 0.75, 1.0],
        ).createShader(headRect),
    );

    canvas.drawOval(
      headRect,
      Paint()
        ..color = const Color(0xFF7E8594).withOpacity(0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85,
    );

    // Perfil de nariz y mentón del maniquí 3D
    final noseTip = Offset(headCenter.dx + facing * (rx + 1.8), headCenter.dy + 0.5);
    final nosePath = Path()
      ..moveTo(headCenter.dx + facing * (rx - 1.5), headCenter.dy - 3.5)
      ..lineTo(noseTip.dx, noseTip.dy)
      ..lineTo(headCenter.dx + facing * (rx - 1.0), headCenter.dy + 2.2);
    canvas.drawPath(
      nosePath,
      Paint()
        ..color = const Color(0xFFE8EAEF)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      nosePath,
      Paint()
        ..color = const Color(0xFF888F9C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75,
    );

    // Detalle de oreja esculpida 3D
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenter.dx - facing * 1.5, headCenter.dy + 0.5),
        width: 3.2,
        height: 5.2,
      ),
      Paint()..color = const Color(0xFFC5CAD4),
    );
  }

  void _draw3DFoot(
    Canvas canvas,
    Offset ankle, {
    double facing = 1.0,
    bool elevated = false,
  }) {
    final footEnd = Offset(
      ankle.dx + facing * (isFemale ? 13.5 : 15.5),
      ankle.dy + (elevated ? 8.0 : 1.5),
    );
    _draw3DLimb(
      canvas,
      ankle,
      footEnd,
      rStart: 3.8,
      rEnd: 2.8,
      bulge: 0.05,
    );
  }

  // ===========================================================================
  // EQUIPAMIENTO ESPECÍFICO 3D (MANCUERNAS, MANCUERNA BÚLGARA/KETTLEBELL,
  // BARRA OLÍMPICA, BARRA EZ, MULTIPOWER/SMITH, POLEA Y MÁQUINAS)
  // ===========================================================================
  void _drawSpecificHandEquipment(
    Canvas canvas,
    Offset handPos, {
    double scale = 1.0,
    bool showBarbellShaft = false,
  }) {
    if (_isBodyweight) return;

    if (_isKettlebellOrBulgarianBag || _isBulgarian) {
      _drawKettlebellOrBulgarian3D(canvas, handPos, scale: scale);
    } else if (_isPlateLoad) {
      _drawOlympicPlate3D(canvas, handPos, radius: 11.5 * scale);
    } else if (_isDumbbell) {
      _drawDumbbell3D(canvas, handPos, scale: scale);
    } else if (_isEZBar) {
      _drawEZBar3D(canvas, handPos, scale: scale);
    } else if (_isBarbell || _isSmith) {
      _drawOlympicBarbellEnd3D(
        canvas,
        handPos,
        scale: scale,
        showHorizontalShaft: showBarbellShaft,
      );
    } else if (_isCable) {
      _drawCableHandle3D(canvas, handPos);
    } else {
      _drawMachineGripPad3D(canvas, handPos);
    }
  }

  /// 1. Mancuerna Común Hexagonal / Profesional 3D
  void _drawDumbbell3D(Canvas canvas, Offset pos, {double scale = 1.0}) {
    final s = scale;
    // Mango cromado moleteado central
    canvas.drawLine(
      Offset(pos.dx - 10 * s, pos.dy),
      Offset(pos.dx + 10 * s, pos.dy),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 3.6 * s
        ..strokeCap = StrokeCap.round,
    );

    // Cabezales hexagonales de caucho negro con borde cian a ambos lados de la mano
    for (final side in [-1.0, 1.0]) {
      final plateRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(pos.dx + side * 9.5 * s, pos.dy),
          width: 6.5 * s,
          height: 16.5 * s,
        ),
        Radius.circular(2.0 * s),
      );
      canvas.drawRRect(
        plateRect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF475569),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ).createShader(plateRect.outerRect),
      );
      canvas.drawRRect(
        plateRect,
        Paint()
          ..color = const Color(0xFF00E5FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 * s,
      );
    }
  }

  /// 2. Mancuerna Búlgara / Kettlebell / Pesa Rusa 3D (con asa curva superior y cuerpo esférico/medialuna)
  void _drawKettlebellOrBulgarian3D(Canvas canvas, Offset gripPos,
      {double scale = 1.0}) {
    final s = scale;
    final isCrescentBag =
        exerciseName.toLowerCase().contains('saco búlgaro') ||
            exerciseName.toLowerCase().contains('mancuerna búlgara');

    if (isCrescentBag) {
      // Mancuerna / Saco Búlgaro en medialuna con doble agarre cónico
      final bagPath = Path()
        ..moveTo(gripPos.dx - 14 * s, gripPos.dy + 2 * s)
        ..quadraticBezierTo(
            gripPos.dx, gripPos.dy + 18 * s, gripPos.dx + 14 * s, gripPos.dy + 2 * s)
        ..quadraticBezierTo(
            gripPos.dx, gripPos.dy + 9 * s, gripPos.dx - 14 * s, gripPos.dy + 2 * s)
        ..close();
      canvas.drawPath(
        bagPath,
        Paint()..color = const Color(0xFFFF6D00),
      );
      canvas.drawPath(
        bagPath,
        Paint()
          ..color = const Color(0xFFCCFF00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * s,
      );
      return;
    }

    // Asa de acero en U (cuernos de la Kettlebell / Mancuerna Búlgara)
    final hornRect = Rect.fromCenter(
      center: Offset(gripPos.dx, gripPos.dy + 3.5 * s),
      width: 12 * s,
      height: 10 * s,
    );
    canvas.drawArc(
      hornRect,
      math.pi * 0.9,
      math.pi * 1.2,
      false,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * s
        ..strokeCap = StrokeCap.round,
    );

    // Bola de hierro fundido con base plana y franja de competición
    final bellCenter = Offset(gripPos.dx, gripPos.dy + 12.5 * s);
    final bellRadius = 9.2 * s;
    final bellRect = Rect.fromCircle(center: bellCenter, radius: bellRadius);

    canvas.drawCircle(
      bellCenter,
      bellRadius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.35),
          colors: [
            Color(0xFF64748B),
            Color(0xFF1E293B),
            Color(0xFF090D16),
          ],
        ).createShader(bellRect),
    );
    // Franja de color de peso en el cuello de la pesa búlgara/rusa
    canvas.drawLine(
      Offset(bellCenter.dx - 6.5 * s, bellCenter.dy - 4.5 * s),
      Offset(bellCenter.dx + 6.5 * s, bellCenter.dy - 4.5 * s),
      Paint()
        ..color = const Color(0xFFCCFF00)
        ..strokeWidth = 2.4 * s
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      bellCenter,
      bellRadius,
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * s,
    );
  }

  /// 3. Barra EZ (Romana / Zig-Zag) con discos
  void _drawEZBar3D(Canvas canvas, Offset pos, {double scale = 1.0}) {
    final s = scale;
    final ezPath = Path()
      ..moveTo(pos.dx - 24 * s, pos.dy)
      ..lineTo(pos.dx - 15 * s, pos.dy)
      ..lineTo(pos.dx - 9 * s, pos.dy + 4.5 * s)
      ..lineTo(pos.dx - 3 * s, pos.dy - 4.0 * s)
      ..lineTo(pos.dx + 3 * s, pos.dy - 4.0 * s)
      ..lineTo(pos.dx + 9 * s, pos.dy + 4.5 * s)
      ..lineTo(pos.dx + 15 * s, pos.dy)
      ..lineTo(pos.dx + 24 * s, pos.dy);

    canvas.drawPath(
      ezPath,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2 * s
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Discos en ambos extremos de la Barra EZ
    for (final side in [-1.0, 1.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(pos.dx + side * 20 * s, pos.dy),
            width: 4.5 * s,
            height: 18 * s,
          ),
          Radius.circular(2 * s),
        ),
        Paint()..color = const Color(0xFF00E5FF),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(pos.dx + side * 23.5 * s, pos.dy),
            width: 3.5 * s,
            height: 13 * s,
          ),
          Radius.circular(1.5 * s),
        ),
        Paint()..color = const Color(0xFFCCFF00),
      );
    }
  }

  /// 4. Barra Olímpica Recta con discos calibrados
  void _drawOlympicBarbellEnd3D(
    Canvas canvas,
    Offset pos, {
    double scale = 1.0,
    bool showHorizontalShaft = false,
  }) {
    final s = scale;
    if (showHorizontalShaft) {
      // Barra olímpica vista de frente (eje largo + discos en los extremos)
      canvas.drawLine(
        Offset(pos.dx - 36 * s, pos.dy),
        Offset(pos.dx + 36 * s, pos.dy),
        Paint()
          ..color = const Color(0xFFE2E8F0)
          ..strokeWidth = 3.8 * s
          ..strokeCap = StrokeCap.round,
      );
      for (final side in [-1.0, 1.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(pos.dx + side * 27 * s, pos.dy),
              width: 5.0 * s,
              height: 24 * s,
            ),
            Radius.circular(2 * s),
          ),
          Paint()..color = const Color(0xFF00E5FF),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(pos.dx + side * 32 * s, pos.dy),
              width: 4.2 * s,
              height: 18 * s,
            ),
            Radius.circular(2 * s),
          ),
          Paint()..color = const Color(0xFFCCFF00),
        );
      }
      return;
    }

    // Vista lateral de Barra Olímpica: discos olímpicos grandes concéntricos + manguito cromado
    final outerR = 13.5 * s;
    canvas.drawCircle(
      pos,
      outerR,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xFF00E5FF),
            Color(0xFF0284C7),
            Color(0xFF0F172A),
          ],
          stops: const [0.0, 0.72, 1.0],
        ).createShader(Rect.fromCircle(center: pos, radius: outerR)),
    );
    canvas.drawCircle(
      pos,
      outerR,
      Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * s,
    );
    // Segundo disco olímpico concéntrico
    canvas.drawCircle(
      pos,
      outerR * 0.66,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      pos,
      outerR * 0.66,
      Paint()
        ..color = const Color(0xFFCCFF00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 * s,
    );
    // Buje de acero central cromado
    canvas.drawCircle(
      pos,
      outerR * 0.26,
      Paint()..color = const Color(0xFFE2E8F0),
    );
  }

  /// 5. Disco Olímpico suelto
  void _drawOlympicPlate3D(Canvas canvas, Offset pos, {double radius = 11}) {
    canvas.drawCircle(
      pos,
      radius,
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = const Color(0xFFCCFF00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    canvas.drawCircle(
      pos,
      radius * 0.3,
      Paint()..color = const Color(0xFF94A3B8),
    );
  }

  /// 6. Agarre de Polea / Cuerda / Estribo
  void _drawCableHandle3D(Canvas canvas, Offset pos) {
    final isRope = exerciseName.toLowerCase().contains('cuerda') ||
        exerciseName.toLowerCase().contains('face pull') ||
        pattern == 'tricep_pushdown';
    if (isRope) {
      // Cuerda trenzada con topes de goma negros
      canvas.drawLine(
        Offset(pos.dx - 7, pos.dy - 7),
        pos,
        Paint()
          ..color = const Color(0xFFFACC15)
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        pos,
        4.8,
        Paint()..color = const Color(0xFF0F172A),
      );
      canvas.drawCircle(
        pos,
        4.8,
        Paint()
          ..color = const Color(0xFF00E5FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    } else {
      // Estribo / Maneral cromado de polea
      final path = Path()
        ..moveTo(pos.dx, pos.dy - 8)
        ..lineTo(pos.dx - 7, pos.dy + 3)
        ..lineTo(pos.dx + 7, pos.dy + 3)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFE2E8F0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
      canvas.drawCircle(pos, 3.5, Paint()..color = const Color(0xFF00E5FF));
    }
  }

  /// 7. Rodillo acolchado / Maneral de Máquina
  void _drawMachineGripPad3D(Canvas canvas, Offset pos, {double radius = 8.5}) {
    canvas.drawCircle(
      pos,
      radius,
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = const Color(0xFFCCFF00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    canvas.drawCircle(
      pos,
      radius * 0.35,
      Paint()..color = const Color(0xFFCBD5E1),
    );
  }

  /// Bastidor de Multipower / Máquina Smith con rieles cromados verticales y seguros
  void _drawSmithMachineFrame(Canvas canvas, double railX, double floorY) {
    final topY = floorY - 152;
    // Poste estructural trasero
    canvas.drawLine(
      Offset(railX - 10, topY),
      Offset(railX - 10, floorY),
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 5.5,
    );
    // Riel guía cromado vertical donde desliza la barra Smith
    canvas.drawLine(
      Offset(railX, topY),
      Offset(railX, floorY),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 2.8,
    );
    // Topes de seguridad a lo largo del riel
    for (int i = 0; i < 6; i++) {
      final y = topY + 22.0 + i * 20.0;
      canvas.drawLine(
        Offset(railX - 4, y),
        Offset(railX + 3, y),
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..strokeWidth = 2,
      );
    }
    // Travesaño superior Multipower
    canvas.drawLine(
      Offset(railX - 14, topY),
      Offset(railX + 14, topY),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 5,
    );
  }

  /// Torre de Poleas / Placas de Peso para ejercicios en Polea o Máquina
  void _drawWeightStackTower(
    Canvas canvas,
    double towerX,
    double floorY, {
    Offset? cableTarget,
    bool pulleyAtBottom = false,
    bool pulleyAtMid = false,
  }) {
    final topY = floorY - 148;
    // Columnas de la torre
    canvas.drawRect(
      Rect.fromLTWH(towerX - 12, topY, 24, 148),
      Paint()
        ..color = const Color(0xFF1E293B).withOpacity(0.85)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      Rect.fromLTWH(towerX - 12, topY, 24, 148),
      Paint()
        ..color = const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Rieles internos de las placas
    canvas.drawLine(
      Offset(towerX - 5, topY + 8),
      Offset(towerX - 5, floorY - 4),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 1.4,
    );
    canvas.drawLine(
      Offset(towerX + 5, topY + 8),
      Offset(towerX + 5, floorY - 4),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 1.4,
    );

    // Placas apiladas (las placas seleccionadas suben con `t`)
    final liftOffset = t * 28.0;
    for (int i = 0; i < 7; i++) {
      final isMoving = i < 4;
      final plateY = (floorY - 14 - (6 - i) * 9.5) - (isMoving ? liftOffset : 0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(towerX, plateY),
            width: 18,
            height: 6.5,
          ),
          const Radius.circular(1.5),
        ),
        Paint()
          ..color = isMoving
              ? const Color(0xFF00E5FF)
              : const Color(0xFF334155),
      );
    }

    // Roldana / Polea y cable de acero hacia la mano del maniquí
    if (cableTarget != null) {
      final pulleyPos = pulleyAtBottom
          ? Offset(towerX, floorY - 14)
          : (pulleyAtMid
              ? Offset(towerX, floorY - 78)
              : Offset(towerX, topY + 6));
      canvas.drawCircle(
        pulleyPos,
        5.5,
        Paint()..color = const Color(0xFFCCFF00),
      );
      canvas.drawLine(
        pulleyPos,
        cableTarget,
        Paint()
          ..color = const Color(0xFF00E5FF)
          ..strokeWidth = 2.0,
      );
    }
  }

  // ===========================================================================
  // ESCENAS BIOMECÁNICAS CON EL MANIQUÍ 3D Y EQUIPAMIENTO ESPECÍFICO
  // ===========================================================================

  /// 1. Banco Plano (Press Banca c/ Barra, Mancuernas, Multipower, Pec Deck, Aperturas, Press Francés)
  void _drawBenchExercise3D(Canvas canvas, double cx, double floorY) {
    // Si es Pec Deck o Máquina de Pecho Sentado, dibujar máquina vertical con brazos convergentes
    if (_isMachine || (_isCable && pattern == 'fly')) {
      _drawSeatedChestMachineOrCableFly3D(canvas, cx, floorY);
      return;
    }

    final benchY = floorY - 36;
    // Tapizado 3D del banco plano + patas de acero
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 66, benchY - 3, 102, 7),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF334155),
    );
    canvas.drawLine(
      Offset(cx - 50, benchY + 4),
      Offset(cx - 50, floorY),
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 5,
    );
    canvas.drawLine(
      Offset(cx + 22, benchY + 4),
      Offset(cx + 22, floorY),
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 5,
    );

    // Si es con Barra Olímpica, dibujar los soportes del rack de banca
    if (_isBarbell && !_isSmith) {
      canvas.drawLine(
        Offset(cx - 38, floorY - 115),
        Offset(cx - 38, floorY),
        Paint()
          ..color = const Color(0xFF475569)
          ..strokeWidth = 4.5,
      );
    }

    final head = Offset(cx - 55, benchY - 12);
    final shoulder = Offset(cx - 35, benchY - 11);
    final hip = Offset(cx + 18, benchY - 10);
    final knee = Offset(cx + 46, benchY - 8);
    final ankle = Offset(cx + 50, floorY - 2);

    // Maniquí 3D acostado en el banco
    _draw3DLimb(canvas, hip, knee, rStart: 7.5, rEnd: 5.5);
    _draw3DLimb(canvas, knee, ankle, rStart: 5.2, rEnd: 3.6);
    _draw3DFoot(canvas, ankle, facing: 1.0);
    _draw3DTorso(
      canvas,
      hip,
      shoulder,
      isActive: pattern != 'skullcrusher',
      facing: 1.0,
    );
    _draw3DHead(canvas, head, shoulder, facing: 1.0);

    Offset elbow;
    Offset hand;
    if (pattern == 'skullcrusher') {
      elbow = Offset(cx - 36, benchY - 46);
      hand = _lerpOffset(
        Offset(cx - 64, benchY - 22),
        Offset(cx - 36, benchY - 78),
        t,
      );
    } else {
      elbow = _lerpOffset(
        Offset(cx - 31, benchY + 6),
        Offset(cx - 35, benchY - 42),
        t,
      );
      hand = _lerpOffset(
        Offset(cx - 31, benchY - 22),
        Offset(cx - 35, benchY - 76),
        t,
      );
    }

    _draw3DLimb(
      canvas,
      shoulder,
      elbow,
      rStart: 5.6,
      rEnd: 4.5,
      isActive: true,
    );
    _draw3DLimb(
      canvas,
      elbow,
      hand,
      rStart: 4.4,
      rEnd: 3.4,
      isActive: true,
    );

    _drawSpecificHandEquipment(canvas, hand);
  }

  /// Máquina de Pecho Sentado / Pec Deck / Cruces en Polea
  void _drawSeatedChestMachineOrCableFly3D(
      Canvas canvas, double cx, double floorY) {
    _drawWeightStackTower(canvas, cx - 54, floorY);

    final seat = Offset(cx - 8, floorY - 42);
    final backTop = Offset(cx - 12, floorY - 96);
    canvas.drawLine(
      backTop,
      seat,
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 6,
    );
    canvas.drawLine(
      seat,
      Offset(cx + 18, floorY - 42),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 6,
    );
    canvas.drawLine(
      seat,
      Offset(seat.dx, floorY),
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 5,
    );

    final hip = Offset(cx - 4, floorY - 48);
    final knee = Offset(cx + 26, floorY - 46);
    final ankle = Offset(cx + 28, floorY - 2);
    final shoulder = Offset(cx - 6, hip.dy - 46);
    final head = Offset(shoulder.dx + 2, shoulder.dy - 16);

    _draw3DLimb(canvas, hip, knee, rStart: 7.5, rEnd: 5.5);
    _draw3DLimb(canvas, knee, ankle, rStart: 5.2, rEnd: 3.6);
    _draw3DFoot(canvas, ankle);
    _draw3DTorso(canvas, hip, shoulder, isActive: true);
    _draw3DHead(canvas, head, shoulder);

    final elbow = _lerpOffset(
      Offset(shoulder.dx - 8, shoulder.dy + 8),
      Offset(shoulder.dx + 18, shoulder.dy + 4),
      t,
    );
    final hand = _lerpOffset(
      Offset(shoulder.dx + 4, shoulder.dy + 6),
      Offset(shoulder.dx + 38, shoulder.dy + 2),
      t,
    );

    // Brazo mecánico convergente de la máquina o cable de polea
    if (_isCable) {
      canvas.drawLine(
        Offset(cx - 42, shoulder.dy),
        hand,
        Paint()
          ..color = const Color(0xFF00E5FF)
          ..strokeWidth = 2,
      );
    } else {
      canvas.drawLine(
        Offset(cx - 10, floorY - 135),
        hand,
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..strokeWidth = 4,
      );
    }

    _draw3DLimb(canvas, shoulder, elbow, rStart: 5.5, rEnd: 4.5, isActive: true);
    _draw3DLimb(canvas, elbow, hand, rStart: 4.3, rEnd: 3.4, isActive: true);
    _drawSpecificHandEquipment(canvas, hand);
  }

  /// 2. Banco Inclinado 3D (Barra, Mancuernas, Multipower)
  void _drawInclineBenchExercise3D(Canvas canvas, double cx, double floorY) {
    final seat = Offset(cx + 10, floorY - 32);
    final backTop = Offset(cx - 42, floorY - 76);

    canvas.drawLine(
      backTop,
      seat,
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      seat,
      Offset(cx + 35, floorY - 28),
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(cx - 25, floorY - 60),
      Offset(cx - 25, floorY),
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 5,
    );
    canvas.drawLine(
      Offset(cx + 15, floorY - 32),
      Offset(cx + 15, floorY),
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 5,
    );

    if (_isBarbell && !_isSmith) {
      canvas.drawLine(
        Offset(cx - 32, floorY - 125),
        Offset(cx - 32, floorY),
        Paint()
          ..color = const Color(0xFF475569)
          ..strokeWidth = 4.5,
      );
    }

    final head = Offset(cx - 40, floorY - 88);
    final shoulder = Offset(cx - 26, floorY - 68);
    final hip = Offset(cx + 8, floorY - 38);
    final knee = Offset(cx + 36, floorY - 34);
    final ankle = Offset(cx + 42, floorY - 2);

    _draw3DLimb(canvas, hip, knee, rStart: 7.5, rEnd: 5.5);
    _draw3DLimb(canvas, knee, ankle, rStart: 5.2, rEnd: 3.6);
    _draw3DFoot(canvas, ankle);
    _draw3DTorso(canvas, hip, shoulder, isActive: true);
    _draw3DHead(canvas, head, shoulder);

    final elbow = _lerpOffset(
      Offset(cx - 20, floorY - 46),
      Offset(cx - 24, floorY - 96),
      t,
    );
    final hand = _lerpOffset(
      Offset(cx - 22, floorY - 76),
      Offset(cx - 24, floorY - 126),
      t,
    );

    _draw3DLimb(canvas, shoulder, elbow, rStart: 5.5, rEnd: 4.5, isActive: true);
    _draw3DLimb(canvas, elbow, hand, rStart: 4.3, rEnd: 3.4, isActive: true);
    _drawSpecificHandEquipment(canvas, hand);
  }

  /// 3. Sentadilla, Sentadilla Búlgara, Zancadas y Elevación de Talones
  void _drawSquatOrLegExercise3D(Canvas canvas, double cx, double floorY) {
    final double depth = 1.0 - t;

    // Caso especial: SENTADILLA BÚLGARA (Pie trasero elevado en banco de apoyo + Mancuerna/Kettlebell Búlgara)
    if (_isBulgarian || pattern == 'lunge') {
      if (_isBulgarian) {
        // Banco/Rodillo trasero donde apoya el empeine posterior
        final padCenter = Offset(cx - 48, floorY - 34);
        canvas.drawLine(
          Offset(padCenter.dx, padCenter.dy),
          Offset(padCenter.dx, floorY),
          Paint()
            ..color = const Color(0xFF64748B)
            ..strokeWidth = 5,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: padCenter, width: 22, height: 10),
            const Radius.circular(5),
          ),
          Paint()..color = const Color(0xFF00E5FF),
        );
      }

      final frontAnkle = Offset(cx + 16, floorY - 2);
      final frontKnee = Offset(cx + 28 + 6 * depth, floorY - 42 + 10 * depth);
      final hip = Offset(cx - 4, floorY - 82 + 28 * depth);
      final rearKnee = Offset(cx - 24, floorY - 44 + 26 * depth);
      final rearAnkle =
          _isBulgarian ? Offset(cx - 46, floorY - 38) : Offset(cx - 44, floorY - 2);

      final shoulder = Offset(hip.dx + 4, hip.dy - 48);
      final head = Offset(shoulder.dx + 3, shoulder.dy - 16);

      // Pierna trasera (en soporte búlgaro o piso)
      _draw3DLimb(canvas, hip, rearKnee, rStart: 7.2, rEnd: 5.2);
      _draw3DLimb(canvas, rearKnee, rearAnkle, rStart: 4.8, rEnd: 3.4);
      _draw3DFoot(canvas, rearAnkle, facing: 1.0, elevated: _isBulgarian);

      // Pierna delantera activa (Cuádriceps + Glúteo)
      _draw3DLimb(canvas, hip, frontKnee, rStart: 8.2, rEnd: 5.8, isActive: true);
      _draw3DLimb(canvas, frontKnee, frontAnkle, rStart: 5.4, rEnd: 3.8);
      _draw3DFoot(canvas, frontAnkle, facing: 1.0);

      _draw3DTorso(canvas, hip, shoulder);
      _draw3DHead(canvas, head, shoulder);

      // Brazos sosteniendo la Mancuerna Búlgara / Kettlebell o Mancuerna común
      final elbow = Offset(shoulder.dx - 2, shoulder.dy + 24);
      final hand = Offset(hip.dx + 4, hip.dy + 6);
      _draw3DLimb(canvas, shoulder, elbow, rStart: 5.2, rEnd: 4.2);
      _draw3DLimb(canvas, elbow, hand, rStart: 4.0, rEnd: 3.2);
      _drawSpecificHandEquipment(canvas, hand);
      return;
    }

    // Sentadilla Libre / Barra / Goblet / Elevación de Gemelos
    if (_isBarbell && !_isSmith) {
      // Soportes de Jaula de Potencia (Power Rack)
      canvas.drawLine(
        Offset(cx + 28, floorY - 142),
        Offset(cx + 28, floorY),
        Paint()
          ..color = const Color(0xFF475569)
          ..strokeWidth = 5,
      );
    }

    final ankle = Offset(cx, floorY - 2 - (pattern == 'calf_raise' ? t * 14 : 0));
    final knee = Offset(cx + 22 * depth, floorY - 42 + 12 * depth);
    final hip = Offset(cx - 26 * depth, floorY - 82 + 34 * depth);
    final shoulder = Offset(cx - 8 * depth, hip.dy - 48);
    final head = Offset(shoulder.dx + 4, shoulder.dy - 16);

    _draw3DLimb(
      canvas,
      hip,
      knee,
      rStart: 8.4,
      rEnd: 5.8,
      isActive: pattern != 'calf_raise',
    );
    _draw3DLimb(
      canvas,
      knee,
      ankle,
      rStart: 5.6,
      rEnd: 3.8,
      isActive: pattern == 'calf_raise',
    );
    _draw3DFoot(canvas, ankle, elevated: pattern == 'calf_raise' && t > 0.3);
    _draw3DTorso(canvas, hip, shoulder);
    _draw3DHead(canvas, head, shoulder);

    final isGoblet = _isDumbbell || _isKettlebellOrBulgarianBag;
    final elbow = isGoblet
        ? Offset(shoulder.dx + 10, shoulder.dy + 22)
        : Offset(shoulder.dx - 8, shoulder.dy + 16);
    final hand = isGoblet
        ? Offset(shoulder.dx + 16, shoulder.dy + 10)
        : Offset(shoulder.dx - 4, shoulder.dy + 4);

    _draw3DLimb(canvas, shoulder, elbow, rStart: 5.2, rEnd: 4.2);
    _draw3DLimb(canvas, elbow, hand, rStart: 4.0, rEnd: 3.2);
    _drawSpecificHandEquipment(canvas, hand);
  }

  /// Prensa de Piernas 45° en Máquina Específica
  void _draw45DegreeLegPressMachine(Canvas canvas, double cx, double floorY) {
    // Rieles diagonales de 45° de la Prensa
    final railStart = Offset(cx - 20, floorY - 28);
    final railEnd = Offset(cx + 68, floorY - 116);
    canvas.drawLine(
      railStart,
      railEnd,
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 6,
    );
    // Respaldo y asiento reclinado de la prensa
    final backTop = Offset(cx - 64, floorY - 56);
    final seat = Offset(cx - 28, floorY - 20);
    canvas.drawLine(
      backTop,
      seat,
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    final head = Offset(cx - 58, floorY - 66);
    final shoulder = Offset(cx - 46, floorY - 46);
    final hip = Offset(cx - 24, floorY - 24);

    final sledPos = _lerpOffset(
      Offset(cx + 16, floorY - 64),
      Offset(cx + 46, floorY - 94),
      t,
    );
    final knee = _lerpOffset(
      Offset(cx - 18, floorY - 58),
      Offset(cx + 10, floorY - 58),
      t,
    );

    _draw3DTorso(canvas, hip, shoulder);
    _draw3DHead(canvas, head, shoulder);
    _draw3DLimb(canvas, hip, knee, rStart: 8.4, rEnd: 5.8, isActive: true);
    _draw3DLimb(canvas, knee, sledPos, rStart: 5.5, rEnd: 3.8, isActive: true);

    // Plataforma del carro de la Prensa 45° + Discos Olímpicos cargados
    canvas.drawLine(
      Offset(sledPos.dx - 10, sledPos.dy - 14),
      Offset(sledPos.dx + 10, sledPos.dy + 14),
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    _drawOlympicBarbellEnd3D(
      canvas,
      Offset(sledPos.dx + 12, sledPos.dy - 12),
      scale: 0.95,
    );
  }

  /// Sentadilla Hack en Máquina Específica
  void _drawHackSquatMachine(Canvas canvas, double cx, double floorY) {
    final railBot = Offset(cx + 36, floorY - 6);
    final railTop = Offset(cx - 34, floorY - 134);
    canvas.drawLine(
      railBot,
      railTop,
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 6,
    );
    // Plataforma inclinada para los pies
    canvas.drawLine(
      Offset(cx + 14, floorY - 4),
      Offset(cx + 44, floorY - 24),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    final depth = 1.0 - t;
    final ankle = Offset(cx + 28, floorY - 14);
    final knee = Offset(cx + 28 + 10 * depth, floorY - 48 + 8 * depth);
    final hip = Offset(cx - 4 + 16 * depth, floorY - 82 + 28 * depth);
    final shoulder = Offset(hip.dx - 16, hip.dy - 42);
    final head = Offset(shoulder.dx - 4, shoulder.dy - 15);

    _draw3DLimb(canvas, hip, knee, rStart: 8.4, rEnd: 5.8, isActive: true);
    _draw3DLimb(canvas, knee, ankle, rStart: 5.4, rEnd: 3.8);
    _draw3DTorso(canvas, hip, shoulder);
    _draw3DHead(canvas, head, shoulder);
    _drawOlympicBarbellEnd3D(
      canvas,
      Offset(shoulder.dx - 10, shoulder.dy + 10),
      scale: 0.9,
    );
  }

  /// 4. Peso Muerto y Remos (Barra, Mancuerna, Polea Baja, Máquina)
  void _drawHingeOrRowExercise3D(Canvas canvas, double cx, double floorY) {
    final isRow = pattern == 'row';

    // Si es Remo en Polea Baja o Remo en Máquina Sentado
    if (isRow && (_isCable || _isMachine)) {
      _drawWeightStackTower(
        canvas,
        cx + 56,
        floorY,
        pulleyAtMid: true,
      );
      final hip = Offset(cx - 18, floorY - 34);
      final knee = Offset(cx + 12, floorY - 30);
      final ankle = Offset(cx + 36, floorY - 20);
      final shoulder = Offset(hip.dx - 2, hip.dy - 48);
      final head = Offset(shoulder.dx + 2, shoulder.dy - 16);

      canvas.drawLine(
        Offset(cx - 32, floorY - 28),
        Offset(cx + 20, floorY - 28),
        Paint()
          ..color = const Color(0xFF475569)
          ..strokeWidth = 6,
      );

      _draw3DLimb(canvas, hip, knee, rStart: 7.5, rEnd: 5.5);
      _draw3DLimb(canvas, knee, ankle, rStart: 5.2, rEnd: 3.6);
      _draw3DFoot(canvas, ankle);
      _draw3DTorso(canvas, hip, shoulder, isActive: true);
      _draw3DHead(canvas, head, shoulder);

      final elbow = _lerpOffset(
        Offset(shoulder.dx + 18, shoulder.dy + 18),
        Offset(shoulder.dx - 14, shoulder.dy + 22),
        t,
      );
      final hand = _lerpOffset(
        Offset(shoulder.dx + 38, shoulder.dy + 20),
        Offset(shoulder.dx + 6, shoulder.dy + 24),
        t,
      );

      canvas.drawLine(
        Offset(cx + 46, hand.dy),
        hand,
        Paint()
          ..color = const Color(0xFF00E5FF)
          ..strokeWidth = 2,
      );

      _draw3DLimb(canvas, shoulder, elbow, rStart: 5.5, rEnd: 4.5, isActive: true);
      _draw3DLimb(canvas, elbow, hand, rStart: 4.3, rEnd: 3.4, isActive: true);
      _drawSpecificHandEquipment(canvas, hand);
      return;
    }

    final torsoAngle = isRow ? 0.85 : _lerp(0.95, 0.08, t);
    final ankle = Offset(cx - 10, floorY - 2);
    final knee = Offset(cx + 6, floorY - 40);
    final hip = Offset(cx - 18, floorY - 76);
    final shoulder = Offset(
      hip.dx + math.sin(torsoAngle) * 52,
      hip.dy - math.cos(torsoAngle) * 52,
    );
    final head = Offset(
      shoulder.dx + math.sin(torsoAngle) * 16,
      shoulder.dy - math.cos(torsoAngle) * 16,
    );

    _draw3DLimb(
      canvas,
      hip,
      knee,
      rStart: 8.2,
      rEnd: 5.6,
      isActive: !isRow,
    );
    _draw3DLimb(canvas, knee, ankle, rStart: 5.4, rEnd: 3.8);
    _draw3DFoot(canvas, ankle);
    _draw3DTorso(canvas, hip, shoulder, isActive: true);
    _draw3DHead(canvas, head, shoulder);

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

    _draw3DLimb(
      canvas,
      shoulder,
      elbow,
      rStart: 5.4,
      rEnd: 4.4,
      isActive: isRow,
    );
    _draw3DLimb(
      canvas,
      elbow,
      hand,
      rStart: 4.2,
      rEnd: 3.3,
      isActive: isRow,
    );
    _drawSpecificHandEquipment(canvas, hand);
  }

  /// 5. Jalón al Pecho en Polea Alta / Dominadas
  void _drawLatPulldownExercise3D(Canvas canvas, double cx, double floorY) {
    final topBarY = floorY - 148;

    final hip = Offset(cx, floorY - 38);
    final knee = Offset(cx + 26, floorY - 36);
    final ankle = Offset(cx + 26, floorY - 2);
    final shoulder = Offset(cx - 4, hip.dy - 48);
    final head = Offset(shoulder.dx + 2, shoulder.dy - 16);

    final handY = _lerp(topBarY + 20, shoulder.dy + 4, t);
    final elbowY = _lerp(topBarY + 44, shoulder.dy + 24, t);
    final elbow = Offset(cx - 18, elbowY);
    final hand = Offset(cx + 6, handY);

    if (_isCable || _isMachine) {
      _drawWeightStackTower(canvas, cx + 52, floorY);
      canvas.drawLine(
        Offset(cx, topBarY),
        Offset(cx + 52, topBarY),
        Paint()
          ..color = const Color(0xFF64748B)
          ..strokeWidth = 5,
      );
      canvas.drawLine(
        Offset(hand.dx, topBarY),
        hand,
        Paint()
          ..color = const Color(0xFF00E5FF)
          ..strokeWidth = 2.2,
      );
    } else {
      // Barra fija de dominadas
      canvas.drawLine(
        Offset(cx - 45, topBarY),
        Offset(cx + 45, topBarY),
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..strokeWidth = 5,
      );
    }

    // Banco con rodillos fijadores de muslos
    canvas.drawLine(
      Offset(cx - 18, floorY - 34),
      Offset(cx + 22, floorY - 34),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 6,
    );
    canvas.drawLine(
      Offset(cx, floorY - 34),
      Offset(cx, floorY),
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 5,
    );

    _draw3DLimb(canvas, hip, knee, rStart: 7.5, rEnd: 5.5);
    _draw3DLimb(canvas, knee, ankle, rStart: 5.2, rEnd: 3.6);
    _draw3DFoot(canvas, ankle);
    _draw3DTorso(canvas, hip, shoulder, isActive: true);
    _draw3DHead(canvas, head, shoulder);

    _draw3DLimb(canvas, shoulder, elbow, rStart: 5.5, rEnd: 4.5, isActive: true);
    _draw3DLimb(canvas, elbow, hand, rStart: 4.3, rEnd: 3.4, isActive: true);

    // Barra larga curva de jalón dorsal
    canvas.drawLine(
      Offset(hand.dx - 22, hand.dy),
      Offset(hand.dx + 22, hand.dy),
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  /// 6. Press Militar, Elevaciones Laterales y Encogimientos (Vista Frontal 3D)
  void _drawShoulderStandingExercise3D(
      Canvas canvas, double cx, double floorY) {
    if (_isCable) {
      _drawWeightStackTower(
        canvas,
        cx - 58,
        floorY,
        pulleyAtBottom: true,
      );
    }

    final footL = Offset(cx - 15, floorY - 2);
    final footR = Offset(cx + 15, floorY - 2);
    final kneeL = Offset(cx - 13, floorY - 36);
    final kneeR = Offset(cx + 13, floorY - 36);
    final hip = Offset(cx, floorY - 68);
    final shoulder = Offset(cx, hip.dy - 48);
    final head = Offset(cx, shoulder.dy - 17);

    // Piernas 3D vistas de frente
    _draw3DLimb(canvas, Offset(hip.dx - 7, hip.dy), kneeL, rStart: 7.4, rEnd: 5.4);
    _draw3DLimb(canvas, Offset(hip.dx + 7, hip.dy), kneeR, rStart: 7.4, rEnd: 5.4);
    _draw3DLimb(canvas, kneeL, footL, rStart: 5.0, rEnd: 3.6);
    _draw3DLimb(canvas, kneeR, footR, rStart: 5.0, rEnd: 3.6);

    // Torso frontal 3D
    _draw3DTorso(canvas, hip, shoulder, isActive: pattern == 'shrug');
    _draw3DHead(canvas, head, shoulder);

    final sSpan = isFemale ? 12.0 : 15.0;
    final shL = Offset(shoulder.dx - sSpan, shoulder.dy + 2);
    final shR = Offset(shoulder.dx + sSpan, shoulder.dy + 2);

    if (pattern == 'lateral_raise' || pattern == 'shrug') {
      final angle = pattern == 'shrug' ? 0.14 : _lerp(0.16, 1.48, t);
      final shrugLift = pattern == 'shrug' ? t * 9.0 : 0.0;
      const armLen = 42.0;

      final shLAdj = Offset(shL.dx, shL.dy - shrugLift);
      final shRAdj = Offset(shR.dx, shR.dy - shrugLift);
      final elbowL = Offset(
        shLAdj.dx - math.sin(angle) * (armLen * 0.52),
        shLAdj.dy + math.cos(angle) * (armLen * 0.52),
      );
      final elbowR = Offset(
        shRAdj.dx + math.sin(angle) * (armLen * 0.52),
        shRAdj.dy + math.cos(angle) * (armLen * 0.52),
      );
      final handL = Offset(
        shLAdj.dx - math.sin(angle) * armLen,
        shLAdj.dy + math.cos(angle) * armLen,
      );
      final handR = Offset(
        shRAdj.dx + math.sin(angle) * armLen,
        shRAdj.dy + math.cos(angle) * armLen,
      );

      _draw3DLimb(canvas, shLAdj, elbowL, rStart: 5.0, rEnd: 4.0, isActive: true);
      _draw3DLimb(canvas, elbowL, handL, rStart: 3.8, rEnd: 3.0, isActive: true);
      _draw3DLimb(canvas, shRAdj, elbowR, rStart: 5.0, rEnd: 4.0, isActive: true);
      _draw3DLimb(canvas, elbowR, handR, rStart: 3.8, rEnd: 3.0, isActive: true);

      if (_isBarbell) {
        _drawOlympicBarbellEnd3D(
          canvas,
          Offset(cx, handL.dy),
          scale: 0.9,
          showHorizontalShaft: true,
        );
      } else {
        _drawSpecificHandEquipment(canvas, handL, scale: 0.85);
        _drawSpecificHandEquipment(canvas, handR, scale: 0.85);
      }
    } else {
      // Press Militar / Press de Hombros (Barra, Mancuernas o Máquina)
      final elbowY = _lerp(shoulder.dy + 18, shoulder.dy - 22, t);
      final handY = _lerp(shoulder.dy - 4, shoulder.dy - 54, t);
      final elbowL = Offset(cx - 26, elbowY);
      final elbowR = Offset(cx + 26, elbowY);
      final handL = Offset(cx - 22, handY);
      final handR = Offset(cx + 22, handY);

      _draw3DLimb(canvas, shL, elbowL, rStart: 5.2, rEnd: 4.2, isActive: true);
      _draw3DLimb(canvas, elbowL, handL, rStart: 4.0, rEnd: 3.2, isActive: true);
      _draw3DLimb(canvas, shR, elbowR, rStart: 5.2, rEnd: 4.2, isActive: true);
      _draw3DLimb(canvas, elbowR, handR, rStart: 4.0, rEnd: 3.2, isActive: true);

      if (_isBarbell || _isSmith || _isEZBar) {
        _drawOlympicBarbellEnd3D(
          canvas,
          Offset(cx, handY),
          scale: 0.95,
          showHorizontalShaft: true,
        );
      } else {
        _drawSpecificHandEquipment(canvas, handL, scale: 0.88);
        _drawSpecificHandEquipment(canvas, handR, scale: 0.88);
      }
    }
  }

  /// 7. Curls de Bíceps y Extensiones de Tríceps (Barra, Barra EZ, Mancuerna, Polea)
  void _drawArmIsolationExercise3D(Canvas canvas, double cx, double floorY) {
    final isTricep = pattern == 'tricep_pushdown';

    final ankle = Offset(cx - 6, floorY - 2);
    final knee = Offset(cx - 4, floorY - 38);
    final hip = Offset(cx - 6, floorY - 72);
    final shoulder = Offset(cx - 4, hip.dy - 48);
    final head = Offset(shoulder.dx + 3, shoulder.dy - 16);

    final elbow = Offset(shoulder.dx + 4, shoulder.dy + 26);
    final double angle =
        isTricep ? _lerp(2.2, 0.35, t) : _lerp(0.35, 2.35, t);
    const forearmLen = 33.0;
    final hand = Offset(
      elbow.dx + math.sin(angle) * forearmLen,
      elbow.dy + math.cos(angle) * forearmLen,
    );

    // Si es Polea (Tríceps con cuerda/barra o Curl en polea baja), dibujar la Torre de Polea
    if (_isCable) {
      _drawWeightStackTower(
        canvas,
        cx + 46,
        floorY,
        cableTarget: hand,
        pulleyAtBottom: !isTricep,
      );
    }

    _draw3DLimb(canvas, hip, knee, rStart: 7.8, rEnd: 5.5);
    _draw3DLimb(canvas, knee, ankle, rStart: 5.2, rEnd: 3.6);
    _draw3DFoot(canvas, ankle);
    _draw3DTorso(canvas, hip, shoulder);
    _draw3DHead(canvas, head, shoulder);

    _draw3DLimb(
      canvas,
      shoulder,
      elbow,
      rStart: 5.6,
      rEnd: 4.6,
      isActive: true,
      bulge: 0.32,
    );
    _draw3DLimb(
      canvas,
      elbow,
      hand,
      rStart: 4.4,
      rEnd: 3.4,
      isActive: true,
    );

    _drawSpecificHandEquipment(canvas, hand);
  }

  /// 8. Sillón de Cuádriceps y Sillón de Curl Femoral Sentado (Máquina Específica)
  void _drawLegMachineExercise3D(Canvas canvas, double cx, double floorY) {
    _drawWeightStackTower(canvas, cx - 54, floorY);

    final seat = Offset(cx - 10, floorY - 44);
    final knee = Offset(cx + 22, floorY - 44);
    final backTop = Offset(cx - 24, floorY - 94);

    // Estructura del sillón de máquina
    canvas.drawLine(
      backTop,
      seat,
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      seat,
      knee,
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      seat,
      Offset(seat.dx, floorY),
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 5,
    );
    // Leva giratoria de la máquina en el eje de la rodilla
    canvas.drawCircle(
      knee,
      6.5,
      Paint()..color = const Color(0xFF94A3B8),
    );

    final shoulder = Offset(backTop.dx + 4, backTop.dy + 6);
    final head = Offset(shoulder.dx + 3, shoulder.dy - 16);

    _draw3DTorso(canvas, seat, shoulder);
    _draw3DHead(canvas, head, shoulder);
    _draw3DLimb(canvas, seat, knee, rStart: 8.2, rEnd: 5.8, isActive: true);

    final isCurl = pattern == 'leg_curl';
    final legAngle = isCurl ? _lerp(1.45, 0.15, t) : _lerp(0.15, 1.48, t);
    final ankle = Offset(
      knee.dx + math.sin(legAngle) * 42,
      knee.dy + math.cos(legAngle) * 42,
    );

    // Brazo mecánico del rodillo
    canvas.drawLine(
      knee,
      ankle,
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 3.5,
    );

    _draw3DLimb(canvas, knee, ankle, rStart: 5.5, rEnd: 3.8, isActive: true);
    _draw3DFoot(canvas, ankle);
    _drawMachineGripPad3D(canvas, ankle, radius: 7.5);
  }

  /// 9. Camilla de Curl Femoral Tumbado (Máquina Específica)
  void _drawLyingLegCurlExercise3D(Canvas canvas, double cx, double floorY) {
    _drawWeightStackTower(canvas, cx - 64, floorY);

    final benchY = floorY - 38;
    canvas.drawLine(
      Offset(cx - 56, benchY + 6),
      Offset(cx - 16, benchY),
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(cx - 16, benchY),
      Offset(cx + 28, benchY),
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(cx - 42, benchY + 4),
      Offset(cx - 42, floorY),
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 5,
    );
    canvas.drawLine(
      Offset(cx + 16, benchY),
      Offset(cx + 16, floorY),
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 5,
    );

    final head = Offset(cx - 48, benchY - 6);
    final shoulder = Offset(cx - 34, benchY - 6);
    final hip = Offset(cx - 6, benchY - 8);
    final knee = Offset(cx + 28, benchY - 6);
    final hand = Offset(cx - 52, benchY + 12);

    _draw3DTorso(canvas, hip, shoulder, facing: -1.0);
    _draw3DHead(canvas, head, shoulder, facing: -1.0);
    _draw3DLimb(canvas, shoulder, hand, rStart: 4.8, rEnd: 3.4);
    _draw3DLimb(canvas, hip, knee, rStart: 8.0, rEnd: 5.6, isActive: true);

    final curlAngle = _lerp(0.12, 2.22, t);
    const lowerLegLen = 38.0;
    final ankle = Offset(
      knee.dx + math.cos(curlAngle) * lowerLegLen,
      knee.dy - math.sin(curlAngle) * lowerLegLen,
    );

    _draw3DLimb(canvas, knee, ankle, rStart: 5.4, rEnd: 3.6, isActive: true);
    _drawMachineGripPad3D(canvas, ankle, radius: 7.5);
  }

  /// 10. Sentadilla Isométrica en Pared
  void _drawIsometricSquatExercise3D(Canvas canvas, double cx, double floorY) {
    final wallX = cx - 32;
    canvas.drawLine(
      Offset(wallX, floorY - 135),
      Offset(wallX, floorY),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    final hip = Offset(wallX + 8, floorY - 42);
    final shoulder = Offset(wallX + 8, hip.dy - 48);
    final head = Offset(wallX + 10, shoulder.dy - 16);
    final knee = Offset(hip.dx + 38, hip.dy);
    final ankle = Offset(knee.dx, floorY - 2);

    _draw3DLimb(canvas, hip, knee, rStart: 8.2, rEnd: 5.8, isActive: true);
    _draw3DLimb(canvas, knee, ankle, rStart: 5.4, rEnd: 3.8);
    _draw3DFoot(canvas, ankle);
    _draw3DTorso(canvas, hip, shoulder);
    _draw3DHead(canvas, head, shoulder);
    _draw3DLimb(
      canvas,
      shoulder,
      Offset(shoulder.dx + 26, shoulder.dy + 12),
      rStart: 4.8,
      rEnd: 3.4,
    );
  }

  /// 11. Plancha Abdominal 3D
  void _drawPlankExercise3D(Canvas canvas, double cx, double floorY) {
    final elbow = Offset(cx - 46, floorY - 4);
    final hand = Offset(cx - 64, floorY - 4);
    final shoulder = Offset(cx - 44, floorY - 30);
    final head = Offset(cx - 58, floorY - 34);
    final hip = Offset(cx + 4, floorY - 26);
    final knee = Offset(cx + 36, floorY - 16);
    final ankle = Offset(cx + 62, floorY - 4);

    _draw3DLimb(canvas, hip, knee, rStart: 7.4, rEnd: 5.4, isActive: true);
    _draw3DLimb(canvas, knee, ankle, rStart: 5.0, rEnd: 3.6);
    _draw3DTorso(canvas, hip, shoulder, isActive: true, facing: -1.0);
    _draw3DHead(canvas, head, shoulder, facing: -1.0);
    _draw3DLimb(canvas, shoulder, elbow, rStart: 5.0, rEnd: 4.2, isActive: true);
    _draw3DLimb(canvas, elbow, hand, rStart: 4.0, rEnd: 3.2);
  }

  /// 12. Swing con Kettlebell / Pesa Rusa / Mancuerna Búlgara
  void _drawKettlebellSwingExercise3D(Canvas canvas, double cx, double floorY) {
    final torsoAngle = _lerp(0.88, 0.04, t);
    final ankle = Offset(cx - 10, floorY - 2);
    final knee = Offset(cx + _lerp(10, 2, t), floorY - 40);
    final hip = Offset(cx - _lerp(24, 4, t), floorY - 76);
    final shoulder = Offset(
      hip.dx + math.sin(torsoAngle) * 50,
      hip.dy - math.cos(torsoAngle) * 50,
    );
    final head = Offset(
      shoulder.dx + math.sin(torsoAngle) * 16,
      shoulder.dy - math.cos(torsoAngle) * 16,
    );

    _draw3DLimb(canvas, hip, knee, rStart: 8.2, rEnd: 5.6, isActive: true);
    _draw3DLimb(canvas, knee, ankle, rStart: 5.4, rEnd: 3.8);
    _draw3DFoot(canvas, ankle);
    _draw3DTorso(canvas, hip, shoulder, isActive: true);
    _draw3DHead(canvas, head, shoulder);

    final armAngle = _lerp(-0.45, 1.45, t);
    const armLen = 44.0;
    final hand = Offset(
      shoulder.dx + math.sin(armAngle) * armLen,
      shoulder.dy + math.cos(armAngle) * armLen,
    );

    _draw3DLimb(canvas, shoulder, hand, rStart: 5.2, rEnd: 3.6, isActive: true);
    _drawKettlebellOrBulgarian3D(canvas, hand);
  }

  /// 13. Thruster con Barra o Mancuernas
  void _drawThrusterExercise3D(Canvas canvas, double cx, double floorY) {
    final depth = 1.0 - t;
    final ankle = Offset(cx, floorY - 2);
    final knee = Offset(cx + 22 * depth, floorY - 40 + 12 * depth);
    final hip = Offset(cx - 26 * depth, floorY - 82 + 34 * depth);
    final shoulder = Offset(cx - 6 * depth, hip.dy - 48);
    final head = Offset(shoulder.dx + 3, shoulder.dy - 16);

    _draw3DLimb(canvas, hip, knee, rStart: 8.2, rEnd: 5.6, isActive: true);
    _draw3DLimb(canvas, knee, ankle, rStart: 5.4, rEnd: 3.8);
    _draw3DFoot(canvas, ankle);
    _draw3DTorso(canvas, hip, shoulder);
    _draw3DHead(canvas, head, shoulder);

    final pressProgress = ((t - 0.35) / 0.65).clamp(0.0, 1.0);
    final elbow = Offset(
      shoulder.dx + 12,
      _lerp(shoulder.dy + 16, shoulder.dy - 24, pressProgress),
    );
    final hand = Offset(
      shoulder.dx + 8,
      _lerp(shoulder.dy - 2, shoulder.dy - 54, pressProgress),
    );

    _draw3DLimb(canvas, shoulder, elbow, rStart: 5.2, rEnd: 4.2, isActive: true);
    _draw3DLimb(canvas, elbow, hand, rStart: 4.0, rEnd: 3.2, isActive: true);
    _drawSpecificHandEquipment(canvas, hand);
  }

  /// 14. Crunch Abdominal (Suelo o Polea Alta)
  void _drawCrunchExercise3D(Canvas canvas, double cx, double floorY) {
    final hip = Offset(cx, floorY - 8);
    final knee = Offset(cx + 28, floorY - 34);
    final ankle = Offset(cx + 48, floorY - 2);

    final curlAngle = _lerp(0.15, 0.85, t);
    final shoulder = Offset(
      hip.dx - math.cos(curlAngle) * 48,
      hip.dy - math.sin(curlAngle) * 48,
    );
    final head = Offset(
      shoulder.dx - math.cos(curlAngle + 0.2) * 16,
      shoulder.dy - math.sin(curlAngle + 0.2) * 16,
    );

    _draw3DLimb(canvas, hip, knee, rStart: 7.5, rEnd: 5.4);
    _draw3DLimb(canvas, knee, ankle, rStart: 5.0, rEnd: 3.6);
    _draw3DFoot(canvas, ankle);
    _draw3DTorso(canvas, hip, shoulder, isActive: true);
    _draw3DHead(canvas, head, shoulder);

    if (_isCable) {
      _drawWeightStackTower(
        canvas,
        cx - 62,
        floorY,
        cableTarget: Offset(head.dx + 8, head.dy + 4),
      );
    }
  }

  /// 15. Hip Thrust (Empuje de Cadera con Barra, Multipower o Máquina)
  void _drawHipThrustExercise3D(Canvas canvas, double cx, double floorY) {
    // Cajón de apoyo escapular
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 68, floorY - 38, 28, 38),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF334155),
    );

    final shoulder = Offset(cx - 42, floorY - 42);
    final head = Offset(cx - 56, floorY - 48);
    final hipY = _lerp(floorY - 14, floorY - 42, t);
    final hip = Offset(cx, hipY);
    final knee = Offset(cx + 36, floorY - 42);
    final ankle = Offset(cx + 38, floorY - 2);

    _draw3DLimb(canvas, hip, knee, rStart: 8.2, rEnd: 5.6, isActive: true);
    _draw3DLimb(canvas, knee, ankle, rStart: 5.4, rEnd: 3.8);
    _draw3DFoot(canvas, ankle);
    _draw3DTorso(canvas, hip, shoulder, isActive: true);
    _draw3DHead(canvas, head, shoulder);

    final barPos = Offset(hip.dx, hip.dy - 7);
    _draw3DLimb(canvas, shoulder, barPos, rStart: 4.8, rEnd: 3.4);
    _drawSpecificHandEquipment(canvas, barPos);
  }

  void _drawPhaseAndEquipmentBadges(Canvas canvas, Size size) {
    final phaseText = isConcentric
        ? 'CONCÉNTRICA (Exhala ↑)'
        : 'EXCÉNTRICA (Controla ↓)';
    final phaseColor =
        isConcentric ? const Color(0xFFCCFF00) : const Color(0xFF00E5FF);

    String equipLabel = equipment;
    if (_isBulgarian) {
      equipLabel = 'Búlgara · $equipment';
    } else if (_isKettlebellOrBulgarianBag) {
      equipLabel = 'Mancuerna Búlgara / Kettlebell';
    }

    final tpPhase = TextPainter(
      text: TextSpan(
        text: phaseText,
        style: TextStyle(
          color: phaseColor,
          fontSize: 9.8,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tpEquip = TextPainter(
      text: TextSpan(
        text: 'Equipo: $equipLabel',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 9.2,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final boxW = math.max(tpPhase.width, tpEquip.width) + 16;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - boxW - 10, 8, boxW, 34),
      const Radius.circular(11),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.black.withOpacity(0.72),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = phaseColor.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tpPhase.paint(canvas, Offset(size.width - boxW - 2, 12));
    tpEquip.paint(canvas, Offset(size.width - boxW - 2, 25));
  }

  @override
  bool shouldRepaint(covariant _BiomechanicsPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.isConcentric != isConcentric ||
        oldDelegate.isFemale != isFemale ||
        oldDelegate.pattern != pattern ||
        oldDelegate.equipment != equipment ||
        oldDelegate.exerciseName != exerciseName;
  }
}
