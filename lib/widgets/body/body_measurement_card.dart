import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/bmi_service.dart';
import '../../theme/app_theme.dart';

class BodyMeasurementCard extends StatefulWidget {
  final double currentWeightKg;
  final double currentHeightCm;
  final WeightUnit weightUnit;
  final HeightUnit heightUnit;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<double> onHeightChanged;

  const BodyMeasurementCard({
    super.key,
    required this.currentWeightKg,
    required this.currentHeightCm,
    this.weightUnit = WeightUnit.kg,
    this.heightUnit = HeightUnit.cm,
    required this.onWeightChanged,
    required this.onHeightChanged,
  });

  @override
  State<BodyMeasurementCard> createState() => _BodyMeasurementCardState();
}

class _BodyMeasurementCardState extends State<BodyMeasurementCard> {
  late double weightVal;
  late double heightVal;

  @override
  void initState() {
    super.initState();
    weightVal = widget.currentWeightKg.clamp(30.0, 150.0);
    heightVal = widget.currentHeightCm.clamp(100.0, 220.0);
  }

  @override
  Widget build(BuildContext context) {
    final bmi = BmiService.calculateBmi(weightVal, heightVal);
    final classification = BmiService.getBmiClassification(bmi);
    final weightDisplay = BmiService.convertWeight(weightVal, widget.weightUnit);
    final heightDisplay = BmiService.formatHeight(heightVal, widget.heightUnit);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppTheme.cardDecoration(
        color: Colors.white,
        radius: 28,
        shadows: AppTheme.softShadow(opacity: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppTheme.softBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.monitor_weight_rounded, color: AppTheme.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Body Measurements & BMI',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Independent Health Metrics',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'BMI: $bmi',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Neutral Classification pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.fitness_center_rounded, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    classification,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Weight Slider (30 - 150 kg)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '$weightDisplay ${widget.weightUnit == WeightUnit.kg ? 'kg' : 'lb'}',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primaryBlue,
              thumbColor: AppTheme.primaryBlue,
              inactiveTrackColor: AppTheme.softBlue,
            ),
            child: Slider(
              value: weightVal,
              min: 30.0,
              max: 150.0,
              divisions: 120,
              onChanged: (val) {
                setState(() => weightVal = val);
                widget.onWeightChanged(val);
              },
            ),
          ),

          const SizedBox(height: 12),

          // Height Slider (100 - 220 cm)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Height',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                heightDisplay,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryPink,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primaryPink,
              thumbColor: AppTheme.primaryPink,
              inactiveTrackColor: AppTheme.softPink,
            ),
            child: Slider(
              value: heightVal,
              min: 100.0,
              max: 220.0,
              divisions: 120,
              onChanged: (val) {
                setState(() => heightVal = val);
                widget.onHeightChanged(val);
              },
            ),
          ),

          const SizedBox(height: 14),

          // Medical Disclaimer
          Text(
            BmiService.disclaimer,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              color: AppTheme.textMuted,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
