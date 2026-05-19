import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _reverseSpinController;
  late AnimationController _dotsController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const Color primaryTeal = Color(0xFF035F5B);
  static const Color sandLight = Color(0xFFF4DFCD);
  static const Color creamBg = Color(0xFFFFF8F5);

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _reverseSpinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      GoRouter.of(context).refresh();
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _reverseSpinController.dispose();
    _dotsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Stone texture background
          _StoneTextureBg(),

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xF2FFFFFF),
                  Color(0x66F4DFCD),
                  Color(0x26035F5B),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo circle
                  _buildLogoCircle(),

                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'تراثي',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: primaryTeal,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Color(0x14000000),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  const Text(
                    'رحلة عبر الزمن في قلب الجزائر',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xB3035F5B),
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Loading dots
                  _buildLoadingDots(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoCircle() {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: sandLight.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer spinning arc
          AnimatedBuilder(
            animation: _spinController,
            builder: (_, __) => Transform.rotate(
              angle: _spinController.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(112, 112),
                painter: _SpinningArcPainter(),
              ),
            ),
          ),

          // Inner dashed ring (reverse spin)
          AnimatedBuilder(
            animation: _reverseSpinController,
            builder: (_, __) => Transform.rotate(
              angle: -_reverseSpinController.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(96, 96),
                painter: _DashedRingPainter(),
              ),
            ),
          ),

          // SVG Logo
          SizedBox(
            width: 56,
            height: 56,
            child: CustomPaint(
              painter: _TurathiLogoPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.15;
            final progress = (_dotsController.value - delay).clamp(0.0, 1.0);
            final offset = math.sin(progress * math.pi) * 6.0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, -offset),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x80035F5B),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// Stone texture background widget
class _StoneTextureBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NoiseTexturePainter(),
    );
  }
}

// Spinning outer arc painter
class _SpinningArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final segments = [
      (0.0, 0.75, const Color(0xFF035F5B), 1.0),
      (0.75, 0.25, const Color(0xFF035F5B), 0.5),
      (0.25, 0.5, const Color(0xFF035F5B), 0.1),
      (0.5, 1.0, const Color(0xFF035F5B), 0.3),
    ];

    for (final seg in segments) {
      final paint = Paint()
        ..color = (seg.$3 as Color).withOpacity(seg.$4 as double)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        (seg.$1 as double) * 2 * math.pi,
        (seg.$2 as double) * 2 * math.pi,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// Dashed inner ring painter
class _DashedRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.5;
    final paint = Paint()
      ..color = const Color(0xFFF4DFCD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashCount = 28;
    const dashAngle = (2 * math.pi) / dashCount;
    const gapRatio = 0.45;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapRatio);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// Noise texture background painter
class _NoiseTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFFFF8F5),
    );
    final rand = math.Random(42);
    final noisePaint = Paint()..strokeWidth = 1;
    for (int i = 0; i < 3000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      noisePaint.color = Color.fromRGBO(0, 0, 0, rand.nextDouble() * 0.04);
      canvas.drawCircle(Offset(x, y), 0.5, noisePaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// Main SVG logo painter — تحويل الـ SVG paths إلى Flutter
class _TurathiLogoPainter extends CustomPainter {
  static const Color logoColor = Color(0xFF035F5B);

  @override
  void paint(Canvas canvas, Size size) {
    // الـ viewBox الأصلي بعد scale(0.750771): 435.6, 197.1, 279.9, 309.2
    // نحسب matrix لتحويل الـ paths لتناسب الـ size (56×56)
    const double vbX = 435.6;
    const double vbY = 197.1;
    const double vbW = 279.9;
    const double vbH = 309.2;

    final double scaleX = size.width / vbW;
    final double scaleY = size.height / vbH;
    final double scale = math.min(scaleX, scaleY);
    final double offsetX = (size.width - vbW * scale) / 2 - vbX * scale;
    final double offsetY = (size.height - vbH * scale) / 2 - vbY * scale;

    canvas.save();

    // تطبيق transform: scale(0.750771) ثم تحويل viewport
    final matrix = Matrix4.identity()
      ..translate(offsetX, offsetY)
      ..scale(scale * 0.750771, scale * 0.750771);
    canvas.transform(matrix.storage);

    final paint = Paint()
      ..color = logoColor
      ..style = PaintingStyle.fill;

    // Path 1 — الجسم الرئيسي للحرف R
    final path1 = Path();
    path1.moveTo(886.315, 385.678);
    path1.cubicTo(897.374, 386.365, 910.055, 386.073, 921.231, 386.072);
    path1.cubicTo(931.039, 386.072, 943.123, 386.368, 952.758, 385.674);
    path1.cubicTo(952.138, 431.264, 953.047, 477.042, 952.669, 522.65);
    path1.cubicTo(952.52, 540.637, 953.337, 556.953, 949.06, 574.644);
    path1.cubicTo(943.87, 596.672, 932.882, 616.91, 917.236, 633.257);
    path1.cubicTo(886.719, 665.028, 852.433, 673.312, 810.225, 674.21);
    path1.cubicTo(805.368, 673.942, 802.193, 673.966, 797.33, 674.206);
    path1.cubicTo(797.058, 653.756, 797.246, 632.725, 797.216, 612.236);
    path1.cubicTo(825.713, 614.308, 859.124, 605.89, 874.657, 580.07);
    path1.cubicTo(885.984, 561.242, 886.239, 546.221, 886.275, 525.316);
    path1.cubicTo(851.563, 525.727, 816.816, 524.958, 782.033, 525.354);
    path1.cubicTo(742.167, 525.806, 702.138, 519.549, 671.079, 550.966);
    path1.cubicTo(646.288, 576.043, 646.405, 600.107, 646.474, 632.537);
    path1.lineTo(646.483, 673.957);
    path1.cubicTo(625.501, 673.333, 601.432, 673.869, 580.219, 673.87);
    path1.cubicTo(579.228, 644.713, 580.109, 610.846, 580.12, 581.082);
    path1.lineTo(580.044, 385.93);
    path1.cubicTo(601.637, 386.405, 624.846, 386.019, 646.521, 386.014);
    path1.lineTo(646.448, 486.216);
    path1.cubicTo(680.422, 458.746, 736.685, 462.783, 777.039, 462.797);
    path1.lineTo(845.682, 462.829);
    path1.cubicTo(858.535, 462.835, 873.814, 463.215, 886.404, 462.524);
    path1.cubicTo(885.714, 438.009, 886.119, 410.36, 886.315, 385.678);
    path1.close();
    canvas.drawPath(path1, paint);

    // Path 2 — الجناح الأيسر العلوي
    final path2 = Path();
    path2.moveTo(707.941, 262.409);
    path2.cubicTo(714.064, 267.382, 723.46, 277.021, 729.297, 282.779);
    path2.lineTo(764.884, 317.866);
    path2.cubicTo(748.51, 332.038, 723.865, 357.206, 708.334, 373.135);
    path2.cubicTo(703.668, 370.825, 659.856, 325.678, 652.229, 318.071);
    path2.cubicTo(668.992, 300.152, 690.258, 279.845, 707.941, 262.409);
    path2.close();
    canvas.drawPath(path2, paint);

    // Path 3 — الجناح الأيمن العلوي
    final path3 = Path();
    path3.moveTo(822.25, 262.953);
    path3.cubicTo(825.466, 263.584, 871.619, 311.21, 878.773, 317.685);
    path3.cubicTo(861.62, 333.32, 839.778, 355.483, 823.467, 372.309);
    path3.lineTo(822.95, 372.611);
    path3.cubicTo(821.119, 372.148, 773.151, 323.693, 767.099, 318.201);
    path3.cubicTo(783.476, 300.534, 804.891, 280.182, 822.25, 262.953);
    path3.close();
    canvas.drawPath(path3, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_) => false;
}
