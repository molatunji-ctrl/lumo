import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';

/// ============================================================
/// LUMO — CINEMATIC COMMERCE UNIVERSE
///
/// ACT I   : Awakening      (dark, dust, light blooms)
/// ACT II  : Universe       (products spiral out, core resolves)
/// ACT III : Interactive    (drag to orbit, tap to pulse)
/// ACT IV  : Portal         (core dives forward, Home opens from
///                           the centre — built once, no remount)
///
/// Native Flutter. No additional packages.
/// ============================================================

/// The splash plays once per app run. Kept top-level (not a field on the
/// const widget) so hot reload stays happy.
bool _splashPlayed = false;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _ambient;
  late final AnimationController _portal;
  late final AnimationController _pulse;

  late final List<_FashionObject> _products;
  late final List<_StarParticle> _particles;

  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);
  final Stopwatch _life = Stopwatch()..start();

  Timer? _autoEnterTimer;
  Timer? _pushTimer;

  double _cameraYaw = 0;
  double _cameraPitch = 0;
  double _targetYaw = 0;
  double _targetPitch = 0;

  bool _entering = false;
  bool _completed = false;
  bool _interacted = false;

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void initState() {
    super.initState();

    _products = _generateProducts();
    _particles = _generateParticles();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Long period: time is read in seconds, so there is no visible loop jump.
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    );

    _portal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Never replay: go straight to Home if this screen is rebuilt.
      if (_splashPlayed) {
        _completed = true;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        return;
      }

      if (_reduceMotion) {
        _intro.value = 1;
        _armAuto(1500);
      } else {
        _intro.forward();
        _ambient.repeat();
        _armAuto(4200);
      }
    });
  }

  // ============================================================
  // WORLD GENERATION
  // ============================================================

  List<_FashionObject> _generateProducts() {
    final random = math.Random(42);

    return List.generate(36, (index) {
      final angle = (index / 36) * math.pi * 2 +
          (random.nextDouble() - 0.5) * 0.35;
      final layer = index % 3;

      return _FashionObject(
        angle: angle,
        radius: 125 + layer * 65 + random.nextDouble() * 35,
        height: (random.nextDouble() - 0.5) * 330,
        size: 0.55 + random.nextDouble() * 0.75,
        speed: 0.25 + random.nextDouble() * 0.4,
        type: index % 4,
        phase: random.nextDouble() * math.pi * 2,
        rotation: random.nextDouble() * math.pi * 2,
      );
    });
  }

  List<_StarParticle> _generateParticles() {
    final random = math.Random(98);

    return List.generate(110, (index) {
      return _StarParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 0.3 + random.nextDouble() * 1.5,
        opacity: 0.05 + random.nextDouble() * 0.3,
        phase: random.nextDouble() * math.pi * 2,
      );
    });
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _armAuto(int ms) {
    _autoEnterTimer?.cancel();
    _autoEnterTimer = Timer(Duration(milliseconds: ms), _enterHome);
  }

  void _enterHome() {
    if (!mounted || _entering || _completed) return;

    _entering = true;
    _autoEnterTimer?.cancel();
    _splashPlayed = true;
    HapticFeedback.mediumImpact();

    if (_reduceMotion) {
      _openHome();
      return;
    }

    // The core dives forward while Home opens from the centre.
    _portal.forward();
    _pushTimer = Timer(const Duration(milliseconds: 600), _openHome);
  }

  void _openHome() {
    if (!mounted || _completed) return;
    _completed = true;

    // HomeScreen is created exactly once, here, inside the reveal route.
    // It keeps the same place in the tree for the whole transition, so
    // there is no remount, flash or lost state.
    Navigator.of(context).pushReplacement(
      _PortalRoute(
        page: const HomeScreen(),
        reduced: _reduceMotion,
      ),
    );
  }

  // ============================================================
  // TOUCH INTERACTION
  // ============================================================

  void _noteInteraction() {
    if (_entering) return;
    if (!_interacted) setState(() => _interacted = true);
    // Give people time to play, but never trap them.
    if (_life.elapsedMilliseconds < 8000) _armAuto(2800);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_entering || _reduceMotion) return;
    _noteInteraction();

    _targetYaw += details.delta.dx * 0.008;
    _targetPitch = (_targetPitch + details.delta.dy * 0.003)
        .clamp(-0.4, 0.4)
        .toDouble();
    _pointer.value = details.localPosition;
  }

  void _handlePanEnd() {
    _pointer.value = null; // never leave a stale pointer pushing the stars
  }

  void _triggerPulse() {
    if (_entering || _reduceMotion) return;
    HapticFeedback.lightImpact();
    _noteInteraction();
    _pulse.forward(from: 0);
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  void dispose() {
    _autoEnterTimer?.cancel();
    _pushTimer?.cancel();

    _intro.dispose();
    _ambient.dispose();
    _portal.dispose();
    _pulse.dispose();
    _pointer.dispose();

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. The cinematic world. Purely visual.
          IgnorePointer(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _intro,
                _ambient,
                _portal,
                _pulse,
                _pointer,
              ]),
              builder: _buildWorld,
            ),
          ),

          // 2. Gesture surface: drag to orbit, tap to pulse.
          //    It sits BELOW the controls so buttons always win.
          Positioned.fill(
            child: MouseRegion(
              onHover: (e) {
                if (!_entering && !_reduceMotion) {
                  _pointer.value = e.localPosition;
                }
              },
              onExit: (_) => _pointer.value = null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: _handlePanUpdate,
                onPanEnd: (_) => _handlePanEnd(),
                onPanCancel: _handlePanEnd,
                onTap: _triggerPulse,
              ),
            ),
          ),

          // 3. Labels + the one ENTER control.
          AnimatedBuilder(
            animation: Listenable.merge([_intro, _portal]),
            builder: _buildChrome,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld(BuildContext context, Widget? _) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 390;

    final intro = Curves.easeOutCubic.transform(_intro.value);
    final portal = Curves.easeInOutCubic.transform(_portal.value);
    final time = _reduceMotion ? 0.0 : _ambient.value * 3600.0; // seconds

    // Smooth camera inertia toward the gesture target.
    _cameraYaw += (_targetYaw - _cameraYaw) * 0.12;
    _cameraPitch += (_targetPitch - _cameraPitch) * 0.12;

    final pointer = _pointer.value;
    final coreSide = math.min(340.0, size.width * 0.92);

    // The whole world dissolves once the portal is wide open.
    final worldOpacity = (1 - _ss(0.7, 1.0, portal)).clamp(0.0, 1.0).toDouble();

    return Opacity(
      opacity: worldOpacity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _CinematicBackground(time: time, portal: portal),

          CustomPaint(
            painter: _StarfieldPainter(
              particles: _particles,
              time: time,
              reveal: intro,
              portal: portal,
              pointer: pointer,
            ),
          ),

          // Central atmospheric light.
          Center(
            child: Transform.scale(
              scale: 0.7 + intro * 0.3,
              child: Opacity(
                opacity: (intro * (1 - portal)).clamp(0.0, 1.0).toDouble(),
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.orange.withValues(alpha: 0.16),
                        AppColors.orange.withValues(alpha: 0.035),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Products BEHIND the brand.
          CustomPaint(
            painter: _FashionUniversePainter(
              products: _products,
              time: time,
              reveal: intro,
              portal: portal,
              yaw: _cameraYaw,
              pitch: _cameraPitch,
              pointer: pointer,
              pulse: _pulse.value,
              orange: AppColors.orange,
              foreground: false,
            ),
          ),

          // The brand core. Dives toward the camera during the portal.
          Center(
            child: Transform.scale(
              scale: (0.65 + intro * 0.35) * (1 + portal * 2.5),
              child: Opacity(
                opacity:
                    (intro * (1 - portal * 1.4)).clamp(0.0, 1.0).toDouble(),
                child: SizedBox(
                  width: coreSide,
                  height: coreSide,
                  child: FittedBox(
                    child: _LumoCore(
                      time: time,
                      intro: intro,
                      pulse: Curves.easeOut.transform(
                        (1 - _pulse.value).clamp(0.0, 1.0).toDouble(),
                      ) *
                          (_pulse.value > 0 ? 1 : 0),
                      compact: compact,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Products IN FRONT of the brand (between it and the camera).
          CustomPaint(
            painter: _FashionUniversePainter(
              products: _products,
              time: time,
              reveal: intro,
              portal: portal,
              yaw: _cameraYaw,
              pitch: _cameraPitch,
              pointer: pointer,
              pulse: _pulse.value,
              orange: AppColors.orange,
              foreground: true,
            ),
          ),

          // Cinematic vignette.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.15,
                colors: [
                  Colors.transparent,
                  const Color(0xFF02040A).withValues(alpha: 0.65),
                ],
                stops: const [0.3, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChrome(BuildContext context, Widget? _) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 390;

    final intro = Curves.easeOutCubic.transform(_intro.value);
    final portal = Curves.easeInOutCubic.transform(_portal.value);
    final opacity = (intro * (1 - portal * 3)).clamp(0.0, 1.0).toDouble();

    if (opacity <= 0.001) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: _entering,
      child: Opacity(
        opacity: opacity,
        child: Stack(
          children: [
            // Top label.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 22,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.orange.withValues(alpha: 0.7),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'LUMO / WORLD 01',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.4,
                          ),
                        ),
                        const Spacer(),
                        const Flexible(
                          child: Text(
                            'DISCOVER DIFFERENT',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom controls.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IgnorePointer(
                        child: Text(
                          'A NEW WORLD OF STYLE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: compact ? 9 : 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: IgnorePointer(
                              child: AnimatedOpacity(
                                opacity: _interacted ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 400),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.swipe_rounded,
                                      color: Colors.white38,
                                      size: 17,
                                    ),
                                    const SizedBox(width: 9),
                                    Flexible(
                                      child: Text(
                                        _reduceMotion
                                            ? ''
                                            : 'DRAG TO EXPLORE',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.4),
                                          fontSize: 9,
                                          letterSpacing: 1.6,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _EnterButton(
                            onPressed: _enterHome,
                            color: AppColors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double _ss(double a, double b, double x) {
  final t = ((x - a) / (b - a)).clamp(0.0, 1.0).toDouble();
  return t * t * (3 - 2 * t);
}

// ============================================================
// DATA MODELS
// ============================================================

class _FashionObject {
  const _FashionObject({
    required this.angle,
    required this.radius,
    required this.height,
    required this.size,
    required this.speed,
    required this.type,
    required this.phase,
    required this.rotation,
  });

  final double angle;
  final double radius;
  final double height;
  final double size;
  final double speed;
  final int type;
  final double phase;
  final double rotation;
}

class _StarParticle {
  const _StarParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
    required this.phase,
  });

  final double x;
  final double y;
  final double radius;
  final double opacity;
  final double phase;
}

class _ProjectedProduct {
  const _ProjectedProduct({
    required this.object,
    required this.position,
    required this.scale,
    required this.depth,
    required this.opacity,
    required this.rotation,
  });

  final _FashionObject object;
  final Offset position;
  final double scale;
  final double depth;
  final double opacity;
  final double rotation;
}

// ============================================================
// CINEMATIC BACKGROUND
// ============================================================

class _CinematicBackground extends StatelessWidget {
  const _CinematicBackground({
    required this.time,
    required this.portal,
  });

  final double time;
  final double portal;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.12),
          radius: 1.25,
          colors: [
            Color(0xFF16243C),
            Color(0xFF08101F),
            Color(0xFF02040A),
          ],
          stops: [0, 0.55, 1],
        ),
      ),
      child: CustomPaint(
        painter: _AtmosphericLightPainter(time: time, portal: portal),
      ),
    );
  }
}

class _AtmosphericLightPainter extends CustomPainter {
  const _AtmosphericLightPainter({
    required this.time,
    required this.portal,
  });

  final double time;
  final double portal;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height);

    // Warm cinematic key light.
    final orangeLight = Paint()
      ..shader = ui.Gradient.radial(
        center + Offset(math.sin(time * 0.4) * 70, -80),
        radius * 0.55,
        [
          const Color(0xFFFF782F).withValues(alpha: 0.12 * (1 - portal)),
          Colors.transparent,
        ],
      );
    canvas.drawRect(Offset.zero & size, orangeLight);

    // Cool opposing light.
    final blueLight = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.8, size.height * 0.3),
        radius * 0.7,
        [
          const Color(0xFF214B78).withValues(alpha: 0.18),
          Colors.transparent,
        ],
      );
    canvas.drawRect(Offset.zero & size, blueLight);

    // Subtle horizon.
    final horizonPaint = Paint()
      ..color = const Color(0xFFFF7A36).withValues(alpha: 0.04 * (1 - portal))
      ..strokeWidth = 1;
    final horizonY = size.height * 0.62;
    canvas.drawLine(
      Offset(0, horizonY),
      Offset(size.width, horizonY),
      horizonPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AtmosphericLightPainter old) =>
      old.time != time || old.portal != portal;
}

// ============================================================
// STARFIELD
// ============================================================

class _StarfieldPainter extends CustomPainter {
  const _StarfieldPainter({
    required this.particles,
    required this.time,
    required this.reveal,
    required this.portal,
    required this.pointer,
  });

  final List<_StarParticle> particles;
  final double time;
  final double reveal;
  final double portal;
  final Offset? pointer;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      var x = particle.x * size.width;
      var y = particle.y * size.height;

      x += math.sin(time * 0.8 + particle.phase) * 9;
      y += math.cos(time * 0.4 + particle.phase) * 5;

      final p = pointer;
      if (p != null) {
        final dx = x - p.dx;
        final dy = y - p.dy;
        final distance = math.sqrt(dx * dx + dy * dy);

        if (distance < 120 && distance > 0.001) {
          final force = (1 - distance / 120) * 16;
          x += dx / distance * force;
          y += dy / distance * force;
        }
      }

      final twinkle = 0.65 + math.sin(time * 2 + particle.phase) * 0.35;
      final opacity = particle.opacity * twinkle * reveal * (1 - portal);

      paint.color = Colors.white.withValues(
        alpha: opacity.clamp(0.0, 1.0).toDouble(),
      );
      canvas.drawCircle(Offset(x, y), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) =>
      old.time != time ||
      old.reveal != reveal ||
      old.portal != portal ||
      old.pointer != pointer;
}

// ============================================================
// FASHION UNIVERSE
// ============================================================

class _FashionUniversePainter extends CustomPainter {
  const _FashionUniversePainter({
    required this.products,
    required this.time,
    required this.reveal,
    required this.portal,
    required this.yaw,
    required this.pitch,
    required this.pointer,
    required this.pulse,
    required this.orange,
    required this.foreground,
  });

  final List<_FashionObject> products;
  final double time;
  final double reveal;
  final double portal;
  final double yaw;
  final double pitch;
  final Offset? pointer;
  final double pulse;
  final Color orange;

  /// false = items behind the brand core, true = items in front of it.
  final bool foreground;

  @override
  void paint(Canvas canvas, Size size) {
    if (reveal <= 0.002) return;

    final center = Offset(size.width / 2, size.height / 2);
    final baseScale = math.min(size.width, size.height) / 420;

    // Camera parameters scale with the screen so the look is identical
    // on phones, tablets and desktop.
    final focalLength = 650.0 * baseScale;
    final cameraDistance = 750.0 * baseScale;

    final pitchCos = math.cos(pitch);
    final pitchSin = math.sin(pitch);

    final pulseActive = pulse > 0 && pulse < 1;
    final waveFront = pulse * 480 * baseScale;

    final projected = <_ProjectedProduct>[];

    for (final product in products) {
      // Uniform orbit (yaw spins the whole market, not each item at its
      // own rate) plus a little spiral while the world is appearing.
      final angle = product.angle +
          time * product.speed * 0.55 +
          yaw +
          (1 - reveal) * 2.4;

      final radius = product.radius * reveal * baseScale;

      var x = math.cos(angle) * radius;
      var z = math.sin(angle) * radius;
      var y = product.height * reveal * baseScale +
          math.sin(time * 1.4 + product.phase) * 9 * reveal * baseScale;

      // Camera pitch.
      final rotatedY = y * pitchCos - z * pitchSin;
      final rotatedZ = y * pitchSin + z * pitchCos;
      y = rotatedY;
      z = rotatedZ;

      // Tap pulse: a wavefront shoves products outward as it passes.
      if (pulseActive) {
        final d = math.sqrt(x * x + y * y + z * z) + 0.001;
        final band = (d - waveFront) / (70 * baseScale);
        final bump =
            44 * baseScale * math.exp(-band * band) * (1 - pulse);
        x += x / d * bump;
        y += y / d * bump;
        z += z / d * bump;
      }

      // Layering relative to the brand plane (z = 0).
      final isNear = z < 0;
      if (isNear != foreground) continue;

      // Portal: the universe rushes outward.
      final expansion = 1 + portal * portal * 5;
      x *= expansion;
      y *= expansion;

      final denominator =
          (cameraDistance + z).clamp(100.0 * baseScale, 2000.0 * baseScale).toDouble();
      final perspective = focalLength / denominator;

      final screenPosition = Offset(
        center.dx + x * perspective,
        center.dy + y * perspective,
      );

      // Atmospheric depth attenuation.
      final depthOpacity =
          (1 - (z / baseScale + 350) / 1100).clamp(0.25, 1.0).toDouble();

      final opacity = depthOpacity * reveal * (1 - portal * 0.8);

      projected.add(
        _ProjectedProduct(
          object: product,
          position: screenPosition,
          scale: product.size * perspective * baseScale,
          depth: z,
          opacity: opacity.clamp(0.0, 1.0).toDouble(),
          // Gentle sway keeps garments readable instead of tumbling.
          rotation: math.sin(time * 0.7 + product.phase) * 0.4 +
              (product.rotation - math.pi) * 0.12,
        ),
      );
    }

    // Painter's algorithm: far to near.
    projected.sort((a, b) => b.depth.compareTo(a.depth));

    if (!foreground) {
      _drawOrbitalGuides(canvas, center, baseScale);
      _drawEnergyPulse(canvas, center, waveFront * (focalLength / cameraDistance));
    }

    for (final product in projected) {
      _drawProduct(canvas, product);
    }
  }

  // ============================================================
  // ORBITAL GUIDES
  // ============================================================

  void _drawOrbitalGuides(Canvas canvas, Offset center, double baseScale) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = orange.withValues(alpha: 0.08 * reveal * (1 - portal));

    for (var i = 0; i < 3; i++) {
      final radius = (130 + i * 65) * baseScale * reveal;

      final rect = Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius * 0.75,
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-0.25 + i * 0.18 + time * 0.03);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawOval(rect, paint);
      canvas.restore();
    }
  }

  // ============================================================
  // PRODUCT RENDERING
  // ============================================================

  void _drawProduct(Canvas canvas, _ProjectedProduct projected) {
    final position = projected.position;

    var interactionScale = 1.0;
    var interactionGlow = 0.0;

    final p = pointer;
    if (p != null) {
      final distance = (position - p).distance;
      if (distance < 120) {
        final influence = 1 - distance / 120;
        interactionScale += influence * 0.3;
        interactionGlow = influence;
      }
    }

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(projected.rotation);
    canvas.scale(projected.scale * interactionScale);

    final opacity = projected.opacity;

    // Soft cinematic glow — a radial gradient, far cheaper than a blur
    // filter on every product every frame.
    final glowAlpha = ((0.18 + interactionGlow * 0.25) * opacity)
        .clamp(0.0, 1.0)
        .toDouble();
    canvas.drawCircle(
      Offset.zero,
      36,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          36,
          [
            orange.withValues(alpha: glowAlpha),
            orange.withValues(alpha: 0),
          ],
        ),
    );

    // Product material.
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        const Offset(-25, -30),
        const Offset(25, 30),
        [
          Colors.white.withValues(alpha: opacity * 0.95),
          const Color(0xFFD4DFEB).withValues(alpha: opacity * 0.85),
          orange.withValues(alpha: opacity * 0.65),
          const Color(0xFF884321).withValues(alpha: opacity * 0.8),
        ],
        const [0, 0.28, 0.7, 1],
      );

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: opacity * 0.8);

    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.black.withValues(alpha: opacity * 0.25);

    switch (projected.object.type) {
      case 0:
        _drawShoppingBag(canvas, fill, outline, shadow);
        break;
      case 1:
        _drawShirt(canvas, fill, outline, shadow);
        break;
      case 2:
        _drawSneaker(canvas, fill, outline, shadow);
        break;
      default:
        _drawHandbag(canvas, fill, outline, shadow);
    }

    canvas.restore();
  }

  /// A copy of [base] with a different stroke width. Prevents one detail's
  /// width from leaking into every later stroke.
  Paint _w(Paint base, double width) => Paint()
    ..style = base.style
    ..strokeJoin = base.strokeJoin
    ..strokeCap = base.strokeCap
    ..color = base.color
    ..strokeWidth = width;

  // ============================================================
  // SHOPPING BAG
  // ============================================================

  void _drawShoppingBag(Canvas canvas, Paint fill, Paint outline, Paint shadow) {
    final body = Path()
      ..moveTo(-20, -14)
      ..lineTo(20, -14)
      ..lineTo(17, 25)
      ..quadraticBezierTo(0, 29, -17, 25)
      ..close();

    canvas.drawPath(body, fill);
    canvas.drawPath(body, outline);

    final handle = Path()
      ..moveTo(-10, -14)
      ..cubicTo(-10, -35, 10, -35, 10, -14);

    canvas.drawPath(handle, shadow);
    canvas.drawPath(handle, _w(outline, 2));

    // Fold detail.
    canvas.drawLine(
      const Offset(12, -11),
      const Offset(10, 20),
      _w(outline, 0.8),
    );
  }

  // ============================================================
  // SHIRT
  // ============================================================

  void _drawShirt(Canvas canvas, Paint fill, Paint outline, Paint shadow) {
    final shirt = Path()
      ..moveTo(-12, -20)
      ..lineTo(-27, -11)
      ..lineTo(-20, 1)
      ..lineTo(-15, -4)
      ..lineTo(-15, 23)
      ..lineTo(15, 23)
      ..lineTo(15, -4)
      ..lineTo(20, 1)
      ..lineTo(27, -11)
      ..lineTo(12, -20)
      ..quadraticBezierTo(0, -11, -12, -20)
      ..close();

    canvas.drawPath(shirt, fill);
    canvas.drawPath(shirt, outline);

    // Collar.
    canvas.drawArc(
      const Rect.fromLTRB(-9, -23, 9, -13),
      0,
      math.pi,
      false,
      outline,
    );

    // Fabric fold.
    canvas.drawLine(
      const Offset(-11, 2),
      const Offset(-8, 18),
      _w(outline, 0.6),
    );
  }

  // ============================================================
  // SNEAKER
  // ============================================================

  void _drawSneaker(Canvas canvas, Paint fill, Paint outline, Paint shadow) {
    final shoe = Path()
      ..moveTo(-25, 9)
      ..lineTo(-22, -7)
      ..quadraticBezierTo(-20, -16, -11, -12)
      ..lineTo(-3, -17)
      ..lineTo(7, -2)
      ..quadraticBezierTo(18, 1, 25, 9)
      ..quadraticBezierTo(29, 18, 19, 19)
      ..lineTo(-22, 19)
      ..quadraticBezierTo(-28, 18, -25, 9)
      ..close();

    canvas.drawPath(shoe, fill);
    canvas.drawPath(shoe, outline);

    // Sole.
    canvas.drawLine(
      const Offset(-24, 13),
      const Offset(25, 13),
      _w(outline, 2),
    );

    // Side marking.
    final detail = Path()
      ..moveTo(-10, 1)
      ..quadraticBezierTo(0, 7, 12, 3);
    canvas.drawPath(detail, outline);

    // Laces.
    final lace = _w(outline, 0.8);
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(-5 + i * 4, -7 + i * 2),
        Offset(1 + i * 4, -5 + i * 2),
        lace,
      );
    }
  }

  // ============================================================
  // HANDBAG
  // ============================================================

  void _drawHandbag(Canvas canvas, Paint fill, Paint outline, Paint shadow) {
    final bag = Path()
      ..moveTo(-22, -5)
      ..lineTo(22, -5)
      ..lineTo(19, 22)
      ..quadraticBezierTo(0, 27, -19, 22)
      ..close();

    canvas.drawPath(bag, fill);
    canvas.drawPath(bag, outline);

    final handle = Path()
      ..moveTo(-11, -5)
      ..cubicTo(-12, -30, 12, -30, 11, -5);

    canvas.drawPath(handle, shadow);
    canvas.drawPath(handle, outline);

    final flap = Path()
      ..moveTo(-18, -4)
      ..lineTo(0, 9)
      ..lineTo(18, -4);
    canvas.drawPath(flap, outline);

    // Clasp.
    canvas.drawCircle(const Offset(0, 9), 2.3, fill);
    canvas.drawCircle(const Offset(0, 9), 2.3, outline);
  }

  // ============================================================
  // ENERGY PULSE RING
  // ============================================================

  void _drawEnergyPulse(Canvas canvas, Offset center, double radius) {
    if (pulse <= 0 || pulse >= 1) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * (1 - pulse)
      ..color = orange.withValues(
        alpha: ((1 - pulse) * 0.6).clamp(0.0, 1.0).toDouble(),
      );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _FashionUniversePainter old) =>
      old.time != time ||
      old.reveal != reveal ||
      old.portal != portal ||
      old.yaw != yaw ||
      old.pitch != pitch ||
      old.pointer != pointer ||
      old.pulse != pulse ||
      old.foreground != foreground;
}

// ============================================================
// CENTRAL LUMO CORE
// ============================================================

class _LumoCore extends StatelessWidget {
  const _LumoCore({
    required this.time,
    required this.intro,
    required this.pulse,
    required this.compact,
  });

  final double time;
  final double intro;
  final double pulse;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final orange = AppColors.orange;
    final fontSize = compact ? 88.0 : 102.0;

    const wordStyleBase = TextStyle(
      height: 0.9,
      fontWeight: FontWeight.w900,
      letterSpacing: -7,
    );

    return SizedBox(
      width: 340,
      height: 340,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating technical ring.
          Transform.rotate(
            angle: time * 0.15,
            child: CustomPaint(
              size: const Size(330, 330),
              painter: _CoreRingPainter(color: orange, progress: intro),
            ),
          ),

          // Inner counter-rotating ring.
          Transform.rotate(
            angle: -time * 0.22,
            child: Container(
              width: 265,
              height: 265,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: orange.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
            ),
          ),

          // Core glow (flares on tap pulse).
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  orange.withValues(
                    alpha: (0.12 + pulse * 0.15).clamp(0.0, 1.0).toDouble(),
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The wordmark is built from separate layers. Shadows must
              // NOT live inside a ShaderMask, or the mask recolours them.
              Stack(
                alignment: Alignment.center,
                children: [
                  // Warm light bleeding from the letters.
                  ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Text(
                      'lumo',
                      textScaler: TextScaler.noScaling,
                      style: wordStyleBase.copyWith(
                        color: orange.withValues(
                          alpha: (0.5 + pulse * 0.3).clamp(0.0, 1.0).toDouble(),
                        ),
                        fontSize: fontSize,
                      ),
                    ),
                  ),

                  // Soft drop shadow.
                  Transform.translate(
                    offset: const Offset(0, 8),
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Text(
                        'lumo',
                        textScaler: TextScaler.noScaling,
                        style: wordStyleBase.copyWith(
                          color: Colors.black.withValues(alpha: 0.6),
                          fontSize: fontSize,
                        ),
                      ),
                    ),
                  ),

                  // Crisp front face with a subtle metallic gradient.
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Color(0xFFF5F7FF),
                          Color(0xFFD5DCE8),
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      'lumo',
                      textScaler: TextScaler.noScaling,
                      style: wordStyleBase.copyWith(
                        color: Colors.white,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Container(
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: orange.withValues(alpha: 0.8),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'THE FUTURE OF COMMERCE',
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CORE RING PAINTER
// ============================================================

class _CoreRingPainter extends CustomPainter {
  const _CoreRingPainter({
    required this.color,
    required this.progress,
  });

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.46;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.18 * progress);

    canvas.drawCircle(center, radius, ringPaint);

    final tickPaint = Paint()..strokeCap = StrokeCap.round;

    for (var i = 0; i < 96; i++) {
      final angle = i * math.pi * 2 / 96;
      final major = i % 8 == 0;

      final innerRadius = radius - (major ? 17 : 7);

      tickPaint
        ..strokeWidth = major ? 1.5 : 0.7
        ..color = color.withValues(alpha: (major ? 0.55 : 0.14) * progress);

      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * innerRadius,
          center.dy + math.sin(angle) * innerRadius,
        ),
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        ),
        tickPaint,
      );
    }

    // Four anchor points.
    final anchor = Paint()..color = color.withValues(alpha: 0.8 * progress);
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 + math.pi / 4;
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        ),
        2.5,
        anchor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CoreRingPainter old) =>
      old.progress != progress || old.color != color;
}

// ============================================================
// PORTAL ROUTE — Home opens from the centre of the screen.
//
// HomeScreen is built once and keeps the same place in the tree for the
// whole transition, so there is no remount, flash or lost state. The splash
// keeps animating underneath until the reveal completes.
// ============================================================

class _PortalRoute extends PageRouteBuilder<void> {
  _PortalRoute({
    required Widget page,
    required bool reduced,
  }) : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: Duration(milliseconds: reduced ? 300 : 800),
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondary, child) {
            if (reduced) {
              return FadeTransition(opacity: animation, child: child);
            }
            return AnimatedBuilder(
              animation: animation,
              child: child,
              builder: (context, child) {
                final size = MediaQuery.sizeOf(context);
                final origin = Offset(size.width / 2, size.height / 2);
                final t = Curves.easeInOutCubic.transform(animation.value);
                final done = animation.value >= 1.0;
                final maxR = math.sqrt(
                  size.width * size.width + size.height * size.height,
                ) / 2;
                final r = maxR * t;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipPath(
                      clipper: _CircleReveal(origin, r, done),
                      child: Transform.scale(
                        scale: 1.0 + 0.10 * (1 - t),
                        child: child,
                      ),
                    ),
                    if (!done)
                      IgnorePointer(
                        child: CustomPaint(painter: _PortalRing(origin, r, t)),
                      ),
                  ],
                );
              },
            );
          },
        );
}

class _CircleReveal extends CustomClipper<Path> {
  _CircleReveal(this.origin, this.radius, this.full);

  final Offset origin;
  final double radius;
  final bool full;

  @override
  Path getClip(Size size) => full
      ? (Path()..addRect(Offset.zero & size))
      : (Path()..addOval(Rect.fromCircle(center: origin, radius: radius)));

  @override
  bool shouldReclip(covariant _CircleReveal old) =>
      old.radius != radius || old.full != full || old.origin != origin;
}

class _PortalRing extends CustomPainter {
  _PortalRing(this.origin, this.radius, this.t);

  final Offset origin;
  final double radius;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0.5) return;

    final opacity = (1 - t).clamp(0.0, 1.0).toDouble();

    final outerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..color = AppColors.orange.withValues(alpha: opacity * 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    final innerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = AppColors.orange.withValues(alpha: opacity * 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final sharpEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: opacity * 0.8);

    canvas.drawCircle(origin, radius, outerGlow);
    canvas.drawCircle(origin, radius, innerGlow);
    canvas.drawCircle(origin, radius, sharpEdge);
  }

  @override
  bool shouldRepaint(covariant _PortalRing old) =>
      old.radius != radius || old.t != t;
}

// ============================================================
// ENTER BUTTON
// ============================================================

class _EnterButton extends StatelessWidget {
  const _EnterButton({
    required this.onPressed,
    required this.color,
  });

  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Enter Lumo marketplace',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ENTER LUMO',
                  style: TextStyle(
                    color: Color(0xFF07101D),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF07101D),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}