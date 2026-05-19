import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Beautiful "Coming Soon" placeholder used for unimplemented features.
class FeaturePlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing icon
              _PulsingIcon(icon: icon, color: colorScheme.primary)
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.08, 1.08),
                    duration: 900.ms,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.08, 1.08),
                    end: const Offset(1.0, 1.0),
                    duration: 900.ms,
                    curve: Curves.easeInOut,
                  ),

              const SizedBox(height: 32),

              // Rocket emoji animated
              const Text('🚀', style: TextStyle(fontSize: 48))
                  .animate(onPlay: (c) => c.repeat())
                  .moveY(begin: 0, end: -12, duration: 800.ms,
                      curve: Curves.easeInOut)
                  .then()
                  .moveY(begin: -12, end: 0, duration: 800.ms,
                      curve: Curves.easeInOut),

              const SizedBox(height: 20),

              // Arabic coming soon text
              Text(
                'ستكون هذه الميزة متوفرة قريباً\nفي التحديث القادم 🚀',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  height: 1.6,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              const SizedBox(height: 12),

              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

              const SizedBox(height: 40),

              // Shimmer progress bar
              _ShimmerBar(color: colorScheme.primary)
                  .animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _PulsingIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(icon, size: 48, color: color),
    );
  }
}

class _ShimmerBar extends StatefulWidget {
  final Color color;
  const _ShimmerBar({required this.color});

  @override
  State<_ShimmerBar> createState() => _ShimmerBarState();
}

class _ShimmerBarState extends State<_ShimmerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 1400.ms)..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: 6,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          gradient: LinearGradient(
            colors: [
              widget.color.withValues(alpha: 0.15),
              widget.color.withValues(alpha: 0.7),
              widget.color.withValues(alpha: 0.15),
            ],
            stops: [
              (_anim.value - 0.4).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.4).clamp(0.0, 1.0),
            ],
          ),
        ),
      ),
    );
  }
}
