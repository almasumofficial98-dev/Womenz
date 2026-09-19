import 'dart:math';
import 'package:flutter/material.dart';
import '../models/cycle_model.dart';
import '../theme/app_theme.dart';

class CycleRingWidget extends StatefulWidget {
  final int? currentDay;
  final int totalDays;
  final int periodDays;
  final CyclePhase currentPhase;
  final bool hasData;
  final String? subtitle;
  final VoidCallback? onTap;

  const CycleRingWidget({
    super.key,
    this.currentDay,
    this.totalDays = 28,
    this.periodDays = 5,
    required this.currentPhase,
    this.hasData = false,
    this.subtitle,
    this.onTap,
  });

  @override
  State<CycleRingWidget> createState() => _CycleRingWidgetState();
}

class _CycleRingWidgetState extends State<CycleRingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Center(
        child: SizedBox(
          width: 270,
          height: 270,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Pulsing Soft Glow Aura
                  Container(
                    width: 220 * _pulseAnimation.value,
                    height: 220 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.currentPhase.primaryColor.withOpacity(0.08),
                    ),
                  ),

                  // Custom Painter for Outer Cycle Ring, Ticks, Arcs & Glows
                  CustomPaint(
                    size: const Size(270, 270),
                    painter: _CycleRingPainter(
                      currentDay: widget.currentDay ?? 1,
                      totalDays: widget.totalDays,
                      periodDays: widget.periodDays,
                      currentPhase: widget.currentPhase,
                      hasData: widget.hasData,
                      pulseScale: _pulseAnimation.value,
                    ),
                  ),

                  // Center Neumorphic Inner Disc
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          widget.currentPhase.primaryColor.withOpacity(0.06),
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.currentPhase.primaryColor.withOpacity(0.2),
                          blurRadius: 24 * _pulseAnimation.value,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          blurRadius: 16,
                          spreadRadius: -4,
                          offset: Offset(-6, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Water Drop / Phase Icon Badge
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.currentPhase.primaryColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.hasData ? Icons.water_drop_rounded : Icons.calendar_today_rounded,
                            color: widget.currentPhase.primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.hasData && widget.currentDay != null ? 'Day ${widget.currentDay}' : 'No Data',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            widget.subtitle ??
                                (widget.hasData
                                    ? widget.currentPhase.displayName
                                    : 'Tap + to log period'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.hasData ? AppTheme.textSecondary : AppTheme.primaryPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CycleRingPainter extends CustomPainter {
  final int currentDay;
  final int totalDays;
  final int periodDays;
  final CyclePhase currentPhase;
  final bool hasData;
  final double pulseScale;

  _CycleRingPainter({
    required this.currentDay,
    required this.totalDays,
    required this.periodDays,
    required this.currentPhase,
    required this.hasData,
    required this.pulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 26;

    // 1. Background Ring Track
    final bgPaint = Paint()
      ..color = const Color(0xFFEFF2FB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    const double startAngle = -pi / 2;

    if (hasData) {
      // Period Arc
      final periodAngleSweep = (periodDays / totalDays) * 2 * pi;
      final periodPaint = Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFFFF6B8B), const Color(0xFFFF94A8)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        periodAngleSweep,
        false,
        periodPaint,
      );

      // Ovulation Arc
      const double ovulationStartDay = 12.5;
      const double ovulationDurationDays = 4.0;
      final ovulationStartAngle = startAngle + (ovulationStartDay / totalDays) * 2 * pi;
      final ovulationSweep = (ovulationDurationDays / totalDays) * 2 * pi;

      final ovulationPaint = Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFF7C8FFD), const Color(0xFFA3B2FF)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        ovulationStartAngle,
        ovulationSweep,
        false,
        ovulationPaint,
      );
    }

    // 2. Outer Orbit Ticks & Milestones
    final outerMarginRadius = (size.width / 2) - 6;
    final dotPaint = Paint()
      ..color = AppTheme.textMuted
      ..style = PaintingStyle.fill;

    for (int i = 0; i < totalDays; i++) {
      final angle = startAngle + (i / totalDays) * 2 * pi;
      final dx = center.dx + outerMarginRadius * cos(angle);
      final dy = center.dy + outerMarginRadius * sin(angle);

      if (i == 0 || i == 3 || i == 12 || i == 15 || i == 18 || i == 21 || i == 24 || i == 27) {
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: '${i + 1}'.padLeft(2, '0'),
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: hasData && (i + 1) == currentDay ? currentPhase.primaryColor : AppTheme.textSecondary,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(dx - tp.width / 2, dy - tp.height / 2));
      } else {
        canvas.drawCircle(Offset(dx, dy), 1.5, dotPaint);
      }
    }

    if (hasData) {
      // Animated Pulsing Day Indicator Handle
      final currentAngle = startAngle + ((currentDay - 1) / totalDays) * 2 * pi;
      final indicatorX = center.dx + radius * cos(currentAngle);
      final indicatorY = center.dy + radius * sin(currentAngle);
      final indicatorOffset = Offset(indicatorX, indicatorY);

      final glowPaint = Paint()
        ..color = currentPhase.primaryColor.withOpacity(0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * pulseScale);
      canvas.drawCircle(indicatorOffset, 16 * pulseScale, glowPaint);

      final outerHandlePaint = Paint()..color = Colors.white;
      canvas.drawCircle(indicatorOffset, 12, outerHandlePaint);

      final innerHandlePaint = Paint()..color = currentPhase.primaryColor;
      canvas.drawCircle(indicatorOffset, 7, innerHandlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) {
    return oldDelegate.currentDay != currentDay ||
        oldDelegate.totalDays != totalDays ||
        oldDelegate.currentPhase != currentPhase ||
        oldDelegate.hasData != hasData ||
        oldDelegate.pulseScale != pulseScale;
  }
}
