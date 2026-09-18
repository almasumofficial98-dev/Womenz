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
        return 'Follicular Phase';
      case CyclePhase.ovulation:
        return 'Ovulation Phase';
      case CyclePhase.luteal:
        return 'Luteal Phase';
      case CyclePhase.unknown:
        return 'No Data Tracked';
    }
  }

  String get pregnancyChance {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Low';
      case CyclePhase.follicular:
        return 'Medium';
      case CyclePhase.ovulation:
        return 'High';
      case CyclePhase.luteal:
        return 'Low';
      case CyclePhase.unknown:
        return 'No Data';
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
        return 'Low energy expected. Hydrate and get plenty of rest.';
      case CyclePhase.follicular:
        return 'Estrogen is rising! Great energy for workouts and planning.';
      case CyclePhase.ovulation:
        return 'Peak fertility and high energy. You might feel more sociable.';
      case CyclePhase.luteal:
        return 'Progesterone rises. Focus on calming activities and self-care.';
      case CyclePhase.unknown:
        return 'No period history logged yet. Go to Calendar or tap + to log your period.';
    }
  }
}

class DailyLog {
  final DateTime date;
  String? flow; // 'Light', 'Medium', 'Heavy', 'Spotting'
  List<String> symptoms;
  String? mood;
  double? weight; // in kg
  bool tookSupplements;
  String? notes;

  DailyLog({
    required this.date,
    this.flow,
    List<String>? symptoms,
    this.mood,
    this.weight,
    this.tookSupplements = false,
    this.notes,
  }) : symptoms = symptoms ?? [];
}

class UserCycleData {
  String userName;
  int cycleLength; // default 28 days
  int periodDuration; // default 5 days
  DateTime? lastPeriodStartDate;
  int? currentDay;
  Map<String, DailyLog> logs;

  UserCycleData({
    this.userName = 'User',
    this.cycleLength = 28,
    this.periodDuration = 5,
    this.lastPeriodStartDate,
    this.currentDay,
    Map<String, DailyLog>? logs,
  }) : logs = logs ?? {};

  bool get hasLoggedData => lastPeriodStartDate != null || logs.isNotEmpty;

  CyclePhase get currentPhase {
    if (!hasLoggedData || currentDay == null) {
      return CyclePhase.unknown;
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
    if (!hasLoggedData || currentDay == null) return '--';
    final days = (cycleLength - currentDay! + 1).clamp(0, cycleLength);
    return '$days days';
  }

  String get daysUntilOvulationText {
    if (!hasLoggedData || currentDay == null) return '--';
    final day = currentDay!;
    int days = day <= 14 ? (14 - day) : ((cycleLength - day) + 14);
    return '$days days';
  }

  DateTime? get nextPeriodDate {
    if (lastPeriodStartDate == null) return null;
    return lastPeriodStartDate!.add(Duration(days: cycleLength));
  }
}
