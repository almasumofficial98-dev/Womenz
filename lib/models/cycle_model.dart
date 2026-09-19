import 'package:flutter/material.dart';

enum CyclePhase {
  menstrual,
  follicular,
  ovulation,
  luteal,
  unknown,
}

extension CyclePhaseExtension on CyclePhase {
  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase';
      case CyclePhase.follicular:
        return 'Estimated Follicular Phase';
      case CyclePhase.ovulation:
        return 'Estimated Ovulation Phase';
      case CyclePhase.luteal:
        return 'Estimated Luteal Phase';
      case CyclePhase.unknown:
        return 'No Data Tracked';
    }
  }

  Color get primaryColor {
    switch (this) {
      case CyclePhase.menstrual:
        return const Color(0xFFFF8BA5);
      case CyclePhase.follicular:
        return const Color(0xFF7C8FFD);
      case CyclePhase.ovulation:
        return const Color(0xFFFF9E6D);
      case CyclePhase.luteal:
        return const Color(0xFF5EA8FE);
      case CyclePhase.unknown:
        return const Color(0xFFB0BEC5);
    }
  }

  Color get accentGradientStart {
    switch (this) {
      case CyclePhase.menstrual:
        return const Color(0xFFFF7597);
      case CyclePhase.follicular:
        return const Color(0xFF6C92F8);
      case CyclePhase.ovulation:
        return const Color(0xFFFFA36C);
      case CyclePhase.luteal:
        return const Color(0xFF51A0FF);
      case CyclePhase.unknown:
        return const Color(0xFFB0BEC5);
    }
  }

  Color get accentGradientEnd {
    switch (this) {
      case CyclePhase.menstrual:
        return const Color(0xFFFFA5B8);
      case CyclePhase.follicular:
        return const Color(0xFFA3B4FF);
      case CyclePhase.ovulation:
        return const Color(0xFFFFD1A6);
      case CyclePhase.luteal:
        return const Color(0xFF8AC0FF);
      case CyclePhase.unknown:
        return const Color(0xFFCFD8DC);
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Rest and stay hydrated. Warmth or gentle movement may help cramps.';
      case CyclePhase.follicular:
        return 'Energy levels often rise during this phase. Nourish your body well.';
      case CyclePhase.ovulation:
        return 'Mid-cycle phase. Energy and libido may peak around this window.';
      case CyclePhase.luteal:
        return 'Focus on restful routines and steady nutrition before your next cycle.';
      case CyclePhase.unknown:
        return 'No period history logged yet. Set your first day of period to begin.';
    }
  }
}

enum ContraceptionType {
  none,
  combinedPill,
  progestinOnlyPill,
  hormonalIud,
  copperIud,
  implant,
  patchRing;

  String get displayName {
    switch (this) {
      case ContraceptionType.none:
        return 'None (Natural Cycle)';
      case ContraceptionType.combinedPill:
        return 'Combined Oral Pill (COC)';
      case ContraceptionType.progestinOnlyPill:
        return 'Progestin-Only Pill (Mini Pill)';
      case ContraceptionType.hormonalIud:
        return 'Hormonal IUD';
      case ContraceptionType.copperIud:
        return 'Copper IUD';
      case ContraceptionType.implant:
        return 'Contraceptive Implant';
      case ContraceptionType.patchRing:
        return 'Contraceptive Patch / Ring';
    }
  }

  bool get isHormonalSuppression =>
      this == ContraceptionType.combinedPill ||
      this == ContraceptionType.progestinOnlyPill ||
      this == ContraceptionType.patchRing;
}

class DailyLog {
  final DateTime date;
  String? flow; // 'None', 'Spotting', 'Light', 'Medium', 'Heavy'
  List<String> symptoms;
  List<String> medications; // Separated from self-care
  List<String> selfCare; // Heat pad, rest, tea, etc.
  String? mood;
  double? weight; // in kg
  bool tookSupplements;
  int painScale; // 0-10 pain scale (0: None, 1-3: Mild, 4-7: Moderate, 8-10: Severe)
  String? clotSize; // 'None', 'Small', 'Large (> quarter)'
  String? cervicalMucus; // 'Dry', 'Sticky', 'Creamy', 'Egg-White'
  bool isRedFlagLogged;
  String? notes;
  double? bbt; // Basal Body Temperature (°C)
  int hotFlashesCount; // Perimenopause vasomotor symptom count
  bool nightSweats; // Perimenopause night sweats marker
  int? sleepRating; // 1-5 scale
  bool tookInositol; // PCOS metabolic support marker

  DailyLog({
    required this.date,
    this.flow,
    List<String>? symptoms,
    List<String>? medications,
    List<String>? selfCare,
    this.mood,
    this.weight,
    this.tookSupplements = false,
    this.painScale = 0,
    this.clotSize,
    this.cervicalMucus,
    this.isRedFlagLogged = false,
    this.notes,
    this.bbt,
    this.hotFlashesCount = 0,
    this.nightSweats = false,
    this.sleepRating,
    this.tookInositol = false,
  })  : symptoms = symptoms ?? [],
        medications = medications ?? [],
        selfCare = selfCare ?? [];

  String get painLabel {
    if (painScale <= 0) return 'No pain (0/10)';
    if (painScale <= 3) return 'Mild discomfort (1–3/10)';
    if (painScale <= 7) return 'Moderate pain (4–7/10)';
    return 'Severe pain (8–10/10)';
  }
}

class UserCycleData {
  String userName;
  int cycleLength; // default 28 days
  int periodDuration; // default 5 days
  DateTime? lastPeriodStartDate;
  int? currentDay;
  String userIntent; // 'track', 'ttc', 'prevent', 'pcos'
  String healthCondition; // 'regular', 'irregular', 'pcod', 'endometriosis', 'perimenopause'
  bool isDiscreetMode; // Hides explicit terms on home screen
  bool? isPeriodOngoing; // explicit on/off period state
  Map<String, DailyLog> logs;

  ContraceptionType contraceptionType;
  String? pillReminderTime;
  bool isPillTakenToday;
  bool isPregnancyPaused;
  DateTime? pregnancyStartDate;
  String healthStage; // 'reproductive', 'pcos', 'perimenopause', 'postpartum'

  UserCycleData({
    this.userName = 'User',
    this.cycleLength = 28,
    this.periodDuration = 5,
    this.lastPeriodStartDate,
    this.currentDay,
    this.userIntent = 'track',
    this.healthCondition = 'regular',
    this.isDiscreetMode = false,
    this.isPeriodOngoing,
    Map<String, DailyLog>? logs,
    this.contraceptionType = ContraceptionType.none,
    this.pillReminderTime,
    this.isPillTakenToday = false,
    this.isPregnancyPaused = false,
    this.pregnancyStartDate,
    this.healthStage = 'reproductive',
  }) : logs = logs ?? {};

  bool get hasLoggedData => lastPeriodStartDate != null || logs.isNotEmpty;

  int? get pregnancyWeeks {
    if (!isPregnancyPaused || pregnancyStartDate == null) return null;
    final diffDays = DateTime.now().difference(pregnancyStartDate!).inDays;
    return (diffDays / 7).floor() + 2; // Clinical LMP convention (+2 weeks)
  }

  bool get isWithdrawalBleeding =>
      contraceptionType.isHormonalSuppression && isPeriodActive;

  bool get isPeriodActive {
    if (isPregnancyPaused) return false;
    if (lastPeriodStartDate == null) return false;
    if (isPeriodOngoing != null) return isPeriodOngoing!;
    final diff = DateTime.now().difference(lastPeriodStartDate!).inDays;
    return diff >= 0 && diff < periodDuration;
  }

  int get activePeriodDay {
    if (lastPeriodStartDate == null) return 1;
    final d = DateTime.now().difference(lastPeriodStartDate!).inDays + 1;
    return d < 1 ? 1 : d;
  }

  // ACOG threshold: Bleeding exceeding 7 days
  bool get hasExtendedBleeding => isPeriodActive && activePeriodDay > 7;

  CyclePhase get currentPhase {
    if (isPregnancyPaused) return CyclePhase.unknown;
    if (!hasLoggedData || currentDay == null) {
      return CyclePhase.unknown;
    }
    if (isPeriodActive) {
      return CyclePhase.menstrual;
    }
    final day = currentDay!;
    if (day <= periodDuration) {
      return CyclePhase.menstrual;
    } else if (day <= 13) {
      return CyclePhase.follicular;
    } else if (day <= 16) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  String get daysUntilNextCycleText {
    if (isPregnancyPaused) return 'Paused';
    if (!hasLoggedData || currentDay == null) return '--';
    final days = (cycleLength - currentDay! + 1).clamp(0, cycleLength);
    return '$days days';
  }

  String get estimatedNextPeriodText {
    if (isPregnancyPaused) return 'Pregnancy Mode';
    if (!hasLoggedData || lastPeriodStartDate == null) return '--';
    final next = nextPeriodDate;
    if (next == null) return '--';
    final days = next.difference(DateTime.now()).inDays + 1;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final formatted = '${months[next.month - 1]} ${next.day}';
    if (days < 0) {
      return '~$formatted (${days.abs()}d past)';
    } else if (days == 0) {
      return 'Around Today';
    } else {
      return '~$formatted (~$days d)';
    }
  }

  String get daysUntilOvulationText {
    if (isPregnancyPaused || contraceptionType.isHormonalSuppression) return '--';
    if (!hasLoggedData || currentDay == null) return '--';
    final day = currentDay!;
    int days = day <= 14 ? (14 - day) : ((cycleLength - day) + 14);
    return '$days days';
  }

  DateTime? get nextPeriodDate {
    if (lastPeriodStartDate == null) return null;
    return lastPeriodStartDate!.add(Duration(days: cycleLength));
  }

  bool get isPcosOrIrregular =>
      healthCondition == 'pcod' || healthCondition == 'irregular' || userIntent == 'pcos' || healthStage == 'pcos';

  bool get hasRecentRedFlags {
    if (hasExtendedBleeding) return true;
    final now = DateTime.now();
    for (final log in logs.values) {
      if (now.difference(log.date).inDays.abs() <= 7) {
        if (log.isRedFlagLogged || log.painScale >= 8 || log.clotSize == 'Large (> Quarter)') {
          return true;
        }
      }
    }
    return false;
  }

  String get redFlagReason {
    if (hasExtendedBleeding) {
      return 'Bleeding active for $activePeriodDay days (> 7 days ACOG alert threshold)';
    }
    for (final log in logs.values) {
      if (DateTime.now().difference(log.date).inDays.abs() <= 7) {
        if (log.painScale >= 8) {
          return 'Severe pain (${log.painScale}/10) logged';
        }
        if (log.clotSize == 'Large (> Quarter)') {
          return 'Heavy bleeding with large clots (> quarter-sized) logged';
        }
        if (log.isRedFlagLogged) {
          return 'Acute pelvic symptoms or bleeding irregularity logged';
        }
      }
    }
    return 'Clinical precaution advised';
  }

  String get centerRingSubtitle {
    if (isPregnancyPaused) {
      final weeks = pregnancyWeeks ?? 4;
      return 'Gestation: ~$weeks Weeks';
    }
    if (!hasLoggedData) return 'Tap + to log period';
    if (isDiscreetMode) return 'Cycle Day ${currentDay ?? 1} • Wellness';
    if (isPeriodActive) {
      return isWithdrawalBleeding
          ? 'Withdrawal Bleed • Day $activePeriodDay'
          : 'Period Active • Day $activePeriodDay';
    }
    if (isPcosOrIrregular) {
      return 'PCOS Care • Day ${currentDay ?? 1}';
    }
    return currentPhase.displayName;
  }

  String get currentPhasePillText {
    if (isPregnancyPaused) return 'Pregnancy';
    if (!hasLoggedData) return 'No Data';
    if (isDiscreetMode) return 'Phase ${currentPhase.index + 1}';
    return currentPhase.displayName.replaceAll(' Phase', '').replaceAll('Estimated ', '');
  }
}

/// FIGO (International Federation of Gynecology & Obstetrics) AUB Pattern Evaluator
class FigoReport {
  final bool hasFindings;
  final String frequencyStatus;
  final String regularityStatus;
  final String durationStatus;
  final String volumeStatus;
  final List<String> clinicalObservations;
  final List<String> discussionPrompts;

  const FigoReport({
    required this.hasFindings,
    required this.frequencyStatus,
    required this.regularityStatus,
    required this.durationStatus,
    required this.volumeStatus,
    required this.clinicalObservations,
    required this.discussionPrompts,
  });

  static FigoReport evaluate({
    required List<int> cycleLengths,
    required List<int> periodDurations,
    required List<DailyLog> recentLogs,
  }) {
    final observations = <String>[];
    final prompts = <String>[];
    bool findings = false;

    // 1. Frequency (FIGO normal: 24 to 38 days)
    String freq = 'Normal (24–38 days)';
    if (cycleLengths.isNotEmpty) {
      final avgLength = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
      if (avgLength < 24) {
        freq = 'Frequent (<24 days)';
        observations.add('Average cycle length is under 24 days (FIGO Frequent Cycle interval).');
        prompts.add('Ask your doctor about short follicular phases or luteal phase length.');
        findings = true;
      } else if (avgLength > 38) {
        freq = 'Infrequent (>38 days)';
        observations.add('Average cycle length exceeds 38 days (FIGO Infrequent Cycle interval / Oligomenorrhea).');
        prompts.add('Discuss ovulatory regularity, thyroid function, or PCOS evaluation.');
        findings = true;
      }
    } else {
      freq = 'More data needed (≥2 cycles)';
    }

    // 2. Regularity (FIGO normal variance: ≤7–9 days)
    String reg = 'Regular (≤9 days variation)';
    if (cycleLengths.length >= 2) {
      final minLen = cycleLengths.reduce((a, b) => a < b ? a : b);
      final maxLen = cycleLengths.reduce((a, b) => a > b ? a : b);
      final variance = maxLen - minLen;
      if (variance > 9) {
        reg = 'Irregular (>9 days variation)';
        observations.add('Cycle lengths varied by $variance days across recent cycles (FIGO Irregular threshold >9d).');
        prompts.add('Review lifestyle stressors, hormonal lab panels, and cycle consistency with your provider.');
        findings = true;
      }
    } else {
      reg = 'Baseline building';
    }

    // 3. Duration (FIGO normal: ≤8 days)
    String dur = 'Normal (≤8 days)';
    if (periodDurations.isNotEmpty) {
      final maxDuration = periodDurations.reduce((a, b) => a > b ? a : b);
      if (maxDuration > 8) {
        dur = 'Prolonged (>8 days)';
        observations.add('Menses bleeding lasted up to $maxDuration days (exceeds FIGO normal duration threshold of 8 days).');
        prompts.add('Ask about structural causes (polyp, fibroid, adenomyosis) or coagulation checks.');
        findings = true;
      }
    }

    // 4. Volume / Heavy Menstrual Bleeding (HMB)
    String vol = 'Normal / Moderate';
    final heavyDays = recentLogs.where((l) => l.flow == 'Heavy').length;
    final largeClots = recentLogs.where((l) => l.clotSize == 'Large (> quarter)').length;
    if (heavyDays >= 3 || largeClots >= 1) {
      vol = 'Heavy Bleeding Indicators Present';
      observations.add('Multiple heavy flow days ($heavyDays) or large clots ($largeClots) recorded.');
      prompts.add('Ask your clinician if a ferritin/iron panel or pelvic ultrasound is recommended.');
      findings = true;
    }

    if (prompts.isEmpty) {
      prompts.add('Bring this timeline log to your routine annual gynecological checkup.');
      prompts.add('Share your average cycle length and flow patterns with your physician.');
    }

    return FigoReport(
      hasFindings: findings,
      frequencyStatus: freq,
      regularityStatus: reg,
      durationStatus: dur,
      volumeStatus: vol,
      clinicalObservations: observations,
      discussionPrompts: prompts,
    );
  }
}

/// Curated Evidence-Based Phase Lifestyle, Nutrition & Workout Guidance
class PhaseLifestyleGuide {
  final String phaseName;
  final List<String> nutritionFocus;
  final List<String> movementAdvice;
  final String energyInsight;
  final String selfCareTip;

  const PhaseLifestyleGuide({
    required this.phaseName,
    required this.nutritionFocus,
    required this.movementAdvice,
    required this.energyInsight,
    required this.selfCareTip,
  });

  static PhaseLifestyleGuide getForPhase(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return const PhaseLifestyleGuide(
          phaseName: 'Menstrual Phase',
          nutritionFocus: [
            'Iron-rich foods (spinach, lentils, sesame) to replenish blood loss',
            'Warm broths, ginger, and turmeric to ease pelvic congestion',
            'Magnesium-dense dark chocolate and pumpkin seeds for muscle relaxation'
          ],
          movementAdvice: [
            'Gentle pelvic-opening stretches and restorative yoga',
            'Light casual walking rather than high-strain workouts',
            'Prioritize restorative sleep over early alarms'
          ],
          energyInsight: 'Rest & Introspection: Endogenous hormone levels are low; ideal for reflection, gentle pacing, and low-stress routines.',
          selfCareTip: 'Use a soothing heat pack across the lower abdomen or sacrum for 15–20 minutes to improve microcirculation.',
        );
      case CyclePhase.follicular:
        return const PhaseLifestyleGuide(
          phaseName: 'Estimated Follicular Phase',
          nutritionFocus: [
            'Lean proteins, sprouted grains, and fermented foods (kimchi, kefir)',
            'Healthy fats (avocado, extra-virgin olive oil) supporting follicular maturation',
            'Cruciferous vegetables (broccoli, arugula) aiding natural estrogen metabolism'
          ],
          movementAdvice: [
            'Progressive strength training and heavier lifting sets',
            'Higher intensity cardio intervals (cycling, running, dance)',
            'Exploring new athletic skills or routines'
          ],
          energyInsight: 'Initiation & Focus: Rising estradiol boosts neural plasticity, stamina, and mental clarity; ideal for planning and launching projects.',
          selfCareTip: 'Schedule mentally demanding tasks, brainstorming sessions, and strategic meetings during this high-energy window.',
        );
      case CyclePhase.ovulation:
        return const PhaseLifestyleGuide(
          phaseName: 'Estimated Ovulatory Phase',
          nutritionFocus: [
            'High-fiber plant foods to support hepatic estrogen clearance',
            'Antioxidant-dense berries, bell peppers, and citrus',
            'Adequate hydration with electrolytes'
          ],
          movementAdvice: [
            'Peak endurance workouts and personal-record strength challenges',
            'Dynamic group fitness or vigorous sports',
            'Gentle post-workout mobility to support ligamentous laxity'
          ],
          energyInsight: 'Peak Vitality & Connection: Estrogen and testosterone crest; verbal fluency, confidence, and social stamina are naturally elevated.',
          selfCareTip: 'An optimal time for public speaking, meaningful discussions, and demanding interpersonal events.',
        );
      case CyclePhase.luteal:
        return const PhaseLifestyleGuide(
          phaseName: 'Estimated Luteal Phase',
          nutritionFocus: [
            'Complex carbohydrates (sweet potatoes, oats, quinoa) to support serotonin synthesis',
            'Vitamin B6 and zinc (chickpeas, salmon, bananas) modulating PMS symptoms',
            'Reduce excess caffeine and sodium to prevent fluid retention'
          ],
          movementAdvice: [
            'Moderate resistance training transitioning to pilates or steady swimming',
            'Dial back high-heat workouts if resting core temperature rises',
            'Incorporate nervous system down-regulation (box breathing, yin yoga)'
          ],
          energyInsight: 'Detail Focus & Organization: Progesterone rises; excellent for focused editing, organizing, and completing ongoing work.',
          selfCareTip: 'Support sleep with a consistent winding-down routine and magnesium glycinate or chamomile tea.',
        );
      case CyclePhase.unknown:
        return const PhaseLifestyleGuide(
          phaseName: 'Cycle Wellness',
          nutritionFocus: ['Balanced whole foods, regular hydration, and nutrient-dense produce.'],
          movementAdvice: ['Consistent daily movement that leaves you feeling energized.'],
          energyInsight: 'Listen to your body rhythm and rest whenever fatigue arises.',
          selfCareTip: 'Log your period start date to unlock personalized daily phase insights.',
        );
    }
  }
}

