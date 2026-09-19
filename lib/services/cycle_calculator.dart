import 'package:flutter/material.dart';
import '../models/cycle_models.dart';
import '../theme/app_theme.dart';

enum CyclePhase {
  menstrual,
  follicular,
  ovulation,
  luteal,
  unknown,
}

extension CyclePhaseExt on CyclePhase {
  String get nameTitle {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.ovulation:
        return 'Ovulation Phase';
      case CyclePhase.luteal:
        return 'Luteal Phase';
      case CyclePhase.unknown:
        return 'Not Started';
    }
  }

  Color get color {
    switch (this) {
      case CyclePhase.menstrual:
        return AppTheme.menstrualRed;
      case CyclePhase.follicular:
        return AppTheme.follicularGreen;
      case CyclePhase.ovulation:
        return AppTheme.ovulationTeal;
      case CyclePhase.luteal:
        return AppTheme.lutealAmber;
      case CyclePhase.unknown:
        return AppTheme.accentPurple;
    }
  }

  String get shortDesc {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Rest, hydrate, and nurture your body during menstruation.';
      case CyclePhase.follicular:
        return 'Energy rising! Ideal time for creativity and new projects.';
      case CyclePhase.ovulation:
        return 'Peak energy & fertility window. Feeling glowing & social.';
      case CyclePhase.luteal:
        return 'Winding down. Focus on grounding foods and self-care.';
      case CyclePhase.unknown:
        return 'Log your first period date to unlock personalized cycle predictions.';
    }
  }
}

class CycleCalculationResult {
  final int currentCycleDay;
  final CyclePhase phase;
  final DateTime? nextPeriodStartDate;
  final DateTime? nextPeriodEndDate; // range for irregular / PCOD
  final int daysUntilNextPeriod;
  final bool isFertile;
  final bool isOvulationDay;
  final double cycleProgressRatio; // 0.0 to 1.0 for ring indicator
  final String conditionBanner;

  CycleCalculationResult({
    required this.currentCycleDay,
    required this.phase,
    this.nextPeriodStartDate,
    this.nextPeriodEndDate,
    required this.daysUntilNextPeriod,
    required this.isFertile,
    required this.isOvulationDay,
    required this.cycleProgressRatio,
    required this.conditionBanner,
  });
}

class CycleCalculator {
  static CycleCalculationResult calculate({
    required UserProfile profile,
    required List<CycleLog> cycleLogs,
  }) {
    if (profile.lastPeriodStart == null || cycleLogs.isEmpty) {
      return CycleCalculationResult(
        currentCycleDay: 0,
        phase: CyclePhase.unknown,
        daysUntilNextPeriod: 0,
        isFertile: false,
        isOvulationDay: false,
        cycleProgressRatio: 0.0,
        conditionBanner: _getConditionBanner(profile.healthCondition),
      );
    }

    final today = DateTime.now();
    final lastStart = profile.lastPeriodStart!;
    final differenceDays = today.difference(lastStart).inDays;

    final cycleLength = profile.avgCycleLength > 0 ? profile.avgCycleLength : 28;
    final periodLength = profile.avgPeriodLength > 0 ? profile.avgPeriodLength : 5;
    final variance = profile.cycleVariance > 0 ? profile.cycleVariance : 3;

    // Current day in the active cycle (1-indexed)
    final currentCycleDay = (differenceDays % cycleLength) + 1;
    final cycleProgressRatio = (currentCycleDay / cycleLength).clamp(0.0, 1.0);

    // Estimate Ovulation Day (typically 14 days before end of cycle)
    final ovulationDay = (cycleLength - 14).clamp(periodLength + 2, cycleLength - 2);

    // Determine Phase
    CyclePhase phase;
    if (currentCycleDay <= periodLength) {
      phase = CyclePhase.menstrual;
    } else if (currentCycleDay < ovulationDay - 1) {
      phase = CyclePhase.follicular;
    } else if (currentCycleDay >= ovulationDay - 1 && currentCycleDay <= ovulationDay + 1) {
      phase = CyclePhase.ovulation;
    } else {
      phase = CyclePhase.luteal;
    }

    final isFertile = currentCycleDay >= (ovulationDay - 4) && currentCycleDay <= (ovulationDay + 2);
    final isOvulationDay = currentCycleDay == ovulationDay;

    // Expected next period calculations
    final expectedStart = lastStart.add(Duration(days: cycleLength));
    final daysUntil = expectedStart.difference(today).inDays;

    DateTime? expectedEnd;
    if (profile.healthCondition == HealthCondition.pcodPcos ||
        profile.healthCondition == HealthCondition.irregular) {
      // For PCOD or Irregular, provide a range window
      expectedEnd = expectedStart.add(Duration(days: variance * 2));
    }

    return CycleCalculationResult(
      currentCycleDay: currentCycleDay,
      phase: phase,
      nextPeriodStartDate: expectedStart,
      nextPeriodEndDate: expectedEnd,
      daysUntilNextPeriod: daysUntil > 0 ? daysUntil : 0,
      isFertile: isFertile,
      isOvulationDay: isOvulationDay,
      cycleProgressRatio: cycleProgressRatio,
      conditionBanner: _getConditionBanner(profile.healthCondition),
    );
  }

  static String _getConditionBanner(HealthCondition condition) {
    switch (condition) {
      case HealthCondition.pcodPcos:
        return 'PCOD / PCOS Adaptive Tracking Mode Active';
      case HealthCondition.irregular:
        return 'Irregular Cycle Window Mode Active';
      case HealthCondition.endometriosis:
        return 'Endometriosis Gentle Care Mode Active';
      case HealthCondition.perimenopause:
        return 'Perimenopause Hormone Support Active';
      case HealthCondition.regular:
        return 'Standard Cycle Tracking Active';
    }
  }

  static List<String> getTipsForConditionAndPhase({
    required HealthCondition condition,
    required CyclePhase phase,
  }) {
    // Condition-specific tailored wellness guidance
    if (condition == HealthCondition.pcodPcos) {
      switch (phase) {
        case CyclePhase.menstrual:
          return [
            'PCOD Care: Sip anti-inflammatory spearmint or chamomile tea to soothe cramps.',
            'Maintain steady blood sugar with complex carbs (oats, quinoa) and healthy fats.',
            'Light stretching or restorative yoga helps pelvic blood circulation.',
          ];
        case CyclePhase.follicular:
          return [
            'PCOD Care: Focus on high-protein breakfasts to balance insulin sensitivity.',
            'Incorporate light strength training or brisk walking.',
            'Inositol and leafy greens support healthy follicle development.',
          ];
        case CyclePhase.ovulation:
          return [
            'PCOD Care: Ovulation may vary in PCOD. Track cervical mucus & energy peaks.',
            'Stay hydrated and consume antioxidant-rich berries and zinc-rich seeds.',
            'Moderate cardio supports cardiovascular health and mood elevation.',
          ];
        case CyclePhase.luteal:
          return [
            'PCOD Care: Reduce refined sugars to curb PCOS luteal sugar cravings.',
            'Magnesium and B-complex vitamins help manage pre-period mood swings.',
            'Prioritize 8 hours of restful sleep to lower cortisol stress levels.',
          ];
        case CyclePhase.unknown:
          return [
            'PCOD / PCOS Mode: Track symptoms regularly to understand your unique cycle rhythm.',
          ];
      }
    } else if (condition == HealthCondition.irregular) {
      return [
        'Irregular Cycle Tip: Log symptoms daily to spot patterns even when dates vary.',
        'Prioritize circadian rhythm: consistent sleep schedules help regulate hormones.',
        'Track stress levels and hydration for optimal body harmony.',
      ];
    } else if (condition == HealthCondition.endometriosis) {
      return [
        'Endo Care: Apply gentle heat compress for pelvic comfort.',
        'Incorporate omega-3 fatty acids (flaxseeds, walnuts) for anti-inflammatory support.',
        'Rest when needed and practice gentle belly breathing exercises.',
      ];
    } else {
      switch (phase) {
        case CyclePhase.menstrual:
          return [
            'Rest & Restore: Hydrate with warm herbal teas and iron-rich foods.',
            'Focus on gentle movement and plenty of warm sleep.',
          ];
        case CyclePhase.follicular:
          return [
            'Rising Energy: Try new exercises and nutrient-dense fresh foods.',
            'Great phase for strategic planning and upbeat social activities.',
          ];
        case CyclePhase.ovulation:
          return [
            'Peak Vitality: Your energy and confidence are at their monthly high!',
            'Stay active and enjoy vibrant meals with fiber and protein.',
          ];
        case CyclePhase.luteal:
          return [
            'Nurture & Slow Down: Focus on complex carbohydrates and grounding meals.',
            'Self-care, warm baths, and calming bedtime routines work wonders.',
          ];
        case CyclePhase.unknown:
          return [
            'Welcome! Tap the button below to log your first cycle date.',
          ];
      }
    }
  }
}
