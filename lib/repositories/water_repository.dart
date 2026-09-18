import '../models/water_log.dart';

class WaterRepository {
  final Map<String, WaterLog> _waterLogs = {};

  String _dateKey(DateTime date) => date.toString().split(' ')[0];

  Future<WaterLog> getLogForDate(DateTime date, {int defaultGoal = 2500}) async {
    final key = _dateKey(date);
    if (_waterLogs.containsKey(key)) {
      return _waterLogs[key]!;
    }
    final newLog = WaterLog(
      id: 'wat_$key',
      date: DateTime(date.year, date.month, date.day),
      waterMl: 0,
      goalMl: defaultGoal,
    );
    _waterLogs[key] = newLog;
    return newLog;
  }

  Future<void> addWater(DateTime date, int deltaMl, {int defaultGoal = 2500}) async {
    final current = await getLogForDate(date, defaultGoal: defaultGoal);
    final updatedMl = (current.waterMl + deltaMl).clamp(0, 10000);
    _waterLogs[_dateKey(date)] = WaterLog(
      id: current.id,
      date: current.date,
      waterMl: updatedMl,
      goalMl: current.goalMl,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> resetLog(DateTime date) async {
    final current = await getLogForDate(date);
    _waterLogs[_dateKey(date)] = WaterLog(
      id: current.id,
      date: current.date,
      waterMl: 0,
      goalMl: current.goalMl,
    );
  }
}
