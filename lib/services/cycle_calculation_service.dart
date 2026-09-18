import '../models/cycle_record.dart';

class CycleCalculationService {
  /// Calculates the current period gap in days from the most recent cycle start date to today (or target date)
  static int calculateCurrentGap(List<CycleRecord> records, {DateTime? targetDate}) {
    final activeRecords = records.where((r) => !r.isDeleted).toList();
    if (activeRecords.isEmpty) return 0;

    activeRecords.sort((a, b) => b.startDate.compareTo(a.startDate));
    final latestStart = activeRecords.first.startDate;
    final now = targetDate ?? DateTime.now();

    final difference = now.difference(latestStart).inDays;
    return difference < 0 ? 0 : difference;
  }

  /// Calculates average cycle length in days across active records
  static int calculateAverageCycleLength(List<CycleRecord> records) {
    final activeRecords = records.where((r) => !r.isDeleted).toList();
    if (activeRecords.length < 2) return 28; // Default fallback

    activeRecords.sort((a, b) => a.startDate.compareTo(b.startDate));

    int totalGapDays = 0;
    int gapCount = 0;

    for (int i = 0; i < activeRecords.length - 1; i++) {
      final gap = activeRecords[i + 1].startDate.difference(activeRecords[i].startDate).inDays;
      if (gap > 10 && gap < 120) { // Reasonable cycle gap filter
        totalGapDays += gap;
        gapCount++;
      }
    }

    if (gapCount == 0) return 28;
    return (totalGapDays / gapCount).round();
  }

  /// Calculates the longest period gap in days
  static int calculateLongestGap(List<CycleRecord> records, {DateTime? targetDate}) {
    final activeRecords = records.where((r) => !r.isDeleted).toList();
    if (activeRecords.isEmpty) return 0;

    activeRecords.sort((a, b) => a.startDate.compareTo(b.startDate));

    int maxGap = calculateCurrentGap(activeRecords, targetDate: targetDate);

    for (int i = 0; i < activeRecords.length - 1; i++) {
      final gap = activeRecords[i + 1].startDate.difference(activeRecords[i].startDate).inDays;
      if (gap > maxGap) {
        maxGap = gap;
      }
    }

    return maxGap;
  }

  /// Calculates total number of periods in the last 12 months
  static int calculatePeriodsLast12Months(List<CycleRecord> records, {DateTime? targetDate}) {
    final now = targetDate ?? DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

    return records
        .where((r) => !r.isDeleted && r.startDate.isAfter(oneYearAgo) && !r.startDate.isAfter(now))
        .length;
  }

  /// Evaluates cycle variability (difference between longest and shortest cycle length)
  static int calculateCycleVariability(List<CycleRecord> records) {
    final activeRecords = records.where((r) => !r.isDeleted).toList();
    if (activeRecords.length < 3) return 0;

    activeRecords.sort((a, b) => a.startDate.compareTo(b.startDate));

    final gaps = <int>[];
    for (int i = 0; i < activeRecords.length - 1; i++) {
      final gap = activeRecords[i + 1].startDate.difference(activeRecords[i].startDate).inDays;
      if (gap >= 15 && gap <= 180) {
        gaps.add(gap);
      }
    }

    if (gaps.isEmpty) return 0;
    gaps.sort();
    return gaps.last - gaps.first;
  }
}
