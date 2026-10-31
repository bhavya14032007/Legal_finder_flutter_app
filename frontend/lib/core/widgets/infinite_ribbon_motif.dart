import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/theme_extensions.dart';

/// Faint Infinite Ribbon Visual Motif
///
/// Reproduces the website's signature undulating ribbon motif in empty states,
/// headers, and subtle decorative backgrounds.
class InfiniteRibbonMotif extends StatefulWidget {
  final double height;
  final double width;
  final double opacity;
  final bool animated;

  const InfiniteRibbonMotif({
    super.key,
    this.height = 120,
    this.width = double.infinity,
    this.opacity = 0.25,
    this.animated = true,
  });

  @override
  State<InfiniteRibbonMotif> createState() => _InfiniteRibbonMotifState();
}

class _InfiniteRibbonMotifState extends State<InfiniteRibbonMotif>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Honor reduced motion preference
    if (context.reducesMotion) {
      _controller.stop();
    } else if (widget.animated && !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.reducesMotion || !widget.animated) {
      return SizedBox(
        height: widget.height,
        width: widget.width,
        child: CustomPaint(
          painter: _RibbonPainter(
            progress: 0.0,
            opacity: widget.opacity,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          width: widget.width,
          child: CustomPaint(
            painter: _RibbonPainter(
              progress: _controller.value,
              opacity: widget.opacity,
            ),
          ),
        );
      },
    );
  }
}

class _RibbonPainter extends CustomPainter {
  final double progress;
  final double opacity;

  _RibbonPainter({required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint1 = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.accentViolet.withValues(alpha: opacity),
          AppColors.accentPurple.withValues(alpha: opacity * 0.8),
          AppColors.accentCyan.withValues(alpha: opacity * 0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..isAntiAlias = true;

    final paint2 = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.accentCyan.withValues(alpha: opacity * 0.7),
          AppColors.accentVioletLight.withValues(alpha: opacity),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;

    final path1 = Path();
    final path2 = Path();

    final midY = size.height * 0.5;
    final waveShift = progress * 2 * math.pi;

    path1.moveTo(0, midY);
    path2.moveTo(0, midY + 10);

    for (double x = 0; x <= size.width; x += 5) {
      final normX = x / size.width;
      final y1 = midY +
          math.sin(normX * 2 * math.pi + waveShift) * (size.height * 0.28) +
          math.cos(normX * 4 * math.pi - waveShift * 0.5) * (size.height * 0.12);

      final y2 = midY +
          math.cos(normX * 2.5 * math.pi - waveShift) * (size.height * 0.24) +
          math.sin(normX * 3 * math.pi + waveShift * 0.3) * (size.height * 0.1);

      path1.lineTo(x, y1);
      path2.lineTo(x, y2);
    }

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _RibbonPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.opacity != opacity;
  }
}

