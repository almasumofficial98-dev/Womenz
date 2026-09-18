import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WeightTimelineWidget extends StatefulWidget {
  final double currentWeight;
  final double lowestWeight;
  final double highestWeight;
  final String dateString;
  final ValueChanged<double>? onWeightChanged;

  const WeightTimelineWidget({
    super.key,
    this.currentWeight = 47.9,
    this.lowestWeight = 47.2,
    this.highestWeight = 51.3,
    this.dateString = '21.02.2026',
    this.onWeightChanged,
  });

  @override
  State<WeightTimelineWidget> createState() => _WeightTimelineWidgetState();
}

class _WeightTimelineWidgetState extends State<WeightTimelineWidget> {
  bool isKg = true;
  late double selectedWeight;

  @override
  void initState() {
    super.initState();
    selectedWeight = widget.currentWeight;
  }

  double get displayWeight => isKg ? selectedWeight : (selectedWeight * 2.20462);
  double get displayLowest => isKg ? widget.lowestWeight : (widget.lowestWeight * 2.20462);
  double get displayHighest => isKg ? widget.highestWeight : (widget.highestWeight * 2.20462);
  String get unitLabel => isKg ? 'kg' : 'lb';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with "Statistics • Weight" and Unit Selector Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    color: AppTheme.primaryPink,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Statistics • Weight',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),

            // kg / lb selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildUnitChip('kg', isKg),
                  _buildUnitChip('lb', !isKg),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Main Weight Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: AppTheme.cardDecoration(
            color: Colors.white,
            radius: 28,
            shadows: AppTheme.softShadow(opacity: 0.06),
          ),
          child: Column(
            children: [
              // Date Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.primaryPink),
                    const SizedBox(width: 6),
                    Text(
                      widget.dateString,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Large Weight Number Display
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: displayWeight.toStringAsFixed(1),
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                    TextSpan(
                      text: ' $unitLabel',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Interactive Ruler Timeline Slider
              SizedBox(
                height: 70,
                child: Stack(
                  children: [
                    // Custom Painted Timeline Ruler Marks
                    CustomPaint(
                      size: const Size(double.infinity, 70),
                      painter: _WeightRulerPainter(),
                    ),
                    // Slider overlay
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        activeTrackColor: AppTheme.primaryPink.withOpacity(0.6),
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: AppTheme.primaryPink,
                        overlayColor: AppTheme.primaryPink.withOpacity(0.15),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      ),
                      child: Slider(
                        value: selectedWeight,
                        min: 40.0,
                        max: 65.0,
                        onChanged: (val) {
                          setState(() {
                            selectedWeight = val;
                          });
                          if (widget.onWeightChanged != null) {
                            widget.onWeightChanged!(val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Timeline Month Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jan', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 12)),
                  Text('Feb', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppTheme.textSecondary, fontWeight: FontWeight.w500, fontSize: 12)),
                  Text('Mar', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppTheme.textSecondary, fontWeight: FontWeight.w500, fontSize: 12)),
                  Text('Apr', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Lowest vs Highest Weight Stat Cards
        Row(
          children: [
            Expanded(
              child: _buildMinMaxCard(
                title: 'Lowest',
                val: displayLowest,
                unit: unitLabel,
                icon: Icons.south_west_rounded,
                color: AppTheme.primaryBlue,
                bgColor: AppTheme.softBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMinMaxCard(
                title: 'Highest',
                val: displayHighest,
                unit: unitLabel,
                icon: Icons.north_east_rounded,
                color: AppTheme.primaryPink,
                bgColor: AppTheme.softPink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitChip(String label, bool active) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isKg = (label == 'kg');
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMinMaxCard({
    required String title,
    required double val,
    required String unit,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(
        color: Colors.white,
        radius: 24,
        shadows: AppTheme.softShadow(opacity: 0.05),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            '${val.toStringAsFixed(1)} $unit',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightRulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppTheme.primaryBlue.withOpacity(0.2)
      ..strokeWidth = 1.5;

    final centerLinePaint = Paint()
      ..color = AppTheme.primaryPink.withOpacity(0.4)
      ..strokeWidth = 2.0;

    const int totalTicks = 25;
    final double spacing = size.width / (totalTicks - 1);
    final double midY = size.height / 2;

    for (int i = 0; i < totalTicks; i++) {
      final x = i * spacing;
      final bool isTall = (i % 5 == 0);
      final double tickHeight = isTall ? 24 : 12;

      final p = (i == totalTicks ~/ 2) ? centerLinePaint : linePaint;
      canvas.drawLine(
        Offset(x, midY - tickHeight / 2),
        Offset(x, midY + tickHeight / 2),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
