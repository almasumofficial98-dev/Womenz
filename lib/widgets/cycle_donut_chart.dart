import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CycleDonutChartWidget extends StatelessWidget {
  final int totalDays;
  final String status;

  const CycleDonutChartWidget({
    super.key,
    this.totalDays = 28,
    this.status = 'Regular',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: AppTheme.cardDecoration(
        color: Colors.white,
        radius: 28,
        shadows: AppTheme.softShadow(opacity: 0.05),
      ),
      child: Column(
        children: [
          // Donut Chart Container with central stats
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _CycleDonutPainter(),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Cycle length',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalDays days',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Legend Chips below donut chart
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendBadge('Period (5d)', const Color(0xFFFF6B8B)),
              _buildLegendBadge('Follicular (8d)', const Color(0xFF6C92F8)),
              _buildLegendBadge('Ovulation (4d)', const Color(0xFFFF9E6D)),
              _buildLegendBadge('Luteal (11d)', const Color(0xFF62A7FE)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 18;
    const strokeWidth = 26.0;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Segment proportions (5 days, 8 days, 4 days, 11 days = 28 days total)
    final segments = [
      {'days': 5, 'color': const Color(0xFFFF6B8B)},
      {'days': 8, 'color': const Color(0xFF6C92F8)},
      {'days': 4, 'color': const Color(0xFFFF9E6D)},
      {'days': 11, 'color': const Color(0xFF62A7FE)},
    ];

    double currentAngle = -pi / 2;
    const totalDays = 28;
    const gapAngle = 0.08;

    for (final seg in segments) {
      final days = seg['days'] as int;
      final color = seg['color'] as Color;

      final sweepAngle = (days / totalDays) * 2 * pi - gapAngle;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, currentAngle, sweepAngle, false, paint);

      currentAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
